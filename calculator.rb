class Calculator

    REQUIRED_ATTRIBUTES = %i(rate amount term type)
    ALLOWED_TYPES       = %i(standart annuity)

  attr_reader :rate, :amount, :type, :term, :errors

  def initialize(rate, amount, type, term)
    @rate     = rate.to_s.gsub(',', '').to_f
    @amount   = amount.to_f
    @type = type.to_sym
    @term = term.to_f
    @errors = { rate: [], amount: [], type: [], term: [] }
  end

  def calculate
    key = @rate/1200

    result = []
    case @type
      when :annuity
        monthly_payment = (@amount * (key + (key / (((1 + key) ** @term)- 1)))).round(2)
        for i in 0..(term-1)
          result << { 
            month: i+1,
            percents: percent = (@amount * key).round(2),
            payment: monthly_payment,
            monthly_payment: payment = (monthly_payment - percent).round(2),
            scum: ((@amount - payment) < 0) ? 0 : @amount = (@amount - payment).round(2)
          }
        end
      when :standart
        monthly_payment = (@amount / @term).round(2)
        for i in 0..(@term-1)
          result << {
            percents: percent = ((@amount - (monthly_payment * i))*key).round(2),
            month: i+1,
            payment: payment = (monthly_payment + percent).round(2),
            monthly_payment: monthly_payment,
            scum: (monthly_payment * (i+1) < @amount) ? (@amount - monthly_payment*(i+1)).round(2) : 0
          }
        end
    end 
    result   
  end
  def attributes
    { rate: @rate, amount: @amount, type: @type, term: @term }
  end

  def valid?
    REQUIRED_ATTRIBUTES.each { |attribute, _| passes_validation_for?(attribute) }
    has_errors?
  end

  def to_json
    attributes.to_json
  end

  def passes_validation_for?(attribute)
    case attribute
      when :rate      then calculator_value_greater_than?(:rate, 0.0) 
      when :amount    then calculator_value_greater_than?(:amount, 0) 
      when :term      then calculator_value_greater_than?(:term, 0)   
      when :type      then calculator_value_allowed_in?(:type, ALLOWED_TYPES)
    end
  end

  def has_errors?
    errors.all? { |_, attribute_errors| attribute_errors.empty? }
  end

  def calculator_value_greater_than?(attribute, offset)
    return true if send(attribute) > offset
    errors[attribute] << "Must be greater than #{offset}"
    false
  end
  
  def calculator_value_allowed_in?(attribute, allowed_values)
    return true if allowed_values.include?(send(attribute))
    errors[attribute] << "Must be either one of #{allowed_values.join(', ')}"
    false
  end
end