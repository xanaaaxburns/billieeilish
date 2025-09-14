local placeId = game.PlaceId

if placeId == 2788229376 then
    loadstring(game:HttpGet(`https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/dhsczx.lua`))()
else
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "Infinite Yield",
        Text = "Do you want to run Infinite Yield?",
        Duration = 10,
        Button1 = "Yes",
        Button2 = "No",
        Icon = "rbxassetid://126864685454351",
        Callback = function(button)
            if button == "Yes" then
                loadstring(game:HttpGet('https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/bilyield'))()
            else
                script:Destroy()
            end
        end
    })
end
