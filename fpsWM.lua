-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "WatermarkGui"
screenGui.ResetOnSpawn = false

-- Outer border frame
local borderFrame = Instance.new("Frame")
borderFrame.Position = UDim2.new(0, 10, 0, 10)
borderFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
borderFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
borderFrame.BorderSizePixel = 1
borderFrame.Parent = screenGui

-- Inner frame (background fill)
local innerFrame = Instance.new("Frame")
innerFrame.Size = UDim2.new(1, -2, 1, -2)
innerFrame.Position = UDim2.new(0, 1, 0, 1)
innerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
innerFrame.BorderSizePixel = 0
innerFrame.Parent = borderFrame

-- Text label
local watermarkText = Instance.new("TextLabel")
watermarkText.Size = UDim2.new(1, 0, 1, 0)
watermarkText.BackgroundTransparency = 1
watermarkText.TextColor3 = Color3.fromRGB(255, 255, 255)
watermarkText.Font = Enum.Font.Code
watermarkText.TextSize = 14
watermarkText.TextXAlignment = Enum.TextXAlignment.Left
watermarkText.Text = "[TrustXanax] | FPS: 0 | Uptime: 0s"
watermarkText.Parent = innerFrame

-- Padding and height
local paddingX = 8
local height = 22
borderFrame.Size = UDim2.new(0, 200, 0, height)

-- Variables for dragging
local dragging = false
local dragStart, startPos

-- Dragging functionality
local function onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = borderFrame.Position
	end
end

local function onInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end

local function onInputChanged(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		borderFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end

borderFrame.InputBegan:Connect(onInputBegan)
borderFrame.InputEnded:Connect(onInputEnded)
UserInputService.InputChanged:Connect(onInputChanged)

-- Variables for data
local startTime = os.time()
local fps, frameCount, lastUpdate = 0, 0, tick()

-- Function to get text width
local function getTextWidth(text)
	local size = TextService:GetTextSize(text, watermarkText.TextSize, watermarkText.Font, Vector2.new(1000, 100))
	return size.X
end

-- Update FPS and uptime
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local currentTime = tick()

	if currentTime - lastUpdate >= 1 then
		fps = math.floor(frameCount / (currentTime - lastUpdate))
		frameCount = 0
		lastUpdate = currentTime

		local uptime = os.time() - startTime
		local uptimeStr = string.format("%ds", uptime)
		if uptime >= 3600 then
			uptimeStr = string.format("%dh %dm %ds", uptime / 3600, (uptime % 3600) / 60, uptime % 60)
		elseif uptime >= 60 then
			uptimeStr = string.format("%dm %ds", uptime / 60, uptime % 60)
		end

		local newText = string.format("[TrustXanax] | FPS: %d | Uptime: %s", fps, uptimeStr)
		watermarkText.Text = newText

		-- Adjust width dynamically
		local textWidth = getTextWidth(newText)
		local totalWidth = textWidth + paddingX * 2
		borderFrame.Size = UDim2.new(0, totalWidth, 0, height)
	end
end)
