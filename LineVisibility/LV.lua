local LV = Class("LV")

local RBTree = require 'RBTree/RBTree'
local Node = require 'RBTree/Node'
local Point = require 'entities/Point'
local Line = require 'entities/Line'
local Geo = require 'Geometry'

function LV:initialize(points,lines,p,scene)
   self.scene = scene
   self.p = p
   self.points = points
   self.lines = lines
   self.sweepLine = nil
   self.debugSL = {}
   self.quads = {}

end

function LV:update(dt)
   self.status = RBTree:new()
   self.maxDist = 0

   self.debugSL = {}
   self.quads = {}

   -- set distance, angle for each point
   local P = self.p
   for _,p in ipairs(self.points) do
      p.distToP = self:distToP(p)
      p.angleToP = self:angleToP(p)
      if self.maxDist < p.distToP then
         self.maxDist = p.distToP
      end
   end

   self:setSweepLine(P.x-1,P.y)
   -- init all lines with starting points
   for _,l in ipairs(self.lines) do
      l.num = _
      -- reset visibility,and set startpoint ref
      l:init()
      -- if line crosses sweepline: revers start point and add to status
      if Geo.intersection(self:getSweepLine(),l) then
         if l.p1.y > l.p2.y then
            l:reverseStartPoint()
            self.status:insert(l)
         end
      end
   end

   table.sort(self.points,function(p1,p2)
      if p1.angleToP > p2.angleToP then
         return true
      elseif p1.angleToP < p2.angleToP then
         return false
      else 
         if p1.isStartPoint and p2.isStartPoint then
            return p1.distToP < p2.distToP
         elseif not p1.isStartPoint and not p2.isStartPoint then
            return p1.distToP > p2.distToP
         elseif p1.isStartPoint and not p2.isStartPoint then
            return true
         elseif not p1.isStartPoint and p2.isStartPoint then
            return false
         end
      end
   end)
   --[[
   --dirty hack, add numbers to points
   for k,point in ipairs(self.points) do
      point.number = k
   end
   ]]
   self:setVisible()
end

function LV:getSweepLine()
   return self.sweepLine
end

function LV:setSweepLine(x,y)
   local P = self.p

   local dx,dy = x - P.x, y - P.y

   dx,dy = Vector.normalize(dx,dy)
   dx,dy = P.x+(dx*(self.maxDist*2)),P.y+(dy*(self.maxDist*2))
   local nsl = Line:new(P,Point:new(dx,dy,self.scene),self.scene)
   table.insert(self.debugSL,nsl)
   self.sweepLine = nsl 
end

function LV:distToP(point)

   local P = self.p
   return Vector.dist(P.x,P.y,point.x,point.y)
end

function LV:angleToP(point)
   local P = self.p
   local dx,dy = point.x-P.x,point.y-P.y
   return Vector.angleTo(dx,dy)
end

function LV:setVisible()
   for _,p in ipairs(self.points) do
      self:setSweepLine(p.x,p.y) 
      if p.isStartPoint then
         self.status:insert(p.line)
      else
         self.status:delete(p.line)
      end

      local minN = self.status:getMin()
      if minN ~= nil then
         minN.obj:setVisible()
         -- create a quad for drawing
         local P = self.p
         local op1,op2 = minN.obj.p1,minN.obj.p2 
         local dx1,dy1 = Vector.normalize(op1.x-P.x,op1.y-P.y)
         local dx2,dy2 = Vector.normalize(op2.x-P.x,op2.y-P.y)
         
         local cam = self.scene.cammgr.cam 
         local w,h = love.graphics.getDimensions()
         local wx0,wy0 = cam:worldCoords(0,0)
         local wxMax,wyMax = cam:worldCoords(w,h)

         local viewDist = w*w      

         table.insert(self.quads,{
            op1.x,
            op1.y,
            op2.x,
            op2.y,
            op2.x+(dx2*viewDist),
            op2.y+(dy2*viewDist),
            op1.x+(dx1*viewDist),
            op1.y+(dy1*viewDist)
         })
      end
   end
end

function LV:draw()
      love.graphics.setColor(LIGHTSILVER)
   for k,v in ipairs(self.quads) do
      love.graphics.polygon("fill",v)
   end
      love.graphics.setColor(WHITE)
   --[[
   for k,v in ipairs(self.debugSL) do
      v:draw()
   end
   ]]
end

return LV
