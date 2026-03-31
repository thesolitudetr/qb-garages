-- test_round.lua

-- Create mock environment to allow loading of client/main.lua
local mockEnv = {
    Config = {
        Garages = {},
        HouseGarages = {},
        HouseGarageCategories = {},
        VehicleCategories = {}
    },
    Lang = {
        t = function() return "" end
    },
    QBCore = {
        Functions = {
            GetCoreObject = function() return {
                Functions = {
                    GetPlayerData = function() return { job = { grade = { level = 1 } } } end,
                    CreateClientCallback = function() end
                }
            } end,
            GetPlayerData = function() return { job = { grade = { level = 1 } } } end,
            CreateClientCallback = function() end
        },
        Shared = {
            Vehicles = {}
        }
    },
    exports = setmetatable({}, {
        __call = function(t, name)
            return setmetatable({}, {
                __index = function(_, method)
                    if method == "GetCoreObject" then
                        return function() return {
                            Functions = {
                                GetPlayerData = function() return { job = { grade = { level = 1 } } } end,
                                CreateClientCallback = function() end
                            }
                        } end
                    end
                    return function() end
                end
            })
        end,
        __index = function(t, k)
            if k == 'qb-core' then
                return setmetatable({}, {
                    __index = function(_, method)
                        if method == "GetCoreObject" then
                            return function() return {
                                Functions = {
                                    GetPlayerData = function() return { job = { grade = { level = 1 } } } end,
                                    CreateClientCallback = function() end
                                }
                            } end
                        end
                        return function() end
                    end
                })
            end
            return function() return {} end
        end
    }),
    RegisterNetEvent = function() end,
    AddEventHandler = function() end,
    CreateThread = function() end,
    Wait = function() end,
    GetEntityCoords = function() return {x=0, y=0, z=0} end,
    GetEntityHeading = function() return 0 end,
    PlayerPedId = function() return 1 end,
    NetToVeh = function() return 1 end,
    lib = {
        registerContext = function() end,
        showContext = function() end,
        notify = function() end,
        removeRadialItem = function() end,
        addRadialItem = function() end,
        showTextUI = function() end,
        hideTextUI = function() end,
        onCache = function() end
    },
    PolyZone = { Create = function() return {} end },
    ComboZone = { Create = function() return { onPlayerInOut = function() end } end },
    BoxZone = { Create = function() return { onPlayerInOut = function() end } end },
    vector3 = function(x, y, z) return {x=x, y=y, z=z} end,
    string = string,
    tonumber = tonumber,
    type = type,
    ipairs = ipairs,
    pairs = pairs,
    math = math,
    table = table,
    joaat = function() return 0 end,
    GetVehicleClassFromName = function() return 0 end,
    GetVehicleClass = function() return 0 end,
    GetVehicleNumberPlateText = function() return "123" end,
    SetVehicleDoorsLocked = function() end,
    TaskLeaveVehicle = function() end,
    GetPedInVehicleSeat = function() return 1 end,
    SetEntityCoords = function() end,
    SetVehicleTyreBurst = function() end,
    SmashVehicleWindow = function() end,
    SetVehicleDoorBroken = function() end,
    SetVehicleEngineHealth = function() end,
    SetVehicleBodyHealth = function() end,
    GetVehicleBodyHealth = function() return 1000 end,
    GetVehicleEngineHealth = function() return 1000 end,
    SetNewWaypoint = function() end,
    SetVehicleHasBeenOwnedByPlayer = function() end,
    SetEntityAsMissionEntity = function() end,
    SetVehicleIsStolen = function() end,
    SetVehicleIsWanted = function() end,
    SetVehRadioStation = function() end,
    NetworkGetNetworkIdFromEntity = function() return 1 end,
    SetNetworkIdCanMigrate = function() end,
    ClearMenu = function() end,
    SetEntityHeading = function() end,
    SetVehicleLivery = function() end,
    TaskWarpPedIntoVehicle = function() end,
    SetVehicleEngineOn = function() end,
    NetworkRequestControlOfEntity = function() end,
    NetworkGetEntityOwner = function() return 1 end,
    NetworkPlayerIdToInt = function() return 1 end,
    GetVehiclePedIsIn = function() return 0 end,
    GetLastDrivenVehicle = function() return 0 end,
    DoesEntityExist = function() return true end,
    GetCurrentResourceName = function() return "qb-garages" end,
    AddBlipForCoord = function() return 1 end,
    SetBlipSprite = function() end,
    SetBlipDisplay = function() end,
    SetBlipScale = function() end,
    SetBlipAsShortRange = function() end,
    SetBlipColour = function() end,
    BeginTextCommandSetBlipName = function() end,
    AddTextComponentSubstringPlayerName = function() end,
    EndTextCommandSetBlipName = function() end,
    DrawMarker = function() end,
    print = print,
    tostring = tostring,
    os = os
}

-- Load the main client file into our mock environment
local function loadClientMain()
    local file = io.open("client/main.lua", "r")
    if not file then
        error("Error opening client/main.lua")
    end
    local content = file:read("*all")
    file:close()

    -- Replace 'local function Round' with 'Round = function' and assign it back to the environment
    content = string.gsub(content, "local function Round%(num, numDecimalPlaces%)", "Round = function(num, numDecimalPlaces)")

    local chunk, err = load(content, "client/main.lua", "t", mockEnv)
    if not chunk then
        error("Error loading client/main.lua: " .. err)
    end
    chunk()
end

loadClientMain()

-- The Round function should now be accessible in mockEnv
local Round = mockEnv.Round

if not Round then
    error("Round function is not exposed in client/main.lua")
end

local failures = 0

local function assertEquals(expected, actual, message)
    if expected ~= actual then
        print(string.format("FAIL: %s. Expected %s, got %s", message, tostring(expected), tostring(actual)))
        failures = failures + 1
    end
end

print("Testing Round function from client/main.lua...")

-- Test positive decimal places
assertEquals(10.5, Round(10.51, 1), "Round to 1 decimal place")
assertEquals(10.56, Round(10.556, 2), "Round to 2 decimal places")
assertEquals(10.556, Round(10.5556, 3), "Round to 3 decimal places")

-- Test zero decimal places
assertEquals(10, Round(10.5, 0), "Round to 0 decimal places (round half to even)")
assertEquals(10, Round(10.4, 0), "Round to 0 decimal places (round down)")

-- Test nil decimal places (defaults to 0)
assertEquals(10, Round(10.5), "Round with nil decimal places (round half to even)")
assertEquals(10, Round(10.4), "Round with nil decimal places (round down)")

-- Test negative decimal places
assertEquals(10, Round(10.5, -1), "Round with -1 decimal places (fallback to 0)")
assertEquals(10, Round(10.5, -5), "Round with -5 decimal places (fallback to 0)")

if failures == 0 then
    print("All tests passed!")
    os.exit(0)
else
    print(string.format("%d tests failed.", failures))
    os.exit(1)
end
