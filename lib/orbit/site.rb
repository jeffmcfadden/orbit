module Orbit

  class Site

    attr_accessor :geo

    def initialize( lat, lon, alt )
      alt = alt / 1000 #km
      @geo = GeocentricCoordinates.new( OrbitGlobals.deg_to_rad( lat ), OrbitGlobals.deg_to_rad( lon ), alt )
    end

    def latitude_rad
      @geo.latitude_rad
    end

    def longitude_rad
      @geo.longitude_rad
    end

    def latitude_deg
      OrbitGlobals::rad_to_deg( latitude_rad )
    end

    def longitude_deg
      OrbitGlobals::rad_to_deg( longitude_rad )
    end

    def altitude
      @geo.altitude
    end

    def get_position(date)
      return Eci.new(@geo, date)
    end

    def view_angle_to_satellite_at_time( sat, time )
      sat_position = sat.eci_position_at_time( time )
      topoLook = get_look_angle( sat_position )
    end

    def get_look_angle(eci)
           # Calculate the ECI coordinates for this Site object at the time
           # of interest.
           date      = eci.date
           eciSite   = Eci.new(@geo, date)
           vecRgRate = Vector.new(eci.velocity.m_x - eciSite.velocity.m_x,
                                         eci.velocity.m_y - eciSite.velocity.m_y,
                                         eci.velocity.m_z - eciSite.velocity.m_z)

           x = eci.position.m_x - eciSite.position.m_x
           y = eci.position.m_y - eciSite.position.m_y
           z = eci.position.m_z - eciSite.position.m_z
           w = Math.sqrt(OrbitGlobals::sqr(x) + OrbitGlobals::sqr(y) + OrbitGlobals::sqr(z))

           vecRange = Vector.new(x, y, z, w)

           # The site's Local Mean Sidereal Time at the time of interest.
           theta = OrbitGlobals.time_to_lmst( date, longitude_rad)

           sin_lat   = Math.sin(latitude_rad)
           cos_lat   = Math.cos(latitude_rad)
           sin_theta = Math.sin(theta)
           cos_theta = Math.cos(theta)

           top_s = sin_lat * cos_theta * vecRange.m_x +
                          sin_lat * sin_theta * vecRange.m_y -
                          cos_lat * vecRange.m_z
           top_e = -sin_theta * vecRange.m_x +
                           cos_theta * vecRange.m_y
           top_z = cos_lat * cos_theta * vecRange.m_x +
                          cos_lat * sin_theta * vecRange.m_y +
                          sin_lat * vecRange.m_z
           az    = Math.atan(-top_e / top_s)

           if (top_s > 0.0)
              az += OrbitGlobals::PI
            end

           if (az < 0.0)
              az += 2.0 * OrbitGlobals::PI
            end

           el   = Math.asin(top_z / vecRange.m_w)
           rate = (vecRange.m_x * vecRgRate.m_x +
                          vecRange.m_y * vecRgRate.m_y +
                          vecRange.m_z * vecRgRate.m_z) / vecRange.m_w

           topo = TopocentricHorizonCoordinates.new(az,         # azimuth, radians
                                          el,         # elevation, radians
                                          vecRange.m_w, # range, km
                                          rate)      # rate, km / sec
  #if WANT_ATMOSPHERIC_CORRECTION
        # Elevation correction for atmospheric refraction.
        # Reference:  Astronomical Algorithms by Jean Meeus, pp. 101-104
        # Note:  Correction is meaningless when apparent elevation is below horizon
        topo.elevation += OrbitGlobals::deg_to_rad((1.02 /
                                      Math.tan(OrbitGlobals::deg_to_rad(OrbitGlobals::rad_to_deg(el) + 10.3 /
                                      (OrbitGlobals::rad_to_deg(el) + 5.11)))) / 60.0)
        if (topo.elevation < 0.0)
           topo.elevation = el    # Reset to true elevation
         end

        if (topo.elevation > (OrbitGlobals::PI / 2))
           topo.elevation = (OrbitGlobals::PI / 2)
         end
  #endif
           return topo

    end




  end
end