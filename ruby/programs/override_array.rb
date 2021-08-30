# Write a program to double each values of an array declaring array double each function in array class
module Enumerable
  def double_each
    self.map {|i| i*2}
  end
end

nums = Array.new(5) { |e| e = e * 2 }
puts nums.double_each
