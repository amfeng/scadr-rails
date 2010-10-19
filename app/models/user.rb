class User < ActiveRecord::Base
  set_primary_key :username

  # Okay, fuck this.
  # This is way too complicated, and I'd have to reimplement it in AvroRecord...
  #
  # has_many :thoughts, :foreign_key => :owner
  # has_many :subscriptions, :foreign_key => :owner
  # has_many :subscribees, :through => :subscriptions
  # has_many :incoming_subscriptions, :class_name => "Subscription", :foreign_key => :target
  # has_many :subscribers, :through => :incoming_subscriptions

  def get_thoughts
  	Thought.find :all, :conditions => { :owner => username }
  end

  # Subscriptions targeted at this user
  def get_subscriptions
  	Subscription.find :all, :conditions => { :target => username }
  end

  # Subscriptions owned by this user
  def get_owned_subscriptions
  	Subscription.find :all, :conditions => { :owner => username }
  end
end
