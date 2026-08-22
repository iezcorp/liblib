-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Reads settings from _G.AimbotSettings (set by UI)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Helper: find nearest enemy and the target part (Head or Torso)
local function getNearestTarget()
    local character = player.Character
    if not character or not character.PrimaryPart then return nil, nil end
    local root = character.PrimaryPart
    local pos = root.Position

    local bestPlayer = nil
    local bestDist = math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character.PrimaryPart then
            -- Optional team check (uncomment if needed)
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
        -- fallback to Head or PrimaryPart
        targetPart = targetChar:FindFirstChild("Head") or targetChar.PrimaryPart
    end
    return bestPlayer, targetPart
end

-- Main loop
RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings or not settings.Enabled then return end

    local targetPlayer, targetPart = getNearestTarget()
    if not targetPart then return end

    -- Get screen position of the target part
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)
    if not onScreen then return end

    -- Smoothness: 0 = instant lock, 100 = almost no correction
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
        local targetPos = targetPart.Position
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local lerpFactor = 1 - (settings.Smoothness / 100)  -- 1 = full lock per frame
        if lerpFactor < 0.01 then lerpFactor = 0.01 end
        local newCF = currentCF:Lerp(targetCF, lerpFactor)
        camera.CFrame = newCF
    end
end)

print("Aimbot ready. Use the UI toggle or its keybind.")
