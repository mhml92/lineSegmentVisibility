local Entity = Class("Entity")

function Entity:initialize(scene)
    self.id = nil
    self.layer = nil
    self.active = true
    self.alive  = true
    self.scene = scene
    self.key = self.scene.key
    self.mouse = self.scene.mouse
    self.flags = {}
end

function Entity:update(dt)
end

function Entity:draw()
end

function Entity:kill()
    self.alive = false
end

function Entity:isAlive()
    return self.alive;
end

function Entity:setActive(value)
    self.active = value
end

function Entity:isActive()
    return self.active
end

function Entity:applyForce(x,y)
    print("implement applyForce")
end

function Entity:setId(id)
    self.id = id
end

function Entity:setLayer(layer)
    self.layer = layer
end


function Entity:exit()

end

return Entity
