# http://space.stackexchange.com/questions/8911/determining-orbital-position-at-a-future-point-in-time

# =====================================================================
#   These data are to be used as described in the related document
#   titled "Keplerian Elements for Approximate Positions of the
#   Major Planets" by E.M. Standish (JPL/Caltech) available from
#   the JPL Solar System Dynamics web site (http://ssd.jpl.nasa.gov/).
# =====================================================================
# 
# 
# Table 1.
# 
# Keplerian elements and their rates, with respect to the mean ecliptic
# and equinox of J2000, valid for the time-interval 1800 AD - 2050 AD.
# 
#                a              e               I                L            long.peri.      long.node.
#            AU, AU/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
# -----------------------------------------------------------------------------------------------------------
# Mercury   0.38709927      0.20563593      7.00497902      252.25032350     77.45779628     48.33076593
#           0.00000037      0.00001906     -0.00594749   149472.67411175      0.16047689     -0.12534081
# Venus     0.72333566      0.00677672      3.39467605      181.97909950    131.60246718     76.67984255
#           0.00000390     -0.00004107     -0.00078890    58517.81538729      0.00268329     -0.27769418
# EM Bary   1.00000261      0.01671123     -0.00001531      100.46457166    102.93768193      0.0
#           0.00000562     -0.00004392     -0.01294668    35999.37244981      0.32327364      0.0
# Mars      1.52371034      0.09339410      1.84969142       -4.55343205    -23.94362959     49.55953891
#           0.00001847      0.00007882     -0.00813131    19140.30268499      0.44441088     -0.29257343
# Jupiter   5.20288700      0.04838624      1.30439695       34.39644051     14.72847983    100.47390909
#          -0.00011607     -0.00013253     -0.00183714     3034.74612775      0.21252668      0.20469106
# Saturn    9.53667594      0.05386179      2.48599187       49.95424423     92.59887831    113.66242448
#          -0.00125060     -0.00050991      0.00193609     1222.49362201     -0.41897216     -0.28867794
# Uranus   19.18916464      0.04725744      0.77263783      313.23810451    170.95427630     74.01692503
#          -0.00196176     -0.00004397     -0.00242939      428.48202785      0.40805281      0.04240589
# Neptune  30.06992276      0.00859048      1.77004347      -55.12002969     44.96476227    131.78422574
#           0.00026291      0.00005105      0.00035372      218.45945325     -0.32241464     -0.00508664
# Pluto    39.48211675      0.24882730     17.14001206      238.92903833    224.06891629    110.30393684
#          -0.00031596      0.00005170      0.00004818      145.20780515     -0.04062942     -0.01183482

# http://www.stjarnhimlen.se/comp/ppcomp.html#7

# You can verify the current positions here: http://cosinekitty.com/solar_system.html

class Numeric
  def degrees
    self * Math::PI / 180.0
  end
end

