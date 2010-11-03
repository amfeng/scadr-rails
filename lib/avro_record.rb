require File.join(RAILS_ROOT,'lib/piql/piql.jar')

import Java::EduBerkeleyCsScadsPiql::UserKey
import Java::EduBerkeleyCsScadsPiql::UserValue
import Java::EduBerkeleyCsScadsPiql::ScadrClient
import Java::EduBerkeleyCsScadsPiql::SimpleExecutor
import Java::EduBerkeleyCsScadsStorage::TestScalaEngine

$CLIENT = ScadrClient.new(TestScalaEngine.getTestCluster, SimpleExecutor.new, 10, 10, 10 ,10)

# TODO: Can't figure out what te object PIQL queries return is
class AvroRecord
  attr_accessor :avro_key
  attr_accessor :avro_value

  # TODO: Enforce primary keys; Does PIQL handle this?
  def self.set_primary_key(key)
  end
  def self.set_primary_keys(*keys)
  end

  # TODO
  def initialize(opts={})
    begin
      @avro_key = "#{self.class.to_s}Key".constantize.new
      @avro_value = "#{self.class.to_s}Value".constantize.new
    # Catches if the class does not exist
    rescue NameError => e
      raise e, "#{e.message} -- does #{self.class} exist in the schema?"
    end
    
    opts.each_pair do |col, val|
      self.send("#{col}=".to_sym, val)
    end
  end

  # TODO
  def valid?
    true
  end

  # TODO
  def save
    $CLIENT.send(self.class.to_s.downcase.pluralize).put(avro_key, avro_value)
  end

  # TODO
  def method_missing(method_id, *arguments, &block)
    # Column accessor methods
    method_id.to_s =~ /^(\w+)(=)?/
    column_name = $1
    method_name = $2 ? (column_name + "_$eq") : column_name
    # Key
    if avro_key.getSchema.getField(column_name)
      avro_key.send(method_name, *arguments, &block)
    # Value
    elsif avro_value.getSchema.getField(column_name)
      avro_value.send(method_name, *arguments, &block)
    
    # Default
    else
      super
    end
  end
end