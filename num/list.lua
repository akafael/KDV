--[[
 Program to implement struture of a list
 @autor Rafael Lima
]]

Node = {}
Nodea = { __index = Node }

-- Function to create a new instance of Node
function Node:new(value,left, right)
   local new_inst = {}    -- the new instance
   local v = value
   setmetatable( new_inst, Nodea ) -- all instances share the same metatable

   self.value = v
   self.left = left or self
   self.right = right or self
   
    return new_inst
end

function Node:set_value(value)
   self.value = value
end

function test()
   local a = Node:new(1)
   local b = Node:new(2) 
   local c = Node:new(3) 
   c:set_value(2) -- set a individual value

   print(a.value,b.value,c.value)
end