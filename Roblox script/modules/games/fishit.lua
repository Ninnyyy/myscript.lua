local M = {}

function M.init(ctx)
    if not ctx or not ctx.config then return end
    local config = ctx.config
    config.gamePreset = "Fish It"
    config.autoInteractFilter = "reel,cast,fish"
    config.esp.nameFilter = "fish,hotspot,pier,vendor"
    config.fullbright = true
    config.noFog = true
    if ctx.registerTeleports then
        ctx.registerTeleports({"Spawn","Ocean","River","Lake","Cave","Lava","Deep sea","Shop","Vendor","Upgrade","Bait","Pier","Hotspot"})
    end
    if ctx.toast then ctx.toast("Fish It features loaded") end
    if ctx.pushLog then ctx.pushLog("Loaded Fish It module") end
end

return M
