-- test_get_vehicle_type.lua

-- Mocking FiveM natives
_G.joaat_calls = {}
function _G.joaat(model)
    table.insert(_G.joaat_calls, model)
    if model == "submersible" then return 123456 end
    if model == "submersible2" then return 654321 end
    -- A simple hash mock for testing purposes
    local hash = 0
    for i = 1, #model do
        hash = hash + string.byte(model, i)
    end
    return hash
end

_G.submersible = 123456
_G.submersible2 = 654321

_G.GetVehicleClassFromName_mock = {}
function _G.GetVehicleClassFromName(model)
    return _G.GetVehicleClassFromName_mock[model] or 0
end

-- Read the client/main.lua file to extract the function
local f = io.open("client/main.lua", "r")
if not f then error("Could not open client/main.lua") end
local content = f:read("*a")
f:close()

-- Extract just the GetVehicleTypeFromModelOrHash function
local start_idx, end_idx = string.find(content, "function GetVehicleTypeFromModelOrHash%(model%).-return types%[vehicleType%] or \"automobile\"\nend")

if not start_idx then
    error("Could not find GetVehicleTypeFromModelOrHash function in client/main.lua")
end

local func_string = string.sub(content, start_idx, end_idx)

-- Load the extracted function into the global environment
local load_func, err = load(func_string)
if not load_func then
    error("Failed to load extracted function: " .. tostring(err))
end
load_func()

-- Test Framework
local tests = {}
local failures = 0

function it(description, fn)
    _G.joaat_calls = {} -- reset mock calls
    local status, err = pcall(fn)
    if not status then
        print("FAIL: " .. description)
        print("  Error: " .. tostring(err))
        failures = failures + 1
    else
        print("PASS: " .. description)
    end
end

function assertEqual(expected, actual, message)
    if expected ~= actual then
        error((message or "") .. " Expected '" .. tostring(expected) .. "', got '" .. tostring(actual) .. "'")
    end
end

print("Running tests for GetVehicleTypeFromModelOrHash...")

it("should convert string model to hash and return automobile by default", function()
    local hash = _G.joaat("adder")
    _G.GetVehicleClassFromName_mock[hash] = 0
    local result = GetVehicleTypeFromModelOrHash("adder")
    assertEqual("automobile", result)
    assertEqual("adder", _G.joaat_calls[#_G.joaat_calls])
end)

it("should return submarine for submersible hashes", function()
    local result = GetVehicleTypeFromModelOrHash(_G.submersible)
    assertEqual("submarine", result)

    local result2 = GetVehicleTypeFromModelOrHash(_G.submersible2)
    assertEqual("submarine", result2)
end)

it("should return submarine for submersible string names", function()
    local result = GetVehicleTypeFromModelOrHash("submersible")
    assertEqual("submarine", result)

    local result2 = GetVehicleTypeFromModelOrHash("submersible2")
    assertEqual("submarine", result2)
end)

it("should return bike for vehicle class 8", function()
    _G.GetVehicleClassFromName_mock[123] = 8
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("bike", result)
end)

it("should return trailer for vehicle class 11", function()
    _G.GetVehicleClassFromName_mock[123] = 11
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("trailer", result)
end)

it("should return bike for vehicle class 13", function()
    _G.GetVehicleClassFromName_mock[123] = 13
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("bike", result)
end)

it("should return boat for vehicle class 14", function()
    _G.GetVehicleClassFromName_mock[123] = 14
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("boat", result)
end)

it("should return heli for vehicle class 15", function()
    _G.GetVehicleClassFromName_mock[123] = 15
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("heli", result)
end)

it("should return plane for vehicle class 16", function()
    _G.GetVehicleClassFromName_mock[123] = 16
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("plane", result)
end)

it("should return train for vehicle class 21", function()
    _G.GetVehicleClassFromName_mock[123] = 21
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("train", result)
end)

it("should return automobile for unmapped vehicle class", function()
    _G.GetVehicleClassFromName_mock[123] = 1
    local result = GetVehicleTypeFromModelOrHash(123)
    assertEqual("automobile", result)
end)

if failures > 0 then
    print("\n" .. failures .. " test(s) failed.")
    error("Tests failed")
else
    print("\nAll tests passed successfully.")
end
