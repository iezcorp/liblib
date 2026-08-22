```lua
-- skybox.lua
-- Usage:
-- loadstring(game:HttpGet("raw_url_to_this_file"))()(imageUrl)

return function(imageUrl)
    -- Validate input
    if type(imageUrl) ~= "string" or imageUrl == "" then
        warn("[Skybox] Invalid image URL provided.")
        return false
    end

    print("[Skybox] Applying skybox...")

    local Lighting = game:GetService("Lighting")

    -- Find existing Sky or create one
    local sky = Lighting:FindFirstChildOfClass("Sky")

    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "Sky"
        sky.Parent = Lighting
    end

    -- Roblox Sky uses 6 faces
    local faces = {
        "SkyboxBk",
        "SkyboxDn",
        "SkyboxFt",
        "SkyboxLf",
        "SkyboxRt",
        "SkyboxUp"
    }

    -- Apply image to all six faces
    for _, face in ipairs(faces) do
        sky[face] = imageUrl
    end

    print("[Skybox] Skybox applied successfully!")

    return true
end
```
