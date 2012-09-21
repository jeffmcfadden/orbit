module Orbit
  class GeocentricCoordinates
    attr_accessor :latitude_rad
    attr_accessor :longitude_rad
    attr_accessor :altitude

    def initialize( lat = nil, lon = nil, alt = 0 )
      @latitude_rad  = lat
      @longitude_rad = lon
      @altitude      = alt
    end

    def latitude
      OrbitGlobals.rad_to_deg( @latitude_rad )
    end

    def longitude
      l = OrbitGlobals.rad_to_deg( @longitude_rad )

      if l > 180
        l = 360 - l
        l *= -1
      end

      l
    end

    def altitude
      @altitude * 1000.0 #Convert from km to m
    end

    def to_s
      "Lat: #{latitude}, Lng: #{longitude}, Alt: #{altitude}"
    end

  end
end