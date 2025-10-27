-- [Aimlock FFA - Fixed Final Version]
-- Watermark-style UI | Functional Drag | Working ESP toggle | Unlock on death | Optimized

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // State
local aimlockEnabled = false
local isLocked = false
local lockedTarget = nil
local espEnabled = true
local espFrames = {}
local connections = {}

-- // UI Setup (same as your watermark)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 40)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = ScreenGui

local InnerFrame = Instance.new("Frame")
InnerFrame.Size = UDim2.new(1, -2, 1, -2)
InnerFrame.Position = UDim2.new(0, 1, 0, 1)
InnerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InnerFrame.BorderSizePixel = 0
InnerFrame.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 160, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "[Da Hood: Aimlock]"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = InnerFrame

local AimlockToggle = Instance.new("TextButton")
AimlockToggle.Size = UDim2.new(0, 75, 0, 22)
AimlockToggle.Position = UDim2.new(0, 195, 0, 9)
AimlockToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimlockToggle.BorderColor3 = Color3.fromRGB(70, 70, 70)
AimlockToggle.Text = "Aim: OFF"
AimlockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimlockToggle.Font = Enum.Font.Code
AimlockToggle.TextSize = 13
AimlockToggle.Parent = InnerFrame

local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(0, 75, 0, 22)
EspToggle.Position = UDim2.new(0, 280, 0, 9)
EspToggle.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
EspToggle.BorderColor3 = Color3.fromRGB(70, 70, 70)
EspToggle.Text = "ESP: ON"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.Code
EspToggle.TextSize = 13
EspToggle.Parent = InnerFrame

-- Status label (toolbar notifier)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 400, 0, 30)
StatusLabel.Position = UDim2.new(0.5, -200, 0.83, 50) -- moved up by 30px
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 16
StatusLabel.Text = "Not currently locking onto anybody"
StatusLabel.Parent = ScreenGui

-- Notification (bottom right)
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 200, 0, 30)
NotificationFrame.Position = UDim2.new(1, -210, 1, -240)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotificationFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
NotificationFrame.BorderSizePixel = 1
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local NotificationLabel = Instance.new("TextLabel")
NotificationLabel.Size = UDim2.new(1, -10, 1, 0)
NotificationLabel.Position = UDim2.new(0, 5, 0, 0)
NotificationLabel.BackgroundTransparency = 1
NotificationLabel.Font = Enum.Font.Code
NotificationLabel.TextSize = 14
NotificationLabel.TextXAlignment = Enum.TextXAlignment.Left
NotificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NotificationLabel.TextTransparency = 1
NotificationLabel.Parent = NotificationFrame

-- Notification fade in/out
local function showNotification(msg)
	if not msg then return end
	local textWidth = TextService:GetTextSize(msg, NotificationLabel.TextSize, NotificationLabel.Font, Vector2.new(2000, 100)).X
	local width = math.clamp(textWidth + 20, 140, 380)
	local screenW = Camera.ViewportSize.X
	local finalX = screenW - width - 10
	local startX = screenW + 10

	NotificationLabel.Text = msg
	NotificationFrame.Size = UDim2.new(0, width, 0, 30)
	NotificationFrame.Position = UDim2.new(0, startX, 1, -240)
	NotificationFrame.Visible = true
	NotificationFrame.BackgroundTransparency = 1
	NotificationLabel.TextTransparency = 1

	local tweenIn = TweenService:Create(NotificationFrame, TweenInfo.new(0.3), {Position = UDim2.new(0, finalX, 1, -240), BackgroundTransparency = 0})
	local textIn = TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {TextTransparency = 0})
	tweenIn:Play()
	textIn:Play()
	tweenIn.Completed:Wait()
	task.wait(2.4)
	local tweenOut = TweenService:Create(NotificationFrame, TweenInfo.new(0.3), {Position = UDim2.new(0, startX, 1, -240), BackgroundTransparency = 1})
	local textOut = TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {TextTransparency = 1})
	tweenOut:Play()
	textOut:Play()
	tweenOut.Completed:Wait()
	NotificationFrame.Visible = false
end

