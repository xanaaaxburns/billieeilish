
-- Modern Minimalist Roblox UI Library
-- Usage:
-- local UILib = require(path_to_this_module)
-- local ui = UILib.new({Keybind = Enum.KeyCode.Q})
-- local tab1 = ui:AddTab("Main", "📁")
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
        Size = UDim2.new(0, 480, 0, 320),
        Position = UDim2.new(0.5, -240, 0.5, -160),
        BackgroundColor3 = Color3.fromRGB(23, 23, 28),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = screenGui,
        Active = true,
        Draggable = true
    })
    self._frame = frame

    local sidebar = create("Frame", {
        Size = UDim2.new(0, 56, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(32, 34, 37),
        BorderSizePixel = 0,
        Parent = frame
    })
    self._sidebar = sidebar

    local title = create("TextLabel", {
        Text = "Minimalist UI",
        Font = Enum.Font.GothamSemibold,
        TextSize = 22,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -56, 0, 40),
        Position = UDim2.new(0, 56, 0, 0),
        Parent = frame,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    self._title = title

    local content = create("Frame", {
        Size = UDim2.new(1, -56, 1, -40),
        Position = UDim2.new(0, 56, 0, 40),
        BackgroundColor3 = Color3.fromRGB(28, 29, 34),
        BorderSizePixel = 0,
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

function UILib:AddTab(tabName, icon)
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
            Font = Enum.Font.Code,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            BackgroundColor3 = Color3.fromRGB(40, 42, 50),
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, 0, 0, 38),
            Position = UDim2.new(0, 0, 0, #tab._buttons * 44),
            Parent = tab._frame,
            BorderSizePixel = 0,
            AutoButtonColor = true
        })
        btn.MouseButton1Click:Connect(callback)
        table.insert(tab._buttons, btn)
        return btn
    end
    local tabBtn = create("TextButton", {
        Text = icon or tabName,
        Font = Enum.Font.Code,
        TextSize = 22,
        TextColor3 = Color3.fromRGB(180, 180, 200),
        BackgroundColor3 = Color3.fromRGB(32, 34, 37),
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 6, 0, 6 + (#self._tabs * 50)),
        Parent = self._sidebar,
        BorderSizePixel = 0,
        AutoButtonColor = true
    })
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self._tabs) do
            t._frame.Visible = false
        end
        tab._frame.Visible = true
        self._activeTab = tab
        -- Highlight selected tab
        for _, b in ipairs(self._tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(44, 48, 54)
    end)
    table.insert(self._tabs, tab)
    table.insert(self._tabButtons, tabBtn)
    if #self._tabs == 1 then
        tab._frame.Visible = true
        self._activeTab = tab
        tabBtn.BackgroundColor3 = Color3.fromRGB(44, 48, 54)
    end
    return tab
end


return UILib
