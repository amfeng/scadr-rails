class UserSession < AvroRecord
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

  def valid?
    not user.nil?
  end

  def save
    valid?
  end

  def user
    User.find_user(username)
  end

  def destroy
    true
  end

end