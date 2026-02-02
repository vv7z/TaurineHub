-- Nut Loader UI - Complete Rewrite
-- Fixed: CoreGui placement, SafeArea ignore, loading bar, all bugs

--====================================================
-- SCRIPT CONFIGURATION
--====================================================
local GAME_SCRIPTS = {
    -- Nut Tycoon
    [114242002030103] = {
        { Name = "Nut Tycoon Autofarm", Script = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vv7z/TaurineHub/refs/heads/main/scripts/nutTycoonAutofarm.lua\"))()" },
    },
}

-- Scripts that show in ANY game
local GLOBAL_SCRIPTS = {
    { Name = "Infinite Yield", Script = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source\"))()" },
}

--====================================================
-- SETTINGS
--====================================================
local CONFIG = {
    IntroSeconds = 0.9,
    AccentColor = Color3.fromRGB(222, 122, 197),
    WindowSize = Vector2.new(420, 500),
}

--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

--====================================================
-- UTILITY FUNCTIONS
--====================================================
local function ExecuteScript(scriptString)
    local success, error = pcall(function()
        loadstring(scriptString)()
    end)
    return success, error
end

local function Tween(instance, properties, duration)
    TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties):Play()
end

--====================================================
-- CREATE GUI
--====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NutLoader_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

--====================================================
-- MAIN WINDOW
--====================================================
local Window = Instance.new("Frame")
Window.Name = "MainWindow"
Window.Size = UDim2.fromOffset(CONFIG.WindowSize.X, CONFIG.WindowSize.Y)
Window.Position = UDim2.fromScale(0.5, 0.5)
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 12)
WindowCorner.Parent = Window

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Color3.fromRGB(50, 50, 55)
WindowStroke.Thickness = 1
WindowStroke.Parent = Window

--====================================================
-- TITLE BAR
--====================================================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Window

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.fromOffset(15, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Nut Loader"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -38, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(240, 240, 245)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}, 0.15)
end)

CloseButton.MouseLeave:Connect(function()
    Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 32)}, 0.15)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Drag functionality
local Dragging = false
local DragStart = nil
local StartPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Window.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        Window.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
        )
    end
end)

--====================================================
-- CONTENT CONTAINER
--====================================================
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Size = UDim2.new(1, 0, 1, -45)
ContentContainer.Position = UDim2.fromOffset(0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Window

--====================================================
-- INTRO/LOADING SCREEN
--====================================================
local IntroFrame = Instance.new("Frame")
IntroFrame.Name = "IntroFrame"
IntroFrame.Size = UDim2.new(1, -30, 0, 120)
IntroFrame.Position = UDim2.new(0.5, 0, 0.5, -60)
IntroFrame.AnchorPoint = Vector2.new(0.5, 0.5)
IntroFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
IntroFrame.BorderSizePixel = 0
IntroFrame.Parent = ContentContainer

local IntroCorner = Instance.new("UICorner")
IntroCorner.CornerRadius = UDim.new(0, 10)
IntroCorner.Parent = IntroFrame

local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UDim2.new(1, -30, 0, 30)
IntroLabel.Position = UDim2.fromOffset(15, 20)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Text = "Loading Scripts..."
IntroLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
IntroLabel.TextSize = 14
IntroLabel.Font = Enum.Font.GothamMedium
IntroLabel.TextXAlignment = Enum.TextXAlignment.Left
IntroLabel.Parent = IntroFrame

-- Progress Bar Background
local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Size = UDim2.new(1, -30, 0, 6)
ProgressBarBG.Position = UDim2.fromOffset(15, 70)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.Parent = IntroFrame

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(1, 0)
ProgressBarCorner.Parent = ProgressBarBG

-- Progress Bar Fill
local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.fromScale(0, 1)
ProgressBarFill.BackgroundColor3 = CONFIG.AccentColor
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBG

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressBarFill

--====================================================
-- MAIN CONTENT (Hidden initially)
--====================================================
local MainContent = Instance.new("Frame")
MainContent.Name = "MainContent"
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false
MainContent.Parent = ContentContainer

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0, 15)
MainPadding.PaddingBottom = UDim.new(0, 15)
MainPadding.PaddingLeft = UDim.new(0, 15)
MainPadding.PaddingRight = UDim.new(0, 15)
MainPadding.Parent = MainContent

