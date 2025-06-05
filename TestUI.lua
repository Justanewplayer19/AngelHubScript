-- Angel Hub Reanimation UI
-- Pink themed animation UI with REANIMATION TOGGLE and SPEED CONTROL

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Track currently playing animation
local currentlyPlaying = nil
local currentAnimationId = nil
local lastKeybindPressed = nil
local lastKeybindTime = 0

-- Animation speed
local fakeAnimSpeed = 1

-- Reanimation state
local reanimationEnabled = false

-- Your reanimation loadstring (you can change this)
local reanimationScript = [[
-- Put your reanimation script here or use loadstring to load from URL
-- Example: loadstring(game:HttpGet("https://your-reanimation-script-url"))()

-- For now, this is a placeholder - replace with your actual reanimation script
print("🔄 LOADING REANIMATION SCRIPT...")
print("Speed parameter:", _G.fakeAnimSpeed or 1)

-- Set up basic reanimation globals (replace with your actual script)
_G.ghostEnabled = true
_G.PhantomReanimationEnabled = true
_G.fakeAnimSpeed = _G.fakeAnimSpeed or 1

-- Example reanimation function (replace with your actual script's function)
_G.playFakeAnimation = function(animId, speed)
    speed = speed or _G.fakeAnimSpeed or 1
    print("🎭 Playing animation:", animId, "at speed:", speed)
    
    -- Your actual animation playing code would go here
    -- This is just a placeholder
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. tostring(animId)
        
        local track = humanoid:LoadAnimation(animation)
        track:Play()
        track:AdjustSpeed(speed)
        
        return track
    end
end

_G.stopFakeAnimation = function()
    print("🛑 Stopping all animations")
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:StopAnimations()
    end
end

print("✅ REANIMATION SCRIPT LOADED!")
]]

-- Function to check if reanimation is enabled
local function isReanimationEnabled()
    return reanimationEnabled and (_G.ghostEnabled == true or _G.PhantomReanimationEnabled == true)
end

-- Function to toggle reanimation
local function toggleReanimation()
    if reanimationEnabled then
        -- Turn OFF reanimation
        print("🔴 TURNING OFF REANIMATION")
        reanimationEnabled = false
        
        -- Stop any currently playing animations
        forceStopAllAnimations()
        
        -- Clear reanimation globals
        _G.ghostEnabled = false
        _G.PhantomReanimationEnabled = false
        _G.playFakeAnimation = nil
        _G.stopFakeAnimation = nil
        _G.PhantomGhostClone = nil
        
        showNotification("REANIMATION DISABLED", 2)
    else
        -- Turn ON reanimation
        print("🟢 TURNING ON REANIMATION")
        
        -- Set speed global before loading
        _G.fakeAnimSpeed = fakeAnimSpeed
        
        -- Load the reanimation script
        local success, error = pcall(function()
            loadstring(reanimationScript)()
        end)
        
        if success then
            reanimationEnabled = true
            showNotification("REANIMATION ENABLED AT " .. math.floor(fakeAnimSpeed * 100) .. "% SPEED", 3)
        else
            print("❌ Failed to load reanimation script:", error)
            showNotification("FAILED TO LOAD REANIMATION", 3)
        end
    end
end

-- Force Stop Function
local function forceStopAllAnimations()
    print("🛑🛑🛑 FORCE STOPPING ALL ANIMATIONS 🛑🛑🛑")
    
    -- Try all known stop methods
    if _G.stopFakeAnimation then
        print("Using _G.stopFakeAnimation")
        pcall(function() _G.stopFakeAnimation() end)
    end
    
    if _G.stopAnimation then
        print("Using _G.stopAnimation")
        pcall(function() _G.stopAnimation() end)
    end
    
    -- Try to stop via setting global variables
    if _G.fakeAnimStop ~= nil then
        print("Setting _G.fakeAnimStop = true")
        _G.fakeAnimStop = true
    end
    
    if _G.fakeAnimRunning ~= nil then
        print("Setting _G.fakeAnimRunning = false")
        _G.fakeAnimRunning = false
    end
    
    -- Additional stop methods
    if _G.currentPlayingAnimation then
        print("Clearing _G.currentPlayingAnimation")
        _G.currentPlayingAnimation = nil
    end
    
    -- Try to stop any animations on the character
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            print("Stopping humanoid animations")
            pcall(function() 
                humanoid:StopAnimations() 
            end)
        end
        
        -- Try to find and stop any animation controllers
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("AnimationController") then
                print("Found AnimationController, stopping tracks")
                pcall(function()
                    for _, track in pairs(child:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                end)
            end
        end
        
        -- Try to stop animation tracks directly
        pcall(function()
            for _, track in pairs(character:GetDescendants()) do
                if track:IsA("AnimationTrack") and track.IsPlaying then
                    track:Stop()
                end
            end
        end)
    end
    
    -- Try to stop animations on the clone character if it exists
    if _G.PhantomGhostClone then
        local cloneChar = _G.PhantomGhostClone
        if cloneChar and typeof(cloneChar) == "Instance" then
            local humanoid = cloneChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                print("Stopping clone humanoid animations")
                pcall(function() humanoid:StopAnimations() end)
            end
            
            -- Stop all animation tracks on the clone
            pcall(function()
                for _, track in pairs(cloneChar:GetDescendants()) do
                    if track:IsA("AnimationTrack") and track.IsPlaying then
                        track:Stop()
                    end
                end
            end)
        end
    end
    
    -- Clear our local tracking
    currentlyPlaying = nil
    currentAnimationId = nil
    lastKeybindPressed = nil
    
    print("Force stop completed")
end

-- Function to show reanimation error
local function showReanimationError()
    print("Showing reanimation error")
    local notification = Instance.new("TextLabel")
    notification.Text = "ENABLE REANIMATION FIRST!"
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

-- Function to show a notification
local function showNotification(text, duration)
    duration = duration or 3
    
    local notification = Instance.new("TextLabel")
    notification.Text = text
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
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
    
    -- Auto remove after duration
    game:GetService("Debris"):AddItem(notification, duration)
end

-- Built-in Animations R15 (expanded list)
local BuiltInAnimationsR15 = {
    ["Dance"] = "507771019",
    ["Dance2"] = "507777623",
    ["Dance3"] = "507777268",
    ["Wave"] = "128777973", 
    ["Point"] = "128853357",
    ["Cheer"] = "129423030",
    ["Laugh"] = "129423131",
    ["Salute"] = "128853357",
    ["Stadium"] = "129423030",
    ["Twerk"] = "5917459365",
    ["Griddy"] = "5918726674",
    ["Orange Justice"] = "5104344710",
    ["Default Dance"] = "5104344710",
    ["Floss"] = "5917570207"
}

-- Table to store custom animations
local customAnimations = {}

-- Table to store keybinds for animations
local animationKeybinds = {}

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

-- Load saved data
loadCustomAnimations()

-- Function to clear all keybinds
local function clearAllKeybinds(animationButtons)
    print("🗑️ CLEARING ALL KEYBINDS")
    animationKeybinds = {}
    
    -- Update all keybind button visuals
    for animName, animButtonData in pairs(animationButtons) do
        if animButtonData.KeybindButton then
            animButtonData.KeybindButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
        end
    end
    
    showNotification("ALL KEYBINDS CLEARED", 2)
    print("All keybinds cleared successfully")
end

-- Debug function
local function debugGlobals()
    print("=== DEBUG: Checking all _G variables ===")
    for k, v in pairs(_G) do
        if type(k) == "string" and (k:lower():find("ghost") or k:lower():find("reanima") or k:lower():find("phantom") or k:lower():find("anim") or k:lower():find("speed")) then
            print(k .. ":", v, "(type: " .. type(v) .. ")")
        end
    end
    print("Currently playing (local):", currentlyPlaying)
    print("Current animation ID (local):", currentAnimationId)
    print("Current speed:", fakeAnimSpeed)
    print("Reanimation enabled (local):", reanimationEnabled)
    print("=== END DEBUG ===")
end

-- Function to update all button states
local function updateAllButtonStates(animationButtons)
    for animName, animButtonData in pairs(animationButtons) do
        if animButtonData.PlayButton then
            if currentlyPlaying == animName then
                animButtonData.PlayButton.Text = "Stop"
                animButtonData.PlayButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60) -- Dark red
            else
                animButtonData.PlayButton.Text = "Play"
                animButtonData.PlayButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147) -- Pink
            end
        end
    end
