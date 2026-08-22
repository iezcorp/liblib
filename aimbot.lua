-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Reads settings from _G.AimbotSettings
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Helper: get the nearest enemy player (ignores dead and team)
local function getNearestEnemy()
    local character = player.Character
    if not character or not character.PrimaryPart then return nil end
    local root = character.PrimaryPart
    local pos = root.Position

    local bestTarget = nil
    local bestDist = math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character.PrimaryPart then
            -- optional team check (remove if not needed)
            -- if player.Team and other.Team == player.Team then continue end
            local otherRoot = other.Character.PrimaryPart
            local dist = (otherRoot.Position - pos).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestTarget = other
            end
        end
    end
    return bestTarget
end

-- Main loop
RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings or not settings.Enabled then return end

    local target = getNearestEnemy()
    if not target then return end

    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then return end

    -- Target screen position
    local screenPos, onScreen = camera:WorldToScreenPoint(targetHead.Position)
    if not onScreen then return end

    local currentMousePos = UserInputService:GetMouseLocation()
    local deltaX = screenPos.X - currentMousePos.X
    local deltaY = screenPos.Y - currentMousePos.Y

    -- Smoothness: 0 = instant lock, 100 = almost no correction
    local smoothFactor = (100 - settings.Smoothness) / 100  -- 0..1
    if smoothFactor < 0.01 then smoothFactor = 0.01 end  -- avoid zero

    -- Apply smoothing to delta
    deltaX = deltaX * smoothFactor
    deltaY = deltaY * smoothFactor

    if settings.AimType == "Mouse" then
        -- Move mouse relative
        mousemoverel(deltaX, deltaY)
    else  -- "Camera"
        -- Smoothly rotate camera towards target
        local targetPos = targetHead.Position
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        -- Interpolate CFrame using smoothFactor (inverse: higher smoothness = slower rotation)
        local lerpFactor = 1 - (settings.Smoothness / 100)  -- 0..1, 1 = full lock per frame
        if lerpFactor < 0.01 then lerpFactor = 0.01 end
        local newCF = currentCF:Lerp(targetCF, lerpFactor)
        camera.CFrame = newCF
    end
end)

print("Aimbot ready. Toggle via UI.")
