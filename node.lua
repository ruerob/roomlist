gl.setup(1920, 1080)

local json = require "json"
local font = resource.load_font "roboto.ttf"

local Config = (function()
    local roomlist = {}

    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)
        
        timezone = config.timezone

        gl.setup(1920, 1080)

        roomlist = {}

        for idx = 1, #config.roomlist do
            local item = config.roomlist[idx]
            roomlist[#roomlist+1] = {
                index = idx,
                room = item.room,
                day = item.day,
                time = item.time,
                course = item.course,
                teacher = item.teacher
            }
        end
    end)

    return {
        get_roomlist = function() return roomlist end;
        get_timezone = function() return timezone end;
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

function write_line(x,y,room,day,time,course,teacher)
    offset_step_length=300
    offset_step=0
    font:write(x+(offset_step_length*(offset_step)),y,room,50,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,"|" .. day,50,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,"|" .. time,50,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,"|" .. course,50,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,"|" .. teacher,50,1,1,1,1)
end

function node.render()
    -- print("--- frame", sys.now())
    local roomlist = Config.get_roomlist()
    gl.clear(0, 0, 0, 1)
    write_line(0,0,"Raum","Tag","Uhrzeit","Fach","Lehrer")
    time = os.date("!%H:%M:%S", os.time + Config.get_timezone()*60*60)
    font:write(1780,0,time,50,1,1,1,1)
    local offset=0
    for idx=1, #roomlist do
        write_line(0,60+offset,roomlist[idx].room,roomlist[idx].day,roomlist[idx].time,roomlist[idx].course,roomlist[idx].teacher)
        offset=offset+60
    end
    
    --font:write(0,1000,"Debug Timezone: " .. tzoffset,50,1,1,1,1)
end
