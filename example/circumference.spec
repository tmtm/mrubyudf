#!ruby
MrubyUdf.function do |f|
  f.name = 'circumference'
  f.return_type = Float
  f.arguments = [
    Float
  ]
end
