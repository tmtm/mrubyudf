#!ruby
MrubyUdf.function do |f|
  f.name = 'repeat_str'
  f.return_type = String
  f.arguments = [
    String,
    Integer,
  ]
end