local MainLayout = Instance.new("UIListLayout")
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Padding = UDim.new(0, 12)
MainLayout.Parent = MainContent

--====================================================
-- WELCOME CARD
--====================================================
local WelcomeCard = Instance.new("Frame")
WelcomeCard.Name = "WelcomeCard"
WelcomeCard.Size = UDim2.new(1, 0, 0, 80)
WelcomeCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
WelcomeCard.BorderSizePixel = 0
WelcomeCard.LayoutOrder = 1
WelcomeCard.Parent = MainContent

local WelcomeCorner = Instance.new("UICorner")
WelcomeCorner.CornerRadius = UDim.new(0, 10)
WelcomeCorner.Parent = WelcomeCard

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(50, 50)
Avatar.Position = UDim2.fromOffset(15, 15)
Avatar.BackgroundTransparency = 1
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
Avatar.Parent = WelcomeCard

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Size = UDim2.new(1, -80, 0, 25)
WelcomeText.Position = UDim2.fromOffset(75, 15)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "Welcome, " .. Player.Name
WelcomeText.TextColor3 = Color3.fromRGB(240, 240, 245)
WelcomeText.TextSize = 15
WelcomeText.Font = Enum.Font.GothamBold
WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
WelcomeText.Parent = WelcomeCard

local GameText = Instance.new("TextLabel")
GameText.Size = UDim2.new(1, -80, 0, 20)
GameText.Position = UDim2.fromOffset(75, 42)
GameText.BackgroundTransparency = 1
GameText.Text = "Loading game info..."
GameText.TextColor3 = Color3.fromRGB(160, 160, 165)
GameText.TextSize = 12
GameText.Font = Enum.Font.Gotham
GameText.TextXAlignment = Enum.TextXAlignment.Left
GameText.Parent = WelcomeCard

--====================================================
-- SCRIPTS CARD
--====================================================
local ScriptsCard = Instance.new("Frame")
ScriptsCard.Name = "ScriptsCard"
ScriptsCard.Size = UDim2.new(1, 0, 1, -105)
ScriptsCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
ScriptsCard.BorderSizePixel = 0
ScriptsCard.LayoutOrder = 2
ScriptsCard.Parent = MainContent

local ScriptsCorner = Instance.new("UICorner")
ScriptsCorner.CornerRadius = UDim.new(0, 10)
ScriptsCorner.Parent = ScriptsCard

local ScriptsTitle = Instance.new("TextLabel")
ScriptsTitle.Size = UDim2.new(1, -30, 0, 30)
ScriptsTitle.Position = UDim2.fromOffset(15, 12)
ScriptsTitle.BackgroundTransparency = 1
ScriptsTitle.Text = "Available Scripts"
ScriptsTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
ScriptsTitle.TextSize = 14
ScriptsTitle.Font = Enum.Font.GothamBold
ScriptsTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptsTitle.Parent = ScriptsCard

local ScriptsList = Instance.new("ScrollingFrame")
ScriptsList.Size = UDim2.new(1, -20, 1, -60)
ScriptsList.Position = UDim2.fromOffset(10, 50)
ScriptsList.BackgroundTransparency = 1
ScriptsList.BorderSizePixel = 0
ScriptsList.ScrollBarThickness = 4
ScriptsList.ScrollBarImageColor3 = CONFIG.AccentColor
ScriptsList.CanvasSize = UDim2.fromScale(0, 0)
ScriptsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScriptsList.Parent = ScriptsCard

