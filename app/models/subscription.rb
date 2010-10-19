class Subscription < ActiveRecord::Base
  set_primary_keys :owner, :target

  def get_owner
  	User.find :first, :conditions => { :username => owner }
  end

  def get_target
  	User.find :first, :conditions => { :username => target }
  end
end
