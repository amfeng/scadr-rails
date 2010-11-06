require File.join(RAILS_ROOT,'lib/piql/piql.jar')

#import Java::EduBerkeleyCsScadsPiql::UserKey
#import Java::EduBerkeleyCsScadsPiql::UserValue
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

  # TODO
  def valid?
    true
  end

  # TODO
  def save
    begin
      $CLIENT.send(self.class.to_s.downcase.pluralize).put(avro_key, avro_value)
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
      # And after about 4 hours, I finally realize that this is not enumerable or any type of iterable object
      # And that I need to call "product_elements" before I can finally do shit
      raw_results = $CLIENT.send(method_id, *arguments, &block).product_elements.to_list
      results = []
      
      # NOTE: raw_results.size - 1, because the last element of the iterator is not an actual result
      while results.size < raw_results.size - 1 do
        keystore, valuestore = raw_results.product_element(results.size)
        keys = keystore.to_s
        values = valuestore.to_s
        instance = self.new
        JSON.parse(keys).each_pair do |field, value|
          instance.send(field+"=", value)
        end
        JSON.parse(values).each_pair do |field, value|
          instance.send(field+"=", value)
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
    column_name = $1
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