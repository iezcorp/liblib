-- ============================================================
--  AIM TAB
-- ============================================================

local AimTab = Window:AddTab("Aim", "crosshair")
local AimGroup = AimTab:AddLeftGroupbox("Aim Settings", "target")

_G.AimbotSettings = {
    Enabled = false,
    Smoothness = 50,
    AimType = "Mouse",
    Part = "Head",
    ToggleKey = Enum.KeyCode.F,  -- default fallback
}

-- Toggle (manual click)
local aimbotToggle = AimGroup:AddToggle("AimbotToggle", {
    Text = "Enable Aimbot",
    Default = false,
})

-- Keypicker with HOLD mode
local toggleKeybind = aimbotToggle:AddKeyPicker("AimbotKeybind", {
    Text = "Hold Key to Aim",
    Default = "F",
    Mode = "Hold",          -- key down = ON, key up = OFF
})

-- Update global settings when toggle changes (click or key)
aimbotToggle:OnChanged(function(value)
    _G.AimbotSettings.Enabled = value
end)

-- Also store the key for the aimbot's direct listener (fallback)
toggleKeybind:OnChanged(function(key)
    _G.AimbotSettings.ToggleKey = key
end)

-- Smoothness Slider
local smoothnessSlider = AimGroup:AddSlider("Smoothness", {
    Text = "Smoothness (higher = weaker lock)",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
})
smoothnessSlider:OnChanged(function(value)
    _G.AimbotSettings.Smoothness = value
end)

-- Aim Type Dropdown
local aimTypeDropdown = AimGroup:AddDropdown("AimType", {
    Text = "Aim Type",
    Values = { "Mouse", "Camera" },
    Default = 1,
    Multi = false,
})
aimTypeDropdown:OnChanged(function(value)
    _G.AimbotSettings.AimType = value
end)

-- Part Dropdown (Head / Torso)
local partDropdown = AimGroup:AddDropdown("Part", {
    Text = "Lock Part",
    Values = { "Head", "Torso" },
    Default = 1,
    Multi = false,
})
partDropdown:OnChanged(function(value)
    _G.AimbotSettings.Part = value
end)
