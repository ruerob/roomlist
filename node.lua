gl.setup(1920, 1080)

local json = require "json"
local font = resource.load_font "roboto.ttf"

local Time = (function()
    local base
    util.data_mapper{
        ["clock/set"] = function(t)
            base = tonumber(t) - sys.now()
        end
    }
    return {
        get = function()
            if base then
                return base + sys.now()
            end
        end
    }
end)()

function node.render()
    -- print("--- frame", sys.now())
    gl.clear(0, 0, 0, 1)
    font:write(400, 200, "Other rooms", 80, 1,1,1,1)
end
