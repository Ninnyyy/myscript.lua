local M = {}

local function safeRequire(ctx, relPath)
    if not ctx or not ctx.requireModule then return nil end
    return ctx.requireModule(relPath)
end

local function applyModules(ctx, modules)
    for _,name in ipairs(modules) do
        local mod = safeRequire(ctx, "modules/games/"..name..".lua")
        if mod and mod.init then
            pcall(function() mod.init(ctx) end)
        end
    end
end

function M.load(ctx, detected)
    if not detected then return end
    local modules = {}
    if detected.isFisch then table.insert(modules, "fisch") end
    if detected.isFishIt then table.insert(modules, "fishit") end
    if detected.isForge then table.insert(modules, "forge") end
    if detected.isRivals then table.insert(modules, "rivals") end
    if detected.isInk then table.insert(modules, "ink_game") end
    if #modules == 0 then return end
    applyModules(ctx, modules)
end

return M
