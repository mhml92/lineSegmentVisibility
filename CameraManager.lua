local humpCamera  = require 'hump/camera'

local CameraManager = Class('CameraManager')

function CameraManager:initialize(scene)
    self.scene = scene
    self.cam = humpCamera(0,0)

    self.zoom = ZOOM_DEFAULT
    self.x = 0
    self.y = 0
    self.mx = nil
    self.my = nil
    self.menuOffset = self.scene.menu.width/2

end

function CameraManager:setCenter(x,y)
    self.x = x
    self.y = y
end

function CameraManager:update(x,y,dt)
    local cx,cy = self.cam:worldCoords(x,y)
    if self.scene.mouseDown["r"] then
        if self.mx == nil then
            self.mx = cx
            self.my = cy
        end
            self.x = self.x + (self.mx-cx)
            self.y = self.y + (self.my-cy)
    else
        self.mx = nil
        self.my = nil
    end
    if self.scene.mouseDown["wu"] then
        self.zoom = self.zoom + ZOOM_STRENGTH*self.zoom
        if self.zoom > ZOOM_MAXIMUM then self.zoom = ZOOM_MAXIMUM end
    elseif self.scene.mouseDown["wd"] then
        self.zoom = self.zoom - ZOOM_STRENGTH*self.zoom
        if self.zoom < ZOOM_MINIMUM then self.zoom = ZOOM_MINIMUM end
    end
    -- Update camera
    self.cam:zoomTo(self.zoom)
    self.cam:lookAt(self.x-(self.menuOffset/self.zoom),self.y)
end

function CameraManager:attach()
    self.cam:attach()
end

function CameraManager:detach()
    self.cam:detach()
end

return CameraManager
