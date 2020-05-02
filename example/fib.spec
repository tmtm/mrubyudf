#!ruby
MrubyUdf.function do |f|
  f.name = 'fib'
  f.return = Integer
  f.arguments = [
    Integer
  ]
end
