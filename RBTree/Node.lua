local Node = Class('Node')

function Node:initialize(color,keyObject,valueObject,left,right,p)
    self.color = color
    self.keyObject = keyObject
    self.valueObject = valueObject
    self.left = left or self
    self.right = right or self
    self.p = p or self
end

function Node:getKey()
    return self.keyObject:getValue()
end

function Node:getKeyObject()
   return self.keyObject
end

function Node:getValue()
	return self.valueObject
end

return Node
