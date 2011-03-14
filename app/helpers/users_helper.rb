module UsersHelper

  module Ravatar

    def self.included(actor)
      actor.class_eval{ after_save :write_images }
      actor.extend(Conf)
    end

    module Conf
      def avatar_config options={ }
        options[:min_size]         ||= 1
        options[:max_size]         ||= 1.megabyte
        options[:size]             ||= (options[:min_size]..options[:max_size])
        options[:storage_path]     ||= File.join(*[Rails.root.to_s, "public", "avatars"])
        @avatar_options = options
      end

      def options
        @avatar_options
      end

    end

    def image; nil; end

    def image= image_file
      @image_file = image_file
    end

    def avatar_url
      @avatar_url ||= self.avatar_options[:storage_path].sub(File.join(Rails.root.to_s, "public"), '') + self.id_to_namepath
    end

    def write_images
      return if @image_file.blank?
      name = File.join(*[self.avatar_options[:storage_path], self.id_to_namepath])
      save_dir = File.dirname(name)
      unless File.directory?(save_dir)
        FileUtils.mkdir_p(save_dir)
      end
      FileUtils.touch(name) unless File.exist?(name)
      File.open(name, "w"){ |f| f.write @image_file.read }
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
