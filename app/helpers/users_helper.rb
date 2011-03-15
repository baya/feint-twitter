module UsersHelper

  module Ravatar

    def self.included(actor)
      actor.class_eval{ after_save :write_images }
      actor.extend(Conf)
    end

    module Conf
      def avatar_config options={ }
        options[:min_size]         ||= 1
        options[:max_size]         ||= 200.kilobytes
        options[:size]             ||= (options[:min_size]..options[:max_size])
        options[:storage_path]     ||= File.join(*[Rails.root.to_s, "public", "avatars"])
        options[:avatar_api]       ||= "http://www.gravatar.com/avatar"
        options[:styles]           ||= { :thumb => "58x58", :medium => "168x168"}
        @avatar_options = options
        include ValidateMethods unless included_modules.include?(ValidateMethods)
      end

      def options
        @avatar_options
      end

    end

    module ValidateMethods

      def self.included(actor)
        actor.class_eval{ validate :size_valid, :format_valid}
      end

      def size_valid
        if @image_file.respond_to?(:size)
          errors.add("avatar_size", "too large") if @image_file.size > self.avatar_options[:max_size]
        end
      end

      def format_valid
        if @image_file.respond_to?(:content_type)
          errors.add("avatar_format", "invalid avatar format ") unless @image_file.content_type.strip =~ /^image/
        end
      end

    end

    def image; nil; end

    def image= image_file
      @image_file = image_file
    end

    def diskfile_path(style=:origin)
      @diskfile_path = File.join(self.avatar_options[:storage_path],self.id_to_namepath + "_#{style}")
    end

    def avatar_url(options = { })
      if File.exist?(self.diskfile_path)
        options[:style] ||= "thumb"
        save_dir = self.avatar_options[:storage_path].sub(File.join(Rails.root.to_s, "public"), '')
        @avatar_url =  File.join(save_dir, self.id_to_namepath + "_#{options[:style]}")
      else
        options.delete(:style)
        options[:size] ||= 58
        options[:default] ||= "wavatar"
        mail_hash = Digest::MD5.hexdigest(self.email.strip.downcase)
        @avatar_url = self.avatar_options[:avatar_api] + "/" + mail_hash + "?" + options.to_param
      end
    end

    def avatar_url_thumb
      self.avatar_url(:style => :thumb, :size => 58)
    end

    def avatar_url_medium
      self.avatar_url(:style => :medium, :size => 168)
    end

    def write_images
      return if @image_file.blank?
      begin
        raw_name = File.join(*[self.avatar_options[:storage_path], self.id_to_namepath])
        save_dir = File.dirname(raw_name)
        unless File.directory?(save_dir)
          FileUtils.mkdir_p(save_dir)
        end
        image_to_disk(raw_name + "_origin")
        self.avatar_options[:styles].each{ |k, v|
          path = image_to_disk(raw_name + "_#{k}")
          `convert #{path} -resize #{v} #{path}`
        }
      rescue => e
        Rails.logger.info("#{Time.now}:#{e.inspect}:#{e.backtrace.join("\n")}")
      end
    end

    def image_to_disk(name)
      FileUtils.touch(name) unless File.exist?(name)
      File.open(name, "w"){ |f| f.write @image_file.read }
      @image_file.rewind if @image_file.respond_to?(:rewind)
      name
    end

    def id_to_namepath
      if @namepath.blank?
        num_str = self.id.to_s.size % 2 == 0 ? self.id.to_s : "0" + self.id.to_s
        @namepath = "/" + num_str.scan(/\d{2}/).join("/")
      end
      @namepath
    end

    def avatar_options
      self.class.options
    end


  end

end
