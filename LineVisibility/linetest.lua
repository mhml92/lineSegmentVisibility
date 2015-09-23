function lineIntersection(line, line2)
  --local tl = {x=self.x-self.velx,y=self.y-self.vely,x2=self.x,y2=self.y+9}
  local a,b,c,d = 
  {X=line2.x,Y=line2.y},
  {X=line2.x2,Y=line2.y2},
  {X=line.x,Y=line.y},
  {X=line.x2,Y=line.y2}

  local denominator = ((b.X - a.X) * (d.Y - c.Y)) - ((b.Y - a.Y) * (d.X - c.X));
  local numerator1 = ((a.Y - c.Y) * (d.X - c.X)) - ((a.X - c.X) * (d.Y - c.Y));
  local numerator2 = ((a.Y - c.Y) * (b.X - a.X)) - ((a.X - c.X) * (b.Y - a.Y));

  -- Detect coincident lines (has a problem, read below)
  if denominator == 0 then return numerator1 == 0 and numerator2 == 0 end

  local r = numerator1 / denominator
  local s = numerator2 / denominator

  return (r >= 0 and r <= 1) and (s >= 0 and s <= 1)
end

local l1, l2 = {x=-10,x2=10,y=0,y2=0},{x=0,x2=0,y=-10,y2=10}
print("local l1, l2 = {x=-10,x2=10,y=0,y2=0},{x=0,x2=0,y=-10,y2=10}", lineIntersection(l1,l2))

local l1, l2 = {x=20,x2=40,y=0,y2=0},{x=0,x2=0,y=-10,y2=10}
print("local l1, l2 = {x=-10,x2=10,y=0,y2=0},{x=0,x2=0,y=-10,y2=10}", lineIntersection(l1,l2))