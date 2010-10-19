class Thought < ActiveRecord::Base
  set_primary_keys :owner, :timestamp

  # Screw this; see user.rb
  #
  # belongs_to :user, :foreign_key => :owner

  def get_owner
  	User.find :first, :conditions => { :username => owner }
  end

  def get_tags
  	HashTag.find :all, :conditions => { :owner => owner, :timestamp => timestamp }
  end
end
