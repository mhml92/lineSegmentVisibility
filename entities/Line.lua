local Line = Class("Line", Entity)

function Line:initialize(p1,p2,scene)
   Entity:initialize(scene)

   self.p1 = p1
   self.p2 = p2
   self.p1.line = self
   self.p2.line = self
   self.startPoint = nil 
   self.layerName = "Line"
   self.visible = false

end

function Line:draw()
   if self.visible then
      love.graphics.setColor(DEBUGVISIBLECOLOR)
   else
      love.graphics.setColor(LINE_COLOR)
   end
   love.graphics.setLineWidth(LINE_WIDTH)
   love.graphics.line( self.p1.x, self.p1.y, self.p2.x, self.p2.y)
   love.graphics.setColor(WHITE)
end

function Line:setVisible()
   self.visible = true
   self.p1:setVisible()
   self.p2:setVisible()
end

function Line:getStartPoint()
   return self.startPoint
end

function Line:init()
   self.visible = false
   self.p1.visible = false
   self.p1.isStartPoint = false
   self.p2.visible = false
   self.p2.isStartPoint = false

   if self.p1.angle < self.p2.angle then
      self.p1.isStartPoint = true
   elseif self.p1.angle > self.p2.angle then
      self.p2.isStartPoint = true
   else
      if self.p1:getValue() < self.p2:getValue() then
         self.p1.isStartPoint = true
      else
         self.p2.isStartPoint = true
      end
   end


   if self.p1.isStartPoint then
      self.startPoint = self.p1
   else
      self.startPoint = self.p2
   end
end

function Line:reverseStartPoint()
   if self.p1.isStartPoint then
      self.startpoint = self.p2
      self.p2.isStartPoint = true
      self.p1.isStartPoint = false
   else
      self.startpoint = self.p1
      self.p1.isStartPoint = true
      self.p2.isStartPoint = false
   end
end

return Line

