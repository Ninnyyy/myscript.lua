local M = {}

function M.init(ctx)
    if not ctx or not ctx.config then return end
    local config = ctx.config
    config.gamePreset = "Rivals"
    if ctx.registerTeleports then
        ctx.registerTeleports({"Spawn","Arena","Lobby","Shop","Training","Ranked","Island"})
    end
    if ctx.toast then ctx.toast("Rivals features loaded") end
    if ctx.pushLog then ctx.pushLog("Loaded Rivals module") end
end

return M
