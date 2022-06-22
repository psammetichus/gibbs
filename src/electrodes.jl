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

@enum Laterality left right midline

function whichSide(etrode ::Electrode)
  if etrode.position[0] < 0.0
    left
  elseif etrode.position[0] > 0.0
    right
  else
    midline
  end #if
end #func

const tenpctDeg = 0.1*180

const tenUp = 90-tenpctDeg

const twenpctDeg = 0.2 * 180

const twenDown = 0+twenpctDeg

# these are derived as the intersections between the circles F7-Fz-F8 and
# Fp1-C3-O1 (and analogously on the right and in the parietal) since the two
# definitions from the IFCN recommendations are not the same point
const threefourth = 49.52

const threefourphi = 40.48


# circle defined by Fp1, C3, O1 will mark F3 and P3
# also subject to the constraint that circles defined by F7, Fz, F8 and P7, Pz,
# P8 will mark F3,F4 and P3,P4

const ifcn_electrodes = 
  Dict(
       "Cz" =>  (0,		0),
       "Nz" =>  (+90,		0),
       "In" =>  (+90,		+180),
       "T9" =>  (+90,		-90),
       "T10" => (+90,		+90),
       "Fpz" => (tenUp,		0),
       "Fz" =>  (twenDown,	0),
       "Pz" =>  (twenDown,	+180),
       "Oz" =>  (tenUp,		+180),
       "T7" =>  (tenUp,		-90),
       "T8" =>  (tenUp,		+90),
       "C3" =>  (twenDown,	-90),
       "C4" =>  (twenDown,	+90),
       "Fp1" => (tenUp,		-tenpctDeg),
       "Fp2" => (tenUp,		+tenpctDeg),
       "F7" =>  (tenUp,		-90 + twenpctDeg),
       "F8" =>  (tenUp,		+90 - twenpctDeg),
       "F3" =>  (threefourth,	-threefourphi),
       "F4" =>  (threefourth,	+threefourphi),
       "P3" =>  (threefourth,	-180+threefourphi),
       "P4" =>  (threefourth,	+180-threefourphi),
       "P7" =>  (tenUp,         -90 - twenpctDeg)
       "P8" =>  (tenUp,         +90 + twenpctDeg)
       "O1" =>  (tenUp,		-180 + tenpctDeg),
       "O2" =>  (tenUp,		+180 - tenpctDeg),
       
      ),

                



end #module
