-- ============================================================
--  AIMBOT – Kitty (Rivals)
--  Core logic adapted from Open‑Aimbot (ttwizz)
--  Reads settings from _G.AimbotSettings
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
--  CONFIGURATION (mirror Open‑Aimbot's defaults)
-- ============================================================

-- Static offset for Head (brings aim down to center)
local HEAD_OFFSET = Vector3.new(0, -0.3, 0)

-- Optional: enable/disable checks (we can add later if UI expands)
local ENABLE_TEAM_CHECK = false   -- set to true if you want team check

-- ============================================================
--  HELPER: Is the target valid?
-- ============================================================

local function IsTargetValid(targetChar, targetPart)
    if not targetChar or not targetPart then return false end
    local humanoid = targetChar:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    -- Team check (optional)
    if ENABLE_TEAM_CHECK then
        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
        if targetPlayer and player.Team and targetPlayer.Team == player.Team then
            return false
        end
    end

    -- Part must be a BasePart
    if not targetPart:IsA("BasePart") then return false end

    -- (Optional wall check using raycast – uncomment if needed)
    -- local origin = camera.CFrame.Position
    -- local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    -- local ray = RaycastParams.new()
    -- ray.FilterType = Enum.RaycastFilterType.Exclude
    -- ray.FilterDescendantsInstances = {player.Character}
    -- local result = workspace:Raycast(origin, direction, ray)
    -- if result and result.Instance and not result.Instance:IsDescendantOf(targetChar) then
    --     return false
    -- end

    return true
end

-- ============================================================
--  FIND THE NEAREST TARGET
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
--  MAIN AIMBOT LOOP
-- ============================================================

local tween = nil

RunService.Heartbeat:Connect(function()
    local settings = _G.AimbotSettings
    if not settings or not settings.Enabled then return end

    local targetChar, targetPart = GetNearestTarget()
    if not targetPart then return end

    -- Apply offset if aiming for Head
    local targetPos = targetPart.Position
    if settings.Part == "Head" then
        targetPos = targetPos + HEAD_OFFSET
    end

    -- Project to screen
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
    if not onScreen then return end

    -- Smoothness factor: 0 = instant, 100 = almost no correction
    local smoothFactor = (100 - settings.Smoothness) / 100
    if smoothFactor < 0.01 then smoothFactor = 0.01 end

    if settings.AimType == "Mouse" then
        -- Move mouse relative
        local currentMouse = UserInputService:GetMouseLocation()
        local deltaX = (screenPos.X - currentMouse.X) * smoothFactor
        local deltaY = (screenPos.Y - currentMouse.Y) * smoothFactor
        mousemoverel(deltaX, deltaY)
    else
        -- Camera smoothing using Tween (like Open‑Aimbot's Camera mode)
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local lerpFactor = 1 - (settings.Smoothness / 100)  -- 1 = full lock per frame
        if lerpFactor < 0.01 then lerpFactor = 0.01 end

        -- If we have a tween, cancel it
        if tween then
            tween:Cancel()
            tween = nil
        end

        -- Use Lerp for smooth camera movement (more responsive than Tween)
        camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    end
end)

print("Aimbot loaded (Open‑Aimbot core). Use the UI toggle/keybind.")
