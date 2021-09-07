# Write a program to flat a nested array
arr = [[1,2], [3,4]]
def flat_array(input)
  res = []
  input.each {|ele| ele.each {|indv_ele| res.push(indv_ele)} }
end

puts flat_array(arr)
# Inbuilt array function having same functionality
puts arr.flatten
