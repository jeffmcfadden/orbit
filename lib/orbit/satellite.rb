module Orbit
  class Satellite

    attr_accessor :tle
    attr_accessor :orbit

    def initialize( tle_string )
      @tle = Tle.new(tle_string)
      @orbit = Orbit.new(@tle)
    end

    def eci_position_at_time( time )
      since_epoch = ( time.to_i - @tle.epoch.to_i )

      eci_position_at_seconds_since_epoch( since_epoch )
    end

    def eci_position_at_seconds_since_epoch( time_since_epoch )
      t = time_since_epoch / 60.0

      p = @orbit.get_position( t ) #For whatever reason this is decimal minutes
    end

    def position_at_time( time )
      seconds_since_epoch = ( time.to_f - @tle.epoch.to_f )
      position_at_seconds_since_epoch( seconds_since_epoch )
    end

    def position_at_seconds_since_epoch( time_since_epoch )
      eci_position_at_seconds_since_epoch( time_since_epoch ).to_geo
    end

    def current_position
      since_epoch = ( Time.new.utc.to_f - @tle.epoch.to_f )

      position_at_seconds_since_epoch( since_epoch )
    end

  end
end