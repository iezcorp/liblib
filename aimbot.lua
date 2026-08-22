-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Uses Open‑Aimbot’s static offset + smoothing logic
--  Reads _G.AimbotSettings
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
--  HELPER: Is the target valid?
-- ============================================================

local function IsTargetValid(targetChar, targetPart)
    if not targetChar or not targetPart then return false end
    local humanoid = targetChar:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    -- Optional team check – uncomment if needed
    -- local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
    -- if targetPlayer and player.Team and targetPlayer.Team == player.Team then return false end
    if not targetPart:IsA("BasePart") then return false end
    return true
end

-- ============================================================
--  FIND NEAREST TARGET
-- ============================================================

local function GetNearestTarget()
    local character = player.Character
    if not character or not character.PrimaryPart then return nil, nil end
    local root = character.PrimaryPart
    local pos = root.Position

    local bestChar = nil
    local bestPart = nil
    local bestDist = math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local otherChar = other.Character
            if otherChar and otherChar.PrimaryPart then
                local settings = _G.AimbotSettings
                local partName = (settings and settings.Part) or "Head"
                local part = otherChar:FindFirstChild(partName)
                if not part then
                    part = otherChar:FindFirstChild("Head") or otherChar.PrimaryPart
                end
                if part and IsTargetValid(otherChar, part) then
                    local dist = (part.Position - pos).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestChar = otherChar
                        bestPart = part
                    end
                end
            end
        end
    end

    return bestChar, bestPart
end

-- ============================================================
--  MAIN LOOP
-- ============================================================

RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings or not settings.Enabled then return end

    local targetChar, targetPart = GetNearestTarget()
    if not targetPart then return end

    -- Apply static offset as in Open‑Aimbot:
    -- Offset = Vector3.new(0, TargetPart.Position.Y * StaticOffsetIncrement / 10, 0)
    local offset = Vector3.new(0, targetPart.Position.Y * settings.StaticOffsetIncrement / 10, 0)
    local targetPos = targetPart.Position + offset

    -- Project to screen
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
    if not onScreen then return end

    -- Smoothness: 0 = instant, 100 = almost no correction
    local smoothFactor = (100 - settings.Smoothness) / 100
    if smoothFactor < 0.01 then smoothFactor = 0.01 end

    if settings.AimType == "Mouse" then
        local currentMouse = UserInputService:GetMouseLocation()
        local deltaX = (screenPos.X - currentMouse.X) * smoothFactor
        local deltaY = (screenPos.Y - currentMouse.Y) * smoothFactor
        mousemoverel(deltaX, deltaY)
    else
        -- Camera mode
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local lerpFactor = 1 - (settings.Smoothness / 100)
        if lerpFactor < 0.01 then lerpFactor = 0.01 end
        camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    end
end)

print("Aimbot loaded with Open‑Aimbot offset method.")
