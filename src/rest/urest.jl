#adapted from https://github.com/ShiangHu/Unified-EEG-reference-rREST
const RMat = Array{Float64, 2}

function rRestCore(data :: RMat, K :: Rmat) :: (RMat, RMat, Rmat, RMat, Float64)

  Nc, Nt = size(data)
  dataR, H, L = rRestVrbTrans(data, K)

  S = svd(H' * H)
  
  lmds = rRestGenLmd(1000)
  rss = zero(lmds)
  df = zero(lmds)
  dataRScaled = dataR ./ norm(dataR, 'fro')

end
