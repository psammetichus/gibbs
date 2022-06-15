module Electrodes

# we assume a spherical head model
# θ and ϕ are the colatitude (polar angle) and azimuth
#
# The head is a sphere with the nasion, inion, and preauricular points all on
# the equator
#
# we use degrees for simplicity, angles are (θ, ϕ), ranges are 0,180 for θ and
# -180 to 180 for ϕ with the left side of the head as negative azimuths
#
# Cz by definition is at (0,0)
# Nz is at (90,0)
# In is at (90,180)
# T9 is at (90,-90)
# T10 is at (90,90)
# 
# the entire inferior temporal set is on the equator
#
#
#


struct Electrode
  name :: string
  position :: Tuple{Float64,Float64}
end #struct

tenpctDeg = 0.1*180

twenpctDeg = 0.2 * 180

ifcn_electrodes = 
  Dict(
       "Cz" => (0,0),
       "Nz" => (+90,0),
       "In" => (+90,+180),
       "T9" => (+90,-90),
       "T10" => (+90,+90),
       "Fpz" => (90-tenpctDeg,0),
       "Fz" => (0+twenpctDeg, 0),
       "Pz" => (0+twenpctDeg, +180),
       "Oz" => (90-tenpctDeg, +180),
       "T7" => (90-tenpctDeg, -90),
       "T8" => (90-tenpctDeg, +90),
       "C3" => (0+twenpctDeg, -90),
       "C4" => (0+twenpctDeg, +90),
       "Fp1" => (0,0)
       "Fp2"=> (0,0)
       "F7"=> (0,0)
       "F8"=> (0,0)
       "F3"=> (0,0)
       "F4"=> (0,0)
       "P3"=> (0,0)
       "P4"=> (0,0)
       "O1"=> (0,0)
       "O2"=> (0,0)
       
      )

                



end #module