-- // Drag functionality
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)
MainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-----------------------------------------------------
-- [ESP Creation & Management]
-----------------------------------------------------
local function removeESP(player)
	if espFrames[player] then
		for _, obj in pairs(espFrames[player]) do
			if typeof(obj) == "Instance" then obj:Destroy() end
		end
		espFrames[player] = nil
	end
end

local function createESP(player)
	if player == LocalPlayer or not player.Character then return end
	local head = player.Character:FindFirstChild("Head")
	if not head then return end

	removeESP(player)

	local gui = Instance.new("BillboardGui")
	gui.Adornee = head
	gui.Size = UDim2.new(0, 120, 0, 20)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = espEnabled
	gui.Parent = ScreenGui

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.Code
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = player.DisplayName
	label.Parent = gui

	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(0, 255, 0)
	h.FillTransparency = 1
	h.OutlineTransparency = 1
	h.Adornee = player.Character
	h.Parent = player.Character

	espFrames[player] = {gui = gui, label = label, highlight = h}

	-- Handle respawn
	if connections[player] then connections[player]:Disconnect() end
	connections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if espEnabled then
			createESP(player)
		end
	end)
end

-----------------------------------------------------
-- [Toggles]
-----------------------------------------------------
AimlockToggle.MouseButton1Click:Connect(function()
	aimlockEnabled = not aimlockEnabled
	AimlockToggle.Text = "Aim: " .. (aimlockEnabled and "ON" or "OFF")
	AimlockToggle.BackgroundColor3 = aimlockEnabled and Color3.fromRGB(10,10,10) or Color3.fromRGB(50,50,50)
	if not aimlockEnabled then
		isLocked = false
		lockedTarget = nil
		StatusLabel.Text = "Not currently locking onto anybody"
	end
end)

EspToggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	EspToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
	EspToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(10,10,10) or Color3.fromRGB(50,50,50)

	for player, data in pairs(espFrames) do
		if data.gui then data.gui.Enabled = espEnabled end
	end
end)

-----------------------------------------------------
-- [Aimlock Input]
-----------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Q and aimlockEnabled then
		if not isLocked then
			local mouse = UserInputService:GetMouseLocation()
			local closest, dist = nil, math.huge
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local pos, visible = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
					if visible then
						local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
						if d < dist then
							dist = d
							closest = p
						end
					end
				end
			end
			if closest then
				lockedTarget = closest
				isLocked = true
				StatusLabel.Text = "Locked onto: " .. closest.Name
				showNotification("Locked onto " .. closest.Name)
			end
		else
			isLocked = false
			lockedTarget = nil
			StatusLabel.Text = "Not currently locking onto anybody"
		end
	end
end)

-----------------------------------------------------
-- [Main Loop - checks death, updates visibility]
-----------------------------------------------------
RunService.Heartbeat:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if not espEnabled then
				removeESP(p)
			else
				if not espFrames[p] then createESP(p) end
				local data = espFrames[p]
				if data and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local _, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
					data.gui.Enabled = onScreen

					local hum = p.Character:FindFirstChild("Humanoid")
					if not hum or hum.Health <= 0 then
						removeESP(p)
						if p == lockedTarget then
							isLocked = false
							lockedTarget = nil
							StatusLabel.Text = "Not currently locking onto anybody"
						end
					else
						local h = data.highlight
						if h then
							local goal = onScreen and 0.7 or 1
							h.FillTransparency = h.FillTransparency + (goal - h.FillTransparency) * 0.25
							h.OutlineTransparency = h.FillTransparency + 0.2
							h.FillColor = (isLocked and lockedTarget == p)
								and Color3.fromRGB(255, 0, 0)
								or Color3.fromRGB(0, 255, 0)
						end
						data.label.TextColor3 = (isLocked and lockedTarget == p)
							and Color3.fromRGB(255, 0, 0)
							or Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end
	end

	-- Aimlock follow
	if isLocked and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
		local hum = lockedTarget.Character:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then
			isLocked = false
			lockedTarget = nil
			StatusLabel.Text = "Not currently locking onto anybody"
			return
		end
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
	end
end)

-- Initial ESP build
for _, p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer and p.Character then
		createESP(p)
	end
end

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
	if p == lockedTarget then
		isLocked = false
		lockedTarget = nil
		StatusLabel.Text = "Not currently locking onto anybody"
	end
end)
