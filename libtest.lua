
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
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Centered
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(23, 23, 28),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = screenGui,
        Active = true,
        Draggable = false
    })
    self._frame = frame

    local frameCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 14)
    })
    frameCorner.Parent = frame

    -- Title bar (draggable area)
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(38, 41, 54), -- More contrast
        BorderSizePixel = 0,
        Parent = frame,
        Active = true,
        Draggable = false -- We'll handle dragging manually
    })
    -- Custom dragging logic for the whole UI
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local titleBarCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    })
    titleBarCorner.Parent = titleBar

    local title = create("TextLabel", {
        Text = "Minimalist UI",
        Font = Enum.Font.FredokaOne,
        TextSize = 22,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 16, 0, 0), -- Slightly right
        Parent = titleBar,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    self._title = title

    -- Minimize button (TextButton, emoji)
    local minimizeBtn = create("TextButton", {
        Text = "–",
        Font = Enum.Font.Gotham,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(180, 180, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -64, 0.5, -16),
        Parent = titleBar,
        BorderSizePixel = 0,
        AutoButtonColor = true
    })
    local minimizeCorner = create("UICorner", { CornerRadius = UDim.new(0, 8) })
    minimizeCorner.Parent = minimizeBtn

    -- Close button (TextButton, emoji)
    local closeBtn = create("TextButton", {
        Text = "✕",
        Font = Enum.Font.Gotham,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(220, 80, 80),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -32, 0.5, -16),
        Parent = titleBar,
        BorderSizePixel = 0,
        AutoButtonColor = true
    })
    local closeCorner = create("UICorner", { CornerRadius = UDim.new(0, 8) })
    closeCorner.Parent = closeBtn

    -- Minimize logic
    local minimized = false
    local function setMinimized(state)
        minimized = state
        frame.Visible = not minimized
    end
    minimizeBtn.MouseButton1Click:Connect(function()
        setMinimized(not minimized)
    end)

    -- Keybind for minimize (P)
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.P then
            setMinimized(not minimized)
        end
    end)

    -- Close logic
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

        local sidebar = create("Frame", {
            Size = UDim2.new(0, 56, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(32, 34, 37),
            BorderSizePixel = 0,
            Parent = frame
        })
        local sidebarCorner = create("UICorner", {
            CornerRadius = UDim.new(0, 14)
        })
        sidebarCorner.Parent = sidebar
        self._sidebar = sidebar

        -- Dark/Light mode toggle
        local isDark = true
        local function setTheme(dark)
            isDark = dark
            frame.BackgroundColor3 = dark and Color3.fromRGB(23, 23, 28) or Color3.fromRGB(235, 235, 240) -- softer offwhite
            titleBar.BackgroundColor3 = dark and Color3.fromRGB(38, 41, 54) or Color3.fromRGB(225, 225, 230) -- light gray
            sidebar.BackgroundColor3 = dark and Color3.fromRGB(32, 34, 37) or Color3.fromRGB(220, 220, 225) -- muted gray
            divider.BackgroundColor3 = dark and Color3.fromRGB(44, 48, 54) or Color3.fromRGB(210, 210, 215) -- soft divider
            content.BackgroundColor3 = dark and Color3.fromRGB(28, 29, 34) or Color3.fromRGB(240, 240, 245) -- gentle light
            title.TextColor3 = dark and Color3.fromRGB(200, 200, 210) or Color3.fromRGB(60, 60, 80) -- less harsh
        end
        local themeBtn = create("TextButton", {
            Text = isDark and "🌙" or "☀️",
            Font = Enum.Font.Gotham,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(180, 180, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 12, 1, -44),
            Parent = sidebar,
            BorderSizePixel = 0,
            AutoButtonColor = true
        })
        local themeCorner = create("UICorner", { CornerRadius = UDim.new(0, 8) })
        themeCorner.Parent = themeBtn
        themeBtn.MouseButton1Click:Connect(function()
            setTheme(not isDark)
            themeBtn.Text = isDark and "🌙" or "☀️"
        end)
        setTheme(true)

    -- Divider line between sidebar and content
    local divider = create("Frame", {
        Size = UDim2.new(0, 2, 1, -40),
        Position = UDim2.new(0, 56, 0, 40),
        BackgroundColor3 = Color3.fromRGB(44, 48, 54),
        BorderSizePixel = 0,
        Parent = frame
    })
    divider.ZIndex = 2

    local content = create("Frame", {
        Size = UDim2.new(1, -60, 1, -44),
        Position = UDim2.new(0, 60, 0, 42),
        BackgroundColor3 = Color3.fromRGB(28, 29, 34),
        BorderSizePixel = 0,
        Parent = frame
    })
    local contentCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    })
    contentCorner.Parent = content
    self._content = content

    -- Keybind to destroy UI (Q)
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
        Visible = false,
        ZIndex = 2
    })
    local tabFrameCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 10)
    })
    tabFrameCorner.Parent = tab._frame
    function tab:AddButton(text, callback)
        local btn = create("TextButton", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            BackgroundColor3 = Color3.fromRGB(40, 42, 50),
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0.92, 0, 0, 40),
            Position = UDim2.new(0.04, 0, 0, #tab._buttons * 48),
            Parent = tab._frame,
            BorderSizePixel = 0,
            AutoButtonColor = true,
            ZIndex = 3
        })
        local btnCorner = create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        })
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(callback)
        table.insert(tab._buttons, btn)
        return btn
    end
    local tabBtn = create("TextButton", {
        Text = icon or tabName or "❓",
        Font = Enum.Font.Gotham,
        TextSize = 28,
        TextColor3 = Color3.fromRGB(180, 180, 200),
        BackgroundColor3 = Color3.fromRGB(32, 34, 37),
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 6, 0, 6 + (#self._tabs * 54)),
        Parent = self._sidebar,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        ZIndex = 3
    })
    local tabBtnCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    })
    tabBtnCorner.Parent = tabBtn
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