module Orbit
  class Planet
    
    attr_accessor :semimajor_axis_initial
    attr_accessor :semimajor_axis_rate_of_change
    
    attr_accessor :eccentricity_initial
    attr_accessor :eccentricity_rate_of_change
    
    attr_accessor :inclination_initial
    attr_accessor :inclination_rate_of_change
    
    attr_accessor :mean_longitude_initial
    attr_accessor :mean_longitude_rate_of_change
    
    attr_accessor :longitude_of_periapsis_initial
    attr_accessor :longitude_of_periapsis_rate_of_change
    
    attr_accessor :longitude_of_ascending_node_initial
    attr_accessor :longitude_of_ascending_node_rate_of_change
    
    attr_accessor :additional_term_b
    attr_accessor :additional_term_c
    attr_accessor :additional_term_s
    attr_accessor :additional_term_f

    def semimajor_axis
      semimajor_axis_initial + semimajor_axis_rate_of_change * @centuries_since_j2000
    end

    def eccentricity
      eccentricity_initial + eccentricity_rate_of_change * @centuries_since_j2000
    end

    def inclination
      inclination_initial + inclination_rate_of_change * @centuries_since_j2000
    end
    
    def mean_longitude
      mean_longitude = mean_longitude_initial + mean_longitude_rate_of_change * @centuries_since_j2000
      
      if !additional_term_b.nil?
        mean_longitude += additional_term_b * (@centuries_since_j2000 ** 2)
      end
      
      if !additional_term_c.nil?
        mean_longitude += additional_term_c * Math.cos(additional_term_f * @centuries_since_j2000)
      end
      
      if !additional_term_s.nil?
        mean_longitude += additional_term_s * Math.sin(additional_term_f * @centuries_since_j2000)
      end
      
      mean_longitude
    end

    def set_longitude_of_periapsis
      @longitude_of_periapsis = longitude_of_periapsis_initial + longitude_of_periapsis_rate_of_change * @centuries_since_j2000
    end

    def set_longitude_of_ascending_node
      @longitude_of_ascending_node = longitude_of_ascending_node_initial + longitude_of_ascending_node_rate_of_change * @centuries_since_j2000
    end
    
    def set_centuries_since_j2000
      seconds_since_j2000   = @time.utc - Orbit::Epoch::J2000
      @centuries_since_j2000 = seconds_since_j2000 / (60*60*24*365.2422*100).to_f
    end

    
    def initialize( name: "", 
      semimajor_axis_initial: 0, 
      semimajor_axis_rate_of_change: 0, 
      eccentricity_initial: 0, 
      eccentricity_rate_of_change: 0,
      inclination_initial: 0, 
      inclination_rate_of_change: 0,
      mean_longitude_initial: 0,
      mean_longitude_rate_of_change: 0,
      longitude_of_periapsis_initial: 0,
      longitude_of_periapsis_rate_of_change: 0,
      longitude_of_ascending_node_initial: 0,
      longitude_of_ascending_node_rate_of_change: 0,
      additional_term_b: nil,
      additional_term_c: nil,
      additional_term_s: nil,
      additional_term_f: nil )
      
      self.semimajor_axis_initial                      = semimajor_axis_initial
      self.semimajor_axis_rate_of_change               = semimajor_axis_rate_of_change
                                                   
      self.eccentricity_initial                        = eccentricity_initial
      self.eccentricity_rate_of_change                 = eccentricity_rate_of_change
                                                  
      self.inclination_initial                         = inclination_initial
      self.inclination_rate_of_change                  = inclination_rate_of_change
                                                  
      self.mean_longitude_initial                      = mean_longitude_initial
      self.mean_longitude_rate_of_change               = mean_longitude_rate_of_change
                                                  
      self.longitude_of_periapsis_initial              = longitude_of_periapsis_initial
      self.longitude_of_periapsis_rate_of_change       = longitude_of_periapsis_rate_of_change
                                                  
      self.longitude_of_ascending_node_initial         = longitude_of_ascending_node_initial
      self.longitude_of_ascending_node_rate_of_change  = longitude_of_ascending_node_rate_of_change
                                                  
      self.additional_term_b                           = additional_term_b
      self.additional_term_c                           = additional_term_c
      self.additional_term_s                           = additional_term_s
      self.additional_term_f                           = additional_term_f    
    end
    
    def position
      position_at_time( Time.now )
    end
    
    def position_at_time( t )
      @time = t
      
      set_centuries_since_j2000
      set_longitude_of_periapsis
      set_longitude_of_ascending_node
      
      # # puts "semimajor_axis_initial                     : #{semimajor_axis_initial                    }"
      # # puts "semimajor_axis_rate_of_change              : #{semimajor_axis_rate_of_change             }"
      # # puts "eccentricity_initial                       : #{eccentricity_initial                      }"
      # # puts "eccentricity_rate_of_change                : #{eccentricity_rate_of_change               }"
      # # puts "inclination_initial                        : #{inclination_initial                       }"
      # # puts "inclination_rate_of_change                 : #{inclination_rate_of_change                }"
      # # puts "mean_longitude_initial                     : #{mean_longitude_initial                    }"
      # # puts "mean_longitude_rate_of_change              : #{mean_longitude_rate_of_change             }"
      # # puts "longitude_of_periapsis_initial             : #{longitude_of_periapsis_initial            }"
      # # puts "longitude_of_periapsis_rate_of_change      : #{longitude_of_periapsis_rate_of_change     }"
      # # puts "longitude_of_ascending_node_initial        : #{longitude_of_ascending_node_initial       }"
      # # puts "longitude_of_ascending_node_rate_of_change : #{longitude_of_ascending_node_rate_of_change}"

      # # puts "additional_term_b                          : #{additional_term_b                         }"
      # # puts "additional_term_c                          : #{additional_term_c                         }"
      # # puts "additional_term_s                          : #{additional_term_s                         }"
      # # puts "additional_term_f                          : #{additional_term_f                         }"
      
      argument_of_periapsis = @longitude_of_periapsis - @longitude_of_ascending_node
      
      mean_anomaly          = mean_longitude - @longitude_of_periapsis
      
      mean_anomaly = mean_anomaly % 360 # if mean_anomaly > 360
        
      # puts "eccentricity: #{eccentricity}"
      # puts "inclination: #{inclination}"
      # puts "longitude_of_periapsis: #{longitude_of_periapsis}"
      
      # puts "mean_anomaly: #{mean_anomaly}"
      
      # puts "longitude_of_periapsis: #{longitude_of_periapsis}"
      # puts "longitude_of_ascending_node: #{longitude_of_ascending_node}"
      # puts "argument_of_periapsis: #{argument_of_periapsis}"
      
      # Solve kepler's equation:
      mean_anomaly = mean_anomaly.degrees
      kepler_E = mean_anomaly.degrees
      
      kepler_E = mean_anomaly + eccentricity * Math.sin(mean_anomaly) * (1.0 + eccentricity * Math.cos(mean_anomaly))
      dE = 1
      n  = 0
      while dE.abs > 1e-8 && n < 5 do
        
        new_E = kepler_E - ( kepler_E - eccentricity * Math.sin(kepler_E) - mean_anomaly ) / ( 1.0 - eccentricity * Math.cos(kepler_E) )
        
        dE = kepler_E - new_E
        
        kepler_E = new_E
        n += 1
        
        # delta_M = mean_anomaly - (e_n - (e_star * Math.sin(e_n)))
        # delta_E = delta_M / (1 - eccentricity * Math.cos(e_n))
        # e_n_next = e_n + delta_E
      end
      
      # puts "n: #{n}"
      
      
      
      # pi = Math::PI
