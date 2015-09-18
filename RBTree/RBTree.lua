local RBTree = Class('RBTree')
local Node = require 'RBTree/Node'

function RBTree:initialize()

    self.null = nil
    self.root = self.null
    self.RED = 0
    self.BLACK = 1

end

function RBTree:deleteFixup(x)
    while x ~= self.root and x.color ~= self.BLACK do
        if x == x.p.left then
            w = x.p.right
            if w.color == self.RED then
                w.color = self.BLACK
                x.p.color = self.RED
                leftRotate(x.p)
                w = x.p.right
            end
            if w.left.color == self.BLACK and w.right.color == self.BLACK then
                w.color = self.RED
                x = x.p
            else
                if w.right.color == self.BLACK then
                    w.left.color = self.BLACK
                    w.color = self.RED
                    rightRotate(w)
                    w = x.p.right
                end
                w.color = x.p.color
                x.p.color = self.BLACK
                w.right.color = self.BLACK
                leftRotate(x.p)
                x = self.root
            end
        else                                                                                -- FIXED
            w = x.p.left
            if w.color == self.RED then
                w.color = self.BLACK
                x.p.color = self.RED
                rightRotate(x.p)
                w = x.p.left
            end
            if w.right.color == self.BLACK and w.left.color == self.BLACK then
                w.color = self.RED
                x = x.p
            else
                if w.left.color == self.BLACK then
                    w.right.color = self.BLACK
                    w.color = self.RED
                    leftRotate(w)
                    w = x.p.left
                end
                w.color = x.p.color
                x.p.color = self.BLACK
                w.left.color = self.BLACK
                rightRotate(x.p)
                x = self.root
            end
        end
    end
    x.color = self.BLACK
end

function RBTree:treeMinimum(x)
    while x.left ~= self.null do
        x = x.left
    end
    return x
end

function RBTree:delete(z)
    y = z
    yOriginalColor = y.color
    if z.left == self.null then
        x = z.right
        transplant(z,z.right)
    elseif z.right == self.null then
        x = z.left
        transplant(z,z.left)
    else
        y = treeMinimum(z.right)
        yOriginalColor = y.color
        x = y.right
        if y.p == z then
            x.p = z
        else
            transplant(y,y.right)
            y.right = z.right
            y.right.p = y
        end
        transplant(z,y)
        y.left = z.left
        y.left.p = y
        y.color = z.color
    end
    if yOriginalColor == self.BLACK then
        deleteFixup(x)
    end
end

function RBTree:transplant(u,v)
    if u.p == self.null then
        self.root = v
    elseif u == u.p.left then
        u.p.left = v
    else 
        u.p.right = v
    end
    v.p = u.p
end

function RBTree:insertFixup(z)
    while z.p.color == self.RED do
        if z.p == z.p.p.left then
            y = z.p.p.left
            if y.color == self.RED then
                z.p.color = self.BLACK
                y.color = self.BLACK
                z.p.p.color = self.RED
                z=z.p.p
            else
                if z == z.p.right then
                    z = z.p
                    leftRotate(z)
                end
                z.p.color = self.BLACK
                z.p.p.color = self.RED
                rightRotate(z.p.p)
            end
        else                                                    -- FIXED
            y = z.p.p.right
            if y.color == self.RED then
                z.p.color = self.BLACK
                y.color = self.BLACK
                z.p.p.color = self.RED
                z=z.p.p
            else
                if z == z.p.left then
                    z = z.p
                    rightRotate(z)
                end
                z.p.color = self.BLACK
                z.p.p.color = self.RED
                leftRotate(z.p.p)
            end
        end
    end
    self.root.color = self.BLACK
end

function RBTree:insert(z)
    y = self.null 
    x = self.root
    while x ~= self.null do
        y = x
        if z:getKey() < x:getKey() then
            x = x.left
        else
            x = x.right 
        end
    end
    z.p = y
    if y == self.null then
        self.root = z
    elseif z:getKey() < y:getKey() then
        y.left = z
    else
        y.right = z
    end
    z.left = self.null
    z.right = self.null
    z.color = self.RED
    self:insertFixup(z) 
end

function RBTree:leftRotate(x)
    local y = x.right
    x.right = y.left
    if y.left ~= self.null then
        y.left.p = x
    end
    y.p = x.p
    if x.p == self.null then
        self.root = y
    elseif x == x.p.left then
        x.p.left = y
    else 
        x.p.right = y
    end
    y.left = x
    x.p = y
end

function RBTree:rightRotate(y)
    local x = y.left
    y.left = x.right
    if x.right ~= self.null then
        x.right.p = y
    end
    x.p = y.p
    if y.p == self.null then
        self.root = x
    elseif y == y.p.right then
        y.p.right = x
    else 
        y.p.left = x
    end
    x.right = y
    y.p = x
end

return RBTree