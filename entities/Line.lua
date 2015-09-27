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
      love.graphics.setColor(DEBUGVISIBLECOLOR)
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
--[[
   if p1.angleToP < p2.angleToP then
      p1.isStartPoint = true
   elseif  p2.angleToP < p1.angleToP then
      p2.isStartPoint = true
   else
      if p1.distToP < p2.distToP then
         p1.isStartPoint = true
      else
         p2.isStartPoint = true
      end
   end
   ]]
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

function Line:__tostring()
   return "num: " .. self.num
end

return Line

