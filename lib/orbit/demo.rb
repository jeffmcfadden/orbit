require './orbit_globals.rb'
require './geocentric_coordinates.rb'
require './topocentric_horizon_coordinates.rb'
require './julian.rb'
require './norad_base.rb'
require './norad_sgp4.rb'
require './norad_sdp4.rb'
require './eci.rb'
require './site.rb'
require './tle.rb'
require './orbit.rb'
require './vector.rb'
require 'pp'
require 'date'

# def PrintPosVel(Tle tle)
#    const int Step = 360;
#
#    Orbit     orbit  = new Orbit(tle);
#    List<Eci> coords = new List<Eci>();
#
#    # Calculate position, velocity
#    # mpe = "minutes past epoch"
#    for (int mpe = 0; mpe <= (Step * 4); mpe += Step)
#    {
#       # Get the position of the satellite at time "mpe".
#       # The coordinates are placed into the variable "eci".
#       Eci eci = orbit.GetPosition(mpe);
#
#       # Add the coordinate object to the list
#       coords.Add(eci);
#    }
#
#    # Print TLE data
#    Console.Write("{0}\n", tle.Name);
#    Console.Write("{0}\n", tle.Line1);
#    Console.Write("{0}\n", tle.Line2);
#
#    # Header
#    Console.Write("\n  TSINCE            X                Y                Z\n\n");
#
#    # Iterate over each of the ECI position objects pushed onto the
#    # coordinate list, above, printing the ECI position information
#    # as we go.
#    for (int i = 0; i < coords.Count; i++)
#    {
#       Eci e = coords[i] as Eci;
#
#       Console.Write("{0,8}.00 {1,16:f8} {2,16:f8} {3,16:f8}\n",
#                     i * Step,
#                     e.Position.X,
#                     e.Position.Y,
#                     e.Position.Z);
#    }
#
#    Console.Write("\n                  XDOT             YDOT             ZDOT\n\n");
#
#    # Iterate over each of the ECI position objects in the coordinate
#    # list again, but this time print the velocity information.
#    for (int i = 0; i < coords.Count; i++)
#    {
#       Eci e = coords[i] as Eci;
#
#       Console.Write("{0,24:f8} {1,16:f8} {2,16:f8}\n",
#                     e.Velocity.X,
#                     e.Velocity.Y,
#                     e.Velocity.Z);
#    }
# end


tle_string  = "OSCAR 3\n"
tle_string += "1 01293U 65016F   12263.95608778 +.00000319 +00000-0 +23014-3 0 04606\n"
tle_string += "2 01293 070.0701 117.1490 0017260 014.5647 345.5955 14.05174409427057"

tle1 = Tle.new(tle_string)

#puts tle1

# PrintPosVel(tle1);

# puts ""

# Test SDP4
# tle_string =  "AO-7\n"
# tle_string += "1 07530U 74089B   12263.39564296 -.00000027  00000-0  10000-3 0  4844\n"
# tle_string += "2 07530 101.4097 256.9929 0012088  96.9320 263.3131 12.53591429731853"

tle2 = Tle.new(tle_string)

# pp tle2
# puts "Epoch: #{tle2.epoch}"
# puts "Now: #{Time.now}"

diff = ( Time.new.to_i - tle2.epoch.to_i ) / 60.0

# puts "Diff: #{diff}"

# PrintPosVel(tle2);

#puts "\nExample output:"

# Example: Define a location on the earth, then determine the look-angle
# to the SDP4 satellite defined above.

# Create an orbit object using the SDP4 TLE object.
orbitSDP4 = Orbit.new(tle2)

# pp orbitSDP4

# Get the location of the satellite from the Orbit object. The
# earth-centered inertial information is placed into eciSDP4.
# Here we ask for the location of the satellite 90 minutes after
# the TLE epoch.
eciSDP4 = orbitSDP4.get_position( diff )

eciGeo = eciSDP4.to_geo
#pp eciSDP4

sat_lat = OrbitGlobals.rad_to_deg( eciGeo.latitude_rad )
sat_lon = OrbitGlobals.rad_to_deg( eciGeo.longitude_rad )
sat_alt = eciGeo.altitude

if sat_lon > 180
  sat_lon = 360 - sat_lon
  sat_lon *= -1
end

puts "Sat Lat: #{sat_lat }"
puts "Sat Lon: #{sat_lon}"
puts "Sat Ele: #{sat_alt}"

# Now create a site object. Site objects represent a location on the
# surface of the earth. Here we arbitrarily select a point on the
# equator.
site_me = Site.new(33.5, -112.05, 380) # 0.00 N, 100.00 W, 0 km altitude

# pp site_me.get_position( eciSDP4.date )

# Now get the "look angle" from the site to the satellite.
# Note that the ECI object "eciSDP4" has a time associated
# with the coordinates it contains; this is the time at which
# the look angle is valid.
topoLook = site_me.get_look_angle(eciSDP4)

# pp topoLook

# Print out the results. Note that the Azimuth and Elevation are
# stored in the CoordTopo object as radians. Here we convert
# to degrees using Rad2Deg()

puts "AZ: #{OrbitGlobals.rad_to_deg(topoLook.azimuth).to_f}  EL: #{OrbitGlobals.rad_to_deg(topoLook.elevation).to_f}"