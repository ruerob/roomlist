gl.setup(1920, 1080)

local font = resource.load_font "roboto.ttf"

function node.render()
    -- print("--- frame", sys.now())
    gl.clear(0, 0, 0, 1)
    font:write(400, 200, "Other rooms", 80, 1,1,1,1)
end
