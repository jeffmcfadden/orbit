module Orbit

  class Tle

    attr_accessor :tle_string
    attr_accessor :norad_num
    attr_accessor :intl_desc
    attr_accessor :set_number      # TLE set number
    attr_accessor :epoch_year      # Epoch: Last two digits of year
    attr_accessor :epoch_day       # Epoch: Fractional Julian Day of year
    attr_accessor :orbit_at_epoch  # Orbit at epoch
    attr_accessor :inclination     # Inclination
    attr_accessor :raan            # R.A. ascending node
    attr_accessor :eccentricity    # Eccentricity
    attr_accessor :arg_perigee     # Argument of perigee
    attr_accessor :mean_anomaly    # Mean anomaly
    attr_accessor :mean_motion     # Mean motion
    attr_accessor :mean_motion_dt  # First time derivative of mean motion
    attr_accessor :mean_motion_dt2 # Second time derivative of mean motion
    attr_accessor :bstar_drag      # BSTAR Drag


  # ISS (ZARYA)
  # 1 25544U 98067A   08264.51782528 −.00002182  00000-0 -11606-4 0  2927
  # 2 25544  51.6416 247.4627 0006703 130.5360 325.0288 15.72125391563537

    FIELD_COLUMNS = {
      norad_num:       [1, 3,7],
      classification:  [1, 8,8],
      launch_year:     [1, 10,11],
      launch_num:      [1, 12,14],
      launch_piece:    [1, 15,17],
      epoch_year:      [1, 19,20],
      epoch_day:       [1, 21,32],
      mean_motion_dt:  [1, 34,43],
      mean_motion_dt2: [1, 45,52],
      bstar_drag:      [1, 54,61],
      number_zero:     [1, 63,63],
      element_num:     [1, 65,68],
      checksum_1:      [1, 69,69],
      inclination:     [2, 9,16],
      raan:            [2, 18,25],
      eccentricity:    [2, 27,33],
      arg_perigee:     [2, 35,42],
      mean_anomaly:    [2, 44,51],
      mean_motion:     [2, 53,63],
      revolution_num:  [2, 64,68],
      checksum_2:      [2, 69,69]
    }


    def initialize( s )
      @tle_string      = s

      # puts @tle_string

      @norad_num       = get_field( :norad_num )
      @classification  = get_field( :classification )
      @launch_year     = get_field( :launch_year )
      @launch_num      = get_field( :launch_num )
      @launch_piece    = get_field( :launch_piece )
      @mean_motion_dt  = get_field( :mean_motion_dt ).to_f
      @mean_motion_dt2 = exp_to_float( "0." + get_field( :mean_motion_dt2 ) ).to_f
      @bstar_drag      = exp_to_float( "0." + get_field( :bstar_drag ) ).to_f
      @element_num     = get_field( :element_num ).to_f
      @inclination     = get_field( :inclination ).to_f
      @raan            = get_field( :raan ).to_f
      @eccentricity    = exp_to_float( "0." + get_field( :eccentricity ) ).to_f
      @arg_perigee     = get_field( :arg_perigee ).to_f
      @mean_anomaly    = get_field( :mean_anomaly ).to_f
      @mean_motion     = get_field( :mean_motion ).to_f
      @revolution_num  = get_field( :revolution_num ).to_f
    end

    def exp_to_float( exp )
      # puts "exp: #{exp}"
      parts = exp.split( "-" )
      exp_part = -0.1

      if parts.count < 2
        parts = exp.split( " " )
        exp_part = 0.1
      end

      float = parts[0].to_f * ( exp_part ** parts[1].to_f )
    end

    def get_field( field )
      lines = @tle_string.split( "\n" )

      line_num        = FIELD_COLUMNS[field][0]
      substring_start = FIELD_COLUMNS[field][1] - 1 # Convert to zero-base
      substring_end   = FIELD_COLUMNS[field][2] - 1 # Convert to zero-base

      lines[line_num][substring_start..substring_end].strip
    end

    def to_s
      hash = {}
      instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }

      hash.to_s
    end

    def epoch
      epoch_year     = get_field( :epoch_year ).to_f
      epoch_day      = get_field( :epoch_day ).to_f

      epoch_year = epoch_year < 57 ? ( epoch_year + 2000 ) : ( epoch_year + 1900 )

      epoch = Time.at( Time.utc( epoch_year ).to_i + ( ( epoch_day - 1 ) * OrbitGlobals::SEC_PER_DAY ) )

      epoch = epoch.utc

      # puts "epoch_year: #{epoch_year}"
      # puts "epoch_day: #{epoch_day}"
      # puts "epoch: #{epoch}"

      epoch
    end

    # def epoch_julian
    #   epoch.
    # end

  end
end