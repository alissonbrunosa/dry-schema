require 'dry/schema/macros/dsl'
require 'dry/schema/constants'

module Dry
  module Schema
    module Macros
      class Key < DSL
        option :input_schema, optional: true, default: proc { schema_dsl&.new }

        def filter(*args, &block)
          input_schema.optional(name).value(*args, &block)
          self
        end

        def value(*args, **opts, &block)
          type_spec = args[0].is_a?(Symbol) && !args[0].to_s.end_with?(QUESTION_MARK) && args[0]

          if type_spec
            type(type_spec).value(*args[1..-1], **opts, &block)
          else
            super(*args, **opts, &block)
          end
        end

        def type(*args)
          schema_dsl.set_type(name, args)
          self
        end

        def maybe(*args, **opts, &block)
          append_macro(Macros::Maybe) do |macro|
            macro.call(*args, **opts, &block)
          end
        end

        def to_rule
          if trace.captures.empty?
            super
          else
            [super, trace.to_rule(name)].reduce(operation)
          end
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
