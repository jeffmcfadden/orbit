module Orbit
  class Satellite

    attr_accessor :tle
    attr_accessor :orbit

    def initialize( tle_string )
      puts "HI"
      #@tle = Tle.new(tle_string)
      #@orbit = Orbit.new(@tle)
    end

    def position_at_time_since_epoch( time_since_epoch )
      @orbit.get_position( time_since_epoch )
    end

    def current_position
      since_epoch = ( Time.new.to_i - @tle.epoch.to_i ) / 60.0

      position_at_time_since_epoch( since_epoch )
    end

  end
end