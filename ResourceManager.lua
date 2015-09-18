ResourceManager = Class('ResourceManager')


function ResourceManager:initialize()
	self.images = {}
	self.sounds = {}
	--[[print(
	[[Loading assets:
	All .mp3 files in sounds/ and subfolders
	All .png files in images/ and subfolders
	Note that all files of the same type must have unique names)
    ]]
	--love.graphics.setDefaultFilter("nearest", "nearest")
	self:loadAssets("sounds")
	self:loadAssets("images")
end

function ResourceManager:loadAssets(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	for k,v in ipairs(files) do
		if love.filesystem.isDirectory(dir.."/"..v) then
			self:loadAssets(dir .."/"..v)
		elseif love.filesystem.isFile(dir.."/"..v) then
			local tokens = self:split(v,"\\.")
			for i,token in ipairs(tokens) do
				if token == "mp3" then
					self:loadSound(dir,v)
				elseif token == "png" then
					self:loadImage(dir,v)
				end
			end
		else
			print("Unknown folder element: " .. v)
		end
	end
end

function ResourceManager:loadSound(dir,name)
	self.sounds[name] = love.audio.newSource(dir .. "/".. name)
end

function ResourceManager:loadImage(dir,name)
	self.images[name] = love.graphics.newImage( dir .. "/" .. name )
end

function ResourceManager:getImg(name)
	if self.images[name] then
		return self.images[name]
	end
end

function ResourceManager:getSound(name)
	if self.sounds[name] then
		return self.sounds[name]
	end
end

function ResourceManager:split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
	
end

return ResourceManager


