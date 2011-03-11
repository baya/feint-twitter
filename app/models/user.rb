class User < ActiveRecord::Base
  has_many :messages

  validates_uniqueness_of :username, :email
  validates_presence_of :password
  validates_confirmation_of :password

  before_save :encrypt_password

  def stars
    @stars = User.find(:all, :joins => "INNER JOIN follows ON follows.star_id = users.id AND follows.fans_id = #{self.id}")
  end

  def fans
    @fans = User.find(:all, :joins => "INNER JOIN follows ON follows.fans_id = users.id AND follows.star_id = #{self.id}")
  end

  def is_a_fans?(star)
    Follow.find(:first, :conditions => { :star_id => star.id, :fans_id => self.id}) ? true : false
  end

  def stream_msgs
    Message.find(:all, :joins => "INNER JOIN streams ON streams.message_id = messages.id AND streams.user_id = #{self.id}")
  end

  def say(msg_text)
    msg = self.messages.create(:body => msg_text)
    return msg if msg.new_record?
    Stream.create(:message_id => msg.id, :user_id => self.id)
    self.fans.each { |f| Stream.create(:message_id => msg.id, :user_id => f.id) }
    if msg_text =~ /@(\S+)\s{1,}/
      user = User.find_by_username($1)
      Stream.create(:message_id => msg.id, :user_id => user.id) if user
    end
    msg
  end

  private

  def encrypt_password
    self.password = Digest::MD5.hexdigest(password)
  end

end
