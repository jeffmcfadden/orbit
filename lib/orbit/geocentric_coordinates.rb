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
  end
end