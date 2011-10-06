module DateParser
  def parse(value, default_value)
    begin
      Date.parse(value)
    rescue ArgumentError, TypeError
      default_value
    end
  end

  extend self
end
