# Initialization stuff for AvroRecord

require File.join(RAILS_ROOT,'lib/piql/piql.jar')

import Java::EduBerkeleyCsScadsPiqlScadr::ScadrClient
import Java::EduBerkeleyCsScadsPiql::SimpleExecutor
import Java::EduBerkeleyCsScadsStorage::TestScalaEngine

$CLIENT = ScadrClient.new(TestScalaEngine.new_scads_cluster(1), SimpleExecutor.new, 10)

class Object
  # Mainly to convert String to Utf8 without having to check if an Object is a String
  # Can help if anything besides a String needs a similar process
  def pickle
	self
  end
end

class String
  def carmelize
	base = self.camelize
	base.slice(0,1).downcase + base.slice(1,base.size)
  end

  # Convert String to Utf8
  def pickle
	Java::OrgApacheAvroUtil.Utf8.new(self)
  end
end

# Wrapper around ListBuffer, to make it more like an array
class ScalaList
  def initialize
	@list_buffer = Java::ScalaCollectionMutable::ListBuffer.new
  end

  def push(item)
	@list_buffer.append{ |foo| foo.apply item.pickle }
  end

  def to_list
	@list_buffer
  end
end

require 'avro_record'