local Point = require "entities/Point"
local Line = require "entities/Line"

local function cross(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end


local function intersection(l1,l2)
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
   if rxs == 0 and qpr == 0 then
     return l2.p1
   end

   --case 2: Parallel and non-intersecting
   if rxs == 0 and qpr ~= 0 then
      return nil
   end

   local tolerance = 0.001
   --case 3: intersection!
   local t = cross(q.x-p.x,q.y-p.y,s.x,s.y)/rxs
   local u = qpr/rxs
   if rxs ~= 0 and 0 <= t+tolerance and t-tolerance <= 1 and 0 <= u+tolerance and u-tolerance <= 1 then
      local px,py = p.x+(t*r.x),p.y+(t*r.y)
      local np = Point:new(px,py,l1.scene)
     -- print(np)
      return np 
   end
   --print(rxs,t,u,qpr)

   return nil
end

return {
   intersection = intersection
}
