--To do:
--make screen a table with properties

--Draw pixels on screen with frames.
local player = game.Players.LocalPlayer
local canvasModule = require(game.ReplicatedStorage.Canvas)
local canvas = canvasModule.new()
local screenPixels = {}
local pixelSize = 2 --size of pixels
local resX, resY = 100, 100 --size of screen

function makeScreen(size, position)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = player.PlayerGui
	local screen = Instance.new("Frame")
	screen.Size = size
	screen.Position = position
	screen.BorderSizePixel = 0
	screen.Parent = screenGui
	return screen
end

function makeFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,pixelSize,0,pixelSize)
	frame.BorderSizePixel = 0
	return frame
end

local screen = makeScreen(
	UDim2.new(0,resX*pixelSize,0,resY*pixelSize),
	UDim2.new(0.5, -(resX*pixelSize)/2, 0.5, -(resY*pixelSize)/2)
)

function test(i) --test pixel manipulation
	local sizeX, sizeY = canvas:GetSize()
	local c1 = {173,60,113}
	local c2 = {62,193,167}
	for x = 1, sizeX do
		for y = 1, sizeY do
			local noise = (1+math.noise(x/15,y/15,i))
			canvas:SetPixel(
				x, y, {
					c1[1]*(1-noise)+c2[1]*noise,
					c1[2]*(1-noise)+c2[2]*noise,
					c1[3]*(1-noise)+c2[3]*noise
				}
			)
		end
	end
end

function clearScreen()
	for i = 1, #screenPixels do
		screenPixels[i]:Destroy()
		screenPixels[i] = nil
	end
end

--only to be used to setup the screen or import data.
function drawPixelData(pixelData)
	clearScreen()
	for i = 1, #pixelData do
		local r,g,b = pixelData[i][1], pixelData[i][2], pixelData[i][3]
		local pixelFrame = makeFrame()
		pixelFrame.BackgroundColor3 = Color3.new(r/255, g/255, b/255)
		pixelFrame.Position = UDim2.new(0, ((i-1)%resX)*pixelSize, 0 , math.floor((i-1)/resX)*pixelSize)
		pixelFrame.Parent = screen
		screenPixels[i] = pixelFrame
	end
end

--update screen frame when associated pixel changes
canvas.onPixelChange(function(x,y)
	local sX,sY = resX, resY
	local pixel = canvas:GetPixel(x,y)
	print(pixel)
	local r,g,b = pixel[1], pixel[2], pixel[3]
	screenPixels[sX*y - (sX-x)].BackgroundColor3 = Color3.new(r/255, g/255, b/255)
end)

function isOnScreen(screen,x,y)
	local size = screen.AbsoluteSize
	local position = screen.AbsolutePosition
	return (
		 x >= position.X and
		 x <= position.X + size.X and
		 y <= position.Y + size.Y and
		 y >= position.Y
	)
end

--get the pixel coordinates from the mouse position on the screen.
function mouseToPixelPosition(screen, x, y)
	if not isOnScreen(screen, x, y) then
		return 0,0
	else
		local position = screen.AbsolutePosition
		return math.floor((x - position.X)/pixelSize), math.floor((y - position.Y)/pixelSize)
	end
end

--setup screen and canvas
canvas:SetSize(resX,resY)
drawPixelData(canvas.pixelData)

local mouse = player:GetMouse()
local mouseDown = false

mouse.Button1Down:connect(function()
	mouseDown = true
end)

mouse.Button1Up:connect(function()
	mouseDown = false
end)

mouse.Move:connect(function()
	if mouseDown then
		if isOnScreen(screen, mouse.X, mouse.Y) then
			--draw on screen
			local x, y = mouseToPixelPosition(screen, mouse.X, mouse.Y)
			canvas:SetPixel(x, y, {0,0,0})
		end
	end
end)

--[[local i = 0
while wait(0.05) do
	i = i + 0.04
	test(i)
end--]]