end

-- Function to update speed globals
local function updateSpeedGlobals()
    _G.fakeAnimSpeed = fakeAnimSpeed
    _G.animSpeed = fakeAnimSpeed
    _G.animationSpeed = fakeAnimSpeed
    _G.fakeAnimationSpeed = fakeAnimSpeed
    _G.PhantomAnimSpeed = fakeAnimSpeed
    _G.ghostAnimSpeed = fakeAnimSpeed
    _G.speed = fakeAnimSpeed
    _G.Speed = fakeAnimSpeed
end

-- Function to play animation WITH SPEED
local function playAnimation(animName, animId)
    print("=== PLAYING ANIMATION WITH SPEED ===")
    print("Animation name:", animName)
    print("Animation ID:", animId)
    print("Speed:", fakeAnimSpeed)
    
    -- Force stop any currently playing animation first
    forceStopAllAnimations()
    
    -- Update speed globals
    updateSpeedGlobals()
    
    -- Use the global function if available
    local success = false
    
    if _G.playFakeAnimation then
        print("Using _G.playFakeAnimation with speed:", fakeAnimSpeed)
        -- Try different ways to pass speed
        pcall(function() _G.playFakeAnimation(tostring(animId), fakeAnimSpeed) end)
        pcall(function() _G.playFakeAnimation(tostring(animId)) end) -- Fallback
        currentlyPlaying = animName
        currentAnimationId = tostring(animId)
        success = true
        print("Set currently playing to:", currentlyPlaying)
    elseif _G.playAnimation then
        print("Using _G.playAnimation with speed:", fakeAnimSpeed)
        pcall(function() _G.playAnimation(tostring(animId), fakeAnimSpeed) end)
        pcall(function() _G.playAnimation(tostring(animId)) end) -- Fallback
        currentlyPlaying = animName
        currentAnimationId = tostring(animId)
        success = true
        print("Set currently playing to:", currentlyPlaying)
    else
        print("No global animation function found")
        showReanimationError()
        return false
    end
    
    if success then
        local speedPercent = math.floor(fakeAnimSpeed * 100)
        showNotification("PLAYING AT " .. speedPercent .. "% SPEED", 2)
    end
    
    print("=== PLAY WITH SPEED COMPLETE ===")
    return success
