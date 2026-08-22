-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Reads settings from _G.AimbotSettings
--  No extra key listeners – respects the toggle state only.
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Offset to bring lock to center of head (adjust Y as needed)
local HEAD_OFFSET = Vector3.new(0, -0.3, 0)

-- Helper: find nearest enemy and target part
local function getNearestTarget()
    local character = player.Character
    if not character or not character.PrimaryPart then return nil, nil end
    local root = character.PrimaryPart
    local pos = root.Position

    local bestPlayer = nil
    local bestDist = math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character.PrimaryPart then
            -- Uncomment for team check:
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

-- Main loop – runs every frame
RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings or not settings.Enabled then return end

    local targetPlayer, targetPart = getNearestTarget()
    if not targetPart then return end

    -- Apply offset if we're aiming at Head
    local targetPos = targetPart.Position
    if settings.Part == "Head" then
        targetPos = targetPos + HEAD_OFFSET
    end

    -- Project target to screen
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
    if not onScreen then return end

    -- Smoothness: 0 = instant lock, 100 = nearly no correction
    local smoothFactor = (100 - settings.Smoothness) / 100
    if smoothFactor < 0.01 then smoothFactor = 0.01 end

    if settings.AimType == "Mouse" then
        local currentMousePos = UserInputService:GetMouseLocation()
        local deltaX = (screenPos.X - currentMousePos.X) * smoothFactor
        local deltaY = (screenPos.Y - currentMousePos.Y) * smoothFactor
        mousemoverel(deltaX, deltaY)
    else  -- "Camera"
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local lerpFactor = 1 - (settings.Smoothness / 100)
        if lerpFactor < 0.01 then lerpFactor = 0.01 end
        camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    end
end)

print("Aimbot ready. Use the UI keybind (right‑click to change mode).")
