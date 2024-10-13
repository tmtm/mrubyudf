FIXNUM_MAX = 2**62-1
def fib(n)
  a, b = 1, 0
  n.times { a, b = b, a + b }
  raise 'Overflow' if b > FIXNUM_MAX
  b
end
