orbit
=====

A ruby gem for calculating satellite positions and observation angles, etc.

## Usage

### Get position of earth satellite

    tle = "EYESAT-1 (AO-27)\n1 22825U 93061C   12265.90994989  .00000070  00000-0  44528-4 0  2022\n2 22825  98.5823 207.2528 0008444   2.3056 357.8161 14.29486540990291"
    s = Orbit::Satellite.new( tle )
    l = Orbit::Site.new( 33.5, -95.3, 23 ) # Lat, Lng, Elevation Above Sea Level in Meters
    tc = l.view_angle_to_satellite_at_time( s, Time.now )

    elevation = Orbit::OrbitGlobals.rad_to_deg( tc.elevation )
    azimuth   = Orbit::OrbitGlobals.rad_to_deg( tc.azimuth )

    puts "Elevation: #{elevation}, Azimuth: #{azimuth}"

### Get position of a planet

    earth = Orbit::Planet.earth
    puts earth.position
    
    > {:x=>0.2570128386496788, :y=>0.9510970893916104, :z=>-4.094071081826459e-05}