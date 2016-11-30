gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local json = require "json"
local font = resource.load_font "roboto.ttf"

local Config = (function()
    local roomlist = {}

    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)

        
        gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
        print("screen size is " .. WIDTH .. "x" .. HEIGHT)

        if #config.playlist == 0 then
            playlist = settings.FALLBACK_PLAYLIST
        else
            playlist = {}

            local offset = 0
            for idx = 1, #config.playlist do
                local item = config.playlist[idx]
                playlist[#playlist+1] = {
                    index = idx,
                    room = item.room,
                    day = item.day,
                    time = item.time,
                    course = item.course,
                    tacher = item.teacher
                }
            end
        end
    end)

    return {
        get_playlist = function() return playlist end;
    }
end)()

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

util.set_interval(1, node.gc)

function node.render()
    -- print("--- frame", sys.now())
    gl.clear(0, 0, 0, 1)
    font:write(400, 200, "Other rooms", 80, 1,1,1,1)
end
