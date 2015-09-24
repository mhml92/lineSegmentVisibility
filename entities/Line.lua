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
   --return point distance of that is closest of the 2 points
   return math.min(self.p1:getValue(),self.p2:getValue())
end


function Line.static:length(x,y)
   return math.sqrt(x*x + y*y)
end

function Line.static:dist(x1,y1,x2,y2)
   return Line.static:length(x1-x2, y1-y2)
end

return Line

