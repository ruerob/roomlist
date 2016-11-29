local Config = (function()
    local text

    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)

        text = config.text
    end)

    return {
        get_text = function() return text end;
    }
end)()

gl.setup(1024, 768)

util.resource_loader{
    "roboto.ttf"
}

function node.render()
    gl.clear(0,0,0,1)
    font:write(250, 300, Config.get_text, 64, 1,1,1,1)
end