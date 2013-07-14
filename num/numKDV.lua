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
H = 0.5 -- value to 'h'
DT = 0.01 -- value to 'dt'
C = 1 -- value to c constant
K = 1 -- value to k constant

ZOOM_X = 10
ZOOM_Y = 1

-- Define initial condition
function f0(x)
   return(ZOOM_Y*math.exp(-((x/ZOOM_X)^2)))
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
  local min_x = min_x or -3*ZOOM_X
  local max_x = max_x or 3*ZOOM_X

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
function printKDV_t(t,listu)

   local u0 = listu or u_f0()
   print(table.concat({"using DT =",DT,"H=",H,",C=",C}," "))

   print("[kdv wave:]")
   -- printDat("ut0.dat",u0)

   if(t>0) then
      for h=0,t,DT do
	 u0 = kdvStepVector(u0)
	 print("generating in t = "..u0[1].t)
	 local filename = {"ut",tostring(h/DT),".dat"}
	 printDat(table.concat(filename),u0)
      end
   end

   local cmd = ""
   print("[gnuplot:]")
   plotfile = setupGnuplot("graphConfig.plot",t)
   cmd = "gnuplot < "..plotfile
   print(io.popen(cmd)..'\n')

   print("[making animation:]")
   cmd = "convert -delay 20 -loop 0 image/ani1-* vani1.gif"
   print(io.popen(cmd)..'\n')

   return u0
end

function setupGnuplot(filename,t)

   local minx = -3*ZOOM_X
   local maxx = 3*ZOOM_X
   local miny = -0.5*ZOOM_Y
   local maxy = 1.5*ZOOM_Y

   local file = filename
   local f =  io.open(file)
   local plotHeader = f:read("*all")
   f.close()

   file = "kdvGraph.plot" 

   f = io.open(file,"w")

   local plot1 = {table.concat({"set xrange [",minx,":",maxx,"]"}),
		  table.concat({"set yrange [",miny,":",maxy,"]"})}

   plot1 = table.concat(plot1,'\n')

   local plot2 = {"do for[a = 0:"..t/DT.."]{",
      "outfile = sprintf('./image/ani1-%03.0f.png',a);",
      "set output outfile;",
      "datafile = sprintf('./data/ut%.0f.dat',a);",
      table.concat({"tgraph = sprintf('t = %2.3f',a*",DT,");"}),
      "plot datafile u 2:3 ls 1 t tgraph;}"}
   plot2 = table.concat(plot2,'\n')
   
   plotf = table.concat({plotHeader,plot1,plot2},'\n')

   f:write(plotf)
   f:close()

   return file
end

-- TODO
-- > Function to find any value of u(x,t)