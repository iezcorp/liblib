-- ============================================================
--  skybox.lua
--  Applies a custom skybox to Roblox Lighting using a single image URL.
--  Usage: loadstring(game:HttpGet("raw_url_to_this_file"))()(imageUrl)
-- ============================================================

return function(imageUrl)
    -- Validate input
    if type(imageUrl) ~= "string" or imageUrl == "" then
        warn("[Skybox] Invalid image URL provided.")
        return false
    end

    -- Get the Lighting service
    local Lighting = game:GetService("Lightning")

    -- Find existing Sky or create a new one
    local sky = Lighting:FindFirstChild("Sky")
    if not sky then
        sky = Instance.new("Sky", Lighting)
        print("[Skybox] Created new Sky instance.")
    else
        print("[Skybox] Using existing Sky instance.")
    end

    -- Roblox Sky uses 6 faces – set all to the same image
    local faces = {
        "SkyboxBk",  -- Back
        "SkyboxDn",  -- Down
        "SkyboxFt",  -- Front
        "SkyboxLf",  -- Left
        "SkyboxRt",  -- Right
        "SkyboxUp"   -- Up
    }

    for _, face in ipairs(faces) do
        sky[face] = imageUrl
    end

    -- Enable the sky
    sky.Enabled = true

    print("[Skybox] Skybox applied successfully!")
    return true
end
