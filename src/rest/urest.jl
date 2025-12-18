#adapted from https://github.com/ShiangHu/Unified-EEG-reference-rREST

function rRestCore(data :: Matrix{Float64}, K :: Matrix{Float64}) :: (Matrix{Float64}, Matrix{Float64}, Matrix{Float64}, Matrix{Float64}, Float64)

  Nc, Nt = size(data)
  dataR, H, L = rRestVrbTrans(data, K)

  S = svd(H' * H)
  
  lmds = rRestGenLmd(1000)
  rss = zero(lmds)
  df = zero(lmds)
  dataRScaled = dataR ./ norm(dataR, "fro")

end
