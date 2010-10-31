class User < ActiveRecord::Base
  extend DataMethods
  set_primary_key :username
  # acts_as_authentic do |c|
  #   c.login_field = :username
  # end
 
  # Okay, fuck this.
  # This is way too complicated, and I'd have to reimplement it in AvroRecord...
  #
  # has_many :thoughts, :foreign_key => :owner
  # has_many :subscriptions, :foreign_key => :owner
  # has_many :subscribees, :through => :subscriptions
  # has_many :incoming_subscriptions, :class_name => "Subscription", :foreign_key => :target
  # has_many :subscribers, :through => :incoming_subscriptions

  def to_param
    username
  end

  def thoughtstream(count)
    User.thoughtstream(username, count)
  end
  
  def following
    User.users_followed_by(username)
  end

  def followers
    User.users_following(username)
  end

  def my_thoughts(count)
    Thought.my_thoughts(username, count)
  end

  def thoughtstream(count)
    Thought.thoughtstream(username, count)
  end
end