end

-- Function to play or stop animation
local function toggleAnimation(animName, animId, animationButtons)
    print("=== TOGGLE ANIMATION ===")
    print("Animation name:", animName)
    print("Animation ID:", animId)
    print("Currently playing before toggle:", currentlyPlaying)
    
    -- If this animation is currently playing, stop it
    if currentlyPlaying == animName then
        print("Animation is currently playing - STOPPING")
        forceStopAllAnimations()
        if animationButtons then
            updateAllButtonStates(animationButtons)
        end
        return
    end
    
    if not isReanimationEnabled() then
        print("Reanimation not enabled, showing error")
        showReanimationError()
        return
    end
    
    print("Animation not playing - STARTING")
    
    -- Play the new animation
    if playAnimation(animName, animId) then
        if animationButtons then
            updateAllButtonStates(animationButtons)
        end
    end
    
    print("=== TOGGLE COMPLETE ===")
end

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
    mainFrame.Size = UDim2.new(0, 350, 0, 480) -- Taller for reanimation toggle
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
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
    
    -- Reanimation toggle container
    local reanimToggleContainer = Instance.new("Frame")
    reanimToggleContainer.Name = "ReanimToggleContainer"
    reanimToggleContainer.Size = UDim2.new(1, -20, 0, 40)
    reanimToggleContainer.Position = UDim2.new(0, 10, 0, 50)
    reanimToggleContainer.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    reanimToggleContainer.BorderSizePixel = 0
    local reanimToggleCorner = Instance.new("UICorner")
    reanimToggleCorner.CornerRadius = UDim.new(0, 6)
    reanimToggleCorner.Parent = reanimToggleContainer
    reanimToggleContainer.Parent = mainFrame
    
    -- Reanimation toggle button
    local reanimToggleButton = Instance.new("TextButton")
    reanimToggleButton.Name = "ReanimToggleButton"
    reanimToggleButton.Size = UDim2.new(0, 120, 0, 30)
    reanimToggleButton.Position = UDim2.new(0, 10, 0.5, -15)
    reanimToggleButton.Text = "🔴 ENABLE REANIMATION"
    reanimToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    reanimToggleButton.TextSize = 12
    reanimToggleButton.Font = Enum.Font.GothamBold
    reanimToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60) -- Red when off
    reanimToggleButton.BorderSizePixel = 0
    local reanimToggleButtonCorner = Instance.new("UICorner")
    reanimToggleButtonCorner.CornerRadius = UDim.new(0, 4)
    reanimToggleButtonCorner.Parent = reanimToggleButton
    reanimToggleButton.Parent = reanimToggleContainer
    
    -- Status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, -20, 0, 35)
    statusFrame.Position = UDim2.new(0, 10, 0, 100)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    statusFrame.BorderSizePixel = 0
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    statusFrame.Parent = mainFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -110, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.Text = "Reanimation Status: DISABLED"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.GothamBold
    statusText.BackgroundTransparency = 1
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusFrame
    
    -- Clear Keybinds button
    local clearKeybindsButton = Instance.new("TextButton")
    clearKeybindsButton.Name = "ClearKeybindsButton"
    clearKeybindsButton.Size = UDim2.new(0, 50, 0, 25)
    clearKeybindsButton.Position = UDim2.new(1, -105, 0.5, -12.5)
    clearKeybindsButton.Text = "Clear"
    clearKeybindsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearKeybindsButton.TextSize = 11
    clearKeybindsButton.Font = Enum.Font.GothamBold
    clearKeybindsButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60) -- Red
    clearKeybindsButton.BorderSizePixel = 0
    local clearKeybindsCorner = Instance.new("UICorner")
    clearKeybindsCorner.CornerRadius = UDim.new(0, 4)
    clearKeybindsCorner.Parent = clearKeybindsButton
    clearKeybindsButton.Parent = statusFrame
    
    -- Debug button
    local debugButton = Instance.new("TextButton")
    debugButton.Name = "DebugButton"
    debugButton.Size = UDim2.new(0, 50, 0, 25)
    debugButton.Position = UDim2.new(1, -55, 0.5, -12.5)
    debugButton.Text = "Debug"
    debugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    debugButton.TextSize = 12
    debugButton.Font = Enum.Font.Gotham
    debugButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
    debugButton.BorderSizePixel = 0
    local debugCorner = Instance.new("UICorner")
    debugCorner.CornerRadius = UDim.new(0, 4)
    debugCorner.Parent = debugButton
    debugButton.Parent = statusFrame
    
    -- Search bar container
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(1, -20, 0, 40)
    searchContainer.Position = UDim2.new(0, 10, 0, 145)
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
    animListContainer.Size = UDim2.new(1, -20, 1, -240)
    animListContainer.Position = UDim2.new(0, 10, 0, 195)
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
    
    -- Speed preset buttons container
    local speedPresetsContainer = Instance.new("Frame")
    speedPresetsContainer.Name = "SpeedPresetsContainer"
    speedPresetsContainer.Size = UDim2.new(0, 120, 1, 0)
    speedPresetsContainer.Position = UDim2.new(0, 60, 0, 0)
    speedPresetsContainer.BackgroundTransparency = 1
    speedPresetsContainer.Parent = speedContainer
    
    -- Speed slider background
    local sliderBG = Instance.new("Frame")
    sliderBG.Name = "SliderBG"
    sliderBG.Size = UDim2.new(0, 100, 0, 6)
    sliderBG.Position = UDim2.new(1, -110, 0.5, -3)
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
    
    -- Speed preset buttons
    local presetSpeeds = {
        {name = "0.5x", value = 0.5},
        {name = "1x", value = 1},
        {name = "2x", value = 2}
    }
    
    for i, preset in ipairs(presetSpeeds) do
        local presetButton = Instance.new("TextButton")
        presetButton.Name = preset.name .. "Button"
        presetButton.Size = UDim2.new(0, 35, 0, 25)
        presetButton.Position = UDim2.new(0, (i-1) * 40, 0.5, -12.5)
        presetButton.Text = preset.name
        presetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        presetButton.TextSize = 12
        presetButton.Font = Enum.Font.GothamBold
        presetButton.BackgroundColor3 = Color3.fromRGB(80, 50, 65)
        presetButton.BorderSizePixel = 0
        local presetButtonCorner = Instance.new("UICorner")
        presetButtonCorner.CornerRadius = UDim.new(0, 4)
        presetButtonCorner.Parent = presetButton
        presetButton.Parent = speedPresetsContainer
        
        -- Preset button click handler
        presetButton.MouseButton1Click:Connect(function()
            fakeAnimSpeed = preset.value
            speedValue.Text = tostring(math.floor(preset.value * 100)) .. "%"
            
            -- Update slider position
            local sliderPos = (preset.value - 0.5) / 3.5
            sliderFill.Size = UDim2.new(sliderPos, 0, 1, 0)
            
            -- Update speed globals
            updateSpeedGlobals()
            
            -- Show notification
            showNotification("SPEED SET TO " .. preset.name, 1)
        end)
    end
    
    -- Add Animation Popup (same as before)
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
                toggleAnimation(animName, animId, animationButtons)
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
                        keybindButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Pink when set
                        isSettingKeybind = false
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
        
        -- Update button states after creating all buttons
        updateAllButtonStates(animationButtons)
    end
    
    -- Initialize the animation list
    refreshAnimationList()
    
    -- Reanimation toggle button click handler
    reanimToggleButton.MouseButton1Click:Connect(function()
        toggleReanimation()
        
        -- Update button appearance
        if reanimationEnabled then
            reanimToggleButton.Text = "🟢 DISABLE REANIMATION"
            reanimToggleButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Green when on
            statusText.Text = "Reanimation Status: ENABLED"
            statusText.TextColor3 = Color3.fromRGB(255, 105, 180)
        else
            reanimToggleButton.Text = "🔴 ENABLE REANIMATION"
            reanimToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60) -- Red when off
            statusText.Text = "Reanimation Status: DISABLED"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        -- Update all button states
        updateAllButtonStates(animationButtons)
    end)
    
    -- Clear Keybinds button click handler
    clearKeybindsButton.MouseButton1Click:Connect(function()
        clearAllKeybinds(animationButtons)
    end)
    
    -- Debug button click
    debugButton.MouseButton1Click:Connect(function()
        debugGlobals()
        print("Current reanimation status:", isReanimationEnabled())
        print("Currently playing:", currentlyPlaying or "None")
    end)
    
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
        
        -- Update speed
        fakeAnimSpeed = newSpeed
        updateSpeedGlobals()
        
        print("🎛️ Speed updated to:", newSpeed, "(" .. displaySpeed .. "%)")
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
    
    return screenGui, animationButtons, reanimToggleButton, statusText
