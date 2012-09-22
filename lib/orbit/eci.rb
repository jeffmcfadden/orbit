module Orbit
  class Eci
    attr_accessor :m_Position
    attr_accessor :m_Velocity
    attr_accessor :m_Date

    def self.new_with_pos_vel_gmt(pos, vel, gmt)
      puts "new_with_pos_vel_gmt #{pos}, #{vel}, #{gmt}"

      eci = self.new

      eci.m_Position = pos
      eci.m_Velocity = vel
      eci.m_Date     = gmt

      eci
    end

    def initialize( geo = nil, date = nil )
      if !geo.nil? && !date.nil?
        setup( geo, date )
      end
    end

    def setup( geo, date )
      puts "Eci.setup( geo, #{date} )"
         mfactor = OrbitGlobals::TWO_PI * (OrbitGlobals::OMEGAE / OrbitGlobals::SEC_PER_DAY)
         lat = geo.latitude_rad
         lon = geo.longitude_rad
         alt = geo.altitude

         # Calculate Local Mean Sidereal Time (theta)
         theta = OrbitGlobals.time_to_lmst( date, lon )
         c = 1.0 / Math.sqrt(1.0 + OrbitGlobals::F * (OrbitGlobals::F - 2.0) * OrbitGlobals::sqr(Math.sin(lat)))
         s = ((1.0 - OrbitGlobals::F) ** 2 ) * c
         achcp = (OrbitGlobals::XKMPER * c + alt) * Math.cos(lat)

         @m_Date = date
         @m_Position = Vector.new()

         @m_Position.m_x = achcp * Math.cos(theta)                    # km
         @m_Position.m_y = achcp * Math.sin(theta)                    # km
         @m_Position.m_z = (OrbitGlobals::XKMPER * s + alt) * Math.sin(lat) # km
         @m_Position.m_w = Math.sqrt(OrbitGlobals::sqr(@m_Position.m_x) +
            OrbitGlobals::sqr(@m_Position.m_y) +
            OrbitGlobals::sqr(@m_Position.m_z))            # range, km

         @m_Velocity = Vector.new()

         @m_Velocity.m_x = -mfactor * @m_Position.m_y               # km / sec
         @m_Velocity.m_y =  mfactor * @m_Position.m_x
         @m_Velocity.m_z = 0.0
         @m_Velocity.m_w = Math.sqrt(OrbitGlobals::sqr(@m_Velocity.m_x) +  # range rate km/sec^2
            OrbitGlobals::sqr(@m_Velocity.m_y))
      end

      #endregion

      #region Properties

      def position
        @m_Position
      end

      def velocity
        @m_Velocity
      end

      def date
        @m_Date
      end

      #endregion

      # #####################################/
      # Return the corresponding geodetic position (based on the current ECI
      # coordinates/Julian date).
      # Assumes the earth is an oblate spheroid as defined in WGS '72.
      # Reference: The 1992 Astronomical Almanac, page K12.
      # Reference: www.celestrak.com (Dr. TS Kelso)
      def to_geo
        puts "to_geo"
         theta = OrbitGlobals::actan(@m_Position.m_y, @m_Position.m_x)
         puts "theta: #{theta}"
         puts "m_Date: #{@m_Date}"
         lon   = (theta - OrbitGlobals.time_to_gmst( @m_Date )) % OrbitGlobals::TWO_PI

         if (lon < 0.0)
            lon += OrbitGlobals::TWO_PI  # "wrap" negative modulo
          end

         r   = Math.sqrt(OrbitGlobals.sqr(@m_Position.m_x) + OrbitGlobals.sqr(@m_Position.m_y))
         e2  = OrbitGlobals::F * (2.0 - OrbitGlobals::F)
         lat = OrbitGlobals.actan(@m_Position.m_z, r)

         delta = 1.0e-07
         phi = nil
         c = nil

         begin
            phi = lat
            c   = 1.0 / Math.sqrt(1.0 - e2 * OrbitGlobals::sqr(Math.sin(phi)))
            lat = OrbitGlobals::actan(@m_Position.m_z + OrbitGlobals::XKMPER * c * e2 * Math.sin(phi), r)
         end while ((lat - phi).abs > delta)

         alt = r / Math.cos(lat) - OrbitGlobals::XKMPER * c

         return GeocentricCoordinates.new(lat, lon, alt) # radians, radians, kilometers
       end


    #/ <summary>
    #/ Scale the position vector by the given scaling factor.
    #/ </summary>
    #/ <param name="factor">The scaling factor.</param>
    def scale_pos_vector(factor)
       @m_Position.mul(factor)
     end

    #/ <summary>
    #/ Scales the velocity vector by the given scaling factor.
    #/ </summary>
    #/ <param name="factor">The scaling factor.</param>
    def scale_vel_vector(factor)
       @m_Velocity.mul(factor)
     end


  end
end