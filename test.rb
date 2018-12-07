require './lib/orbit/epoch'
require './lib/orbit/planet'
require 'benchmark'

earth = Orbit::Planet.earth
mars  = Orbit::Planet.mars

mercury = Orbit::Planet.mercury
venus   = Orbit::Planet.venus
jupiter = Orbit::Planet.jupiter
saturn  = Orbit::Planet.saturn
uranus  = Orbit::Planet.uranus
neptune = Orbit::Planet.neptune
pluto   = Orbit::Planet.pluto

ceres   = Orbit::Planet.new(  name: "Ceres", 
                              semimajor_axis_initial: 2.767880825324262, 
                              eccentricity_initial: 0.07568276766977486, 
                              inclination_initial: 10.59240162556512, 
                              mean_longitude_initial: (266.8015867367354 + 80.30985818155804 + 72.90778936046735),
                              longitude_of_periapsis_initial: (80.30985818155804 + 72.9077893604673),
                              longitude_of_ascending_node_initial: 80.30985818155804,
  )

t = Time.now

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

puts "Ceres:"
puts ceres.position_at_time( t )
puts ""


puts "Jupiter:"
puts jupiter.position_at_time( t )
puts ""

puts "Saturn:"
puts saturn.position_at_time( t )
puts ""

puts "Uranus:"
puts uranus.position_at_time( t )
puts ""

puts "Neptune:"
puts neptune.position_at_time( t )
puts ""

puts "Pluto:"
puts pluto.position_at_time( t )
puts ""


puts "Benchmarking position of earth 1000 times:"

Benchmark.bm do |x|
  x.report( "Earth's Position" ) { 10000.times{ earth.position } }
end