local ScriptsListPadding = Instance.new("UIPadding")
ScriptsListPadding.PaddingLeft = UDim.new(0, 5)
ScriptsListPadding.PaddingRight = UDim.new(0, 5)
ScriptsListPadding.Parent = ScriptsList

local ScriptsLayout = Instance.new("UIListLayout")
ScriptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScriptsLayout.Padding = UDim.new(0, 8)
ScriptsLayout.Parent = ScriptsList

--====================================================
-- MODAL OVERLAY
--====================================================
local ModalOverlay = Instance.new("Frame")
ModalOverlay.Name = "ModalOverlay"
ModalOverlay.Size = UDim2.fromScale(1, 1)
ModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ModalOverlay.BackgroundTransparency = 0.6
ModalOverlay.BorderSizePixel = 0
ModalOverlay.Visible = false
ModalOverlay.ZIndex = 100
ModalOverlay.Parent = ScreenGui

local ModalDialog = Instance.new("Frame")
ModalDialog.Size = UDim2.fromOffset(340, 160)
ModalDialog.Position = UDim2.fromScale(0.5, 0.5)
ModalDialog.AnchorPoint = Vector2.new(0.5, 0.5)
ModalDialog.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
ModalDialog.BorderSizePixel = 0
ModalDialog.ZIndex = 101
ModalDialog.Parent = ModalOverlay

local ModalCorner = Instance.new("UICorner")
ModalCorner.CornerRadius = UDim.new(0, 12)
ModalCorner.Parent = ModalDialog

local ModalStroke = Instance.new("UIStroke")
ModalStroke.Color = Color3.fromRGB(50, 50, 55)
ModalStroke.Thickness = 1
ModalStroke.Parent = ModalDialog

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Size = UDim2.new(1, -30, 0, 60)
ModalTitle.Position = UDim2.fromOffset(15, 20)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "Load Another Script?"
ModalTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
ModalTitle.TextSize = 14
ModalTitle.Font = Enum.Font.GothamMedium
ModalTitle.TextWrapped = true
ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
ModalTitle.TextYAlignment = Enum.TextYAlignment.Top
ModalTitle.ZIndex = 102
ModalTitle.Parent = ModalDialog

local ModalButtonContainer = Instance.new("Frame")
ModalButtonContainer.Size = UDim2.new(1, -30, 0, 40)
ModalButtonContainer.Position = UDim2.new(0, 15, 1, -55)
ModalButtonContainer.BackgroundTransparency = 1
ModalButtonContainer.ZIndex = 102
ModalButtonContainer.Parent = ModalDialog

local ModalButtonLayout = Instance.new("UIListLayout")
ModalButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ModalButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ModalButtonLayout.Padding = UDim.new(0, 10)
ModalButtonLayout.Parent = ModalButtonContainer

local function CreateModalButton(text, isPrimary)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(150, 40)
    Button.BackgroundColor3 = isPrimary and CONFIG.AccentColor or Color3.fromRGB(35, 35, 38)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = isPrimary and Color3.fromRGB(20, 20, 22) or Color3.fromRGB(240, 240, 245)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.ZIndex = 103
    Button.Parent = ModalButtonContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        Tween(Button, {BackgroundColor3 = isPrimary and Color3.fromRGB(200, 100, 175) or Color3.fromRGB(45, 45, 48)}, 0.15)
    end)
    
    Button.MouseLeave:Connect(function()
        Tween(Button, {BackgroundColor3 = isPrimary and CONFIG.AccentColor or Color3.fromRGB(35, 35, 38)}, 0.15)
    end)
    
    return Button
end

local NoButton = CreateModalButton("No", false)
local YesButton = CreateModalButton("Yes", true)

