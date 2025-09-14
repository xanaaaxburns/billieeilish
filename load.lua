local placeId = game.PlaceId

if placeId == 2788229376 then
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/dhsczx.lua'
        )
    )()
else
    local StarterGui = game:GetService('StarterGui')
    local callbackFunc = Instance.new('BindableFunction')
    callbackFunc.OnInvoke = function(button)
        if button == 'Yes' then
            loadstring(
                game:HttpGet(
                    'https://raw.githubusercontent.com/xanaaaxburns/billieeilish/refs/heads/main/bilyield'
                )
            )()
        else
            if script and script.Destroy then
                script:Destroy()
            end
        end
    end
    StarterGui:SetCore('SendNotification', {
        Title = 'Infinite Yield',
        Text = 'Do you want to run Infinite Yield?',
        Duration = 10,
        Button1 = 'Yes',
        Button2 = 'No',
        Icon = 'rbxassetid://112648799794015',
        Callback = callbackFunc,
    })
end
