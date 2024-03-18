#taken from https://github.com/afternone/DFA.jl by Jihui Han

#Copyright (c) 2015: afternone.

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function integrate(x::AbstractArray{T}) where T<:Real
    N = length(x)
    y = zeros(N)
    sumx = 0.0
    for i=1:N
        sumx += x[i]
        y[i] = sumx
    end
    return y
end

function integrate1(x::AbstractArray{T}) where T<:Real
    N = length(x)
    y = zeros(N)
    sumx = 0.0
    meanx = 0.0
    for i=1:N
        sumx += x[i]
        meanx += sumx/i
        y[i] = sumx - meanx
    end
    return y
end

function polyfit(x::AbstractArray{S},
                 y::AbstractArray{T},
                 order::Int = 1) where {S<:Real, T<:Real}
  A = [ float(x[i])^p for i = 1:length(x), p = 0:order ]
  return A \ y
end

function dfa(x::AbstractArray{T},
             boxsize::Int;
             order::Int = 1,
             overlap::Real = 0.0,
             integrated::Bool = false) where T<:Real
    if boxsize > 1 && order >= 0 && 0.0 <= overlap < 1.0
        if !integrated
            x = integrate(x)
        end
        overlapnum = ifloor(overlap*boxsize)
        N = length(x)
        tr = zeros(N)
        i = 0
        fluc = 0.0
        while i*(boxsize-overlapnum)+boxsize <= N
            boxstart = i*(boxsize - overlapnum) + 1
            boxend = i*(boxsize - overlapnum) + boxsize
            p = polyfit(boxstart:boxend, view(x, boxstart:boxend), order)
            for j=boxstart:boxend
                Δ = x[j] - sum([p[k+1]*j^k for k=0:order])
                fluc += Δ*Δ
            end
            i += 1
        end
        return sqrt(fluc/i/boxsize)
    else
        error("boxsize at least 2, fit order at least 0, overlap must between [0, 1)")
    end
end

function dfa(x::AbstractArray{T},
             boxes::AbstractArray{S};
             order::Int = 1,
             overlap::Real = 0.0,
             integrated::Bool = false) where {T<:Real, S<:Real}
    if !integrated
        x = integrate(x)
        integrated = true
    end
    N = length(boxes)
    fluc = zeros(N)
    for i=1:N
        fluc[i] = dfa(x, boxes[i], order=order, overlap=overlap, integrated=integrated)
    end
    return fluc
end

function dfa(x::AbstractArray{T};
             order::Int = 1,
             overlap::Real = 0.0,
             boxmax::Int = div(length(x), 2),
             boxmin::Int = 2*(order + 1),
             boxratio::Real = 2,
             integrated::Bool = false) where {T<:Real}
    if boxmax > boxmin
        boxes = unique(int(boxratio.^[log(boxratio, boxmin):log(boxratio, boxmax)]))
        if length(boxes) > 1
            if !integrated
                x = integrate(x)
                integrated = true
            end
            return boxes, dfa(x, boxes, order=order, overlap=overlap, integrated=integrated)
        else
            error("box number at least 2")
        end
    else
        error("boxmax must be greater than boxmin, or length(x)/2 must be greater than 2(order+1)")
    end
end