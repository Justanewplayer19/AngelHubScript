-- FIXED REANIMATION SYSTEM START --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
 
-- [[ State for reanimation ]]
local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection
local ghostOriginalHipHeight
local cloneSize = 1
local cloneWidth = 1
local ghostOriginalSizes = {}
local ghostOriginalMotorCFrames = {}
local bodyParts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}
 
--// do this first so it's ready to use :P
local _storage_clone = nil
local function _get_c()
    return game:GetService("Players").LocalPlayer.Character
end
 
do
    local char = _get_c()
    char.Archivable = true
 
    _storage_clone = char:Clone()
 
    for _, obj in ipairs(_storage_clone:GetDescendants()) do
        if obj:IsA("ForceField") then
            obj:Destroy()
        end
    end
 
    _storage_clone.Name = "temp"
    _storage_clone.Parent = game.Lighting
 
    game:GetService("RunService").RenderStepped:Connect(function()
        local realRoot = char:FindFirstChild("HumanoidRootPart")
        local cloneRoot = _storage_clone:FindFirstChild("HumanoidRootPart")
        if realRoot and cloneRoot then
            cloneRoot.CFrame = realRoot.CFrame
        end
    end)
end
 
-- [[ Adjusts the clone so its lowest part is on the ground ]]
local function adjustCloneToGround(clone)
    if not clone then return end
    local lowestY = math.huge
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            local bottomY = part.Position.Y - (part.Size.Y * 0.5)
            if bottomY < lowestY then
                lowestY = bottomY
            end
        end
    end
    local offset = 0 - lowestY
    if offset > 0 then
        if clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame + Vector3.new(0, offset, 0))
        else
            clone:TranslateBy(Vector3.new(0, offset, 0))
        end
    end
end
 
-- [[ Prevent GUI loss on respawn ]]
local preservedGuis = {}
local function preserveGuis()
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
                table.insert(preservedGuis, gui)
                gui.ResetOnSpawn = false
            end
        end
    end
end
 
local function restoreGuis()
    for _, gui in ipairs(preservedGuis) do
        if gui and gui.Parent then
            gui.ResetOnSpawn = true
        end
    end
    table.clear(preservedGuis)
end
 
-- [[ Update clone scale for size/width sliders ]]
local function updateCloneScale()
    if not ghostClone then return end
    for part, origSize in pairs(ghostOriginalSizes) do
        if part and part:IsA("BasePart") then
            part.Size = Vector3.new(origSize.X * cloneSize * cloneWidth, origSize.Y * cloneSize, origSize.Z * cloneSize)
        end
    end
    for motor, orig in pairs(ghostOriginalMotorCFrames) do
        if motor and motor:IsA("Motor6D") then
            local c0 = orig.C0
            local c1 = orig.C1
            local newC0 = CFrame.new(
                c0.Position.X * cloneSize * cloneWidth,
                c0.Position.Y * cloneSize,
                c0.Position.Z * cloneSize
            ) * CFrame.Angles(c0:ToEulerAnglesXYZ())
            local newC1 = CFrame.new(
                c1.Position.X * cloneSize * cloneWidth,
                c1.Position.Y * cloneSize,
                c1.Position.Z * cloneSize
            ) * CFrame.Angles(c1:ToEulerAnglesXYZ())
            motor.C0 = newC0
            motor.C1 = newC1
        end
    end
 
    local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
    if ghostHumanoid and ghostOriginalHipHeight then
        ghostHumanoid.HipHeight = ghostOriginalHipHeight * cloneSize
    end
 
    adjustCloneToGround(ghostClone)
end
 
-- [[ Copy ragdoll part positions from clone to original ]]
local function updateRagdolledParts()
    if not ghostEnabled or not originalCharacter or not ghostClone then return end
    for _, partName in ipairs(bodyParts) do
        local originalPart = originalCharacter:FindFirstChild(partName)
        local clonePart = ghostClone:FindFirstChild(partName)
        if originalPart and clonePart then
            originalPart.CFrame = clonePart.CFrame
            originalPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            originalPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end
 
