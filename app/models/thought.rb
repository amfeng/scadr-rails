class Thought < AvroRecord
  set_primary_keys :owner, :timestamp

  # Screw this; see user.rb
  #
  # belongs_to :user, :foreign_key => :owner

  # Because of the unexpected return tuple of thoughtstream, this will be hardcoded for now:
  # [SubscriptionKey, SubscriptionValue, ThoughtKey, ThoughtValue]
  # This method basically ignores the existence of the Subscription part and returns an array of Thoughts
  def self.thoughtstream(username, count)
    begin
      raw_results = $CLIENT.thoughtstream(username, count)
    rescue Exception => e
      raw_results = []
    end
    results = []

    while results.size < raw_results.size do
      sub_key, sub_value, thought_key, thought_value = raw_results.apply(results.size)
      instance = self.fetch

      key_schema = thought_key.getSchema.getFields
      (0...key_schema.size).each do |index|
        field = key_schema.get(index).name
        value = thought_key.get(index)
        value = value.to_s if value.is_a?(Java::OrgApacheAvroUtil::Utf8)
        instance.send(field.underscore+"=", value)
      end

      value_schema = thought_value.getSchema.getFields
      (0...value_schema.size).each do |index|
        field = value_schema.get(index).name
        value = thought_value.get(index)
        value = value.to_s if value.is_a?(Java::OrgApacheAvroUtil::Utf8)
        instance.send(field.underscore+"=", value)
      end

      results.push instance
    end
    results
  end
    
  def to_param
    timestamp.to_s
  end

  def posted_at
    post_time = Time.at(timestamp)
    if Time.now - post_time < 1.hour
      "#{((Time.now - post_time)/60).to_i} minutes ago"
    elsif Time.now - post_time < 1.day
      "#{((Time.now - post_time)/60/60).to_i} hours ago"
    else
      post_time.strftime("on %A, %B %d")
    end
  end
end
