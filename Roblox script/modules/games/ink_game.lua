local M = {}

function M.init(ctx)
    if not ctx or not ctx.config then return end
    local config = ctx.config
    config.gamePreset = "Ink Game"
    if ctx.registerTeleports then
        ctx.registerTeleports({"Spawn","Arena","Village","Shop","Lobby","Island"})
    end
    if ctx.toast then ctx.toast("Ink Game features loaded") end
    if ctx.pushLog then ctx.pushLog("Loaded Ink Game module") end
end

return M
