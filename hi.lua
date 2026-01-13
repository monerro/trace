--// TR4CE MINIMAL TEST
print("[TR4CE] Starting minimal test...")

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

-- Test loading a simple module
local testModuleURL = repo .. "test-module.lua"
print("[TR4CE] Testing URL: " .. testModuleURL)

local success, content = pcall(function()
    return game:HttpGet(testModuleURL)
end)

if success and content then
    print("[TR4CE] Got module content (" .. #content .. " chars)")
    
    local loadSuccess, loadResult = pcall(function()
        return loadstring(content)()
    end)
    
    if loadSuccess then
        print("[TR4CE] ✓ Module loaded successfully!")
        print("[TR4CE] Module returned: " .. tostring(loadResult))
    else
        print("[TR4CE] ✗ Failed to execute module: " .. tostring(loadResult))
    end
else
    print("[TR4CE] ✗ Failed to fetch module: " .. tostring(content))
end

print("[TR4CE] Test complete")
