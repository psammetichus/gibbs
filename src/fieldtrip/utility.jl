module Fields

const Vertex = Array{Float64,1}

function solidAngle(v1 :: Vertex, v2 :: Vertex, v3 :: Vertex)
    cp23x = v2[2]*v3[3] - v2[3]*v3[2]
    cp23y = v2[3]*v3[1] - v2[1]*v3[3]
    cp23z = v2[1]*v3[2] - v2[2]*v3[1]
    nom = cp23x*v1[1] + cp23y*v1[2] + cp23z*v1[3]
    n1 = sqrt( v1[1]^2 + v1[2]^2 + v1[3]^2 )
    n2 = sqrt( v2[1]^2 + v2[2]^2 + v2[3]^2 )
    n3 = sqrt( v3[1]^2 + v3[2]^2 + v3[3]^2 )
    ip12 = v1[1]*v2[2] + v1[2]*v2[2] + v1[3]*v2[3]
    ip23 = v2[1]*v3[1] + v2[2]*v3[2] + v2[3]*v3[3]
    ip13 = v1[1]*v3[1] + v1[2]*v3[2] + v1[3]*v3[3]
    den = n1*n2*n3 + ip12*n3 + ip23*n1 + ip13*n2
    if nom == 0.0
        if den < 0.0
            return NaN
        end
    end
    return 2 * atan(nom, den)
end #function

function fitsphere(points :: Array{Float64,2})
    #points is Nx3 array
    x = points[:,1]
    y = points[:,2]
    z = points[:,3]

    l = ones(length(x))
    O = zeros(length(x))

    #make design matrix
    D = [ (x .* x + y .* y + z .* z) x y z l ]

    Dx = [2x l O O O]
    Dy = [2y O l O O]
    Dz = [2z O O l O]

    #create scatter matrices
    M = D' * D
    N = Dx' * Dx + Dy' * Dy + Dz' * Dz

    #eigensystem
    ee = eigen(M)
    minval = eps(Float64)*5*norm(M)
    Mrank = sum(all(vals -> vals > minval))

    if Mrank == 5
        #full rank; min ev corresponds to solution
        vals, vecs = eigen( inv(M) * N )
        dmin, dminidx = findmax(values)
        pvec = vecs[:, dminidx[1]]'
    else
        #rank deficient; extract nullspace of M
        idx = findall(val -> val <= eps(Float64)*5*norm(M), vals)
        pvec = v[:, idx]
        m,n = size(pvec)
        if m > 1
            pvec = pvec[1,:]
        end
    end





end #module
