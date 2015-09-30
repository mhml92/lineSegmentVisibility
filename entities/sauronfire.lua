local Fire = Class("Fire", Entity)

function Fire:initialize(scene)
   Entity:initialize(scene)

   self.fire = resmgr:getImg("fire.png")

   self.quads = {}
   for i=0,3 do
      for j=0,3 do
         table.insert(self.quads, love.graphics.newQuad(i*200, j*200, 200, 200, self.fire:getDimensions()))
      end  
   end

   self.counter = 1
end

function Fire:update(dt)
   self.counter = self.counter + 12 * dt
   if not self.quads[math.floor(self.counter)] then
      self.counter = 1
   end
end


function Fire:draw(line)
   love.graphics.setColor(255,255,255,255)
   love.graphics.draw(self.fire, self.quads[math.floor(self.counter)], line.p1.x,line.p1.y, Vector.angleTo(line.p1.x-line.p2.x, line.p1.y-line.p2.y), Vector.dist(line.p1.x,line.p1.y,line.p2.x,line.p2.y)/120,0.3, 160,180)
end



return Fire
