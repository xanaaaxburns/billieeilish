-- Minimalist Roblox UI Library
-- Usage:
-- local UILib = require(path_to_this_module)
-- local ui = UILib.new({Keybind = Enum.KeyCode.Q})
-- local tab1 = ui:AddTab("Main")
-- tab1:AddButton("Click Me", function() print("Button clicked!") end)

local UILib = {}
UILib.__index = UILib

-- Helper to create UI elements
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

function UILib.new(options)
    options = options or {}
    local self = setmetatable({}, UILib)
    local player = game:GetService("Players").LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local screenGui = create("ScreenGui", {
        Name = "MinimalistUILib",
        Parent = player:WaitForChild("PlayerGui")
    })
    self._screenGui = screenGui
    self._tabs = {}
    self._activeTab = nil
    self._tabButtons = {}

    local frame = create("Frame", {
        Size = UDim2.new(0, 400, 0, 260),
        Position = UDim2.new(0.5, -200, 0.5, -130),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = screenGui,
        Active = true,
        Draggable = true
    })
    self._frame = frame

    local title = create("TextLabel", {
        Text = "Minimalist UI",
        Font = Enum.Font.GothamSemibold,
        TextSize = 28,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = frame
    })
    self._title = title

    local tabBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = frame
    })
    self._tabBar = tabBar

    local content = create("Frame", {
        Size = UDim2.new(1, -20, 1, -106),
        Position = UDim2.new(0, 10, 0, 86),
        BackgroundTransparency = 1,
        Parent = frame
    })
    self._content = content

    -- Keybind to destroy UI
    local keybind = options.Keybind or Enum.KeyCode.Q
    self._conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == keybind then
            screenGui:Destroy()
            self._conn:Disconnect()
        end
    end)

    return self
end

function UILib:AddTab(tabName)
    local tab = {}
    tab._buttons = {}
    tab._frame = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self._content,
        Visible = false
    })
    function tab:AddButton(text, callback)
        local btn = create("TextButton", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, 0, 0, 36),
            Position = UDim2.new(0, 0, 0, #tab._buttons * 42),
            Parent = tab._frame,
            BorderSizePixel = 0
        })
        btn.MouseButton1Click:Connect(callback)
        table.insert(tab._buttons, btn)
        return btn
    end
    local tabBtn = create("TextButton", {
        Text = tabName,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, #self._tabs * 110, 0, 0),
        Parent = self._tabBar,
        BorderSizePixel = 0
    })
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self._tabs) do
            t._frame.Visible = false
        end
        tab._frame.Visible = true
        self._activeTab = tab
    end)
    table.insert(self._tabs, tab)
    table.insert(self._tabButtons, tabBtn)
    if #self._tabs == 1 then
        tab._frame.Visible = true
        self._activeTab = tab
    end
    return tab
end

return UILib
