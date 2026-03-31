-- Simple testing framework
local fails = 0

local function assert_equal(expected, actual, message)
    if expected ~= actual then
        print(string.format("❌ FAIL: %s", message))
        print(string.format("   Expected: %s (%s)", tostring(expected), type(expected)))
        print(string.format("   Got:      %s (%s)", tostring(actual), type(actual)))
        fails = fails + 1
    else
        print(string.format("✅ PASS: %s", message))
    end
end

-- Setup test environment for FiveM/QBCore
_G.TESTING = true

-- Mock FiveM Natives
local mock_export = setmetatable({}, {
    __index = function(t, k)
        return setmetatable({}, {
            __index = function(t2, k2)
                return function(...)
                    if k2 == "GetCoreObject" then
                        return setmetatable({}, {
                            __index = function(t3, k3)
                                return setmetatable({}, {
                                    __index = function() return function() end end
                                })
                            end
                        })
                    end
                    return function() end
                end
            end
        })
    end,
    __call = function(t, k)
        return function() end
    end
})

_G.exports = mock_export

_G.RegisterNetEvent = function() end
_G.AddEventHandler = function() end
_G.CreateThread = function() end
_G.Wait = function() end
_G.NetToVeh = function() end
_G.GetEntityCoords = function() end
_G.GetEntityHeading = function() end
_G.GetEntityForwardVector = function() end
_G.PlayerPedId = function() end
_G.TriggerEvent = function() end
_G.TriggerServerEvent = function() end
_G.SetNewWaypoint = function() end
_G.SetVehicleHasBeenOwnedByPlayer = function() end
_G.SetEntityAsMissionEntity = function() end
_G.SetVehicleIsStolen = function() end
_G.SetVehicleIsWanted = function() end
_G.SetVehRadioStation = function() end
_G.NetworkGetNetworkIdFromEntity = function() end
_G.SetNetworkIdCanMigrate = function() end
_G.GetVehicleNumberPlateText = function() end
_G.GetVehicleClass = function() end
_G.GetVehicleClassFromName = function() end
_G.GetVehicleBodyHealth = function() end
_G.GetVehicleEngineHealth = function() end
_G.SetVehicleTyreBurst = function() end
_G.SmashVehicleWindow = function() end
_G.SetVehicleDoorBroken = function() end
_G.SetVehicleEngineHealth = function() end
_G.SetVehicleBodyHealth = function() end
_G.GetPedInVehicleSeat = function() end
_G.TaskLeaveVehicle = function() end
_G.SetEntityCoords = function() end
_G.SetVehicleDoorsLocked = function() end
_G.SetEntityHeading = function() end
_G.SetVehicleLivery = function() end
_G.TaskWarpPedIntoVehicle = function() end
_G.SetVehicleEngineOn = function() end
_G.NetworkRequestControlOfEntity = function() end
_G.NetworkGetEntityOwner = function() end
_G.NetworkPlayerIdToInt = function() end
_G.DoesEntityExist = function() end
_G.GetVehiclePedIsIn = function() end
_G.GetLastDrivenVehicle = function() end
_G.AddBlipForCoord = function() end
_G.SetBlipSprite = function() end
_G.SetBlipDisplay = function() end
_G.SetBlipScale = function() end
_G.SetBlipAsShortRange = function() end
_G.SetBlipColour = function() end
_G.BeginTextCommandSetBlipName = function() end
_G.AddTextComponentSubstringPlayerName = function() end
_G.EndTextCommandSetBlipName = function() end
_G.DrawMarker = function() end
_G.ClearMenu = function() end
_G.IsPedInAnyVehicle = function() return false end
_G.joaat = function() return 0 end
_G.vector2 = function() return {} end
_G.vector3 = function(...) return {...} end

-- Mock Libs
_G.lib = setmetatable({}, {
    __index = function()
        return function() end
    end
})

-- Mock QBCore variables that might be accessed
_G.Config = {
    Garages = {},
    HouseGarages = {},
    VehicleCategories = {},
    HouseGarageCategories = {},
    UseIMG = false,
    OXRadial = false,
    OXDrawText = false,
}
_G.HouseGarages = {}
_G.Lang = {
    t = function() return "" end
}
_G.ComboZone = setmetatable({}, {
    __index = function()
        return function() end
    end
})
_G.PolyZone = setmetatable({}, {
    __index = function()
        return function() end
    end
})
_G.BoxZone = setmetatable({}, {
    __index = function()
        return function() end
    end
})

-- Load the client file
local status, err = pcall(dofile, "client/main.lua")
if not status then
    print("❌ Error loading client/main.lua:")
    print(err)
    os.exit(1)
end

print("🧪 Running tests for Round utility function...\n")

local Round = _G.Round
if not Round then
    print("❌ FAIL: Round function was not exported correctly")
    os.exit(1)
end

-- Test cases
-- Basic rounding with no decimal places
assert_equal(10, Round(10.4), "Round down with no decimal places")
assert_equal(11, Round(10.6), "Round up with no decimal places")

-- Halfway rounding behavior check (depends on C runtime)
assert_equal(tonumber(string.format("%.0f", 10.5)), Round(10.5), "Halfway rounding with no decimal places matches string.format")

-- Positive decimal places
assert_equal(10.4, Round(10.44, 1), "Round down to 1 decimal place")
assert_equal(10.5, Round(10.46, 1), "Round up to 1 decimal place")
assert_equal(10.44, Round(10.444, 2), "Round down to 2 decimal places")
assert_equal(10.45, Round(10.446, 2), "Round up to 2 decimal places")

-- Negative numbers
assert_equal(-10, Round(-10.4), "Round negative number down in magnitude")
assert_equal(-11, Round(-10.6), "Round negative number up in magnitude")

-- Missing numDecimalPlaces (should default to 0)
assert_equal(10, Round(10.4, nil), "Missing numDecimalPlaces defaults to 0")

-- Rounding zero
assert_equal(0, Round(0), "Rounding zero")
assert_equal(0, Round(0, 2), "Rounding zero with decimal places")
assert_equal(0, Round(0.001, 2), "Rounding small number to zero")

-- Exact return type check (should be number)
assert_equal("number", type(Round(10.4)), "Returns a number type")

print("\n📊 Test Results:")
if fails > 0 then
    print(string.format("❌ %d tests failed", fails))
    os.exit(1)
else
    print("✨ All tests passed successfully!")
    os.exit(0)
end
