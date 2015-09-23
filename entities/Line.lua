local Line = Class("Line", Entity)

function Line:initialize(p1,p2,scene)
   Entity:initialize(scene)

   --normalize line
   if p1.x > p2.x then
      p1,p2 = p2,p1 --swap if p2.x is less than p1.x
   else
      if p1.x == p2.x then
         if p1.y > p2.y then
            p1,p2 = p2,p1 --swap
         end
      end
   end

   self.p1 = p1
   self.p2 = p2
   
   self.layerName = "Line"

   --fast references
   self.p1.line = self
   self.p1.other = p2
   self.p2.line = self
   self.p2.other = p1

end

function Line:draw()
   love.graphics.setColor(LINE_COLOR)
   love.graphics.setLineWidth(LINE_WIDTH)
   love.graphics.line( self.p1.x, self.p1.y, self.p2.x, self.p2.y)
   love.graphics.setColor(WHITE)
end

function Line:getValue()
   local p = self.scene.p
   print("line dist from p")
end


function Line.static:length(x,y)
   return math.sqrt(x*x + y*y)
end

function Line.static:dist(x1,y1,x2,y2)
   return Line.static:length(x1-x2, y1-y2)
end

--[[
function Line:distanceToP(p, line)
   var m1 = 0.0 -- slope of first line
   var b1 = 0.0 -- y-intercept of first line
   var m2 = 0.0 -- slope of second line
   var b2 = 0.0 -- y-intercept of second line

   var x = 0.0 -- (x, y) point of intersection.
   var y = 0.0

   var message = ''

   -- get slopes and y-intercepts
   m1 = parseFloat(window.document.input.m1.value)
   b1 = parseFloat(window.document.input.b1.value)
   m2 = parseFloat(window.document.input.m2.value)
   b2 = parseFloat(window.document.input.b2.value)

   x = (b2 - b1) / (m1 - m2); -- solve for x-coordinate of intersection

   y = m1 * x + b1; -- solve

   message  = 'Point of intersection: \n'
   message = message .. '(' + x + ', ' + y + ')';

   --alert(message);
end]]


return Line

