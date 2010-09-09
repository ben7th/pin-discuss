# config/initializers/active_record_extensions.rb

module ActiveRecord
  class Base
    def dup
      obj = super
      obj.instance_variable_set('@attributes', instance_variable_get('@attributes').dup)
      obj
    end
  end
end
