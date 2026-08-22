-- skybox.lua
return function(assetInput)
    if not assetInput or assetInput == "" then
        return false, "No asset ID or URL provided."
    end

    -- Extract numeric ID if given a URL or full string
    local cleanId = tostring(assetInput):match("%d+")
    if not cleanId then
        return false, "Invalid asset ID or URL format."
    end

    local assetUrl = "rbxassetid://" .. cleanId
    local Lighting = game:GetService("Lighting")

    -- Find existing Sky or create a new one
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "KittySkybox"
        sky.Parent = Lighting
    end

    -- Apply image to all six faces
    sky.SkyboxBk = assetUrl
    sky.SkyboxDn = assetUrl
    sky.SkyboxFt = assetUrl
    sky.SkyboxLf = assetUrl
    sky.SkyboxRt = assetUrl
    sky.SkyboxUp = assetUrl

    return true
end
