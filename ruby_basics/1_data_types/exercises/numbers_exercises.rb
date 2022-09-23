def add(a, b)
  # return the result of adding a and b
  a + b
end

def subtract(a, b)
  # return the result of subtracting b from a
  a - b
end

def multiply(a, b)
  # return the result of multiplying a times b
  a * b
end

def divide(a, b)
  # return the result of dividing a by b
  a / b
end

def remainder(a, b)
  # return the remainder of dividing a by b using the modulo operator
  a % b
end

def float_division(a, b)
  # return the result of dividing a by b as a float, rather than an integer
  a.to_f / b.to_f
end

def string_to_number(string)
  string.to_i
end

def even?(number)
  number.even?
end

def odd?(number)
  number.odd?
end
