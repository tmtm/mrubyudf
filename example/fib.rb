LONG_LONG_MAX = 9223372036854775807

def fib(n)
  b = 1
  c = 0
  n.times do
    a, b = b, c
    c = a + b
    raise 'Overflow' if c > LONG_LONG_MAX
  end
  c
end
