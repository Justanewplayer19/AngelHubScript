-- Angel Hub Reanimation UI
-- Pink themed animation UI with reanimation checking

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Function to check if reanimation is enabled
local function isReanimationEnabled()
    -- Check multiple possible ways reanimation might be enabled
    if _G.ghostEnabled then
        return true
    end
    if _G.PhantomReanimationEnabled then
        return true
    end
    -- Check if the global reanimation functions exist
    if _G.setGhostEnabled and type(_G.setGhostEnabled) == "function" then
        return _G.ghostEnabled or false
    end
    return false
end

-- Function to show reanimation error
local function showReanimationError()
    local notification = Instance.new("TextLabel")
    notification.Text = "ENABLE REANIMATION YOU DINGUS"
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(255, 20, 147) -- Pink error
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 16
    notification.Font = Enum.Font.GothamBold
    notification.TextStrokeTransparency = 0
    notification.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    notification.Parent = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    -- Add a border
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(200, 80, 120)
    border.Thickness = 2
    border.Parent = notification
    
    -- Animate in
    notification.Position = UDim2.new(0.5, -150, 0, -60)
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, 20)
    })
    slideIn:Play()
    
    -- Auto remove after 3 seconds
    game:GetService("Debris"):AddItem(notification, 3)
end

-- Built-in Animations R15 (you can expand this)
local BuiltInAnimationsR15 = {
    ["Dance"] = "507771019",
    ["Wave"] = "128777973", 
    ["Point"] = "128853357",
    ["Cheer"] = "129423030",
    ["Laugh"] = "129423131",
    ["Salute"] = "128853357",
    ["Stadium"] = "129423030"
}

-- Table to store custom animations
local customAnimations = {}

-- Table to store favorite animations
local favoriteAnimations = {}

-- Table to store keybinds for animations
local animationKeybinds = {}

-- Animation speed
local fakeAnimSpeed = 1

-- Function to save custom animations
local function saveCustomAnimations()
    local success, encodedCustom = pcall(HttpService.JSONEncode, HttpService, customAnimations)
    if success and writefile then
        pcall(function()
            writefile("angel_hub_custom_animations.json", encodedCustom)
        end)
    end
end

-- Function to load custom animations
local function loadCustomAnimations()
    if readfile then
        local success, fileContent = pcall(readfile, "angel_hub_custom_animations.json")
        if success then
            local decodeSuccess, decodedCustom = pcall(function()
                return HttpService:JSONDecode(fileContent)
            end)
            if decodeSuccess and typeof(decodedCustom) == "table" then
                customAnimations = decodedCustom
                for animName, animId in pairs(customAnimations) do
                    if not BuiltInAnimationsR15[animName] then
                        BuiltInAnimationsR15[animName] = animId
                    end
                end
            end
        end
    end
end

-- Function to save keybinds
local function saveKeybinds()
    local keybindsToSave = {}
    for animName, keyCode in pairs(animationKeybinds) do
        keybindsToSave[animName] = keyCode.Name
    end
    local success, encodedKeybinds = pcall(HttpService.JSONEncode, HttpService, keybindsToSave)
    if success and writefile then
        pcall(function()
            writefile("angel_hub_keybinds.json", encodedKeybinds)
        end)
    end
end

-- Function to load keybinds
local function loadKeybinds()
    if readfile then
        local success, fileContent = pcall(readfile, "angel_hub_keybinds.json")
        if success then
            local decodeSuccess, decodedKeybinds = pcall(HttpService.JSONDecode, HttpService, fileContent)
            if decodeSuccess and typeof(decodedKeybinds) == "table" then
                for animName, keyName in pairs(decodedKeybinds) do
                    if Enum.KeyCode[keyName] then
                        animationKeybinds[animName] = Enum.KeyCode[keyName]
                    end
                end
            end
        end
    end
end

-- Load saved data
loadCustomAnimations()
loadKeybinds()

