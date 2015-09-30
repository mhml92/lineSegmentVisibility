local Menu = Class('Menu',Entity)

function Menu:initialize(x,y,scene)
   Entity:initialize(scene)
   self.x = x
   self.y = y
   self.width = BUTTONCOLUMNS*(BUTTON_ZISE+PADDING)+PADDING
   self.height = love.graphics.getHeight( )
   self.buttons = {}
   self.btnid = 0
   self.mouseDownOn = nil

   -- ADD NEW POINT MODE
   self:addButton(resmgr:getImg("move.png"),"MOVE",function(m) self.scene.actmgr:changeMode(m) end)
   self:addButton(resmgr:getImg("add.png"),"ADD",function(m) self.scene.actmgr:changeMode(m) end)
   self:addButton(resmgr:getImg("remove.png"),"REMOVE",function(m) self.scene.actmgr:changeMode(m) end)
   self:addButton(resmgr:getImg("snap.png"),"TOGGLESNAP",function(m) self.scene.actmgr:toggleSnap()  end)
   self:addButton(resmgr:getImg("print.png"),"DUMPTOFILE",function(m) self.scene.actmgr:dumpToFile()  end)
end

function Menu:addButton(image,m, func)
   table.insert(self.buttons,{
      id = self.btnid, 
      img = image,
      mode = m,
      f = func,
      x = self.x + PADDING + (self.btnid%BUTTONCOLUMNS)*(BUTTON_ZISE+PADDING),
      y = self.y + PADDING + math.floor((self.btnid)/BUTTONCOLUMNS)*(BUTTON_ZISE+PADDING) 
   })
   self.btnid = self.btnid + 1
end

function Menu:update(dt)
   if self.scene.mouseDown['l'] then
      self.mouseDownOn = self:btnDown(love.mouse.getPosition())
   end
   if self.mouseDownOn and not self.scene.mouseDown['l'] then
      self.mouseDownOn.f(self.mouseDownOn.mode)
      self.mouseDownOn = nil
   end
end

function Menu:draw()
   love.graphics.setColor(MENUBG)
   love.graphics.rectangle("fill", self.x, self.y, self.width, self.height )
   currentMode = self.scene.actmgr.MODE
   for i,btn in ipairs(self.buttons)  do
      if btn.mode == currentMode 
         or (btn.mode == "TOGGLESNAP" and self.scene.actmgr.snap )
         or btn.mode == "DUMPTOFILE" then
         
         love.graphics.setColor(BUTTON_COLOR_ACTIVE)
      else
         love.graphics.setColor(BUTTON_COLOR)
      end
      love.graphics.rectangle("fill",btn.x,btn.y,BUTTON_ZISE,BUTTON_ZISE)
      if btn.mode == currentMode 
         or (btn.mode == "TOGGLESNAP" and self.scene.actmgr.snap )
         or btn.mode == "DUMPTOFILE" then
         love.graphics.setColor(OFFWHITE)
      else
         love.graphics.setColor(TURQOUISE)
         --love.graphics.setColor(WETASPHALT)
      end
      local scale = BUTTON_ZISE/btn.img:getWidth()
      love.graphics.draw(btn.img,btn.x, btn.y,0,scale,scale)
      love.graphics.setColor(WHITE)
   end
end

function Menu:btnDown(x,y)
   for i,btn in ipairs(self.buttons) do
      if x >= btn.x and x <= btn.x+BUTTON_ZISE then 
         if y >= btn.y and y <= btn.y + BUTTON_ZISE then
            return btn
         end
      end
   end
   return nil
end


return Menu
