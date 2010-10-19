class HashTag < ActiveRecord::Base
  set_primary_keys :owner, :timestamp, :tag

  # The specific thought associated with this HashTag
  def get_thought
  	Thought.find :first, :conditions => { :owner => owner, :timestamp => timestamp }
  end

  # All thoughts associated with a tag of this name
  def get_tagged
  	HashTag.find(:all, :conditions => { :tag => tag }).collect { |ht| ht.get_thought }
  end

end
