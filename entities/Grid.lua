local Grid = Class("Grid",Entity)

function Grid:initialize(scene)
   Entity:initialize(scene)
   self.layerName = "Grid"
end

function Grid:draw()
   -- upper left corner in world coordinates
   local ulx,uly  = self.scene.cammgr.cam:worldCoords(0,0)
   -- bottom right color in world coordinates
   local brx,bry  = self.scene.cammgr.cam:worldCoords(love.graphics.getDimensions( ))

   local offsetX = 0
   local offsetY = 0
   local dx = ulx-(ulx % GRID_X)
   --love.graphics.setLineStyle("rough")
   love.graphics.setColor(GRID_LINE_COLOR)
   while dx <= brx do
      if (dx/GRID_X) % 10 == 0 then 
         if dx == 0 then 
            love.graphics.setLineWidth(GRID_ORIGO_WIDTH)
         else
            love.graphics.setLineWidth(GRID_BOLDLINE_WIDTH)
         end
      else
         love.graphics.setLineWidth(GRID_LINE_WIDTH)
      end

      love.graphics.line(dx,uly,dx,bry)
      dx = dx + GRID_X 
   end
   dy = uly - (uly % GRID_Y)
   while dy <= bry do
      if (dy/GRID_Y) % 10 == 0 then
         if dy == 0 then 
            love.graphics.setLineWidth(GRID_ORIGO_WIDTH)
         else
            love.graphics.setLineWidth(GRID_BOLDLINE_WIDTH)
         end
      else
         love.graphics.setLineWidth(GRID_LINE_WIDTH)
      end
      love.graphics.line(ulx,dy,brx,dy)
      dy = dy + GRID_Y 
   end
   --love.graphics.setLineStyle("smooth")
   love.graphics.setColor(WHITE)
end
return Grid
