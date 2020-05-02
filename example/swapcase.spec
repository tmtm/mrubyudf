#!ruby
MrubyUdf.function do |f|
  f.name = 'swapcase'
  f.return_type = String
  f.arguments = [
    String
  ]
end
