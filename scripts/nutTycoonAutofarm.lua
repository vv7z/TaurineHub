-- Minimal, clean executor UI for automation toggles
-- All toggles OFF by default; numeric defaults preserved

-- ==============================
-- STATE (BOUND TO UI)
-- ==============================
local AutoCollect        = false
local collectDelay       = 0

local AutoProcess        = false
local autoProcessDelay   = 10

local AutoCollectMoney   = false
local autoCollectDelay   = 10

local autoObby           = false -- fixed internal 119s
local AutoItemRain       = false

-- ==============================
-- INTERNAL FLAGS (DO NOT EXPOSE)
-- ==============================
local ForceTouch = true

-- ==============================
-- SERVICES
-- ==============================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local username = lp.Name

-- ==============================
-- CHARACTER
-- ==============================
local function getChar()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Head")
end
local character, humanoid, hrp, head = getChar()
lp.CharacterAdded:Connect(function()
    character, humanoid, hrp, head = getChar()
end)

-- ==============================
-- TOUCH HELPER (ZERO DELAY)
-- ==============================
local function fireTouch(part)
    if not ForceTouch or not firetouchinterest then return end
    firetouchinterest(head, part, false)
    task.wait(0)
    firetouchinterest(head, part, true)
end

-- ==============================
-- COLLECTOR LOOP
-- ==============================
local tempFolder = Workspace:WaitForChild("Temp")

task.spawn(function()
    while true do
        if AutoCollect then
            for _, obj in ipairs(tempFolder:GetChildren()) do
                if not AutoCollect then break end
                if obj.Name == username then
                    local hitbox = obj:FindFirstChild("Hitbox", true)
                    if hitbox and hitbox:IsA("BasePart") then
                        fireTouch(hitbox)
                        task.wait(collectDelay > 0 and collectDelay or 0)
                    end
                end
            end
        end
        task.wait(0)
    end
end)

-- ==============================
-- AUTO PROCESS
-- ==============================
task.spawn(function()
    while true do
        if AutoProcess then
            local tycoon = Workspace:FindFirstChild("Tycoons") and Workspace.Tycoons:FindFirstChild(username)
            local button = tycoon and tycoon:FindFirstChild("Buttons")
                and tycoon.Buttons:FindFirstChild("ButtonProcess")
                and tycoon.Buttons.ButtonProcess:FindFirstChild("Button")
            if button and button:IsA("BasePart") then fireTouch(button) end
            local t0 = os.clock()
            while AutoProcess and os.clock() - t0 < autoProcessDelay do task.wait(0) end
        else
            task.wait(0)
        end
    end
end)

-- ==============================
-- AUTO COLLECT MONEY
-- ==============================
task.spawn(function()
    while true do
        if AutoCollectMoney then
            local tycoon = Workspace:FindFirstChild("Tycoons") and Workspace.Tycoons:FindFirstChild(username)
            local button = tycoon and tycoon:FindFirstChild("Buttons")
                and tycoon.Buttons:FindFirstChild("ButtonCollect")
                and tycoon.Buttons.ButtonCollect:FindFirstChild("Button")
            if button and button:IsA("BasePart") then fireTouch(button) end
            local t0 = os.clock()
            while AutoCollectMoney and os.clock() - t0 < autoCollectDelay do task.wait(0) end
        else
            task.wait(0)
        end
    end
end)

-- ==============================
-- AUTO OBBY (119s FIXED)
-- ==============================
task.spawn(function()
    while true do
        if autoObby then
            local endPart = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Obby") and Workspace.Map.Obby:FindFirstChild("End")
            if endPart and endPart:IsA("BasePart") and hrp then
                hrp.CFrame = endPart.CFrame + Vector3.new(0,3,0)
            end
            local t0 = os.clock()
            while autoObby and os.clock() - t0 < 119 do task.wait(0) end
        else
            task.wait(0)
        end
    end
end)

-- ==============================
-- AUTO ITEM RAIN (SEARCH TouchInterest)
-- ==============================
task.spawn(function()
    local rainFolder = Workspace:WaitForChild("ItemRainItems")
    while true do
        if AutoItemRain then
            local found = false
            for _, inst in ipairs(rainFolder:GetDescendants()) do
                if not AutoItemRain then break end
                if inst:IsA("TouchTransmitter") then
                    local part = inst.Parent
                    if part and part:IsA("BasePart") then
                        found = true
                        fireTouch(part)
                    end
                end
            end
            if not found then
                local t0 = os.clock()
                while AutoItemRain and os.clock() - t0 < 5 do task.wait(0) end
            else
                task.wait(0)
            end
        else
            task.wait(0)
        end
    end
end)

-- ============================== UI ==============================

local gui = Instance.new("ScreenGui")
gui.Name = "NutTycoonAutofarmUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)

