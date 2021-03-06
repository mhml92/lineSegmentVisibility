require "socket"
local MainScene = Class("MainScene", Scene)
local Menu = require 'entities/Menu'
local CameraManager = require 'CameraManager'
local Point = require 'entities/Point'
local Line = require 'entities/Line'
local Grid = require 'entities/Grid'
local ActionManager = require 'ActionManager'

local RBTree = require 'RBTree/RBTree'
local LV = require 'LineVisibility/LV'

---------------------------------------------------------------------
--										INITIALIZE
---------------------------------------------------------------------
function MainScene:initialize()
   Scene:initialize(resmgr)
   self.menu = Menu:new(0,0,self)
   self.cammgr = CameraManager:new(self)
   self.actmgr = ActionManager:new(self)
   self:defineLayers()
   self.p = nil
   self.points = {}
   self.lines = {}
   self.grid = Grid:new(self)
   self.easterBG = false

   self:addEntity(self.grid) 
   -----------------------------------------------------------------
   -- READ INPUT FILE
   -----------------------------------------------------------------
   inputArg = arg[2] or nil
   print(inputArg)
   if inputArg then
      io.input(inputArg)
      while true do
         local line = io.read()
         if line == nil then break end
      
         -- trim all whitespace
         line = line:gsub("%s+", "")
         if line:sub(1,1) ~= "#" and line ~= "" then
            local pList = {}
            -- split line on ';'
            for s in line:gmatch('([^;%s]+)') do
               pval =  {}
               for val in s:gmatch('([^,%s]+)') do
                  table.insert(pval,val)
               end
               table.insert(pList,Point:new(GRID_X * pval[1],GRID_Y * pval[2],self))  
            end
            if #pList == 1 then
               self.p = pList[1]
               self:addEntity(self.p)
               self.p:setViewPoint()
               self.cammgr:setCenter(self.p.x,self.p.y)
            else 
               local line = Line:new(pList[1],pList[2],self)
               table.insert(self.lines, line)

               self:addEntity(line)
               self:addEntity(pList[1])
               self:addEntity(pList[2])
               table.insert(self.points,pList[1])
               table.insert(self.points,pList[2])
            end
         end
      end
      if self.p == nil then
         self.p = Point(0,0,self)
         self:addEntity(self.p)
         self.p:setViewPoint()
         self.cammgr:setCenter(self.p.x,self.p.y)
      end
   else
      self.p = Point(0,0,self)
      self:addEntity(self.p)
      self.p:setViewPoint()
      self.cammgr:setCenter(self.p.x,self.p.y)
      msg = [[ 
      +-----------------------------------------+
      | No input given - Build some yourself :) | 
      +-----------------------------------------+
      ]]
      print(msg)
   end
   self.LV = LV:new(self.points,self.lines,self.p,self)
   self:easter(inputArg)
end

function MainScene:easter(file)
if file then
	local t={} ; i=1
	for str in string.gmatch(file, "([^".."/".."]+)") do
		t[i] = str
		i = i + 1
	end
   if t[#t] == "asteroids.txt" then
      print("HAPPY EASTER!!!!")
      self.actmgr.snap = false
      self.easterBG = true
      self.grid:setActive(false)
      POINT_MARKED_COLOR = OFFWHITE 
      POINT_COLOR_VISIBLE = WHITE
      POINT_COLOR = DARKGREY
      POINT_LINE_COLOR = DARKGREY


      VIEW_POINT_COLOR = OFFWHITE 
      VIEW_POINT_LINE_COLOR = OFFWHITE
      --------------------------------
      --  LINE SEGMENT 
      --------------------------------
      LINE_COLOR = DARKGREY
      LINE_COLOR_VISIBLE = WHITE 

      --------------------------------
      -- GRID
      --------------------------------
      GRID_LINE_COLOR = OFFBLACK

      SHADOW_COLOR = BLACK
   end
end
end

function MainScene:defineLayers()

   self:addLayer("Grid")
   self:addLayer("Line")
   self:addLayer("Point")
end
---------------------------------------------------------------------
--										UPDATE
---------------------------------------------------------------------
function MainScene:update(dt)
   self.LV:update(dt)
   local mx,my = love.mouse.getPosition()
   self.actmgr:update(dt)
   self.cammgr:update(mx,my,dt)
   self.menu:update(dt)

   for i=#self.entities, 1, -1 do
      if self.entities[i]:isAlive() == false then
         if self.entities[i].body then
            self.entities[i].body:destroy()
         end
         table.remove(self.entities, i);
      else
         if self.entities[i]:isActive() then
            self.entities[i]:update(dt)
         end
      end
   end
   self.mouseDown["wd"] = nil
   self.mouseDown["wu"] = nil
end

---------------------------------------------------------------------
--										DRAW
---------------------------------------------------------------------
function MainScene:draw()
   if self.easterBG then
      love.graphics.setColor(10,10,10)
      love.graphics.rectangle("fill", 0, 0, love.window.getDimensions() )
      love.graphics.setColor(WHITE)
   end

   -- sort entities by their layer
   table.sort(self.entities,
   function(a,b) 
      if a.layer < b.layer then 
         return true 
      elseif a.layer == b.layer then 
         if a.id < b.id then 
            return true 
         else 
            return false 
         end 
      else 
         return false 
      end 
   end)

   self.cammgr:attach()	
   self.LV:draw()
   for i, v in ipairs(self.entities) do
      if v:isActive() then
         v:draw()
      end
   end
   self.cammgr:detach()
   self.menu:draw()
end

---------------------------------------------------------------------
--                            FUNCTIONS
---------------------------------------------------------------------
--[[
function Scene:keypressed(key)
   --quick hack, update lv on each step
   if key == "r" then
      self.LV = LV:new(self.points,self.lines,self.p,self)
   end
end
]]
return MainScene
