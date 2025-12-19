local M = {}

function M.init(ctx)
    if not ctx or not ctx.config then return end
    local config = ctx.config
    config.gamePreset = "Forge"
    config.autoInteractFilter = "forge,smelt,anvil"
    config.esp.nameFilter = "ore,anvil,forge,smelt"
    if ctx.registerTeleports then
        ctx.registerTeleports({"Spawn","Forge","Anvil","Smelter","Ore","Mine","Shop","Upgrade","Bank"})
    end
    if ctx.toast then ctx.toast("Forge features loaded") end
    if ctx.pushLog then ctx.pushLog("Loaded Forge module") end
end

return M