--====================================================
-- SCRIPT BUTTON CREATION
--====================================================
local function CreateScriptButton(scriptName, scriptCode)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = ScriptsList
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(45, 45, 50)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button
    
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -20, 1, 0)
    ButtonText.Position = UDim2.fromOffset(10, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = scriptName
    ButtonText.TextColor3 = Color3.fromRGB(240, 240, 245)
    ButtonText.TextSize = 13
    ButtonText.Font = Enum.Font.GothamMedium
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button
    
    Button.MouseEnter:Connect(function()
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 32)}, 0.15)
        Tween(ButtonStroke, {Color = CONFIG.AccentColor}, 0.15)
    end)
    
    Button.MouseLeave:Connect(function()
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(22, 22, 24)}, 0.15)
        Tween(ButtonStroke, {Color = Color3.fromRGB(45, 45, 50)}, 0.15)
    end)
    
    return Button
end

--====================================================
-- SCRIPT LOADING LOGIC
--====================================================
local AllScripts = {}

-- Add global scripts
for _, script in ipairs(GLOBAL_SCRIPTS) do
    table.insert(AllScripts, script)
end

-- Add game-specific scripts
if GAME_SCRIPTS[PlaceId] then
    for _, script in ipairs(GAME_SCRIPTS[PlaceId]) do
        table.insert(AllScripts, script)
    end
end

-- Populate script list
if #AllScripts == 0 then
    local NoScripts = Instance.new("TextLabel")
    NoScripts.Size = UDim2.new(1, 0, 0, 100)
    NoScripts.BackgroundTransparency = 1
    NoScripts.Text = "No scripts available for this game"
    NoScripts.TextColor3 = Color3.fromRGB(160, 160, 165)
    NoScripts.TextSize = 13
    NoScripts.Font = Enum.Font.Gotham
    NoScripts.Parent = ScriptsList
else
    local SelectedScript = nil
    
    for index, scriptData in ipairs(AllScripts) do
        local ScriptButton = CreateScriptButton(scriptData.Name, scriptData.Script)
        
        ScriptButton.MouseButton1Click:Connect(function()
            SelectedScript = scriptData
            ModalOverlay.Visible = true
        end)
    end
    
    -- Modal button handlers
    NoButton.MouseButton1Click:Connect(function()
        ModalOverlay.Visible = false
        if SelectedScript then
            local success, err = ExecuteScript(SelectedScript.Script)
            if not success then
                warn("Script execution failed:", err)
            end
            task.wait(0.5)
            ScreenGui:Destroy()
        end
    end)
    
    YesButton.MouseButton1Click:Connect(function()
        ModalOverlay.Visible = false
        -- TODO: Implement multi-select mode in future
        if SelectedScript then
            local success, err = ExecuteScript(SelectedScript.Script)
            if not success then
                warn("Script execution failed:", err)
            end
        end
    end)
end

--====================================================
-- INTRO ANIMATION
--====================================================
local function RunIntroAnimation()
    local StartTime = tick()
    local Connection
    
    Connection = RunService.RenderStepped:Connect(function()
        local Elapsed = tick() - StartTime
        local Progress = math.min(Elapsed / CONFIG.IntroSeconds, 1)
        local Eased = 1 - math.pow(1 - Progress, 3)
        
        ProgressBarFill.Size = UDim2.fromScale(Eased, 1)
        
        if Progress >= 0.5 then
            IntroLabel.Text = "Almost ready..."
        end
        
        if Progress >= 1 then
            Connection:Disconnect()
            IntroLabel.Text = "Ready!"
            task.wait(0.2)
            
            Tween(IntroFrame, {BackgroundTransparency = 1}, 0.3)
            Tween(IntroLabel, {TextTransparency = 1}, 0.3)
            Tween(ProgressBarBG, {BackgroundTransparency = 1}, 0.3)
            Tween(ProgressBarFill, {BackgroundTransparency = 1}, 0.3)
            
            task.wait(0.3)
            IntroFrame.Visible = false
            MainContent.Visible = true
        end
    end)
end

-- Fetch game info
task.spawn(function()
    local success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(PlaceId)
    end)
    
    if success and gameInfo then
        GameText.Text = gameInfo.Name
    else
        GameText.Text = "Place ID: " .. PlaceId
    end
end)

-- Start intro
RunIntroAnimation()
