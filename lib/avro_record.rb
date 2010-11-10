require File.join(RAILS_ROOT,'lib/piql/piql.jar')

#import Java::EduBerkeleyCsScadsPiql::UserKey
#import Java::EduBerkeleyCsScadsPiql::UserValue
import Java::EduBerkeleyCsScadsPiql::ScadrClient
import Java::EduBerkeleyCsScadsPiql::SimpleExecutor
import Java::EduBerkeleyCsScadsStorage::TestScalaEngine

$CLIENT = ScadrClient.new(TestScalaEngine.getTestCluster, SimpleExecutor.new, 10)

class String
  def carmelize
    base = self.camelize
    base.slice(0,1).downcase + base.slice(1,base.size)
  end
end

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
    @is_new_record = true
    begin
      @avro_key = eval("Java::EduBerkeleyCsScadsPiql::#{self.class.to_s}Key").new
      @avro_value = eval("Java::EduBerkeleyCsScadsPiql::#{self.class.to_s}Value").new
    # Catches if the class does not exist
    rescue NameError => e
      raise e, "#{e.message} -- does #{self.class} exist in the schema?"
    end
    
    opts.each_pair do |col, val|
      self.send("#{col}=".to_sym, val)
    end
  end
  
  def self.fetch(opts={})
    record = self.new(opts)
    record.set_stale
    record
  end

  # TODO
  def valid?
    true
  end
  
  def new_record?
    @is_new_record
  end

  # TODO
  def save
    begin
      $CLIENT.send(self.class.to_s.downcase.pluralize).put(avro_key, avro_value)
      @is_new_record = false
      true
    rescue NativeException
      false
    end
  end

  def self.respond_to?(method_id, include_private=false)
    if $CLIENT.respond_to?(method_id)
      true
    else
      super
    end
  end

  # TODO: Either pre-define or cache these methods?
  def self.method_missing(method_id, *arguments, &block)
    # Find
    if $CLIENT.respond_to?(method_id)
      begin
        raw_results = $CLIENT.send(method_id, *arguments, &block)
      rescue Exception => e
        raw_results = []
      end
      results = []
      
      while results.size < raw_results.size do
        keystore, valuestore = raw_results.apply(results.size)
        
        instance = self.fetch
        
        key_schema = keystore.getSchema.getFields
        (0...key_schema.size).each do |index|
          field = key_schema.get(index).name
          value = keystore.get(index)
          value = value.to_s if value.is_a?(Java::OrgApacheAvroUtil::Utf8)
          instance.send(field.underscore+"=", value)
        end

        value_schema = valuestore.getSchema.getFields
        (0...value_schema.size).each do |index|
          field = value_schema.get(index).name
          value = valuestore.get(index)
          value = value.to_s if value.is_a?(Java::OrgApacheAvroUtil::Utf8)
          instance.send(field.underscore+"=", value)
        end
        
        results.push instance
      end
      results
    else
      super
    end
  end

  def respond_to?(method_id, include_private=false)
    method_id.to_s =~ /^(\w+)(=)?/
    column_name = $1.carmelize
    if avro_key.getSchema.getField(column_name) || avro_value.getSchema.getField(column_name)
      true
    else
      super
    end
  end

  # TODO: Should be able to "cache" these calls by defining methods on-the-fly
  def method_missing(method_id, *arguments, &block)
    # Column accessor methods
    method_id.to_s =~ /^(\w+)(=)?/
    column_name = $1.carmelize
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
  
  def set_stale
    @is_new_record = false
  end

  def set_fresh
    @is_new_record = true
  end
end