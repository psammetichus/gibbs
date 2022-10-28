import LinearAlgebra
using Statistics
using CSV

# data is the EEG potentials with average reference, chan x samples
# G is the lead field matrix, sources x channels

const RMat = Array{Float64, 2}

function loadDipoles(filename :: String) :: RMat
  dataFile = File(filename)
  buffer = zeros( (3000, 3))
  rowN = 1
  for row in dataFile
    buffer[rowN] = [ row[:col1], row[:col2], row[:col3] ]
    rowN += 1
  end

  return buffer
end
		

function rest_refer(data :: Rmat, G :: Rmat) :: Rmat

    G = G'

    channels = size(G,2)

    assert(size(data,1) == size(G,1)) #channel num should be the same

    assert(size(data,1) > size(data,2)) # need more time points than channels

    Gar = G - repeat(mean(a,dims=1),channels)

    dataZ = G * LinearAlgebra.pinv(Gar, 0.05) * data #value 0.05 for real data

    dataZ = data + repeat( mean(dataZ, dims=1), channels) # V = Vavg + AVG(V0)


end #rest_refer

function calcLeadField(xyzElec, xyzDipoles, xyzDipOri, headmodel)


end


