-- skybox.lua
local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")

-- Helper function to convert Decal IDs to true Image IDs
local function getImageId(assetId)
    local numId = tonumber(tostring(assetId):match("%d+"))
    if not numId then return nil end

    -- Try resolving via InsertService
    local success, result = pcall(function()
        local decal = InsertService:LoadAsset(numId):FindFirstChildOfClass("Decal")
        if decal and decal.Texture then
            return decal.Texture
        end
    end)

    if success and result and result ~= "" then
        return result
    end

    -- Fallback to direct asset ID format if InsertService is blocked by executor/game
    return "rbxassetid://" .. tostring(numId)
end

return function(assetInput)
    if not assetInput or assetInput == "" then
        return false, "No asset ID provided."
    end

    local textureUrl = getImageId(assetInput)
    if not textureUrl then
        return false, "Invalid Asset ID format."
    end

    -- Get or create Sky instance
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "KittySkybox"
        sky.Parent = Lighting
    end

    -- Apply texture to all six faces
    sky.SkyboxBk = textureUrl
    sky.SkyboxDn = textureUrl
    sky.SkyboxFt = textureUrl
    sky.SkyboxLf = textureUrl
    sky.SkyboxRt = textureUrl
    sky.SkyboxUp = textureUrl

    return true
end
