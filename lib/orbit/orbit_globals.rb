module Orbit

  class OrbitGlobals

    PI            = 3.141592653589793
    TWO_PI        = 2.0 * OrbitGlobals::PI
    RADS_PER_DEGREE = OrbitGlobals::PI / 180.0
    DEGREES_PER_RAD = 180.0 / OrbitGlobals::PI

    GM            = 398601.2   # Earth gravitational constant, km^3/sec^2
    GEO_SYNC_ALT    = 42241.892  # km
    EARTHDIAM     = 12800.0    # km
    DAYSIDEREAL   = (23 * 3600) + (56 * 60) + 4.09  # sec
    DAYSOLAR      = (24 * 3600.0)   # sec

    AE            = 1.0
    AU            = 149597870.0  # Astronomical unit (km) (IAU 76)
    SR            = 696000.0     # Solar radius (km)      (IAU 76)
    XKMPER        = 6378.135     # Earth equatorial radius - kilometers (WGS '72)
    F             = 1.0 / 298.26 # Earth flattening (WGS '72)
    GE            = 398600.8     # Earth gravitational constant (WGS '72)
    J2            = 1.0826158E-3 # J2 harmonic (WGS '72)
    J3            = -2.53881E-6  # J3 harmonic (WGS '72)
    J4            = -1.65597E-6  # J4 harmonic (WGS '72)
    CK2           = OrbitGlobals::J2 / 2.0
    CK4           = -3.0 * OrbitGlobals::J4 / 8.0
    XJ3           = OrbitGlobals::J3
    QO            = OrbitGlobals::AE + 120.0 / OrbitGlobals::XKMPER
    S             = OrbitGlobals::AE + 78.0  / OrbitGlobals::XKMPER
    MIN_PER_DAY     = 1440.0        # Minutes per day (solar)
    SEC_PER_DAY     = 86400.0       # Seconds per day (solar)
    OMEGAE        = 1.00273790934 # Earth rotation per sidereal day
     XKE          = Math.sqrt(3600.0 * OrbitGlobals::GE /
                       (OrbitGlobals::XKMPER * OrbitGlobals::XKMPER * OrbitGlobals::XKMPER)) # sqrt(ge) ER^3/min^2
     QOMS2T       = ((OrbitGlobals::QO - OrbitGlobals::S) ** 4.0) #(QO - S)^4 ER^4


     def self.sqr( n )
       n ** 2
     end

     def self.deg_to_rad( deg )
       deg * RADS_PER_DEGREE;
     end

     def self.rad_to_deg( rad )
       rad * DEGREES_PER_RAD;
     end


     def self.fmod2p(arg)
        modu = (arg % TWO_PI);

        if (modu < 0.0)
           modu += TWO_PI
         end

        return modu
      end

     # // ///////////////////////////////////////////////////////////////////////////
     #    // Globals.AcTan()
     #    // ArcTangent of sin(x) / cos(x). The advantage of this function over arctan()
     #    // is that it returns the correct quadrant of the angle.
     def self.actan( sinx,  cosx)
        ret = nil

        if (cosx == 0.0)
           if (sinx > 0.0)
              ret = PI / 2.0
           else
              ret = 3.0 * PI / 2.0
          end
        else
           if (cosx > 0.0)
              ret = Math.atan(sinx / cosx)
           else
              ret = PI + Math.atan(sinx / cosx)
            end
          end

        return ret
      end

      def self.time_to_gmst(t)
        jd = t.to_date.jd - 0.5
        seconds = (t.hour * 3600) + (t.min * 60) + (t.sec).to_f + (t.subsec).to_f
        fraction_of_day = seconds / 86400.0

        jd += fraction_of_day

        #puts "jd: #{jd}"

        ut = (jd + 0.5 ) % 1.0;
        jd = jd - ut
        tu = (jd - 2451545.0) / 36525.0
        gmst = 24110.54841 + tu * (8640184.812866 + tu * (0.093104 - tu * 6.2E-6));
        gmst =  ( gmst + 86400.0 * 1.00273790934 * ut ) % 86400.0
        if (gmst < 0.0)
          gmst += 86400.0 # "wrap" negative modulo value
        end

        gmst = (OrbitGlobals::TWO_PI * (gmst / 86400.0))

        # puts "gmst: #{gmst}"

        gmst
      end

      # /////////////////////////////////////////////////////////////////////
      # ToLmst()
      # Calculate Local Mean Sidereal Time for given longitude (for this date).
      # The longitude is assumed to be in radians measured west from Greenwich.
      # The return value is the angle, in radians, measuring eastward from the
      # Vernal Equinox to the given longitude.
      def self.time_to_lmst (t, lon)
        gmst = OrbitGlobals.time_to_gmst( t )
        lmst = ( gmst + lon ) % TWO_PI

        # puts "long: #{lon}"
        # puts "gmst: #{gmst}"
        # puts "lmst: #{lmst}"

        lmst
      end

  end
end