local window = Instance.new("Frame", gui)
window.Size = UDim2.fromOffset(360, 0)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
window.BorderSizePixel = 0
window.AutomaticSize = Enum.AutomaticSize.Y

Instance.new("UICorner", window).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", window)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(60, 60, 66)

-- Titlebar (drag only here)
local titleBar = Instance.new("Frame", window)
titleBar.Size = UDim2.fromOffset(360, 44)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "Nut Tycoon Autofarm"
title.Font = Enum.Font.GothamSemibold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,240)

-- Drag logic
do
    local dragging, startPos, startFrame
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = i.Position
            startFrame = window.Position
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - startPos
            window.Position = startFrame + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)
end

-- Content
local content = Instance.new("Frame", window)
content.Position = UDim2.fromOffset(0, 44)
content.Size = UDim2.fromScale(1, 0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1

local list = Instance.new("UIListLayout", content)
list.Padding = UDim.new(0, 10)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding", content)
padding.PaddingBottom = UDim.new(0, 12)

-- Helpers


local function toggle(text, get, set)
    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(320, 42)
    row.BackgroundColor3 = Color3.fromRGB(36,36,40)
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.fromOffset(12,0)
    lbl.Size = UDim2.fromScale(0.7,1)
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235,235,240)

    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.fromOffset(44,24)
    sw.Position = UDim2.new(1,-56,0.5,-12)
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.fromOffset(20,20)
    knob.Position = UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = Color3.fromRGB(245,245,250)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local function refresh()
        if get() then
            sw.BackgroundColor3 = Color3.fromRGB(222,122,197)
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(22,2)}):Play()
        else
            sw.BackgroundColor3 = Color3.fromRGB(58,58,64)
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(2,2)}):Play()
        end
    end

    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            set(not get())
            refresh()
        end
    end)

    refresh()
end

local function slider(text, min, max, get, set)
    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(320, 66)
    row.BackgroundColor3 = Color3.fromRGB(36,36,40)
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.fromOffset(12,8)
    lbl.Size = UDim2.new(1, -24, 0, 18)
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235,235,240)

    local val = Instance.new("TextLabel", row)
    val.Parent = row
    val.BackgroundTransparency = 1
    val.Position = UDim2.new(1, -72, 0, 8)
    val.Size = UDim2.fromOffset(60, 18)
    val.Font = Enum.Font.Gotham
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextColor3 = Color3.fromRGB(170,170,180)
    val.ZIndex = 3

    local bar = Instance.new("Frame", row)
    bar.Position = UDim2.fromOffset(12, 38)
    bar.Size = UDim2.fromOffset(296, 8)
    bar.BackgroundColor3 = Color3.fromRGB(58,58,64)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(222,122,197)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.fromScale(0, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(245,245,250)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local displayA = 0
    local targetA = 0
    local dragging = false

    local function clampValue(v)
        v = math.clamp(v, min, max)
        return math.floor(v + 0.5)
    end

    local function valueToAlpha(v)
        if max == min then return 0 end
        return (v - min) / (max - min)
    end

    local function alphaToValue(a)
        return clampValue(min + (max - min) * math.clamp(a, 0, 1))
    end

    local function refresh(instant)
        local v = clampValue(get())
        local a = valueToAlpha(v)
        targetA = a
        if instant then displayA = a end

        fill.Size = UDim2.fromScale(displayA, 1)
        knob.Position = UDim2.fromScale(displayA, 0.5)
        val.Text = string.format("%ds", v)
    end

    local rsConn
    rsConn = RunService.RenderStepped:Connect(function()
        if not row.Parent then
            rsConn:Disconnect()
            return
        end
        displayA = displayA + (targetA - displayA) * 0.35
        fill.Size = UDim2.fromScale(displayA, 1)
        knob.Position = UDim2.fromScale(displayA, 0.5)
    end)

    local function setFromX(x)
        local a = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        local v = alphaToValue(a)
        set(v)
        targetA = valueToAlpha(v)
        val.Text = string.format("%ds", v)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(i.Position.X)
        end
    end)

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(i.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(i.Position.X)
        end
    end)

    refresh(true)
end

-- Build UI (no group labels)
toggle("Auto Collect", function() return AutoCollect end, function(v) AutoCollect = v end)
slider("Collect Delay", 0, 10, function() return collectDelay end, function(v) collectDelay = v end)

toggle("Auto Process", function() return AutoProcess end, function(v) AutoProcess = v end)
slider("Process Delay", 1, 30, function() return autoProcessDelay end, function(v) autoProcessDelay = v end)

toggle("Auto Collect Money", function() return AutoCollectMoney end, function(v) AutoCollectMoney = v end)
slider("Collect Money Delay", 1, 30, function() return autoCollectDelay end, function(v) autoCollectDelay = v end)

toggle("Auto Obby", function() return autoObby end, function(v) autoObby = v end)

toggle("Auto Collect Rain", function() return AutoItemRain end, function(v) AutoItemRain = v end)
