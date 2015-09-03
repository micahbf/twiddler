module Twiddler
  class Operator
    class InvalidOperation < StandardError; end

    def operate(operation, value)
      result = case operation[:function]
      when :raw
        value
      when :lin
        linear(operation, value)
      when :log
        logarithm(operation, value)
      when :exp
        exponent(operation, value)
      else
        raise InvalidOperation, "invalid operation: #{operation[:function]}"
      end

      if operation[:integer]
        result.round
      elsif round = operation[:round]
        result.round(round)
      else
        result
      end
    end

    private

    def linear(operation, value)
      min, max = operation.values_at(:min, :max)
      unless min && max
        raise InvalidOperation, "linear operation needs min and max"
      end

      slope = (max - min) / 127.0
      slope * value + min
    end

    def logarithm(operation, value)
      coefficient, constant = operation.values_at(:coefficient, :constant)
      coefficient ||= 1
      constant    ||= 0

      coefficient * Math.log(value) + constant
    end

    def exponent(operation, value)
      base, coefficient, constant = operation.values_at(:base, :coefficient, :constant)
      base        ||= Math::E
      coefficient ||= 1
      constant    ||= 0

      coefficient * base ** value + constant
    end
  end
end
