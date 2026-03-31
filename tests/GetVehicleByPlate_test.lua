-- tests/GetVehicleByPlate_test.lua

-- Enable testing mode to export the function
_G.__TEST_MODE__ = true

-- Mock dependencies for main.lua
_G.exports = { ["qb-core"] = { GetCoreObject = function() return QBCore end } }

_G.Config = { StartingPrices = {} }

_G.QBCore = {
    Commands = { Add = function() end },
    Functions = {
        CreateCallback = function() end,
        GetPlayer = function() return { PlayerData = { gang = { name = "none" }, citizenid = "123" } } end,
        GetVehicleProperties = function() return {} end,
        GetVehicleLabel = function() return "TestVehicle" end,
    },
    Shared = {
        Vehicles = {},
    }
}
_G.MySQL = {
    Async = {
        fetchAll = function() end,
        execute = function() end,
    },
    query = {
        await = function() return {} end,
    },
    update = function() end,
    insert = function() end,
}
_G.RegisterNetEvent = function() end
_G.AddEventHandler = function() end

-- Mock string functions if needed, usually string library is built-in
-- Mock math functions if needed, usually math library is built-in

-- Mock functions required for testing GetVehicleByPlate
_G.GetAllVehicles_calls = 0
_G.mock_vehicles = {}
function _G.GetAllVehicles()
    _G.GetAllVehicles_calls = _G.GetAllVehicles_calls + 1
    return _G.mock_vehicles
end

_G.GetVehicleNumberPlateText_calls = 0
_G.mock_plates = {}
function _G.GetVehicleNumberPlateText(vehicle)
    _G.GetVehicleNumberPlateText_calls = _G.GetVehicleNumberPlateText_calls + 1
    return _G.mock_plates[vehicle]
end

_G.TriggerClientEvent = function() end
_G.GetEntityCoords = function() return vector3(0,0,0) end
_G.GetEntityHeading = function() return 0 end
_G.DeleteEntity = function() end
_G.TaskWarpPedIntoVehicle = function() end
_G.GetPlayerPed = function() return 1 end

-- Load the server/main.lua file to define the function
local f, err = loadfile("server/main.lua")
if not f then
    print("Failed to load server/main.lua: " .. tostring(err))
    os.exit(1)
end

-- We wrap the execution in pcall in case it tries to call some unsupported global FiveM function
local success, err_msg = pcall(f)
if not success then
    -- It's ok if it fails because of missing FiveM globals during initialization,
    -- as long as `GetVehicleByPlate` was assigned to `_G`
    print("Warning during loading server/main.lua: " .. tostring(err_msg))
end

if type(_G.GetVehicleByPlate) ~= "function" then
    print("Failed to load GetVehicleByPlate function. Ensure it is exported when _G.__TEST_MODE__ is true.")
    os.exit(1)
end

-- Test runner
local failures = 0

local function assert_equal(expected, actual, message)
    if expected ~= actual then
        print("FAIL: " .. message)
        print("  Expected: " .. tostring(expected))
        print("  Actual: " .. tostring(actual))
        failures = failures + 1
    else
        print("PASS: " .. message)
    end
end

local function reset_mocks()
    _G.GetAllVehicles_calls = 0
    _G.GetVehicleNumberPlateText_calls = 0
    _G.mock_vehicles = {}
    _G.mock_plates = {}
end

-- Tests
local function run_tests()
    print("Running GetVehicleByPlate tests...")

    -- Test 1: Empty vehicle list
    reset_mocks()
    assert_equal(nil, _G.GetVehicleByPlate("ABC 123"), "Should return nil when there are no vehicles")

    -- Test 2: Vehicle found with exact match
    reset_mocks()
    _G.mock_vehicles = {1, 2, 3}
    _G.mock_plates = {[1] = "XYZ 987", [2] = "ABC 123", [3] = "DEF 456"}
    assert_equal(2, _G.GetVehicleByPlate("ABC 123"), "Should return vehicle 2 with exact plate match")

    -- Test 3: Vehicle found with case insensitive match
    reset_mocks()
    _G.mock_vehicles = {1, 2, 3}
    _G.mock_plates = {[1] = "xyz 987", [2] = "ABC 123", [3] = "DEF 456"}
    assert_equal(2, _G.GetVehicleByPlate("abc 123"), "Should return vehicle 2 with lowercase input")

    -- Test 4: Vehicle not found
    reset_mocks()
    _G.mock_vehicles = {1, 2, 3}
    _G.mock_plates = {[1] = "XYZ 987", [2] = "ABC 123", [3] = "DEF 456"}
    assert_equal(nil, _G.GetVehicleByPlate("NOT FND"), "Should return nil when plate is not found")

    -- Test 5: Input is automatically uppercased, and existing plate is uppercase
    reset_mocks()
    _G.mock_vehicles = {5}
    _G.mock_plates = {[5] = "QWERTY"}
    assert_equal(5, _G.GetVehicleByPlate("qwerty"), "Should uppercase input and find the uppercase plate")

    if failures > 0 then
        print(string.format("\n%d tests failed.", failures))
        os.exit(1)
    else
        print("\nAll tests passed successfully.")
        os.exit(0)
    end
end

run_tests()
-- fix for exports
