class Integer
  def prime_divisors
    factors = []
    (2..abs).each do |number|
      if (self % number == 0) && factors.all? { |factor| number % factor != 0 }
      factors << number
	  end
    end
    factors
  end
end

class Range
  def fizzbuzz
    map do |n|
      n = :fizzbuzz if n % 15 == 0
      n = :fizz if n != :fizzbuzz and n % 3 == 0
      n = :buzz if n != :fizz and n != :fizzbuzz and n % 5 == 0
      n
    end
  end
end

class Hash
  def group_values
    result = {}
    each do |key, value|
      result[value] ||= []
      result[value] << key
    end
    result
  end
end

class Array
  def densities
    map { |element| count(element) }
  end
end
