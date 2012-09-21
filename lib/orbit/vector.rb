module Orbit

  class Vector
    attr_accessor :m_x
    attr_accessor :m_y
    attr_accessor :m_z
    attr_accessor :m_w

    def initialize( x = nil, y = nil, z = nil, w = nil )
      @m_x = x
      @m_y = y
      @m_z = z
      @m_w = w
    end

    # ##################################/
    # Multiply each component in the vector by 'factor'.
    def mul(factor)
      #puts "m_x: #{@m_x}, factor: #{factor}"

       @m_x = @m_x * factor
       @m_y *= factor
       @m_z *= factor
       @m_w *= (factor).abs if @m_w
     end

    # ##################################/
    # Subtract a vector from this one.
    def sub(vec)
       @m_x -= vec.m_x
       @m_y -= vec.m_y
       @m_z -= vec.m_z
       @m_w -= vec.m_w
     end

    # ##################################/
    # Calculate the angle between this vector and another
    def angle(vec)
       return Math.acos(dot(vec) / (magnitude() * vec.magnitude()))
     end

    # ##################################/
    def magnitude
       return Math.sqrt((@m_x * @m_x) + (@m_y * @m_y) + (@m_z * @m_z))
     end


    # ##################################/
    # Return the dot product
    def dot(vec)
       return (@m_x * vec.m_x) + (@m_y * vec.m_y) + (@m_z * vec.m_z)
     end


  end
end