#       k = pi / 180.0
#       maxIter = 30
#       i = 0
#       m = mean_anomaly / 360
#       m = 2.0 * pi * ( m - m.floor )
#       delta = 1e-6
#       kepler_E = m
#
#       kepler_f = kepler_E - eccentricity * Math.sin(m) - m
#
#
#       while( kepler_f.abs > delta && i < maxIter ) do
#         # dE = (kepler_E - eccentricity * Math.sin(kepler_E) - mean_anomaly)/(1.0 - eccentricity * Math.cos(kepler_E))
#         #
#         # kepler_E -= dE
#         # if( (dE).abs < 1e-6 )
#         #   break
#         # end
#
#         kepler_E = kepler_E - kepler_f/(1.0-eccentricity*Math.cos(kepler_E))
#         kepler_f = kepler_E - eccentricity*Math.sin(kepler_E) - m
#
#         i += 1
#       end
      

      k = Math::PI / 180.0
      s = Math.sin( kepler_E )
      c = Math.cos( kepler_E )
      fak=Math.sqrt(1.0 - (eccentricity * eccentricity) )
      true_anomaly=Math.atan2(fak*s,c-eccentricity) / k
      
      # puts "mean_anomaly: #{mean_anomaly}"
      # puts "true_anomaly: #{true_anomaly}"
      
      # kepler_E=kepler_E/k
      
      # puts "kepler_E: #{kepler_E}"
      # puts "should be mean anomaly: #{kepler_E - (e_star * Math.sin(kepler_E))}"

      x_prime = semimajor_axis * (Math.cos(kepler_E) - eccentricity)
      y_prime = semimajor_axis * Math.sqrt(1.0 - (eccentricity * eccentricity)) * Math.sin(kepler_E)
      
      ⍵ = argument_of_periapsis.degrees
      ☊ = @longitude_of_ascending_node.degrees
      i = inclination.degrees
      
      
      
      x = (x_prime * ((Math.cos(⍵) * Math.cos(☊)) - (Math.sin(⍵) * Math.sin(☊) * Math.cos(i)))) + (y_prime * ((-1 * Math.sin(⍵) * Math.cos(☊)) - (Math.cos(⍵) * Math.sin(☊) * Math.cos(i))))
      y = (x_prime * ((Math.cos(⍵) * Math.sin(☊)) + (Math.sin(⍵) * Math.cos(☊) * Math.cos(i)))) + (y_prime * ((-1 * Math.sin(⍵) * Math.sin(☊)) + (Math.cos(⍵) * Math.cos(☊) * Math.cos(i))))
      z = (x_prime * Math.sin(⍵) * Math.sin(i)) + (y_prime * Math.cos(⍵) * Math.sin(i))
            
      { x: x, y: y, z: z }
    end    
    
    def self.planet_from_elements( rows: (4..5), additional_terms_rows: nil, year: Time.now.utc.year )
      
      if year >= 1800 && year <= 2050
        data = self.jpl_elements_1800_2050
        elements = data[:elements]
        additional_terms = data[:additional_terms]
      else
        data = self.jpl_elements_3000bc_3000
        elements = data[:elements]
        additional_terms = data[:additional_terms]
      end
      
      orbit_data = elements.split( "\n" )[rows].collect{ |r| r.split( " " ) }.flatten
      
      if orbit_data[0] == "EM"
        orbit_data[0] = "Earth"
        orbit_data.delete_at(1)
      end
      
      # ["EM Bary", "1.00000018", "0.01673163", "-0.00054346", "100.46691572", "102.93005885", "-5.11260389", "-0.00000003", "-0.00003661", "-0.01337178", "35999.37306329", "0.31795260", "-0.24123856"]
      
      additional_terms_data = []
      if !additional_terms.nil?
        additional_terms_data = additional_terms.split( "\n" ).select{ |r| r.split( " ")[0] == orbit_data[0] }.first.split( " " ).inject( &:to_f )
      end
      
      ::Orbit::Planet.new( 
        name: orbit_data[0],
        semimajor_axis_initial:                     orbit_data[1].to_f, 
        semimajor_axis_rate_of_change:              orbit_data[7].to_f, 
        eccentricity_initial:                       orbit_data[2].to_f, 
        eccentricity_rate_of_change:                orbit_data[8].to_f, 
        inclination_initial:                        orbit_data[3].to_f, 
        inclination_rate_of_change:                 orbit_data[9].to_f, 
        mean_longitude_initial:                     orbit_data[4].to_f, 
        mean_longitude_rate_of_change:              orbit_data[10].to_f, 
        longitude_of_periapsis_initial:             orbit_data[5].to_f, 
        longitude_of_periapsis_rate_of_change:      orbit_data[11].to_f, 
        longitude_of_ascending_node_initial:        orbit_data[6].to_f, 
        longitude_of_ascending_node_rate_of_change: orbit_data[12].to_f, 
        additional_term_b: additional_terms_data[1],
        additional_term_c: additional_terms_data[2],
        additional_term_s: additional_terms_data[3],
        additional_term_f: additional_terms_data[4]
      )
    end
    
    def self.mercury( year: Time.now.utc.year )
      self.planet_from_elements( rows: (0..1), additional_terms_rows: nil, year: year )
    end
    
    def self.venus( year: Time.now.utc.year )
      self.planet_from_elements( rows: (2..3), additional_terms_rows: nil, year: year )
    end
    
    def self.earth( year: Time.now.utc.year )
      self.planet_from_elements( rows: (4..5), additional_terms_rows: nil, year: year )
    end

    def self.mars( year: Time.now.utc.year )
      self.planet_from_elements( rows: (6..7), additional_terms_rows: nil, year: year )
    end
    
    def self.jupiter( year: Time.now.utc.year )
      self.planet_from_elements( rows: (8..9), additional_terms_rows: nil, year: year )
    end
    
    def self.saturn( year: Time.now.utc.year )
      self.planet_from_elements( rows: (10..11), additional_terms_rows: nil, year: year )
    end

    def self.uranus( year: Time.now.utc.year )
      self.planet_from_elements( rows: (12..13), additional_terms_rows: nil, year: year )
    end

    def self.neptune( year: Time.now.utc.year )
      self.planet_from_elements( rows: (14..15), additional_terms_rows: nil, year: year )
    end

    def self.pluto( year: Time.now.utc.year )
      self.planet_from_elements( rows: (16..17), additional_terms_rows: nil, year: year )
    end
    
      
    def self.jpl_elements_1800_2050
      # =====================================================================
      #   These data are to be used as described in the related document
      #   titled "Keplerian Elements for Approximate Positions of the
      #   Major Planets" by E.M. Standish (JPL/Caltech) available from
      #   the JPL Solar System Dynamics web site (http://ssd.jpl.nasa.gov/).
      # =====================================================================
      # 
      # 
      # Table 1.
      # 
      # Keplerian elements and their rates, with respect to the mean ecliptic
      # and equinox of J2000, valid for the time-interval 1800 AD - 2050 AD.

      #                a              e               I                L            long.peri.      long.node.
      #            AU, AU/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
      # -----------------------------------------------------------------------------------------------------------
      
