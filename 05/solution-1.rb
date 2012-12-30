  class Integer
	  def prime?
	    (2..abs-1).each { |x| if self % x == 0
	                            return false
	                          end
	                    }
	     true
	  end
	
	  def prime_divisors
	    divisors = []
	      (2..abs).each { |x| if x.prime? and self%x == 0
	                             divisors<<x        
	                          end 
	                    }
	      divisors
	  end
	end
	
	class Range
	  def fizzbuzz
	    fuzzbuzz = []
	    each do |x|  if x % 15 == 0 then fuzzbuzz<<:fizzbuzz
	                   elsif x % 5 == 0 then fuzzbuzz<<:buzz
	                     elsif x % 3 == 0 then fuzzbuzz<<:fizz
	                     else fuzzbuzz<<x
	                  end
	         end
	    fuzzbuzz
	  end
	end
	
	class Hash
	  def group_values
	    group_values = {}
	    each do |key, value| group_values[value] ||= []
	                         group_values[value] << key
	         end
	    group_values
	  end
	end
	
	class Array
	  def densities
	    collect {|x| count x}
	  end
	end
