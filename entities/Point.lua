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
   self.value = 0
   self.visible = false

   self.isStartPoint = false
   self.angle = nil
end

function Point:setViewPoint()
   self.viewPoint = true
   self.point_size = VIEW_POINT_SIZE
end

function Point:setMarked(v)
   self.marked = v
end

function Point:getValue()
   return self.value
end

function Point:setVisible()
   self.visible = true
end

function Point:isVisible()
   return self.visible
end


function Point:draw()
   if self.isStartPoint then
      love.graphics.setColor(DEBUGVISIBLECOLOR)
      --love.graphics.circle("fill", self.x, self.y, POINT_MARKED_SIZE, 16)
      love.graphics.circle("line", self.x, self.y, POINT_MARKED_SIZE, 32)
      love.graphics.print(self:__tostring(), self.x, self.y)

   end

   if self.marked then
      love.graphics.setColor(POINT_MARKED_COLOR)
      --love.graphics.circle("fill", self.x, self.y, POINT_MARKED_SIZE, 16)
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
   elseif self.visible then
      love.graphics.setColor(DEBUGVISIBLECOLOR)
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