elements = <<-EOF
Mercury   0.38709927      0.20563593      7.00497902      252.25032350     77.45779628     48.33076593
          0.00000037      0.00001906     -0.00594749   149472.67411175      0.16047689     -0.12534081
Venus     0.72333566      0.00677672      3.39467605      181.97909950    131.60246718     76.67984255
          0.00000390     -0.00004107     -0.00078890    58517.81538729      0.00268329     -0.27769418
EM Bary   1.00000261      0.01671123     -0.00001531      100.46457166    102.93768193      0.0
          0.00000562     -0.00004392     -0.01294668    35999.37244981      0.32327364      0.0
Mars      1.52371034      0.09339410      1.84969142       -4.55343205    -23.94362959     49.55953891
          0.00001847      0.00007882     -0.00813131    19140.30268499      0.44441088     -0.29257343
Jupiter   5.20288700      0.04838624      1.30439695       34.39644051     14.72847983    100.47390909
         -0.00011607     -0.00013253     -0.00183714     3034.74612775      0.21252668      0.20469106
Saturn    9.53667594      0.05386179      2.48599187       49.95424423     92.59887831    113.66242448
         -0.00125060     -0.00050991      0.00193609     1222.49362201     -0.41897216     -0.28867794
Uranus   19.18916464      0.04725744      0.77263783      313.23810451    170.95427630     74.01692503
         -0.00196176     -0.00004397     -0.00242939      428.48202785      0.40805281      0.04240589
