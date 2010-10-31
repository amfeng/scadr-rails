class Thought < ActiveRecord::Base
  extend DataMethods
  set_primary_keys :owner, :timestamp

  # Screw this; see user.rb
  #
  # belongs_to :user, :foreign_key => :owner

  def to_param
    timestamp.to_s
  end
end