-- [[ Main function to enable/disable ghost reanimation ]]
local function setGhostEnabled(newState)
    ghostEnabled = newState
 
    if ghostEnabled then
        local char = LocalPlayer.Character
        if not char then
            warn("No character found!")
            return
        end
 
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then
            warn("Character is missing either Humanoid or HumanoidRootPart!")
            return
        end
 
        originalCharacter = char
        originalCFrame = root.CFrame
 
        char.Archivable = true
        ghostClone = _storage_clone:Clone()
        char.Archivable = false
 
        local originalName = originalCharacter.Name
        ghostClone.Name = originalName .. "_clone"
 
        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalName .. "_clone"
            ghostOriginalHipHeight = ghostHumanoid.HipHeight
        end
 
        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then
                ghostClone.PrimaryPart = hrp
            end
        end
 
        -- [[ Make clone invisible ]]
        for _, part in ipairs(ghostClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        local head = ghostClone:FindFirstChild("Head")
        if head then
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("Decal") then
                    child.Transparency = 1
                end
            end
        end
 
        -- [[ Store original sizes and motor CFrames for scaling ]]
        ghostOriginalSizes = {}
        ghostOriginalMotorCFrames = {}
        for _, desc in ipairs(ghostClone:GetDescendants()) do
            if desc:IsA("BasePart") then
                ghostOriginalSizes[desc] = desc.Size
            elseif desc:IsA("Motor6D") then
                ghostOriginalMotorCFrames[desc] = { C0 = desc.C0, C1 = desc.C1 }
            end
        end
 
        if cloneSize ~= 1 or cloneWidth ~= 1 then
            updateCloneScale()
        end
 
        local animate = originalCharacter:FindFirstChild("Animate")
        if animate then
            originalAnimateScript = animate
            originalAnimateScript.Disabled = true
            originalAnimateScript.Parent = ghostClone
        end
 
        preserveGuis()
        ghostClone.Parent = originalCharacter.Parent
 
        adjustCloneToGround(ghostClone)
 
        LocalPlayer.Character = ghostClone
        if ghostHumanoid then
            Workspace.CurrentCamera.CameraSubject = ghostHumanoid
        end
        restoreGuis()
 
        if originalAnimateScript then
            originalAnimateScript.Disabled = false
        end
 
        -- [[ Start ragdoll sync ]]
        task.delay(0, function()
            if not ghostEnabled then return end
            local ohString1 = "Ball"
            ReplicatedStorage.Ragdoll:FireServer(ohString1)
            task.delay(0, function()
                if not ghostEnabled then return end
                if updateConnection then updateConnection:Disconnect() end
                updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts)
            end)
        end)
 
    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
 
        if not originalCharacter or not ghostClone then return end
 
        for i = 1, 2 do
            ReplicatedStorage.Unragdoll:FireServer()
            task.wait(0.01)
        end
 
        local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
        local ghostRoot = ghostClone:FindFirstChild("HumanoidRootPart")
        local targetCFrame = ghostRoot and ghostRoot.CFrame or originalCFrame
 
        local animate = ghostClone:FindFirstChild("Animate")
        if animate then
            animate.Disabled = true
            animate.Parent = originalCharacter
        end
 
        ghostClone:Destroy()
 
        if origRoot then
            origRoot.CFrame = targetCFrame
            origRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            origRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
 
        local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
        preserveGuis()
        LocalPlayer.Character = originalCharacter
        if origHumanoid then
            Workspace.CurrentCamera.CameraSubject = origHumanoid
            origHumanoid.PlatformStand = false
            origHumanoid.Sit = false
            origHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.06)
            origHumanoid:ChangeState(Enum.HumanoidStateType.Running)
            for _, part in ipairs(originalCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
            local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
            if origRoot then
                origRoot.CFrame = targetCFrame
            end
        end
        restoreGuis()
 
        if animate then
            task.wait(0.1)
            animate.Disabled = false
        end
 
        cloneSize = 1
        cloneWidth = 1
    end
end
 
-- [[ Animation playback logic (fake animation system) ]]
local fakeAnimStop
local fakeAnimRunning = false
fakeAnimStop = false
local fakeAnimSpeed = 1.1
local function stopFakeAnimation()
    fakeAnimStop = true
    fakeAnimRunning = false
    if not ghostClone then return end
    for i,script in pairs(ghostClone:GetChildren()) do
        if script:IsA("LocalScript") and script.Enabled == false then
            script.Enabled=true
        end
    end
    for motor, orig in pairs(ghostOriginalMotorCFrames) do
        if motor and motor:IsA("Motor6D") then
            motor.C0 = orig.C0
            motor.C1 = orig.C1
        end
    end
 
    for _, partName in ipairs(bodyParts) do
        local part = ghostClone:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end
 
-- [[ Play a fake animation on the ghost clone using keyframes ]]
local function playFakeAnimation(animationId)
    if not ghostClone then
        warn("No fake character available!")
        return
    end
    if animationId == "" then return end
    if fakeAnimRunning then
        stopFakeAnimation()
        task.wait(0.01)
        stopFakeAnimation()
    end
    wait(0.02)
    cloneSize = 1
    cloneWidth = 1
    updateCloneScale()
 
    for motor, orig in pairs(ghostOriginalMotorCFrames) do
        motor.C0 = orig.C0
    end
 
    local success, NeededAssets = pcall(function()
        return game:GetObjects("rbxassetid://" .. animationId)[1]
    end)
    if not success or not NeededAssets then
        warn("Invalid Animation ID.")
        return
    end
 
    local character = ghostClone
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")
    local leftFoot = character:WaitForChild("LeftFoot")
    local leftHand = character:WaitForChild("LeftHand")
    local leftLowerArm = character:WaitForChild("LeftLowerArm")
    local leftLowerLeg = character:WaitForChild("LeftLowerLeg")
    local leftUpperArm = character:WaitForChild("LeftUpperArm")
    local leftUpperLeg = character:WaitForChild("LeftUpperLeg")
    local lowerTorso = character:WaitForChild("LowerTorso")
    local rightFoot = character:WaitForChild("RightFoot")
    local rightHand = character:WaitForChild("RightHand")
    local rightLowerArm = character:WaitForChild("RightLowerArm")
    local rightLowerLeg = character:WaitForChild("RightLowerLeg")
    local rightUpperArm = character:WaitForChild("RightUpperArm")
    local rightUpperLeg = character:WaitForChild("RightUpperLeg")
    local upperTorso = character:WaitForChild("UpperTorso")
 
    local Joints = {
        ["Torso"] = rootPart:FindFirstChild("RootJoint"),
        ["Head"] = head:FindFirstChild("Neck"),
        ["LeftUpperArm"] = leftUpperArm:FindFirstChild("LeftShoulder"),
        ["RightUpperArm"] = rightUpperArm:FindFirstChild("RightShoulder"),
        ["LeftUpperLeg"] = leftUpperLeg:FindFirstChild("LeftHip"),
        ["RightUpperLeg"] = rightUpperLeg:FindFirstChild("RightHip"),
        ["LeftFoot"] = leftFoot:FindFirstChild("LeftAnkle"),
        ["RightFoot"] = rightFoot:FindFirstChild("RightAnkle"),
        ["LeftHand"] = leftHand:FindFirstChild("LeftWrist"),
        ["RightHand"] = rightHand:FindFirstChild("RightWrist"),
        ["LeftLowerArm"] = leftLowerArm:FindFirstChild("LeftElbow"),
        ["RightLowerArm"] = rightLowerArm:FindFirstChild("RightElbow"),
        ["LeftLowerLeg"] = leftLowerLeg:FindFirstChild("LeftKnee"),
        ["RightLowerLeg"] = rightLowerLeg:FindFirstChild("RightKnee"),
        ["LowerTorso"] = lowerTorso:FindFirstChild("Root"),
        ["UpperTorso"] = upperTorso:FindFirstChild("Waist"),
    }
 
    fakeAnimStop = false
    fakeAnimRunning = true
 
    -- [[ PlatformStand trick to prevent physics glitches ]]
    local part = Instance.new("Part")
    part.Size = Vector3.new(2048,0.1,2048)
    part.Anchored = true
    part.Position = game.Players.LocalPlayer.Character.LowerTorso.Position + Vector3.new(0,-0.537,0)
    part.Transparency = 1
    part.Parent = workspace
    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
    task.wait(0.1)
    for i,script in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if script:IsA("LocalScript") and script.Enabled then
            script.Enabled=false
        end
    end
    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
    part:Destroy()
    spawn(function()
        while fakeAnimRunning do
            if fakeAnimStop then
                fakeAnimRunning = false
                break
            end
 
            pcall(function()
                local keyframes = NeededAssets:GetKeyframes()
                for ii = 1, #keyframes do
                    if fakeAnimStop then break end
 
                    local currentFrame = keyframes[ii]
                    local nextFrame = keyframes[ii + 1] or keyframes[1]
                    local currentTime = currentFrame.Time
                    local nextTime = nextFrame.Time
                    if nextTime <= currentTime then
                        nextTime = nextTime + NeededAssets.Length
                    end
 
                    local frameLength = (nextTime - currentTime) / fakeAnimSpeed
                    local startTime = os.clock()
                    local endTime = startTime + frameLength
 
                    while os.clock() < endTime and not fakeAnimStop do
                        local now = os.clock()
                        local alpha = math.clamp((now - startTime) / frameLength, 0, 1)
 
                        pcall(function()
                            for _, currentPose in pairs(currentFrame:GetDescendants()) do
                                local nextPose = nextFrame:FindFirstChild(currentPose.Name, true)
                                local motor = Joints[currentPose.Name]
 
                                if motor and nextPose and ghostOriginalMotorCFrames[motor] then
                                    local currentCF = ghostOriginalMotorCFrames[motor].C0 * currentPose.CFrame
                                    local nextCF = ghostOriginalMotorCFrames[motor].C0 * nextPose.CFrame
                                    motor.C0 = currentCF:Lerp(nextCF, alpha)
                                end
                            end
                        end)
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
 
            task.wait(0.03)
        end
    end)
end
 
-- Make functions globally accessible
_G.setGhostEnabled = setGhostEnabled
_G.playFakeAnimation = playFakeAnimation
_G.stopFakeAnimation = stopFakeAnimation
-- FIXED REANIMATION SYSTEM END --
