local Node = Class('Node')

function Node:initialize(color,keyObject,left,right,p)
    self.color = color
    self.keyObject = keyObject
    self.left = left
    self.right = right
    self.p = p
end

function getKey()
    return self.keyObject:getValue()
end

return Node
