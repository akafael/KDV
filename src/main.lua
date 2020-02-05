
--[[
-- Use library numKDV.lua
--
--
--]]

require "numKDV" -- library to solve KDV

-- Get parameters:

print("Digite os valores dos parâmetros H,DT e C:\n")
io.flush()
n1, n2, n3 = io.read("*number", "*number","*number")
H = H or n1
DT = DT or n2
C = C or n3

k0 = u_f0() -- begin

n1=nil
n2=nil
n3=nil

print("Digite a quantidade ciclos de tempo:\n")
io.flush()
n = io.read("*number")
printKDV_t(n*DT,k0)