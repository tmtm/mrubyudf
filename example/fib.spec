#!ruby
MrubyUdf.function do |f|
  f.name = 'fib'
  f.return_type = Integer
  f.arguments = [
    Integer
  ]
end