-- Create the Angel Hub GUI
local function createAngelHubGui()
    -- Create the main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AngelHubReanimation"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create the main frame with pink theme
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 20) -- Dark pink background
    mainFrame.BorderSizePixel = 0
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(255, 20, 147) -- Deep pink border
    border.Thickness = 2
    border.Parent = mainFrame
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 20, 30) -- Slightly lighter pink
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    -- Fix the bottom corners of the title bar
    local titleBottom = Instance.new("Frame")
    titleBottom.Name = "TitleBottom"
    titleBottom.Size = UDim2.new(1, 0, 0, 10)
    titleBottom.Position = UDim2.new(0, 0, 1, -10)
    titleBottom.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    titleBottom.BorderSizePixel = 0
    titleBottom.Parent = titleBar
    
    titleBar.Parent = mainFrame
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.Text = "Angel Hub Reanimation"
    titleText.TextColor3 = Color3.fromRGB(255, 105, 180) -- Hot pink
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.BackgroundTransparency = 1
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = titleBar
    
    -- Status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, -20, 0, 35)
    statusFrame.Position = UDim2.new(0, 10, 0, 50)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    statusFrame.BorderSizePixel = 0
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    statusFrame.Parent = mainFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.Text = "Reanimation Status: CHECKING..."
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.GothamBold
    statusText.BackgroundTransparency = 1
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusFrame
    
    -- Search bar container
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(1, -20, 0, 40)
    searchContainer.Position = UDim2.new(0, 10, 0, 95)
    searchContainer.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
    searchContainer.BorderSizePixel = 0
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchContainer
    searchContainer.Parent = mainFrame
    
    -- Search text box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -100, 1, 0)
    searchBox.Position = UDim2.new(0, 15, 0, 0)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search animations..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(200, 150, 175)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.BackgroundTransparency = 1
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer
    
    -- Add button
    local addButton = Instance.new("TextButton")
    addButton.Name = "AddButton"
    addButton.Size = UDim2.new(0, 70, 0, 30)
    addButton.Position = UDim2.new(1, -80, 0.5, -15)
    addButton.Text = "Add"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 14
    addButton.Font = Enum.Font.GothamBold
    addButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    addButton.BorderSizePixel = 0
    local addButtonCorner = Instance.new("UICorner")
    addButtonCorner.CornerRadius = UDim.new(0, 4)
    addButtonCorner.Parent = addButton
    addButton.Parent = searchContainer
    
    -- Animation list container
    local animListContainer = Instance.new("ScrollingFrame")
    animListContainer.Name = "AnimListContainer"
    animListContainer.Size = UDim2.new(1, -20, 1, -190)
    animListContainer.Position = UDim2.new(0, 10, 0, 145)
    animListContainer.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    animListContainer.BorderSizePixel = 0
    animListContainer.ScrollBarThickness = 4
    animListContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
    animListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = animListContainer
    animListContainer.Parent = mainFrame
    
    -- Speed control container
    local speedContainer = Instance.new("Frame")
    speedContainer.Name = "SpeedContainer"
    speedContainer.Size = UDim2.new(1, -20, 0, 40)
    speedContainer.Position = UDim2.new(0, 10, 1, -50)
    speedContainer.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
    speedContainer.BorderSizePixel = 0
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedContainer
    speedContainer.Parent = mainFrame
    
    -- Speed label
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0, 50, 1, 0)
    speedLabel.Position = UDim2.new(0, 10, 0, 0)
    speedLabel.Text = "Speed:"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedContainer
    
    -- Speed slider background
    local sliderBG = Instance.new("Frame")
    sliderBG.Name = "SliderBG"
    sliderBG.Size = UDim2.new(0, 180, 0, 6)
    sliderBG.Position = UDim2.new(0, 65, 0.5, -3)
    sliderBG.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
    sliderBG.BorderSizePixel = 0
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(0, 3)
    sliderBGCorner.Parent = sliderBG
    sliderBG.Parent = speedContainer
    
    -- Speed slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    sliderFill.BorderSizePixel = 0
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 3)
    sliderFillCorner.Parent = sliderFill
    sliderFill.Parent = sliderBG
    
    -- Speed slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position = UDim2.new(1, -7, 0.5, -7)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    sliderKnob.Parent = sliderFill
    
    -- Speed value label
    local speedValue = Instance.new("TextLabel")
    speedValue.Name = "SpeedValue"
    speedValue.Size = UDim2.new(0, 50, 1, 0)
    speedValue.Position = UDim2.new(1, -60, 0, 0)
    speedValue.Text = "100%"
    speedValue.TextColor3 = Color3.fromRGB(255, 105, 180)
    speedValue.TextSize = 14
    speedValue.Font = Enum.Font.GothamBold
    speedValue.BackgroundTransparency = 1
    speedValue.TextXAlignment = Enum.TextXAlignment.Right
    speedValue.Parent = speedContainer
    
    -- Add Animation Popup
    local addAnimPopup = Instance.new("Frame")
    addAnimPopup.Name = "AddAnimPopup"
    addAnimPopup.Size = UDim2.new(0, 300, 0, 200)
    addAnimPopup.Position = UDim2.new(0.5, -150, 0.5, -100)
    addAnimPopup.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    addAnimPopup.BorderSizePixel = 0
    addAnimPopup.Visible = false
    addAnimPopup.ZIndex = 10
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 10)
    popupCorner.Parent = addAnimPopup
    addAnimPopup.Parent = screenGui
    
    -- Popup border
    local popupBorder = Instance.new("UIStroke")
    popupBorder.Color = Color3.fromRGB(255, 20, 147)
    popupBorder.Thickness = 2
    popupBorder.Parent = addAnimPopup
    
    -- Popup title
    local popupTitle = Instance.new("TextLabel")
    popupTitle.Name = "PopupTitle"
    popupTitle.Size = UDim2.new(1, 0, 0, 40)
    popupTitle.Text = "Add Custom Animation"
    popupTitle.TextColor3 = Color3.fromRGB(255, 105, 180)
    popupTitle.TextSize = 16
    popupTitle.Font = Enum.Font.GothamBold
    popupTitle.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
    popupTitle.BorderSizePixel = 0
    popupTitle.ZIndex = 10
    local popupTitleCorner = Instance.new("UICorner")
    popupTitleCorner.CornerRadius = UDim.new(0, 10)
    popupTitleCorner.Parent = popupTitle
    
    -- Fix the bottom corners of the popup title
    local popupTitleBottom = Instance.new("Frame")
    popupTitleBottom.Name = "TitleBottom"
    popupTitleBottom.Size = UDim2.new(1, 0, 0, 10)
    popupTitleBottom.Position = UDim2.new(0, 0, 1, -10)
    popupTitleBottom.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
    popupTitleBottom.BorderSizePixel = 0
    popupTitleBottom.ZIndex = 10
    popupTitleBottom.Parent = popupTitle
    
    popupTitle.Parent = addAnimPopup
    
    -- Name input
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -40, 0, 35)
    nameInput.Position = UDim2.new(0, 20, 0, 60)
    nameInput.PlaceholderText = "Animation Name..."
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.PlaceholderColor3 = Color3.fromRGB(200, 150, 175)
    nameInput.BackgroundColor3 = Color3.fromRGB(25, 15, 20)
    nameInput.BorderSizePixel = 0
    nameInput.ZIndex = 10
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextSize = 14
    local nameInputCorner = Instance.new("UICorner")
    nameInputCorner.CornerRadius = UDim.new(0, 6)
    nameInputCorner.Parent = nameInput
    nameInput.Parent = addAnimPopup
    
    -- ID input
    local idInput = Instance.new("TextBox")
    idInput.Name = "IDInput"
    idInput.Size = UDim2.new(1, -40, 0, 35)
    idInput.Position = UDim2.new(0, 20, 0, 105)
    idInput.PlaceholderText = "Animation ID..."
    idInput.Text = ""
    idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    idInput.PlaceholderColor3 = Color3.fromRGB(200, 150, 175)
    idInput.BackgroundColor3 = Color3.fromRGB(25, 15, 20)
    idInput.BorderSizePixel = 0
    idInput.ZIndex = 10
    idInput.Font = Enum.Font.Gotham
    idInput.TextSize = 14
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 6)
    idInputCorner.Parent = idInput
    idInput.Parent = addAnimPopup
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 100, 0, 35)
    cancelButton.Position = UDim2.new(0, 20, 1, -50)
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 14
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
    cancelButton.BorderSizePixel = 0
    cancelButton.ZIndex = 10
    local cancelButtonCorner = Instance.new("UICorner")
    cancelButtonCorner.CornerRadius = UDim.new(0, 6)
    cancelButtonCorner.Parent = cancelButton
    cancelButton.Parent = addAnimPopup
    
    -- Add button for popup
    local popupAddButton = Instance.new("TextButton")
    popupAddButton.Name = "AddButton"
    popupAddButton.Size = UDim2.new(0, 100, 0, 35)
    popupAddButton.Position = UDim2.new(1, -120, 1, -50)
    popupAddButton.Text = "Add"
    popupAddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    popupAddButton.TextSize = 14
    popupAddButton.Font = Enum.Font.GothamBold
    popupAddButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    popupAddButton.BorderSizePixel = 0
    popupAddButton.ZIndex = 10
    local popupAddButtonCorner = Instance.new("UICorner")
    popupAddButtonCorner.CornerRadius = UDim.new(0, 6)
    popupAddButtonCorner.Parent = popupAddButton
    popupAddButton.Parent = addAnimPopup
    
    -- Table to store animation buttons for search functionality
    local animationButtons = {}
    
    -- Function to update animation button visibility based on search text
    local function updateAnimationButtonsVisibility(searchText)
        local yOffset = 8
        
        for animName, animButtonData in pairs(animationButtons) do
            if string.find(string.lower(animName), string.lower(searchText)) then
                animButtonData.Container.Visible = true
                animButtonData.Container.Position = UDim2.new(0, 8, 0, yOffset)
                yOffset = yOffset + 50
            else
                animButtonData.Container.Visible = false
            end
        end
        
        animListContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(0, yOffset))
    end
    
    -- Function to refresh the animation list
    local function refreshAnimationList()
        -- Clear existing buttons
        for _, animButtonData in pairs(animationButtons) do
            if animButtonData.Container then
                animButtonData.Container:Destroy()
            end
        end
        animationButtons = {}
        
        -- Recreate buttons for all animations
        local yOffset = 8
        for animName, animId in pairs(BuiltInAnimationsR15) do
            -- Create a container for each animation entry
            local animContainer = Instance.new("Frame")
            animContainer.Name = animName .. "Container"
            animContainer.Size = UDim2.new(1, -16, 0, 45)
            animContainer.Position = UDim2.new(0, 8, 0, yOffset)
            animContainer.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
            animContainer.BorderSizePixel = 0
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 6)
            containerCorner.Parent = animContainer
            animContainer.Parent = animListContainer
            
            -- Animation name label
            local animNameLabel = Instance.new("TextLabel")
            animNameLabel.Name = animName .. "Label"
            animNameLabel.Size = UDim2.new(1, -140, 1, 0)
            animNameLabel.Position = UDim2.new(0, 12, 0, 0)
            animNameLabel.Text = animName
            animNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            animNameLabel.TextSize = 14
            animNameLabel.Font = Enum.Font.Gotham
            animNameLabel.BackgroundTransparency = 1
            animNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            animNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            animNameLabel.Parent = animContainer
            
            -- Play button
            local playButton = Instance.new("TextButton")
            playButton.Name = animName .. "PlayButton"
            playButton.Size = UDim2.new(0, 60, 0, 30)
            playButton.Position = UDim2.new(1, -70, 0.5, -15)
            playButton.Text = "Play"
            playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playButton.TextSize = 12
            playButton.Font = Enum.Font.GothamBold
            playButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
            playButton.BorderSizePixel = 0
            local playButtonCorner = Instance.new("UICorner")
            playButtonCorner.CornerRadius = UDim.new(0, 4)
            playButtonCorner.Parent = playButton
            playButton.Parent = animContainer
            
            -- Keybind button
            local keybindButton = Instance.new("TextButton")
            keybindButton.Name = animName .. "KeybindButton"
            keybindButton.Size = UDim2.new(0, 30, 0, 30)
            keybindButton.Position = UDim2.new(1, -110, 0.5, -15)
            keybindButton.Text = "⌨"
            keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindButton.TextSize = 14
            keybindButton.Font = Enum.Font.GothamBold
            keybindButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
            keybindButton.BorderSizePixel = 0
            local keybindButtonCorner = Instance.new("UICorner")
            keybindButtonCorner.CornerRadius = UDim.new(0, 4)
            keybindButtonCorner.Parent = keybindButton
            keybindButton.Parent = animContainer
            
            -- Play button click handler
            playButton.MouseButton1Click:Connect(function()
                if not isReanimationEnabled() then
                    showReanimationError()
                    return
                end
                
                -- Use the global function if available
                if _G.playFakeAnimation then
                    _G.playFakeAnimation(tostring(animId))
                elseif _G.playAnimation then
                    _G.playAnimation(tostring(animId))
                else
                    showReanimationError()
                end
            end)
            
            -- Keybind button click handler
            local isSettingKeybind = false
            keybindButton.MouseButton1Click:Connect(function()
                if isSettingKeybind then return end
                
                isSettingKeybind = true
                keybindButton.Text = "..."
                keybindButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        animationKeybinds[animName] = input.KeyCode
                        keybindButton.Text = "⌨"
                        keybindButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
                        isSettingKeybind = false
                        saveKeybinds()
                        connection:Disconnect()
                    end
                end)
            end)
            
            -- Update keybind button if a keybind exists
            if animationKeybinds[animName] then
                keybindButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            end
            
            animationButtons[animName] = {
                Container = animContainer,
                NameLabel = animNameLabel,
                PlayButton = playButton,
                KeybindButton = keybindButton
            }
            
            yOffset = yOffset + 50
        end
        
        animListContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(0, yOffset))
    end
    
    -- Initialize the animation list
    refreshAnimationList()
    
    -- Search box functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateAnimationButtonsVisibility(searchBox.Text)
    end)
    
    -- Speed slider functionality
    local isDraggingSpeed = false
    
    local function updateSpeedFromPosition(input)
        local sliderPosition = (input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newSpeed = 0.5 + sliderPosition * 3.5 -- Range from 0.5 to 4.0
        
        -- Update slider visuals
        sliderFill.Size = UDim2.new(sliderPosition, 0, 1, 0)
        
        -- Update speed value
        local displaySpeed = math.floor(newSpeed * 100)
        speedValue.Text = tostring(displaySpeed) .. "%"
        
        -- Update animation speed (if the global variable exists)
        if _G.fakeAnimSpeed then
            _G.fakeAnimSpeed = newSpeed
        end
        fakeAnimSpeed = newSpeed
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = true
            updateSpeedFromPosition(input)
        end
    end)
    
    sliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
        end
    end)
    
    sliderBG.InputChanged:Connect(function(input)
        if isDraggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSpeedFromPosition(input)
        end
    end)
    
    -- Add button functionality
    addButton.MouseButton1Click:Connect(function()
        nameInput.Text = ""
        idInput.Text = ""
        addAnimPopup.Visible = true
    end)
    
    -- Cancel button functionality
    cancelButton.MouseButton1Click:Connect(function()
        addAnimPopup.Visible = false
    end)
    
    -- Popup add button functionality
    popupAddButton.MouseButton1Click:Connect(function()
        local animName = nameInput.Text:gsub("^%s*(.-)%s*$", "%1")
        local animId = idInput.Text:gsub("^%s*(.-)%s*$", "%1")
        
        if animName == "" or animId == "" then
            return
        end
        
        -- Add to custom animations
        customAnimations[animName] = animId
        BuiltInAnimationsR15[animName] = animId
        
        -- Save to file
        saveCustomAnimations()
        
        -- Hide popup
        addAnimPopup.Visible = false
        
        -- Refresh the animation list
        refreshAnimationList()
        updateAnimationButtonsVisibility(searchBox.Text)
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Make the GUI draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            updateInput(input)
        end
    end)
    
    -- Update status periodically
    task.spawn(function()
        while screenGui.Parent do
            local enabled = isReanimationEnabled()
            statusText.Text = "Reanimation Status: " .. (enabled and "ENABLED" or "DISABLED")
            statusText.TextColor3 = enabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 100, 100)
            task.wait(1)
        end
    end)
    
    return screenGui
end

-- Create the GUI when the script runs
local angelHubGui = createAngelHubGui()

-- Keybind handling for animations
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for animName, keyCode in pairs(animationKeybinds) do
            if input.KeyCode == keyCode then
                if not isReanimationEnabled() then
                    showReanimationError()
                    return
                end
                
                if _G.playFakeAnimation then
                    _G.playFakeAnimation(BuiltInAnimationsR15[animName])
                elseif _G.playAnimation then
                    _G.playAnimation(BuiltInAnimationsR15[animName])
                else
                    showReanimationError()
                end
                return
            end
        end
    end
end)
