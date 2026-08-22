-- skybox.lua
-- Usage: loadstring(game:HttpGet("raw_url_to_this_file"))()(imageUrl)

return function(imageUrl)
    -- Validate input
    if type(imageUrl) ~= "string" or imageUrl == "" then
        warn("[Skybox] Invalid image URL provided.")
        return false
    end

    print("[Skybox] Applying skybox...")

    local Lighting = game:GetService("Lighting")
    local sky = Lighting:FindFirstChild("Sky") or Instance.new("Sky", Lighting)

    -- Roblox Sky uses 6 faces; set all to the same image
    local faces = {
        "SkyboxBk", "SkyboxDn", "SkyboxFt",
        "SkyboxLf", "SkyboxRt", "SkyboxUp"
    }

    for _, face in ipairs(faces) do
        sky[face] = imageUrl
    end

    -- Enable the sky
    sky.Enabled = true

    print("[Skybox] Skybox applied successfully!")
    return true
end
