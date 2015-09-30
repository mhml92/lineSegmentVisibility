local Line = Class("Line", Entity)

function Line:initialize(p1,p2,scene)
   Entity:initialize(scene)

   self.p1 = p1
   self.p2 = p2
   self.p1.line = self
   self.p2.line = self
   self.layerName = "Line"
   self.visible = false
   self.num = 0

   self.node = nil
end

function Line:draw()
   if self.visible then
      love.graphics.setColor(LINE_COLOR_VISIBLE)
   else
      love.graphics.setColor(LINE_COLOR)
   end
   --love.graphics.print(self:__tostring(), self.p2.x, self.p2.y)
   love.graphics.setLineWidth(LINE_WIDTH)
   love.graphics.line( self.p1.x, self.p1.y, self.p2.x, self.p2.y)
   love.graphics.setColor(WHITE)

end

function Line:setVisible()
   self.visible = true
   self.p1:setVisible()
   self.p2:setVisible()
end

function Line:init()
   self.visible = false
   self.p1.visible = false
   self.p1.isStartPoint = false
   self.p2.visible = false
   self.p2.isStartPoint = false
   self.node = nil

   local p1,p2 = self.p1,self.p2
   if p1.angleToP > p2.angleToP then
      p1.isStartPoint = true
   elseif  p2.angleToP > p1.angleToP then
      p2.isStartPoint = true
   else
      if p1.distToP < p2.distToP then
         p1.isStartPoint = true
      else
         p2.isStartPoint = true
      end
   end

   -- p1 is always startpoint
   if self.p2.isStartPoint then
      self:reverseStartPoint()
   end
end

function Line:reverseStartPoint()
   local p = self.p2
   self.p2 = self.p1
   self.p1 = p
   self.p1.isStartPoint = true
   self.p2.isStartPoint = false
end

function Line:kill()
   local points = self.scene.points
   local lines = self.scene.lines

   self.p1:kill()
   self.p2:kill()
   self.alive = false

   local n = 0
   for k,v in ipairs(points) do
      if v == self.p1 or v == self.p2 then
         table.remove(points,k)
         n = n+1
         if n == 2 then
            break
         end
      end
   end
   for k,v in ipairs(lines) do
      if v == self then
         table.remove(lines,k)
         break
      end
   end
end

function Line:__tostring()
   return "num: " .. self.num .. " p1: " .. self.p1.x .. ",".. self.p1.y .. " p2: ".. self.p2.x .. "," .. self.p2.y
end

return Line

