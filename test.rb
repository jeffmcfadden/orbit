require './lib/orbit/planet'

earth = Orbit::Planet.earth
mars  = Orbit::Planet.mars

mercury = Orbit::Planet.mercury
venus = Orbit::Planet.venus
jupiter = Orbit::Planet.jupiter
saturn = Orbit::Planet.saturn

t = Time.now - (86400 * 4)

puts "Mercury:"
puts mercury.position_at_time( t )
puts ""

puts "Venus:"
puts venus.position_at_time( t )
puts ""

puts "Earth:"
puts earth.position_at_time( t )
puts ""

puts "Mars:"
puts mars.position_at_time( t )
puts ""

puts "Jupiter:"
puts jupiter.position_at_time( t )
puts ""

puts "Saturn:"
puts saturn.position_at_time( t )
puts ""