local Node = Class('Node')

function Node:initialize(color,keyObject,left,right,p)
    self.color = color
    self.keyObject = keyObject
    self.left = left --or self
    self.right = right --or self
    self.p = p --or self
end

function Node:getKey()
    return self.keyObject:getValue()
end

function Node:getObject()
	return self.keyObject
end

return Node
