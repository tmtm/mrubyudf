#!ruby
MrubyUdf.function do |f|
  f.name = 'rownum'
  f.return_type = Integer
  f.arguments = []
end
