local function setup_env()
    local env = {
        Config = {
            OXRadial = false
        }
    }

    local triggerEventCalled = false

    local qbRadialMenu = {
        RemoveOption = function(self, id) end
    }

    env.exports = setmetatable({}, {
        __index = function(t, k)
            if k == 'qb-radialmenu' then
                return qbRadialMenu
            end
            if k == 'qb-core' then
                return {
                    GetCoreObject = function() return {
                        Functions = {
                            GetPlayerData = function() return {} end,
                            CreateClientCallback = function() end
                        }
                    } end
                }
            end
            return rawget(t, k)
        end,
        __call = function(t, k)
            if k == 'qb-radialmenu' then return qbRadialMenu end
            return function() end
        end
    })

    env.lib = {
        removeRadialItem = function(id) end,
        onCache = function() end,
        addRadialItem = function(item) end
    }

    env.TriggerEvent = function(eventName)
        triggerEventCalled = true
        assert.are.equal("qb-garages:client:oxrefresh", eventName)
    end

    env.getTriggerEventCalled = function()
        return triggerEventCalled
    end

    -- Global setup
    setmetatable(env, {
        __index = function(t, k)
            if k == "RegisterNetEvent" or k == "AddEventHandler" or k == "CreateThread" then
                return function() end
            end
            if k == "PlayerPedId" then
                return function() return 1 end
            end
            if k == "IsPedInAnyVehicle" then
                return function() return false end
            end
            if k == "exports" then
                return t.exports
            end
            return _G[k]
        end,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    })

    local chunk = loadfile('client/main.lua', "t", env)
    chunk()

    -- Expose local variables by injecting them into env
    env.getMenuItemId1 = function()
        local i = 1
        while true do
            local name, value = debug.getupvalue(env.RemoveRadialOptions, i)
            if not name then break end
            if name == "MenuItemId1" then return value end
            i = i + 1
        end
    end

    env.getMenuItemId2 = function()
        local i = 1
        while true do
            local name, value = debug.getupvalue(env.RemoveRadialOptions, i)
            if not name then break end
            if name == "MenuItemId2" then return value end
            i = i + 1
        end
    end

    env.setMenuItemId1 = function(val)
        local i = 1
        while true do
            local name = debug.getupvalue(env.RemoveRadialOptions, i)
            if not name then break end
            if name == "MenuItemId1" then
                debug.setupvalue(env.RemoveRadialOptions, i, val)
                return
            end
            i = i + 1
        end
    end

    env.setMenuItemId2 = function(val)
        local i = 1
        while true do
            local name = debug.getupvalue(env.RemoveRadialOptions, i)
            if not name then break end
            if name == "MenuItemId2" then
                debug.setupvalue(env.RemoveRadialOptions, i, val)
                return
            end
            i = i + 1
        end
    end

    return env, qbRadialMenu
end

describe("RemoveRadialOptions", function()
    local env
    local qbRadialMenu

    before_each(function()
        env, qbRadialMenu = setup_env()
        spy.on(qbRadialMenu, "RemoveOption")
        spy.on(env.lib, "removeRadialItem")
    end)

    describe("when Config.OXRadial is not true (using qb-radialmenu)", function()
        before_each(function()
            env.Config.OXRadial = false
        end)

        it("should remove MenuItemId1 and set it to nil if it is not nil", function()
            env.setMenuItemId1(100)
            env.RemoveRadialOptions()
            assert.spy(qbRadialMenu.RemoveOption).was.called_with(qbRadialMenu, 100)
            assert.is_nil(env.getMenuItemId1())
        end)

        it("should remove MenuItemId2 and set it to nil if it is not nil", function()
            env.setMenuItemId2(200)
            env.RemoveRadialOptions()
            assert.spy(qbRadialMenu.RemoveOption).was.called_with(qbRadialMenu, 200)
            assert.is_nil(env.getMenuItemId2())
        end)

        it("should not call RemoveOption if MenuItemId1 and MenuItemId2 are nil", function()
            env.setMenuItemId1(nil)
            env.setMenuItemId2(nil)
            env.RemoveRadialOptions()
            assert.spy(qbRadialMenu.RemoveOption).was_not.called()
        end)

        it("should not trigger oxrefresh event", function()
            env.RemoveRadialOptions()
            assert.is_false(env.getTriggerEventCalled())
        end)
    end)

    describe("when Config.OXRadial is true (using ox_lib)", function()
        before_each(function()
            env.Config.OXRadial = true
        end)

        it("should remove MenuItemId1 using lib and set it to nil if it is not nil", function()
            env.setMenuItemId1(true)
            env.RemoveRadialOptions()
            assert.spy(env.lib.removeRadialItem).was.called_with('MenuItemId1')
            assert.is_nil(env.getMenuItemId1())
        end)

        it("should remove MenuItemId2 using lib and set it to nil if it is not nil", function()
            env.setMenuItemId2(true)
            env.RemoveRadialOptions()
            assert.spy(env.lib.removeRadialItem).was.called_with('MenuItemId2')
            assert.is_nil(env.getMenuItemId2())
        end)

        it("should not call removeRadialItem if MenuItemId1 and MenuItemId2 are nil", function()
            env.setMenuItemId1(nil)
            env.setMenuItemId2(nil)
            env.RemoveRadialOptions()
            assert.spy(env.lib.removeRadialItem).was_not.called()
        end)

        it("should trigger oxrefresh event", function()
            env.RemoveRadialOptions()
            assert.is_true(env.getTriggerEventCalled())
        end)
    end)
end)
