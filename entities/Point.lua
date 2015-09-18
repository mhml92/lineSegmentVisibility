local Point = Class("Point", Entity)

function Point:initialize(x,y,scene)
   Entity:initialize(scene)
   self.x = x
   self.y = y
   self.layerName = "Point"
   self.viewPoint = false
   self.point_size = POINT_SIZE
   self.marked = false
   self.markShown = false
   self.line = nil
end

function Point:setViewPoint()
   self.viewPoint = true
   self.point_size = VIEW_POINT_SIZE
end

function Point:setMarked()
   self.marked = true
end

function Point:draw()

   if self.marked then
      love.graphics.setColor(POINT_MARKED_COLOR)
      --love.graphics.circle("fill", self.x, self.y, POINT_MARKED_SIZE, 16)
      love.graphics.circle("line", self.x, self.y, POINT_MARKED_SIZE, 32)
      self.marked = false
   end

   if self.viewPoint then
      love.graphics.setColor(VIEW_POINT_COLOR)
   else
      love.graphics.setColor(POINT_COLOR)
   end
   love.graphics.circle("fill", self.x, self.y, self.point_size, 16)
   love.graphics.setLineWidth(POINT_LINE_WIDTH)

   if self.viewPoint then
      love.graphics.setColor(VIEW_POINT_LINE_COLOR)
   else
      love.graphics.setColor(POINT_LINE_COLOR)
   end
   love.graphics.circle("line", self.x, self.y, self.point_size, 16)
   love.graphics.setColor(WHITE)
end

return Point
