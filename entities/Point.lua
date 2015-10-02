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
   self.distance = 0
   self.visible = 0
end

function Point:setViewPoint()
   self.viewPoint = true
   self.point_size = VIEW_POINT_SIZE
end

function Point:setMarked(v)
   self.marked = v
end

function Point:getDistance()
   return self.distance
end

function Point:setVisible(val)
   self.visible = val
end

function Point:isVisible()
   return self.visible == 1
end

function Point:setDistance(val)
   self.distance = val
end

function Point:isFirst()
   return self.number < self.other.number
end

function Point:getFirst()
   return self:isFirst() and self or self.other
end

function Point:draw()

   if self.marked then
      love.graphics.setColor(POINT_MARKED_COLOR)
      love.graphics.circle("line", self.x, self.y, POINT_MARKED_SIZE, 32)
      love.graphics.print(self:__tostring(), self.x, self.y)
   end

   --dirty hack
   if self.number then
      love.graphics.setColor(POINT_MARKED_COLOR)
      love.graphics.print(self.number, self.x, self.y-15)
   end

   if self.viewPoint then
      love.graphics.setColor(VIEW_POINT_COLOR)
   elseif self:isVisible() then
      love.graphics.setColor(EMERALD)
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

function Point:__tostring()
   return "[x]" .. self.x .. " [y]" .. self.y
end

return Point
