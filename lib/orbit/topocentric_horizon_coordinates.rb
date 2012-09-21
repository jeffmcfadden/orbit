module Orbit

  class TopocentricHorizonCoordinates
    #/ <summary>
    #/ The azimuth, in radians.
    #/ </summary>
    attr_accessor :azimuth

    #/ <summary>
    #/ The elevation, in radians.
    #/ </summary>
    attr_accessor :elevation

    #/ <summary>
    #/ The range, in kilometers.
    #/ </summary>
    attr_accessor :range

    #/ <summary>
    #/ The range rate, in kilometers per second.
    #/ A negative value means "towards observer".
    #/ </summary>
    attr_accessor :range_rate

    def initialize( az, el, r, rr )
      @azimuth    = az
      @elevation  = el
      @range      = r
      @range_rate = rr
    end

  end
end