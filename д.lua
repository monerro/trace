local BASE_URL = "https://raw.githubusercontent.com/monerro/trace/main/"

local function Load(path)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not ok then
        warn("FAILED TO LOAD:", path)
        warn(res)
    end
    return res
end

