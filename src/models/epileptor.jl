using OrdinaryDiffEq

#From
#On the nature of seizure dynamics, Jirsa et al, Brain 2014


#need to write as a stochastic system
#and involve the constants as parameters
function epileptor!(du, u, p, t)
    gamma = 0.01
    x0 = -1.6
    y0 = 1.0
    tau0 = 2857
    tau1 = 1.0
    tau2 = 10
    Irest1 = 3.1
    Irest2 = 0.45
    du[1] = u[2] - f1(u[1], u[3], u[5]) - u[5] + Irest1
    du[2] = y0 - 5*u[1]^2 - u[2]
    du[5] = (1/tau0)*(4*(u[1]-x0)-u[5])
    du[3] = -u[4] + u[3] - u[3]^3 + Irest2 + 2u[6] - 0.3*(u[5] - 3.5)
    du[4] = (1/tau2)*(-u[4] + f2(u[3], u[4]))
    du[6] = -gamma*(u[6]-0.1u[1])
end #function

function f1(x1, x2, z)
    if x1 < 0
        return x1^3 - 3*x1^2
    else
        return x1*(x2 - 0.6*(z-4)^2)
    end
end #function

function f2(x1,x2)
    if x2 < -0.25
        return 0.0
    else
        return 6*(x2+0.25)
    end #if
end #func

function runEpileptor()
    prob = ODEProblem(epileptor!, [0, -5, 0, 0, 3, 0], 10.0)
    sol = solve(prob, Tsit5())
end #func