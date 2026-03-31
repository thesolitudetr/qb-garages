-- Mocks for globals
_G.exports = setmetatable({}, {
    __index = function(t, k)
        return {
            GetCoreObject = function() return {
                Functions = {
                    GetPlayerData = function() return {job = {grade = {level = 1}}} end,
                    TriggerCallback = function() end,
                    CreateClientCallback = function() end,
                },
                Shared = {
                    Vehicles = {}
                }
            } end
        }
    end,
    __call = function(t, k)
        return { GetCoreObject = function() return {} end }
    end
})

_G.RegisterNetEvent = function() end
_G.AddEventHandler = function() end
_G.CreateThread = function() end

_G.Config = {
    OXNotify = false,
    Garages = {},
    HouseGarages = {},
    VehicleCategories = {},
    StoreParkinglotAccuratly = false,
    SpawnAtLastParkinglot = false,
}

_G.Lang = setmetatable({}, {
    __index = function() return function() return "" end end
})

_G.lib = {
    onCache = function() end,
    registerContext = function() end,
    showContext = function() end,
    notify = function() end,
    addRadialItem = function() end,
    removeRadialItem = function() end,
    showTextUI = function() end,
    hideTextUI = function() end,
}

_G.ComboZone = { Create = function() return { onPlayerInOut = function() end } end }
_G.PolyZone = { Create = function() return { onPlayerInOut = function() end } end }
_G.BoxZone = { Create = function() return { onPlayerInOut = function() end } end }

_G.joaat = function() return 0 end
_G.GetVehicleClassFromName = function() return 0 end

-- Simple test runner
local passes = 0
local fails = 0

local function assert_equal(expected, actual, msg)
    if expected == actual then
        passes = passes + 1
        print("PASS: " .. (msg or ""))
    else
        fails = fails + 1
        print("FAIL: " .. (msg or "") .. " | Expected " .. tostring(expected) .. " but got " .. tostring(actual))
    end
end

-- Override vector length calc
local vector_mt = {
    __sub = function(v1, v2)
        local res = setmetatable({
            x = v1.x - v2.x,
            y = v1.y - v2.y,
            z = v1.z - v2.z
        }, _G.vector_mt_internal)
        return res
    end
}
_G.vector_mt_internal = {
    __len = function(v)
        return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    end
}

_G.vector3 = function(x, y, z)
    return setmetatable({x = x, y = y, z = z}, vector_mt)
end
_G.GetEntityCoords = function() return _G.vector3(0, 0, 0) end
_G.PlayerPedId = function() return 1 end

-- Load script (this gives access to global functions declared in it, like GetFreeSingleParkingSpot)
local f = loadfile("client/main.lua")
f()

print("--- Testing GetFreeSingleParkingSpot ---")

local parkingSpots = {
    {x = 10, y = 10, z = 10, w = 90},
    {x = 20, y = 20, z = 20, w = 90},
    {x = 30, y = 30, z = 30, w = 90}
}

-- Test 1: Empty parking spots
local loc1 = GetFreeSingleParkingSpot({}, nil)
assert_equal(nil, loc1, "Should return nil if parking spots list is empty")

-- Test 2: Basic return from free spots (should return closest to 0,0,0 which is 10,10,10)
local loc2 = GetFreeSingleParkingSpot(parkingSpots, nil)
assert_equal(10, loc2.x, "Should return closest spot to 0,0,0 (x=10)")
assert_equal(10, loc2.y, "Should return closest spot to 0,0,0 (y=10)")
assert_equal(10, loc2.z, "Should return closest spot to 0,0,0 (z=10)")

-- Test 3: vehicle last parkingspot is used
_G.Config.StoreParkinglotAccuratly = true
_G.Config.SpawnAtLastParkinglot = true

local vehicle = {
    parkingspot = {x = 29, y = 29, z = 29}
}

local loc3 = GetFreeSingleParkingSpot(parkingSpots, vehicle)
assert_equal(30, loc3.x, "Should return closest spot to vehicle last parkingspot (x=30)")
assert_equal(30, loc3.y, "Should return closest spot to vehicle last parkingspot (y=30)")
assert_equal(30, loc3.z, "Should return closest spot to vehicle last parkingspot (z=30)")

-- Test 4: vehicle with missing parkingspot falls back to closest to player
local vehicle_no_spot = {}
local loc4 = GetFreeSingleParkingSpot(parkingSpots, vehicle_no_spot)
assert_equal(10, loc4.x, "Should fallback to closest spot to player if vehicle has no parkingspot (x=10)")

print("\nTests completed: " .. passes .. " passed, " .. fails .. " failed.")
if fails > 0 then
    os.exit(1)
end
