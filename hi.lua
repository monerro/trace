--// TR4CE DEBUG LOADER
-- Updated: [current time]
print("[DEBUG] Starting TR4CE loader...")

-- Test if we can reach GitHub
local testURL = "https://raw.githubusercontent.com/monerro/trace/main/hi.lua"
print("[DEBUG] Testing URL: " .. testURL)

local success, result = pcall(function()
    local content = game:HttpGet(testURL)
    print("[DEBUG] Got content length: " .. tostring(#content))
    return content
end)

if success then
    print("[DEBUG] ✓ GitHub access successful")
else
    print("[DEBUG] ✗ GitHub access failed: " .. tostring(result))
end

-- Try loading the simplest possible module
local simpleTest = [[
    print("[DEBUG] Simple module loaded successfully!")
    return {test = "success"}
]]

local loaded = loadstring(simpleTest)
if loaded then
    print("[DEBUG] ✓ loadstring works")
    loaded()
else
    print("[DEBUG] ✗ loadstring failed")
end

print("[DEBUG] Loader complete")
