local canvas = {}
function CopyTable(t) --make shallow copy. sufficient for the data dealt with
	local copy = {}
	for i,v in pairs(t) do
		copy[i] = v
	end
	return copy
end

function canvas.new()
	local canvas = {}
	canvas.color = {255,255,255} --default color of canvas
	canvas.size = {0,0}
	canvas.listeners = {}
	canvas.pixelData = {}
	--[[Data Format: {r,g,b}
		will re-evaluate format if data operations become costly.
		The addition of an alpha property may be considered if layers are added.
	--]]

	--set the canvas size, first iteration will not retain previous canvas data.
	function canvas:SetSize(x,y)
		local i = 1
		canvas.size = {x, y}
		for col = 1,x do
			for row = 1,y do
				canvas.pixelData[i] = CopyTable(canvas.color)
				i = i + 1
			end
		end
	end
	--get the size of the canvas - returns tuple x,y
	function canvas:GetSize()
		return canvas.size[1], canvas.size[2]
	end
	--get pixel data for the given coordinates - returns pixel {r,g,b}
	function canvas:GetPixel(x,y)
		local sX,sY = canvas:GetSize()
		return CopyTable(canvas.pixelData[sX*y - (sX-x)])
	end
	--set pixel data for the given coordinates
	function canvas:SetPixel(x,y, data)
		local sX,sY = canvas.size[1], canvas.size[2]--canvas:GetSize()
		canvas.pixelData[sX*y - (sX-x)] = data
		canvas.firePixelChange(x,y)
	end

	function canvas.onPixelChange(func)
		table.insert(canvas.listeners, func)
	end
	function canvas.firePixelChange(x,y)
		for _, listener in pairs(canvas.listeners) do
			listener(x,y)
		end
	end
	return canvas
end

return canvas