Neptune  30.06992276      0.00859048      1.77004347      -55.12002969     44.96476227    131.78422574
          0.00026291      0.00005105      0.00035372      218.45945325     -0.32241464     -0.00508664
Pluto    39.48211675      0.24882730     17.14001206      238.92903833    224.06891629    110.30393684
         -0.00031596      0.00005170      0.00004818      145.20780515     -0.04062942     -0.01183482
EOF

      return { elements: elements, additional_terms: nil }
    end

    def self.jpl_elements_3000bc_3000
      # =====================================================================
      #   These data are to be used as described in the related document
      #   titled "Keplerian Elements for Approximate Positions of the
      #   Major Planets" by E.M. Standish (JPL/Caltech) available from
      #   the JPL Solar System Dynamics web site (http://ssd.jpl.nasa.gov/).
      # =====================================================================
      # 
      # 
      # Table 2a.
      # 
      # Keplerian elements and their rates, with respect to the mean ecliptic and equinox of J2000,
      # valid for the time-interval 3000 BC -- 3000 AD.  NOTE: the computation of M for Jupiter through
      # Pluto *must* be augmented by the additional terms given in Table 2b (below).
      
      #...

      # Table 2b.
      # 
      # Additional terms which must be added to the computation of M
      # for Jupiter through Pluto, 3000 BC to 3000 AD, as described
      # in the related document.
      
      #                a              e               I                L            long.peri.      long.node.
      #            AU, AU/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
      # -----------------------------------------------------------------------------------------------------------

elements = <<-EOF1
Mercury   0.38709843      0.20563661      7.00559432      252.25166724     77.45771895     48.33961819
          0.00000000      0.00002123     -0.00590158   149472.67486623      0.15940013     -0.12214182
Venus     0.72332102      0.00676399      3.39777545      181.97970850    131.76755713     76.67261496
         -0.00000026     -0.00005107      0.00043494    58517.81560260      0.05679648     -0.27274174
EM Bary   1.00000018      0.01673163     -0.00054346      100.46691572    102.93005885     -5.11260389
         -0.00000003     -0.00003661     -0.01337178    35999.37306329      0.31795260     -0.24123856
Mars      1.52371243      0.09336511      1.85181869       -4.56813164    -23.91744784     49.71320984
          0.00000097      0.00009149     -0.00724757    19140.29934243      0.45223625     -0.26852431
Jupiter   5.20248019      0.04853590      1.29861416       34.33479152     14.27495244    100.29282654
         -0.00002864      0.00018026     -0.00322699     3034.90371757      0.18199196      0.13024619
Saturn    9.54149883      0.05550825      2.49424102       50.07571329     92.86136063    113.63998702
         -0.00003065     -0.00032044      0.00451969     1222.11494724      0.54179478     -0.25015002
Uranus   19.18797948      0.04685740      0.77298127      314.20276625    172.43404441     73.96250215
         -0.00020455     -0.00001550     -0.00180155      428.49512595      0.09266985      0.05739699
Neptune  30.06952752      0.00895439      1.77005520      304.22289287     46.68158724    131.78635853
          0.00006447      0.00000818      0.00022400      218.46515314      0.01009938     -0.00606302
Pluto    39.48686035      0.24885238     17.14104260      238.96535011    224.09702598    110.30167986
          0.00449751      0.00006016      0.00000501      145.18042903     -0.00968827     -0.00809981
EOF1

additional_terms = <<-EOF2
Jupiter   -0.00012452    0.06064060   -0.35635438   38.35125000
Saturn     0.00025899   -0.13434469    0.87320147   38.35125000
Uranus     0.00058331   -0.97731848    0.17689245    7.67025000
Neptune   -0.00041348    0.68346318   -0.10162547    7.67025000
Pluto     -0.01262724
EOF2

      return { elements: elements, additional_terms: additional_terms }
    end
  end
end