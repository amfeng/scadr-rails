class HashTag < ActiveRecord::Base
  extend DataMethods
  set_primary_keys :owner, :timestamp, :tag
end
