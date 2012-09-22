module Orbit
  class NoradBase

    attr_accessor :m_satInc  # inclination
    attr_accessor :m_satEcc  # eccentricity

    attr_accessor :m_cosio
    attr_accessor :m_betao2
    attr_accessor :m_s4
    attr_accessor :m_eta
    attr_accessor :m_coef1
    attr_accessor :m_sinio
    attr_accessor :m_xnodot
    attr_accessor :m_aycof

    attr_accessor :m_eosq
    attr_accessor :m_xnodp
    attr_accessor :m_tsi
    attr_accessor :m_coef
    attr_accessor :m_c4
    attr_accessor :m_omgdot
    attr_accessor :m_xlcof
    attr_accessor :m_x3thm1
    attr_accessor :m_aodp
    attr_accessor :m_perigee
    attr_accessor :m_eeta
    attr_accessor :m_c3
    attr_accessor :m_xmdot
    attr_accessor :m_t2cof
    attr_accessor :m_theta2
    attr_accessor :m_betao
    attr_accessor :m_qoms24
    attr_accessor :m_etasq
    attr_accessor :m_c1
    attr_accessor :m_x1mth2
    attr_accessor :m_xnodcf
    attr_accessor :m_x7thm1

    def initialize( nothing )
       # Initialize any variables which are time-independent when
       # calculating the ECI coordinates of the satellite.
       @m_satInc = @orbit.inclination
       @m_satEcc = @orbit.eccentricity

       @m_cosio  = Math.cos(@m_satInc)
       @m_theta2 = @m_cosio * @m_cosio
       @m_x3thm1 = 3.0 * @m_theta2 - 1.0
       @m_eosq   = @m_satEcc * @m_satEcc
       @m_betao2 = 1.0 - @m_eosq
       @m_betao  = Math.sqrt(@m_betao2)

       # The "recovered" semimajor axis and mean motion.
       @m_aodp  = @orbit.semi_major
       @m_xnodp = @orbit.mean_motion

       # For perigee below 156 km, the values of OrbitGlobals::S and OrbitGlobals::QOMS2T are altered.
       @m_perigee = OrbitGlobals::XKMPER * (@m_aodp * (1.0 - @m_satEcc) - OrbitGlobals::AE)

       @m_s4      = OrbitGlobals::S
       @m_qoms24  = OrbitGlobals::QOMS2T

       if (@m_perigee < 156.0)
          @m_s4 = @m_perigee - 78.0

          if (@m_perigee <= 98.0)
             @m_s4 = 20.0
           end

          @m_qoms24 = (((120.0 - @m_s4) * OrbitGlobals::AE / OrbitGlobals::XKMPER ) ** 4.0)
          @m_s4 = @m_s4 / OrbitGlobals::XKMPER + OrbitGlobals::AE
        end

       pinvsq = 1.0 / (@m_aodp * @m_aodp * @m_betao2 * @m_betao2)

       @m_tsi   = 1.0 / (@m_aodp - @m_s4)
       @m_eta   = @m_aodp * @m_satEcc * @m_tsi
       @m_etasq = @m_eta * @m_eta
       @m_eeta  = @m_satEcc * @m_eta

       psisq  = (1.0 - @m_etasq).abs

       @m_coef  = @m_qoms24 * (@m_tsi ** 4.0)
       @m_coef1 = @m_coef / (psisq ** 3.5)

       c2 = @m_coef1 * @m_xnodp *
                   (@m_aodp * (1.0 + 1.5 * @m_etasq + @m_eeta * (4.0 + @m_etasq)) +
                   0.75 * OrbitGlobals::CK2 * @m_tsi / psisq * @m_x3thm1 *
                   (8.0 + 3.0 * @m_etasq * (8.0 + @m_etasq)))

       @m_c1    = @orbit.bstar * c2
       @m_sinio = Math.sin(@m_satInc)

       a3ovk2 = -OrbitGlobals::XJ3 / OrbitGlobals::CK2 * (OrbitGlobals::AE ** 3.0)

       @m_c3     = @m_coef * @m_tsi * a3ovk2 * @m_xnodp * OrbitGlobals::AE * @m_sinio / @m_satEcc
       @m_x1mth2 = 1.0 - @m_theta2
       @m_c4     = 2.0 * @m_xnodp * @m_coef1 * @m_aodp * @m_betao2 *
                  (@m_eta * (2.0 + 0.5 * @m_etasq) +
                  @m_satEcc * (0.5 + 2.0 * @m_etasq) -
                  2.0 * OrbitGlobals::CK2 * @m_tsi / (@m_aodp * psisq) *
                  (-3.0 * @m_x3thm1 * (1.0 - 2.0 * @m_eeta + @m_etasq * (1.5 - 0.5 * @m_eeta)) +
                  0.75 * @m_x1mth2 *
                  (2.0 * @m_etasq - @m_eeta * (1.0 + @m_etasq)) *
                  Math.cos(2.0 * @orbit.arg_perigee)))

       theta4 = @m_theta2 * @m_theta2
       temp1  = 3.0 * OrbitGlobals::CK2 * pinvsq * @m_xnodp
       temp2  = temp1 * OrbitGlobals::CK2 * pinvsq
       temp3  = 1.25 * OrbitGlobals::CK4 * pinvsq * pinvsq * @m_xnodp

       @m_xmdot = @m_xnodp + 0.5 * temp1 * @m_betao * @m_x3thm1 +
                 0.0625 * temp2 * @m_betao *
                 (13.0 - 78.0 * @m_theta2 + 137.0 * theta4)

       x1m5th = 1.0 - 5.0 * @m_theta2

       @m_omgdot = -0.5 * temp1 * x1m5th + 0.0625 * temp2 *
                  (7.0 - 114.0 * @m_theta2 + 395.0 * theta4) +
                  temp3 * (3.0 - 36.0 * @m_theta2 + 49.0 * theta4)

       xhdot1 = -temp1 * @m_cosio

       @m_xnodot = xhdot1 + (0.5 * temp2 * (4.0 - 19.0 * @m_theta2) +
                  2.0 * temp3 * (3.0 - 7.0 * @m_theta2)) * @m_cosio
       @m_xnodcf = 3.5 * @m_betao2 * xhdot1 * @m_c1
       @m_t2cof  = 1.5 * @m_c1
       @m_xlcof  = 0.125 * a3ovk2 * @m_sinio *
                  (3.0 + 5.0 * @m_cosio) / (1.0 + @m_cosio)
       @m_aycof  = 0.25 * a3ovk2 * @m_sinio
       @m_x7thm1 = 7.0 * @m_theta2 - 1.0
     end

    def final_position( incl, omega,      e,
                                    a,    xl,  xnode,
                                   xn, tsince)
       if (e * e) > 1.0
         Exception.new( "Error in satellite data" )
          #throw new PropagationException("Error in satellite data")
        end

       beta = Math.sqrt(1.0 - e * e)

       # Long period periodics
       axn  = e * Math.cos(omega)
       temp = 1.0 / (a * beta * beta)
       xll  = temp * @m_xlcof * axn
       aynl = temp * @m_aycof
       xlt  = xl + xll
       ayn  = e * Math.sin(omega) + aynl

       # Solve Kepler's Equation
       capu   = OrbitGlobals::fmod2p(xlt - xnode)
       temp2  = capu
       temp3  = 0.0
       temp4  = 0.0
       temp5  = 0.0
       temp6  = 0.0
       sinepw = 0.0
       cosepw = 0.0

       fDone  = false
       i = 1
       while i <= 10 && !fDone do
       #for (int i = 1 (i <= 10) && !fDone i++)
          sinepw = Math.sin(temp2)
          cosepw = Math.cos(temp2)
          temp3 = axn * sinepw
          temp4 = ayn * cosepw
          temp5 = axn * cosepw
          temp6 = ayn * sinepw

          epw = (capu - temp4 + temp3 - temp2) /
                       (1.0 - temp5 - temp6) + temp2

          if ((epw - temp2).abs <= 1.0e-06)
            fDone = true
          else
           temp2 = epw
          end

          i += 1
        end

       # Short period preliminary quantities
       ecose = temp5 + temp6
       esine = temp3 - temp4
       elsq  = axn * axn + ayn * ayn
       temp  = 1.0 - elsq
       pl = a * temp
       r  = a * (1.0 - ecose)
       temp1 = 1.0 / r
       rdot  = OrbitGlobals::XKE * Math.sqrt(a) * esine * temp1
       rfdot = OrbitGlobals::XKE * Math.sqrt(pl) * temp1
       temp2 = a * temp1
       betal = Math.sqrt(temp)
       temp3 = 1.0 / (1.0 + betal)
       cosu  = temp2 * (cosepw - axn + ayn * esine * temp3)
       sinu  = temp2 * (sinepw - ayn - axn * esine * temp3)
       u     = OrbitGlobals.actan(sinu, cosu)
       sin2u = 2.0 * sinu * cosu
       cos2u = 2.0 * cosu * cosu - 1.0

       temp  = 1.0 / pl
       temp1 = OrbitGlobals::CK2 * temp
       temp2 = temp1 * temp

       # Update for short periodics
       rk = r * (1.0 - 1.5 * temp2 * betal * @m_x3thm1) +
                   0.5 * temp1 * @m_x1mth2 * cos2u
       uk = u - 0.25 * temp2 * @m_x7thm1 * sin2u
       xnodek = xnode + 1.5 * temp2 * @m_cosio * sin2u
       xinck  = incl + 1.5 * temp2 * @m_cosio * @m_sinio * cos2u
       rdotk  = rdot - xn * temp1 * @m_x1mth2 * sin2u
       rfdotk = rfdot + xn * temp1 * (@m_x1mth2 * cos2u + 1.5 * @m_x3thm1)

       # Orientation vectors
       sinuk  = Math.sin(uk)
       cosuk  = Math.cos(uk)
       sinik  = Math.sin(xinck)
       cosik  = Math.cos(xinck)
       sinnok = Math.sin(xnodek)
       cosnok = Math.cos(xnodek)
       xmx = -sinnok * cosik
       xmy = cosnok * cosik
       ux  = xmx * sinuk + cosnok * cosuk
       uy  = xmy * sinuk + sinnok * cosuk
       uz  = sinik * sinuk
       vx  = xmx * cosuk - cosnok * sinuk
       vy  = xmy * cosuk - sinnok * sinuk
       vz  = sinik * cosuk

       # Position
       x = rk * ux
       y = rk * uy
       z = rk * uz

       vecPos = Vector.new(x, y, z)

       # puts "@orbit.epoch_time : #{@orbit.epoch_time}"

       gmt = @orbit.epoch_time  + ( tsince * 60.0 )

       # Validate on altitude
       altKm = (vecPos.magnitude * (OrbitGlobals::XKMPER / OrbitGlobals::AE))

       if (altKm < OrbitGlobals::XKMPER)
          Exception.new( "Decay Exception" )
          #throw new DecayException(gmt, @orbit.SatNameLong)
        end

       # Velocity
       xdot = rdotk * ux + rfdotk * vx
       ydot = rdotk * uy + rfdotk * vy
       zdot = rdotk * uz + rfdotk * vz

      vecVel = Vector.new(xdot, ydot, zdot)

       return Eci.new_with_pos_vel_gmt(vecPos, vecVel, gmt)
     end
  end
end