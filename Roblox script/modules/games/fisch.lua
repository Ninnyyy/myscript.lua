local M = {}

function M.init(ctx)
    if not ctx or not ctx.config then return end
    local config = ctx.config
    config.gamePreset = "Fisch"
    config.autoInteractFilter = "reel,cast,fish"
    config.esp.nameFilter = "fish,hotspot"
    config.fov = config.fov or 80
    if ctx.registerTeleports then
        ctx.registerTeleports({"Spawn","Dock","Harbor","Ocean","Snowcap","Roslit","Moosewood","Terrapin","Mushgrove","Depths","Ancient","Island","Hotspot"})
    end
    if ctx.toast then ctx.toast("Fisch features loaded") end
    if ctx.pushLog then ctx.pushLog("Loaded Fisch module") end
end

return M
