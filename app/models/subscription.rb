class Subscription < AvroRecord
  set_primary_keys :owner, :target

  def to_param
    target
  end
  
end