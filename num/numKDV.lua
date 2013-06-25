--[[
-- Solving KDV by diferences finites
-- @author: Rafael Lima
--]]

--[[
--  KDV=
--   U_t + U_x -k*U_{xxx}=0
--   f_0 = e^{-x^2}
--]]

-- default table values
H = 0.01 -- value to 'h'
C = 1 -- value to c constant
K = 1 -- value to k constant

-- Define initial condition
function f0(x)
 return(math.exp(-(x^2)))
end

-- First Derivate whith accuracy 2
function d1a2(u,h)
  local h = h or H
  local u = u
  return((u.left.v-u.right.v)/(2*h))
end

-- Third Derivate whith accuracy 2
function d3a2(u,h)
  local h = h or H
  local u = u
  return((-(0.5)*(u.left.left.v) + u.left.v - u.right.v +(0.5)*(u.right.right.v))/(h^3))
end

-- Macro to derivate in order n
function diff(u,n,h)
  local n = n or 0

  if n==0 then
    return(u)
  elseif n==1 then
    return(d1a2(u,h))
  elseif n==3 then
    return(d3a2(u,h))
  else
    return(nil)
  end
end

-- Calc U(x,t+dt) based in foward derivate
function kdvStep(u,c,k,h,dt)
  -- set default values
  local c = c or C
  local k = k or K
  local dt = dt or H

  -- calc U(x,t+dt)
  local u1 = -c*dt*diff(u,1,h) - k*dt*diff(u,3,h)

  return(u1)
end

function kdvStepVector(u,c,k,h,dt)
  local u0 = u0
  for u0 in u do
    kdvStep(u0,c,k,h,dt)
  end
  return(u0)
end

-- Initial condition:
function u_f0(min_x,max_x,dx)
  local dx = dx or H
  local min_x = min_x or -3
  local max_x = max_x or 3

  local u0 = {u0} u0.left = u0[1] u0.right = u0[1]
  for i=-3, 3,0.1 do
    local u = {} u.left = u0[#u0] u.right = u0[#u0]
    u.left.right = u
    u.right.left = u
    u.v = f0(i)
    -- u.x = i
    -- u.t = 0
    u0[#u0+1] = u
  end

  return(u0)
end

-- TODO
-- function to Print a .dat
-- Add 't' and 'x' values to the vector 'u'