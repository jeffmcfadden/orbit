require 'orbit/orbit_globals'
require 'orbit/geocentric_coordinates'
require 'orbit/topocentric_horizon_coordinates'
require 'orbit/julian'
require 'orbit/norad_base'
require 'orbit/norad_sgp4'
require 'orbit/norad_sdp4'
require 'orbit/eci'
require 'orbit/epoch'
require 'orbit/site'
require 'orbit/satellite'
require 'orbit/tle'
require 'orbit/orbit'
require 'orbit/planet'
require 'orbit/vector'
require 'date'

module Orbit

end

# Testing
# tle_string = "CUBESAT XI-V (CO-58)\n1 28895U 05043F   12264.16320281  .00000287  00000-0  67805-4 0  2813\n2 28895  97.9003 126.1967 0016829 209.8455 150.1749 14.60744896367522"
#
# tle = Orbit::Tle.new( tle_string )
# o   = Orbit::Orbit.new( tle )
# eci = o.get_position( ( Time.new.utc.to_f - tle.epoch.to_f ) / 60.0 )
# puts eci
# puts eci.to_geo