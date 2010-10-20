class UserSession
  attr_accessor :username

  def initialize(params={})
    @username = params[:username]
  end

  def new_record?
    true
  end

  def self.find(username)
    session = UserSession.new :username => username
    return nil if session.user.nil?
    session
  end

  def save
    true
  end

  def user
    User.find :first, :conditions => { :username => username }
  end

  def destroy
    true
  end

end