require 'busted.runner'()

describe("GetFreeParkingSpots", function()
    local env

    before_each(function()
        -- Create a mocked environment for the FiveM script
        env = setmetatable({}, { __index = _G })

        -- Mocking FiveM globals
        env.vector3 = function(x, y, z) return { x = x, y = y, z = z } end

        env.RegisterNetEvent = function(...) end
        env.AddEventHandler = function(...) end
        env.CreateThread = function(...) end

        env.Config = {
            OXNotify = false,
            OXRadial = false,
            Garages = {},
            HouseGarages = {},
            HouseGarageCategories = {},
            VehicleCategories = {}
        }

        env.Lang = { t = function(...) return "mock" end }

        env.lib = {
            registerContext = function(...) end,
            showContext = function(...) end,
            notify = function(...) end,
            addRadialItem = function(...) end,
            removeRadialItem = function(...) end,
            showTextUI = function(...) end,
            hideTextUI = function(...) end,
            onCache = function(...) end
        }

        env.QBCore = {
            Functions = {
                GetClosestVehicle = function(coords) return -1, -1 end,
                Notify = function(...) end,
                TriggerCallback = function(...) end,
                GetVehicles = function() return {} end,
                GetPlate = function(...) return "MOCK" end,
                GetPlayerData = function() return { job = { name = "mock", grade = { level = 1 } }, gang = { name = "mock" } } end,
                DeleteVehicle = function(...) end,
                GetVehicleProperties = function(...) return {} end,
                SpawnVehicle = function(...) end,
                SetVehicleProperties = function(...) end,
                CreateClientCallback = function(...) end
            },
            Shared = {
                Vehicles = {},
                SetDefaultVehicleExtras = function(...) end
            }
        }

        -- exports
        env.exports = setmetatable({
            ['qb-core'] = { GetCoreObject = function() return env.QBCore end },
            ['qb-radialmenu'] = { AddOption = function() return 1 end, RemoveOption = function() end },
            ['qb-target'] = { RemoveZone = function() end }
        }, {
            __call = function(t, k)
                return function(...) end
            end
        })

        -- FiveM natives
        env.PlayerPedId = function() return 1 end
        env.GetEntityCoords = function(...) return env.vector3(0,0,0) end
        env.GetEntityHeading = function(...) return 0 end
        env.NetToVeh = function(...) return 1 end
        env.SetNewWaypoint = function(...) end
        env.SetVehicleHasBeenOwnedByPlayer = function(...) end
        env.SetEntityAsMissionEntity = function(...) end
        env.SetVehicleIsStolen = function(...) end
        env.SetVehicleIsWanted = function(...) end
        env.SetVehRadioStation = function(...) end
        env.NetworkGetNetworkIdFromEntity = function(...) return 1 end
        env.SetNetworkIdCanMigrate = function(...) end
        env.SetVehicleTyreBurst = function(...) end
        env.SmashVehicleWindow = function(...) end
        env.SetVehicleDoorBroken = function(...) end
        env.SetVehicleEngineHealth = function(...) end
        env.SetVehicleBodyHealth = function(...) end
        env.GetPedInVehicleSeat = function(...) return nil end
        env.TaskLeaveVehicle = function(...) end
        env.SetVehicleDoorsLocked = function(...) end
        env.GetVehicleNumberPlateText = function(...) return "MOCK" end
        env.GetVehicleClass = function(...) return 1 end
        env.GetVehicleBodyHealth = function(...) return 1000 end
        env.GetVehicleEngineHealth = function(...) return 1000 end
        env.TriggerServerEvent = function(...) end
        env.TriggerEvent = function(...) end
        env.Wait = function(...) end
        env.IsPedInAnyVehicle = function(...) return false end
        env.ComboZone = { Create = function(...) return { onPlayerInOut = function(...) end } end }
        env.PolyZone = { Create = function(...) return { onPlayerInOut = function(...) end } end }
        env.BoxZone = { Create = function(...) return { onPlayerInOut = function(...) end } end }
        env.GetEntityForwardVector = function(...) return env.vector3(1,0,0) end
        env.ClearMenu = function(...) end
        env.SetEntityHeading = function(...) end
        env.SetVehicleLivery = function(...) end
        env.TaskWarpPedIntoVehicle = function(...) end
        env.SetVehicleEngineOn = function(...) end
        env.NetworkRequestControlOfEntity = function(...) end
        env.NetworkGetEntityOwner = function(...) return 1 end
        env.NetworkPlayerIdToInt = function(...) return 1 end
        env.GetVehicleClassFromName = function(...) return 1 end
        env.joaat = function(...) return 1 end
        env.GetVehiclePedIsIn = function(...) return 0 end
        env.DoesEntityExist = function(...) return false end
        env.GetLastDrivenVehicle = function(...) return nil end
        env.AddBlipForCoord = function(...) return 1 end
        env.SetBlipSprite = function(...) end
        env.SetBlipDisplay = function(...) end
        env.SetBlipScale = function(...) end
        env.SetBlipAsShortRange = function(...) end
        env.SetBlipColour = function(...) end
        env.BeginTextCommandSetBlipName = function(...) end
        env.AddTextComponentSubstringPlayerName = function(...) end
        env.EndTextCommandSetBlipName = function(...) end
        env.DrawMarker = function(...) end

        -- Math override for # vector3
        local original_mt = getmetatable(env.vector3(0,0,0))
        if original_mt then
            original_mt.__sub = function(a, b) return env.vector3(a.x - b.x, a.y - b.y, a.z - b.z) end
            original_mt.__len = function(a) return math.sqrt(a.x*a.x + a.y*a.y + a.z*a.z) end
        else
            debug.setmetatable(env.vector3(0,0,0), {
                __sub = function(a, b) return env.vector3(a.x - b.x, a.y - b.y, a.z - b.z) end,
                __len = function(a) return math.sqrt(a.x*a.x + a.y*a.y + a.z*a.z) end
            })
        end

        -- Load the client file into the mocked environment
        local f = loadfile("client/main.lua", "t", env)
        if not f then error("Could not load client/main.lua") end
        pcall(f)
    end)

    it("should return all spots when all spots are free (veh == -1)", function()
        env.QBCore.Functions.GetClosestVehicle = function(coords)
            return -1, -1 -- -1 means no vehicle found
        end

        local spots = {
            {x = 1, y = 1, z = 1},
            {x = 2, y = 2, z = 2}
        }

        local freeSpots = env.GetFreeParkingSpots(spots)
        assert.are.same(spots, freeSpots)
    end)

    it("should filter out spots with a vehicle too close (veh ~= -1 and distance < 1.5)", function()
        env.QBCore.Functions.GetClosestVehicle = function(coords)
            if coords.x == 1 then
                return 123, 1.0 -- Vehicle found, very close
            else
                return -1, -1 -- Free
            end
        end

        local spots = {
            {x = 1, y = 1, z = 1},
            {x = 2, y = 2, z = 2}
        }

        local freeSpots = env.GetFreeParkingSpots(spots)
        assert.are.same({ {x = 2, y = 2, z = 2} }, freeSpots)
    end)

    it("should consider spot free if vehicle is found but distance is >= 1.5", function()
        env.QBCore.Functions.GetClosestVehicle = function(coords)
            if coords.x == 1 then
                return 123, 2.0 -- Vehicle found, but far away
            else
                return -1, -1 -- Free
            end
        end

        local spots = {
            {x = 1, y = 1, z = 1},
            {x = 2, y = 2, z = 2}
        }

        local freeSpots = env.GetFreeParkingSpots(spots)
        assert.are.same(spots, freeSpots)
    end)

    it("should return empty table for empty input table", function()
        local spots = {}
        local freeSpots = env.GetFreeParkingSpots(spots)
        assert.are.same({}, freeSpots)
    end)
end)
