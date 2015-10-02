local Point = require "entities/Point"
local Line = require "entities/Line"

local function cross(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

local function round(num)
   local p = 10000
   return math.floor((num*p)+0.5)/p
end

local function looseIntersection(l1,l2)
   local x1,y1,
         x2,y2,
         x3,y3,
         x4,y4 = 
         l1.p1.x,l1.p1.y,
         l1.p2.x,l1.p2.y,
         l2.p1.x,l2.p1.y,
         l2.p2.x,l2.p2.y

   local first,last = (x1*y2-y1*x2),(x3*y4-y3*x4)
   local denom = ((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4))

   local px = (first*(x3-x4)-(x1-x2)*last)/denom 
   local py = (first*(y3-y4)-(y1-y2)*last)/denom 
   return Point:new(px,py,l1.scene)
end

local function strictIntersection(l1,l2)
   local p = {}
   local r = {}
   p.x,p.y = l1.p1.x,l1.p1.y
   r.x, r.y = l1.p2.x-p.x, l1.p2.y-p.y

   local q = {}
   local s = {}
   q.x,q.y = l2.p1.x,l2.p1.y
   s.x, s.y = l2.p2.x-q.x, l2.p2.y-q.y

   local rxs = cross(r.x,r.y,s.x,s.y)
   local qpr = cross(q.x-p.x,q.y-p.y,r.x,r.y) 
   --case 1: Colliniear
   if round(rxs) == 0 and round(qpr) == 0 then
     -- print("case1")
      local nx,ny = l2.p1.x,l2.p1.y
      return Point:new(nx,ny,l2.scene)
   end

   --case 2: Parallel and non-intersecting
   if round(rxs) == 0 and round(qpr) ~= 0 then
      return nil
   end

   local tolerance = 0.000
   --case 3: intersection!
   local t = round(cross(q.x-p.x,q.y-p.y,s.x,s.y)/rxs)
   local u = round(qpr/rxs)
   if round(rxs) ~= 0 and 0 <= round(t)+tolerance and round(t)-tolerance <= 1 and 0 <= round(u)+tolerance and round(u)-tolerance <= 1 then
      --print(t,u)
      local px,py = p.x+(t*r.x),p.y+(t*r.y)
      --print("case3",px,py)
      local np = Point:new(px,py,l1.scene)
      return np 
   end
   return nil
end

local function isLeftOf(l,p)
  -- print(l,p)
   local vx,vy = l.p2.x - l.p1.x, l.p2.y - l.p1.y
   local dx,dy = p.x - l.p1.x, p.y - l.p1.y
   --print("isLeftOf")
   --print(vx,vy,dx,dy)
   return ((l.p1.x - l.p2.x)*(p.y - l.p2.y) - (l.p1.y - l.p2.y)*(p.x - l.p2.x)) > 0
end


return {
   looseIntersection = looseIntersection,
   strictIntersection = strictIntersection,
   isLeftOf = isLeftOf,
   round = round
}
