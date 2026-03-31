local assert = require("luassert")

describe("Server Main", function()

    local original_exports
    local original_Config
    local original_RegisterNetEvent
    local original_TriggerEvent
    local original_TriggerClientEvent
    local original_PerformHttpRequest
    local original_json
    local original_joaat
    local original_CreateVehicle
    local original_CreateVehicleServerSetter
    local original_Wait
    local original_DoesEntityExist
    local original_GetVehicleNumberPlateText
    local original_SetVehicleNumberPlateText
    local original_SetPedIntoVehicle
    local original_NetworkGetNetworkIdFromEntity
    local original_GetAllVehicles
    local original_GetEntityCoords
    local original_GetPlayerPed
    local original_AddEventHandler
    local original_GetCurrentResourceName
    local original_DeleteEntity
    local original_print
    local original_tonumber
    local original_type
    local original_ipairs
    local original_pairs
    local original_string_upper

    local commands = {}
    local netEvents = {}
    local qbCoreMock

    local triggeredClientEvents = {}
    local triggeredEvents = {}

    before_each(function()
        commands = {}
        netEvents = {}
        triggeredClientEvents = {}
        triggeredEvents = {}

        -- Backup globals
        original_exports = _G.exports
        original_Config = _G.Config
        original_RegisterNetEvent = _G.RegisterNetEvent
        original_TriggerEvent = _G.TriggerEvent
        original_TriggerClientEvent = _G.TriggerClientEvent
        original_PerformHttpRequest = _G.PerformHttpRequest
        original_json = _G.json
        original_joaat = _G.joaat
        original_CreateVehicle = _G.CreateVehicle
        original_CreateVehicleServerSetter = _G.CreateVehicleServerSetter
        original_Wait = _G.Wait
        original_DoesEntityExist = _G.DoesEntityExist
        original_GetVehicleNumberPlateText = _G.GetVehicleNumberPlateText
        original_SetVehicleNumberPlateText = _G.SetVehicleNumberPlateText
        original_SetPedIntoVehicle = _G.SetPedIntoVehicle
        original_NetworkGetNetworkIdFromEntity = _G.NetworkGetNetworkIdFromEntity
        original_GetAllVehicles = _G.GetAllVehicles
        original_GetEntityCoords = _G.GetEntityCoords
        original_GetPlayerPed = _G.GetPlayerPed
        original_AddEventHandler = _G.AddEventHandler
        original_GetCurrentResourceName = _G.GetCurrentResourceName
        original_DeleteEntity = _G.DeleteEntity
        original_print = _G.print

        -- Mock globals
        _G.Config = {
            CustomIMG = {},
            Garages = {
                ["test_garage"] = { type = "public", label = "Test Garage" }
            },
            HouseGarages = {},
            SharedJobGarages = {},
            SharedGangGarages = false,
            EnableTrackVehicleByPlateCommand = true,
            TrackVehicleByPlateCommand = "trackveh",
            BFakePlates = false
        }
        _G.RegisterNetEvent = function(name, cb)
            netEvents[name] = cb
        end
        _G.TriggerEvent = function(name, ...)
            table.insert(triggeredEvents, {name = name, args = {...}})
        end

        _G.TriggerClientEvent = function(name, src, ...)
            table.insert(triggeredClientEvents, {name = name, src = src, args = {...}})
        end

        _G.PerformHttpRequest = function() end
        _G.json = { decode = function() return {} end, encode = function() return "{}" end }
        _G.joaat = function(str) return str end
        _G.CreateVehicle = function() return 1 end
        _G.CreateVehicleServerSetter = nil
        _G.Wait = function() end
        _G.DoesEntityExist = function() return true end
        _G.GetVehicleNumberPlateText = function() return "TESTPL" end
        _G.SetVehicleNumberPlateText = function() end
        _G.SetPedIntoVehicle = function() end
        _G.NetworkGetNetworkIdFromEntity = function() return 123 end
        _G.GetAllVehicles = function() return {} end
        _G.GetEntityCoords = function() return {x=0,y=0,z=0} end
        _G.GetPlayerPed = function() return 1 end
        _G.AddEventHandler = function() end
        _G.GetCurrentResourceName = function() return "qb-garages" end
        _G.DeleteEntity = function() end
        _G.print = function() end
        _G.vector3 = function(x,y,z) return {x=x,y=y,z=z} end
        _G.Lang = { t = function(self, key, params) return key end }
        setmetatable(_G.Lang, {
            __call = function(t, key, params) return key end
        })
        _G.source = 1

        qbCoreMock = {
            Commands = {
                Add = function(name, help, args, req, cb)
                    commands[name] = cb
                end
            },
            Functions = {
                GetPlayer = function()
                    return {
                        PlayerData = {
                            citizenid = "TESTID",
                            charinfo = { firstname = "John", lastname = "Doe" },
                            gang = { name = "none" },
                            money = { cash = 100, bank = 100 }
                        },
                        Functions = {
                            RemoveMoney = function() return true end
                        }
                    }
                end,
                CreateCallback = function() end,
                SpawnVehicle = function() return 1 end,
                TriggerClientCallback = function() end,
            },
            Shared = {
                Vehicles = {
                    ['testveh'] = { category = "sedans", brand = "Test", name = "Vehicle" }
                }
            }
        }

        -- Mock QBCore
        _G.exports = {
            ['qb-core'] = {
                GetCoreObject = function()
                    return qbCoreMock
                end
            },
            ['brazzers-fakeplates'] = {
                getFakePlateFromPlate = function() return nil end,
                getPlateFromFakePlate = function() return nil end
            }
        }

        -- Mock MySQL
        _G.MySQL = {
            Sync = {
                fetchAll = function() return {} end
            },
            query = function(q, p, cb) if cb then cb({}) end end,
            update = function() return 1 end
        }

    end)

    after_each(function()
        -- Restore globals
        _G.exports = original_exports
        _G.Config = original_Config
        _G.RegisterNetEvent = original_RegisterNetEvent
        _G.TriggerEvent = original_TriggerEvent
        _G.TriggerClientEvent = original_TriggerClientEvent
        _G.PerformHttpRequest = original_PerformHttpRequest
        _G.json = original_json
        _G.joaat = original_joaat
        _G.CreateVehicle = original_CreateVehicle
        _G.CreateVehicleServerSetter = original_CreateVehicleServerSetter
        _G.Wait = original_Wait
        _G.DoesEntityExist = original_DoesEntityExist
        _G.GetVehicleNumberPlateText = original_GetVehicleNumberPlateText
        _G.SetVehicleNumberPlateText = original_SetVehicleNumberPlateText
        _G.SetPedIntoVehicle = original_SetPedIntoVehicle
        _G.NetworkGetNetworkIdFromEntity = original_NetworkGetNetworkIdFromEntity
        _G.GetAllVehicles = original_GetAllVehicles
        _G.GetEntityCoords = original_GetEntityCoords
        _G.GetPlayerPed = original_GetPlayerPed
        _G.AddEventHandler = original_AddEventHandler
        _G.GetCurrentResourceName = original_GetCurrentResourceName
        _G.DeleteEntity = original_DeleteEntity
        _G.print = original_print
    end)


    it("should load the server main file without errors", function()
        assert.has_no.errors(function()
            dofile("server/main.lua")
        end)
    end)

    describe("Commands", function()
        before_each(function()
            dofile("server/main.lua")
        end)

        it("should execute pgarage command and trigger client event when vehicles found", function()
            local pgarageCmd = commands["pgarage"]
            assert.is_not_nil(pgarageCmd)

            local mockVehicles = {
                { engine = 1000, body = 1000, vehicle = "testveh", plate = "TESTPL", state = 1, fuel = 100 }
            }
            _G.MySQL.Sync.fetchAll = function() return mockVehicles end

            pgarageCmd(1, {"1"})

            assert.is_true(#triggeredClientEvents > 0)
            local lastEvent = triggeredClientEvents[#triggeredClientEvents]
            assert.equals("qb-garages:client:openmanage", lastEvent.name)
            assert.equals(1, lastEvent.src)
            assert.equals("John Doe [TESTID]", lastEvent.args[1])
            assert.equals(1, #lastEvent.args[2])
            assert.equals("TESTVEH (TESTPL)", lastEvent.args[2][1].title)
            assert.equals(100, lastEvent.args[2][1].progress)
            assert.equals("green", lastEvent.args[2][1].colorScheme)
            assert.equals("qb-garages:client:managecar", lastEvent.args[2][1].event)
        end)

        it("should execute deletevehicle command and trigger server event", function()
            local deletevehicleCmd = commands["deletevehicle"]
            assert.is_not_nil(deletevehicleCmd)

            deletevehicleCmd(1, {"TESTPL"})

            assert.is_true(#triggeredEvents > 0)
            local lastEvent = triggeredEvents[#triggeredEvents]
            assert.equals("qb-garages:server:deletecar", lastEvent.name)
            assert.equals("TESTPL", lastEvent.args[1])
        end)
    end)

    describe("Net Events", function()
        before_each(function()
            dofile("server/main.lua")
        end)

        it("should delete car from db and notify success on qb-garages:server:deletecar", function()
            local deletecarEvent = netEvents["qb-garages:server:deletecar"]
            assert.is_not_nil(deletecarEvent)

            local function customQuery(q, p, cb)
                if string.match(q, "SELECT") then
                    cb({ {plate = "TESTPL"} })
                elseif string.match(q, "DELETE") then
                    cb({ affectedRows = 1 }) -- Simulating successful delete
                else
                    cb({})
                end
            end

            _G.MySQL.query = customQuery

            _G.source = 1
            deletecarEvent("TESTPL")

            assert.is_true(#triggeredClientEvents > 0)
            local lastEvent = triggeredClientEvents[#triggeredClientEvents]
            assert.equals("ox_lib:notify", lastEvent.name)
            assert.equals(1, lastEvent.src)

            local data = lastEvent.args[1]
            assert.equals("Success", data.title)
            assert.equals("You succesfully deleted car with plate: TESTPL", data.description)
            assert.equals("check", data.icon)
        end)

        it("should notify error if vehicle not found on qb-garages:server:deletecar", function()
            local deletecarEvent = netEvents["qb-garages:server:deletecar"]
            assert.is_not_nil(deletecarEvent)

            local function customQuery(q, p, cb)
                if string.match(q, "SELECT") then
                    cb({}) -- Not found
                else
                    cb({})
                end
            end

            _G.MySQL.query = customQuery

            _G.source = 1
            deletecarEvent("TESTPL")

            assert.is_true(#triggeredClientEvents > 0)
            local lastEvent = triggeredClientEvents[#triggeredClientEvents]
            assert.equals("ox_lib:notify", lastEvent.name)
            assert.equals(1, lastEvent.src)

            local data = lastEvent.args[1]
            assert.equals("Error", data.title)
            assert.equals("Plate is wrong.", data.description)
            assert.equals("ban", data.icon)
        end)
    end)

end)