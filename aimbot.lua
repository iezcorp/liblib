-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Reads settings from _G.AimbotSettings
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Offset to bring aim down to the center of the head (adjust if needed)
local HEAD_OFFSET = Vector3.new(0, -0.3, 0)

-- Helper: find nearest enemy and the target part
local function getNearestTarget()
    local character = player.Character
    if not character or not character.PrimaryPart then return nil, nil end
    local root = character.PrimaryPart
    local pos = root.Position

    local bestPlayer = nil
    local bestDist = math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character.PrimaryPart then
            -- optional team check (uncomment if needed)
            -- if player.Team and other.Team == player.Team then continue end
            local otherRoot = other.Character.PrimaryPart
            local dist = (otherRoot.Position - pos).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestPlayer = other
            end
        end
    end

    if not bestPlayer then return nil, nil end

    local targetChar = bestPlayer.Character
    local settings = _G.AimbotSettings
    local partName = (settings and settings.Part) or "Head"
    local targetPart = targetChar:FindFirstChild(partName)
    if not targetPart then
        targetPart = targetChar:FindFirstChild("Head") or targetChar.PrimaryPart
    end
    return bestPlayer, targetPart
end

-- Direct key listener (fallback for hold mode)
local keyDown = false
local toggleKey = _G.AimbotSettings and _G.AimbotSettings.ToggleKey or Enum.KeyCode.F

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        keyDown = true
        -- If the manual toggle is off, we temporarily enable aimbot
        -- but we don't override the toggle's value; we set a separate flag.
        -- We'll combine: if manual toggle is on OR key is held, aimbot active.
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        keyDown = false
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings then return end

    -- Aimbot active if manual toggle is ON OR key is held down
    local active = settings.Enabled or keyDown
    if not active then return end

    local targetPlayer, targetPart = getNearestTarget()
    if not targetPart then return end

    -- Apply offset to bring aim to center of head (if head is selected)
    local targetPos = targetPart.Position
    if settings.Part == "Head" then
        targetPos = targetPos + HEAD_OFFSET
    end

    -- Get screen position
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
    if not onScreen then return end

    -- Smoothness
    local smoothFactor = (100 - settings.Smoothness) / 100
    if smoothFactor < 0.01 then smoothFactor = 0.01 end

    if settings.AimType == "Mouse" then
        local currentMousePos = UserInputService:GetMouseLocation()
        local deltaX = screenPos.X - currentMousePos.X
        local deltaY = screenPos.Y - currentMousePos.Y
        deltaX = deltaX * smoothFactor
        deltaY = deltaY * smoothFactor
        mousemoverel(deltaX, deltaY)
    else  -- "Camera"
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local lerpFactor = 1 - (settings.Smoothness / 100)
        if lerpFactor < 0.01 then lerpFactor = 0.01 end
        camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    end
end)

print("Aimbot loaded. Hold the key to aim, or toggle manually.")
