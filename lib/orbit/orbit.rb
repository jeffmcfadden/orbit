module Orbit
  class Orbit
    attr_accessor :tle

    # TLE caching variables
    attr_accessor :m_Inclination
    attr_accessor :m_Eccentricity
    attr_accessor :m_RAAN
    attr_accessor :m_ArgPerigee
    attr_accessor :m_BStar
    attr_accessor :m_Drag
    attr_accessor :m_TleMeanMotion
    attr_accessor :m_MeanAnomaly

    # Caching variables recovered from the input TLE elements
    attr_accessor :m_aeAxisSemiMajorRec  # semimajor axis, in AE units
    attr_accessor :m_aeAxisSemiMinorRec  # semiminor axis, in AE units
    attr_accessor :m_rmMeanMotionRec     # radians per minute
    attr_accessor :m_kmPerigeeRec        # perigee, in km
    attr_accessor :m_kmApogeeRec         # apogee, in km

    attr_accessor :epoch

    attr_accessor :norad_model
    attr_accessor :period

    def initialize( tle )
      @tle = tle


      @epoch = tle.epoch

      @m_Inclination   = OrbitGlobals.deg_to_rad(@tle.inclination)
      @m_Eccentricity  = @tle.eccentricity
      @m_RAAN          = OrbitGlobals.deg_to_rad(@tle.raan)
      @m_ArgPerigee    = OrbitGlobals.deg_to_rad(@tle.arg_perigee)
      @m_BStar         = @tle.bstar_drag
      @m_Drag          = @tle.mean_motion_dt
      @m_MeanAnomaly   = OrbitGlobals.deg_to_rad(@tle.mean_anomaly)
      @m_TleMeanMotion = @tle.mean_motion

      # Recover the original mean motion and semimajor axis from the
      # input elements.
      mm     = tle_mean_motion
      rpmin  = mm * OrbitGlobals::TWO_PI / OrbitGlobals::MIN_PER_DAY   # rads per minute

      a1     = (OrbitGlobals::XKE / rpmin) ** (2.0 / 3.0)
      e      = eccentricity
      i      = inclination
      temp   = (1.5 * OrbitGlobals::CK2 * (3.0 * (Math.cos(i) ** 2) - 1.0) /
                      ( (1.0 - e * e) ** 1.5 ) )
      delta1 = temp / (a1 * a1)
      a0     = a1 *
                     (1.0 - delta1 *
                     ((1.0 / 3.0) + delta1 *
                     (1.0 + 134.0 / 81.0 * delta1)))

      delta0 = temp / (a0 * a0)

      @m_rmMeanMotionRec    = rpmin / (1.0 + delta0)
      @m_aeAxisSemiMajorRec = a0 / (1.0 - delta0)
      @m_aeAxisSemiMinorRec = @m_aeAxisSemiMajorRec * Math.sqrt(1.0 - (e * e))
      @m_kmPerigeeRec       = OrbitGlobals::XKMPER * (m_aeAxisSemiMajorRec * (1.0 - e) - OrbitGlobals::AE)
      @m_kmApogeeRec        = OrbitGlobals::XKMPER * (m_aeAxisSemiMajorRec * (1.0 + e) - OrbitGlobals::AE)



      @period_minutes = calculate_period_minutes

      if @period_minutes > 225
        @norad_model = NoradSDP4.new( self )
      else
        @norad_model = NoradSGP4.new( self )
      end
    end

    def calculate_period_minutes
      if @tle.mean_motion == 0
        minutes = 0.0
      else
        minutes = (OrbitGlobals::TWO_PI / @tle.mean_motion)
      end

      minutes
    end

    def get_position(minutesPastEpoch)
      # puts "Orbit.get_position( #{minutesPastEpoch} )"

      eci = @norad_model.get_position(minutesPastEpoch)

      # puts "Position: #{eci.m_Position.m_x}"

      eci.scale_pos_vector(OrbitGlobals::XKMPER / OrbitGlobals::AE)      # km
      eci.scale_vel_vector((OrbitGlobals::XKMPER / OrbitGlobals::AE) *
                        (OrbitGlobals::MIN_PER_DAY / 86400.0))      # km/sec
      return eci
    end

    def epoch_time
      @epoch
    end

    def semi_major
   return @m_aeAxisSemiMajorRec
  end
    def semi_minor
   return @m_aeAxisSemiMinorRec
  end
    def mean_motion
   return @m_rmMeanMotionRec
  end
    def major
   return 2.0 * SemiMajor
  end
    def minor
   return 2.0 * SemiMinor
  end
    def perigee
   return @m_kmPerigeeRec
  end
    def apogee
   return @m_kmApogeeRec
  end

    def inclination
   return @m_Inclination
  end
    def eccentricity
   return @m_Eccentricity
  end
    def raan
   return @m_RAAN
  end
    def arg_perigee
   return @m_ArgPerigee
  end
    def bstar
   return @m_BStar
  end
    def drag
   return @m_Drag
  end
    def mean_anomaly
   return @m_MeanAnomaly
  end
    def tle_mean_motion
   return @m_TleMeanMotion
  end

    def sat_norad_id
   return @tle.norad_number
  end
    def sat_name
   return @tle.name
  end
    def sat_name_long
   return SatName + " #" + SatNoradId
  end
  end
end