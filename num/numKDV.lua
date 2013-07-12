--[[
-- Solving KDV by diferences finites
-- @author: Rafael Lima
--]]

--[[
--  KDV=
--   U_t + U_x -k*U_{xxx}=0
--   f_0 = e^{-x^2}
--]]

require "list" -- package to do the nodes of vector

-- default table values
H = 0.1 -- value to 'h'
DT = 0.01 -- value to 'dt'
C = 1 -- value to c constant
K = 1 -- value to k constant

ZOOM_X = 1
ZOOM_Y = 1

-- Define initial condition
function f0(x)
 return(ZOOM_Y*math.exp(-(x^2)))
end

-- First Central Derivative with accuracy 2
function d1c2(u,h)
  local h = h or H
  local u = u
  return((u.right.value-u.left.value)/(2*h))
end

-- First backward Derivative with accuracy 2 
function d1b2(u,h)
   -- −3/2 2 −1/2
   local h = h or H
   local u = u
   return(((-3)*u.value+
	   (4)*u.left.value+
	   (-1)*u.left.value)/(2*h))
end

-- Third Central Derivative with accuracy 2
function d3c2(u,h)
   local h = h or H
  local u = u
  return((-(0.5)*(u.left.left.value) + u.left.value -
    u.right.value +(0.5)*(u.right.right.value))/(h^3))
end

-- Macro to derivative in order n
function diff(u,n,h)
  local n = n or 0

  if n==0 then
    return(u)
  elseif n==1 then
    return(d1b2(u,h))
  elseif n==3 then
    return(d3c2(u,h))
  else
    return(nil)
  end
end

-- Calculate U(x,t+dt) based in forward derivate
function kdvStep(u,c,k,h,dt)
  -- set default values
  local c = c or C
  local k = k or K
  local dt = dt or DT

  -- calc U(x,t+dt)
  local u1 = Node:new()
 
  -- TODO Check this line:
  -- u1.value = -c*dt*diff(u,1,h) + k*dt*diff(u,3,h)
  u1.value = -c*dt*diff(u,1,h) + k*dt*diff(u,3,h) + u.value

  u1.t = u.t+dt
  u1.x = u.x

  return(u1)
end

function kdvStepVector(u,c,k,h,dt)
  local listu1 = u or u_f0()
  local listu = {}
  for _,u1 in ipairs(listu1) do
     local n = Node:new()
     n:set_pos(listu[#listu],listu[1])
     n.left.right = n
     n.right.left = n

     u0 = kdvStep(u1,c,k,h,dt)

     n.value = u0.value
     n.x = u0.x
     n.t = u0.t

     listu[#listu + 1] = n
  end
  return(listu)
end

-- Initial condition:
function u_f0(min_x,max_x,dx)
  local dx = dx or H
  local min_x = min_x or -3
  local max_x = max_x or 3

  local u0 = {}
  for i=min_x, max_x, dx do
    local u = Node:new()
    u:set_pos(u0[#u0],u0[1])
    u.left.right = u
    u.right.left = u

    u.value = f0(i)
    u.x = i
    u.t = 0

    u0[#u0+1] = u
  end

  return(u0)
end

-- Calculate the values to kdv wave before 't' time:
function kdv_t(u,t)
   local u0 = u or u_f0()
   for h=0,t,H do
      u0 = kdvStepVector(u0,c,k,H,DT)
   end
   return u0
end

function kdv_x(u,x)
   -- BUG returning nil..
   local u0  = {}
   for i,u0 in ipairs(u) do
      if (math.abs(u0.x - x)<0.1) then
	 break
      end
   end

   return u0
end

function kdv(x,t)
   local u = u_f0()
   u = kdv_t(u,t)
   u = kdv_x(u,x)
   return u
end

-- Print file with u(x,t) in a fixed t
function printDat(filename,u)
   local file = io.open("data/"..filename,"w")

   local data = {}
   for _, u0 in ipairs(u) do
      data[#data+1] = table.concat({tostring(u0.t),
				   tostring(u0.x),
				   tostring(u0.value)},
				   "\t")
   end

   file:write(table.concat(data,"\n"))
   file:close()
end

-- Print files whith  u(x,ti) with ti = [0,t]
function printKDV_t(listu,t)

   local u0 = u_f0()
   print(table.concat({"using DT =",DT,"H=",H,",C=",C}," "))

   if(t>0) then
      for h=0,t,DT do
	 u0 = kdvStepVector(u0)
	 print("drawing t = "..u0[1].t)
	 local filename = {"ut",tostring(h/DT),".dat"}
	 printDat(table.concat(filename),u0)
      end
   else
      printDat("ut0.dat")
   end

   print("[gnuplot:]")
   print(io.popen("gnuplot < graphConfig.plot")..'\n')
end

-- TODO
-- > Function to find any value of u(x,t)