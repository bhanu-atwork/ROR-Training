# Write a program to flat a nested array
def flat_array(input)
  res = []
  input.each {|ele| ele.each {|indv_ele| res.push(indv_ele)} }
end

puts flat_array([[1,2], [3,4]])
