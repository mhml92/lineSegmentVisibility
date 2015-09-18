local Line = Class("Line", Entity)

function Line:initialize(p1,p2,scene)
    Entity:initialize(scene)
    self.p1 = p1
    self.p2 = p2
    self.layerName = "Line"
    self.p1.line = self
    self.p2.line = self

end

function Line:draw()
    love.graphics.setColor(LINE_COLOR)
    love.graphics.setLineWidth(LINE_WIDTH)
    love.graphics.line( self.p1.x, self.p1.y, self.p2.x, self.p2.y)
    love.graphics.setColor(WHITE)
end

function Line.static:length(x,y)
	return math.sqrt(x*x + y*y)
end

function Line.static:dist(x1,y1,x2,y2)
	return Line.static:length(x1-x2, y1-y2)
end


return Line

