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
   self:addButton(resmgr:getImg("debuglines.png"),"DEBUGLINES",function(m) self.scene.drawDebugLines = not self.scene.drawDebugLines end)
   self:addButton(resmgr:getImg("step.png"),"STEP",function(m) self.scene:startStep() end)
   self:addButton(resmgr:getImg("dostep.png"),"DOSTEP",function(m) self.scene:doStep() end)
   self:addButton(resmgr:getImg("runonce.png"),"RUNONCE",function(m) self.scene:run() end)
   self:addButton(resmgr:getImg("runeachframe.png"),"RUNEACHFRAME",function(m) self.scene.runeachframe = not self.scene.runeachframe end)
   self:addButton(resmgr:getImg("screenshot.png"),"SCREENSHOT",function(m) 
      local screenshot = love.graphics.newScreenshot()
      local name = os.time() .. '.png'
      screenshot:encode(name)
      print("screenshot printed to " ..name)
      print("Can normally be found in ~/.local/share/love/lineSegmentVisibility/")
   end)
   self:addButton(resmgr:getImg("savepoints.png"),"SAVEPOINTS",function(m) 
      --output all visible lines and exit program
      local name = "output-"..os.time()..".txt"
      local f = io.output(name)
      io.write("#point\n"..self.scene.p.x/GRID_X..","..self.scene.p.y/GRID_Y.."\n\n")

      for _,line in ipairs(self.scene.lines) do
         io.write(line.p1.x/GRID_X..","..line.p1.y/GRID_Y..";"..line.p2.x/GRID_X..","..line.p2.y/GRID_Y.."\n")
      end
      f:close()
      print("File saved to " .. name)
   end)
   self:addButton(resmgr:getImg("sauron.png"),"SAURON",function(m) self.scene.sauronMode = not self.scene.sauronMode end)
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
      if btn.mode == currentMode then
         love.graphics.setColor(BUTTON_COLOR_ACTIVE)
      else
         love.graphics.setColor(BUTTON_COLOR)
      end
      love.graphics.rectangle("fill",btn.x,btn.y,BUTTON_ZISE,BUTTON_ZISE)
      if btn.mode == currentMode or self.scene.drawDebugLines and btn.mode == "DEBUGLINES" 
         or btn.mode == "STEP" and self.scene.co and coroutine.status(self.scene.co) == "suspended" 
         or self.scene.runeachframe and btn.mode == "RUNEACHFRAME" or self.scene.sauronMode and btn.mode == "SAURON"
         then
         love.graphics.setColor(OFFWHITE)
      else
         love.graphics.setColor(TURQOUISE)
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