end

-- Create the GUI when the script runs
local angelHubGui, animationButtons, reanimToggleButton, statusText = createAngelHubGui()

-- KEYBIND HANDLING
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- R key to force stop all animations
        if input.KeyCode == Enum.KeyCode.R then
            print("🛑 R KEY PRESSED - FORCE STOPPING ALL ANIMATIONS 🛑")
            forceStopAllAnimations()
            updateAllButtonStates(animationButtons)
            return
        end
        
        -- Check for animation keybinds
        for animName, keyCode in pairs(animationKeybinds) do
            if input.KeyCode == keyCode then
                print("🔑 KEYBIND PRESSED:", keyCode.Name, "for animation:", animName)
                
                -- Check if this is a double-press of the same key (to force stop)
                local currentTime = tick()
                if lastKeybindPressed == keyCode and (currentTime - lastKeybindTime) < 0.5 then
                    print("🔑 DOUBLE PRESS DETECTED - FORCE STOPPING")
                    forceStopAllAnimations()
                    updateAllButtonStates(animationButtons)
                    lastKeybindPressed = nil
                    return
                end
                
                -- Update last keybind info
                lastKeybindPressed = keyCode
                lastKeybindTime = currentTime
                
                -- Check if this animation is currently playing
                if currentlyPlaying == animName then
                    print("🔑 ANIMATION IS CURRENTLY PLAYING - STOPPING")
                    forceStopAllAnimations()
                    updateAllButtonStates(animationButtons)
                    return
                end
                
                -- Check reanimation status
                if not isReanimationEnabled() then
                    print("🔑 REANIMATION NOT ENABLED")
                    showReanimationError()
                    return
                end
                
                -- Stop any currently playing animation
                if currentlyPlaying then
                    print("🔑 STOPPING PREVIOUS ANIMATION:", currentlyPlaying)
                    forceStopAllAnimations()
                    task.wait(0.1) -- Small delay to ensure stop completes
                end
                
                -- Play the animation
                local animId = BuiltInAnimationsR15[animName]
                if animId then
                    print("🔑 PLAYING ANIMATION:", animName, "ID:", animId)
                    if playAnimation(animName, animId) then
                        updateAllButtonStates(animationButtons)
                    end
                else
                    print("🔑 ANIMATION ID NOT FOUND FOR:", animName)
                end
                
                return
            end
        end
    end
end)

-- Add a notification to show the script is loaded
showNotification("ANGEL HUB TOGGLE VERSION LOADED", 3)

print("=== ANGEL HUB TOGGLE VERSION LOADED ===")
print("🔴 Click 'ENABLE REANIMATION' to load your reanimation script!")
print("🎛️ Set your speed BEFORE enabling reanimation for best results!")
print("📝 Replace the reanimationScript variable with your actual loadstring!")
