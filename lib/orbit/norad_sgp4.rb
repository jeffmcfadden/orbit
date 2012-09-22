module Orbit
  class NoradSGP4 < NoradBase

    attr_accessor :orbit

    attr_accessor :m_c5
    attr_accessor :m_omgcof
    attr_accessor :m_xmcof
    attr_accessor :m_delmo
    attr_accessor :m_sinmo


    def initialize( orbit )
      @orbit = orbit

      super

      @m_c5     = 2.0 * @m_coef1 * @m_aodp * @m_betao2 *
                 (1.0 + 2.75 * (@m_etasq + @m_eeta) + @m_eeta * @m_etasq)
      @m_omgcof = orbit.bstar * @m_c3 * Math.cos(orbit.arg_perigee)
      @m_xmcof  = -(2.0 / 3.0) * @m_coef * orbit.bstar * OrbitGlobals::AE / @m_eeta
      @m_delmo  = ((1.0 + @m_eta * Math.cos(orbit.mean_anomaly) ) ** 3.0)
      @m_sinmo  = Math.sin(orbit.mean_anomaly)

    end

    def get_position(tsince)
      puts "get_position( #{tsince} )"

      # For @m_perigee less than 220 kilometers, the isimp flag is set and
      # the equations are truncated to linear variation in Math.Sqrt a and
      # quadratic variation in mean anomaly.  Also, the @m_c3 term, the
      # delta omega term, and the delta m term are dropped.
      isimp = false
      if ((@m_aodp * (1.0 - @m_satEcc) / OrbitGlobals::AE) < (220.0 / OrbitGlobals::XKMPER + OrbitGlobals::AE))
       isimp = true
      end

        d2 = 0.0
        d3 = 0.0
        d4 = 0.0

        t3cof = 0.0
        t4cof = 0.0
        t5cof = 0.0

        if (!isimp)
          c1sq = @m_c1 * @m_c1

          d2 = 4.0 * @m_aodp * @m_tsi * c1sq

          temp = d2 * @m_tsi * @m_c1 / 3.0

          d3 = (17.0 * @m_aodp + @m_s4) * temp
          d4 = 0.5 * temp * @m_aodp * @m_tsi *
            (221.0 * @m_aodp + 31.0 * @m_s4) * @m_c1
          t3cof = d2 + 2.0 * c1sq
          t4cof = 0.25 * (3.0 * d3 + @m_c1 * (12.0 * d2 + 10.0 * c1sq))
          t5cof = 0.2 * (3.0 * d4 + 12.0 * @m_c1 * d3 + 6.0 *
            d2 * d2 + 15.0 * c1sq * (2.0 * d2 + c1sq))
        end

        # Update for secular gravity and atmospheric drag.
        xmdf   = orbit.mean_anomaly + @m_xmdot * tsince
        omgadf = orbit.arg_perigee + @m_omgdot * tsince
        xnoddf = orbit.raan + @m_xnodot * tsince
        omega  = omgadf
        xmp    = xmdf
        tsq    = tsince * tsince
        xnode  = xnoddf + @m_xnodcf * tsq
        tempa  = 1.0 - @m_c1 * tsince
        tempe  = orbit.bstar * @m_c4 * tsince
        templ  = @m_t2cof * tsq

        if (!isimp)
           delomg = @m_omgcof * tsince
           delm = @m_xmcof * (((1.0 + @m_eta * Math.cos(xmdf) ) ** 3.0) - @m_delmo)
           temp = delomg + delm

           xmp = xmdf + temp
           omega = omgadf - temp

           tcube = tsq * tsince
           tfour = tsince * tcube

           tempa = tempa - d2 * tsq - d3 * tcube - d4 * tfour
           tempe = tempe + orbit.bstar * @m_c5 * (Math.sin(xmp) - @m_sinmo)
           templ = templ + t3cof * tcube + tfour * (t4cof + tsince * t5cof)
         end

        a  = @m_aodp * (tempa ** 2)
        e  = @m_satEcc - tempe


        xl = xmp + omega + xnode + @m_xnodp * templ
        xn = OrbitGlobals::XKE / (a ** 1.5)

        return final_position(@m_satInc, omgadf, e, a, xl, xnode, xn, tsince)
      end
  end
end