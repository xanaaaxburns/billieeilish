local a = game.ReplicatedStorage.MainEvent
local b = {"CHECKER_1", "TeleportDetect", "OneMoreTime"}
local c
c =
    hookmetamethod(
    game,
    "__namecall",
    function(...)
        local d = {...}
        local self = d[1]
        local e = getnamecallmethod()
        local f = getcallingscript()
        if e == "FireServer" and self == a and table.find(b, d[2]) then
            return
        end
        if not checkcaller() and getfenv(2).crash then
            hookfunction(
                getfenv(2).crash,
                function()
                end
            )
        end
        return c(...)
    end
)

task.wait(3)

local loadstring_code = "loadstring" 
local StarterGui = game:GetService("StarterGui")

StarterGui:SetCore("SendNotification", {
	Title = "Da Hood Bypass enabled",
	Text = "Do not rejoin this server!",
	Duration = 10,
    Icon = "rbxassetid://126864685454351",
})

task.wait(3)

local iyCallback = Instance.new("BindableFunction")
iyCallback.OnInvoke = function(button)
    if button == "Yes" then
        loadstring(game:HttpGet('https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/bilyield'))()
    else
        return
    end
end
StarterGui:SetCore("SendNotification", {
    Title = "Infinite Yield",
    Text = "Do you want to run Infinite Yield?",
    Duration = 10,
    Button1 = "Yes",
    Button2 = "No",
    Icon = "rbxassetid://126864685454351",
    Callback = iyCallback
})

task.wait(5)

local xkCallback = Instance.new("BindableFunction")
xkCallback.OnInvoke = function(button)
    if button == "Yes" then
        loadstring(game:HttpGet('https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/kg5g.lua'))()
    else
        return
    end
end
StarterGui:SetCore("SendNotification", {
    Title = "XK5NG GUI",
    Text = "Do you want to run XK5NG GUI?",
    Duration = 10,
    Button1 = "Yes",
    Button2 = "No",
    Icon = "rbxassetid://71097348134395",
    Callback = xkCallback
})
