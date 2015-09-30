local Line = Class("Line", Entity)

function Line:initialize(p1,p2,scene)
   Entity:initialize(scene)

   --make sure p1 comes before p2 in the coordinate system
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

   self.value = 0
end

function Line:swapPoints()
   self.p1.number,self.p2.number = self.p2.number,self.p1.number
end
--[[
def GetClosestPoint(A, B, P)

  a_to_p = [P.x - A.x, P.y - A.y]     # Storing vector A->P
  a_to_b = [B.x - A.x, B.y - A.y]     # Storing vector A->B

  atb2 = a_to_b[0]**2 + a_to_b[1]**2  # **2 means "squared"
                                      #   Basically finding the squared magnitude
                                      #   of a_to_b

  atp_dot_atb = a_to_p[0]*a_to_b[0] + a_to_p[1]*a_to_b[1]
                                      # The dot product of a_to_p and a_to_b

  t = atp_dot_atb / atb2              # The normalized "distance" from a to
                                      #   your closest point

  return Point.new( :x => A.x + a_to_b[0]*t,
                    :y => A.y + a_to_b[1]*t )
                                      # Add the distance to A, moving
                                      #   towards B

end
]]
--[[function Line:calcDistToP(P)
   local A,B = self.p1,self.p2
   a_to_p = {P.x - A.x, P.y - A.y}     --# Storing vector A->P
   a_to_b = {B.x - A.x, B.y - A.y}     --# Storing vector A->B

   atb2 = math.pow(a_to_b[1],2) + math.pow(a_to_b[2],2)
   atp_dot_atb = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]

   local t = atp_dot_atb / atb2



   self.value=Vector.dist(A.x + a_to_b[1]*t,A.y + a_to_b[2]*t,P.x,P.y)

   print(P.x,P.y,A.x + a_to_b[1]*t, A.y + a_to_b[2]*t,"dist"..self.value)
end]]

function Line:calcDistToP(P)
  local B,A = self.p1,self.p2
  local AP,AB = {P.x-A.x,P.y-A.y},{B.x-A.x,B.y-A.y}

  local ABlenghtSquared = Vector.len2(AB[1],AB[2])
  local ABdotAP = Vector.dot(AP[1],AP[2],AB[1],AB[2])
  local distance = ABdotAP/ABlenghtSquared

  if distance < 0 then
    --A is closest
    self.value = Vector.dist(A.x,A.y,P.x,P.y)  
  elseif distance > 1 then 
    --B is closest
    self.value = Vector.dist(B.x,B.y,P.x,P.y)
  else
    self.value = Vector.dist(A.x+AB[1]*distance,A.y+AB[2]*distance,P.x,P.y) 
  end
end

function Line:draw()
   love.graphics.setColor(LINE_COLOR)
   if self.p1:isVisible() or self.p2:isVisible() then
    love.graphics.setColor(EMERALD)
    love.graphics.setLineWidth(LINE_WIDTH + 1)
   else
    love.graphics.setColor(BLACK)
    love.graphics.setLineWidth(LINE_WIDTH)
   end
   love.graphics.line( self.p1.x, self.p1.y, self.p2.x, self.p2.y)
   love.graphics.setColor(WHITE)
end

function Line:getValue()
   --return point distance of that is closest of the 2 points
   return self.value
end

function Line:getFirst()
  return self.p1:getFirst()
end

function Line.static:length(x,y)
   return math.sqrt(x*x + y*y)
end

function Line.static:dist(x1,y1,x2,y2)
   return Line.static:length(x1-x2, y1-y2)
end

return Line

