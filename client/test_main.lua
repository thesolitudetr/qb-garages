-- Global Mocks
QBCore = {
    Functions = {}
}

Config = {
    OXNotify = false
}

-- Mocks implementation
local mockVehicles = {}

QBCore.Functions.GetVehicles = function()
    return mockVehicles
end

QBCore.Functions.GetPlate = function(v)
    return v.plate
end

QBCore.Functions.Notify = function() end

local exports_mt = {
    __index = function(t, k)
        return {
            GetCoreObject = function()
                return QBCore
            end,
            AddBoxZone = function() end,
            AddCircleZone = function() end,
            AddPolyZone = function() end,
            AddTargetModel = function() end,
            RemoveZone = function() end
        }
    end,
    __call = function(t, k, v)
        -- To handle exports("func", func)
    end
}
exports = setmetatable({}, exports_mt)

-- Mock other functions that might be called in client/main.lua
function RegisterNetEvent() end
function AddEventHandler() end
function CreateThread() end
function SetTimeout() end
function Wait() end
function GetPlayerPed() end
function GetVehiclePedIsIn() end
function GetPedInVehicleSeat() end
function TaskLeaveVehicle() end
function SetVehicleDoorsLocked() end
function SetEntityAsMissionEntity() end
function DeleteEntity() end
function AddTextEntry() end
function vector3() return {} end
function vector4() return {} end
function PlaySoundFrontend() end
function HasModelLoaded() end
function RequestModel() end
function LoadModel() end

lib = {
    notify = function() end,
    registerContext = function() end,
    showContext = function() end,
    callback = {
        register = function() end
    }
}

-- Load the actual client/main.lua file using an environment
local env = setmetatable({}, { __index = _G })

-- Fix QBCore.Functions missing lib fields
lib.callback.register = function() end

env.lib = lib

-- QBCore functions missing for init
env.QBCore.Functions.TriggerCallback = function() end
env.QBCore.Functions.CreateClientCallback = function() end

local chunk = assert(loadfile("client/main.lua", "t", env))
local status, err = pcall(chunk)

if not status then
    print("Warning: error while executing client/main.lua (probably missing mocks): " .. tostring(err))
end

-- Verify the function was loaded into the environment
if _G.type(env.GetVehicleByPlate) ~= "function" then
    error("GetVehicleByPlate function not found after loading client/main.lua")
end

local GetVehicleByPlate = env.GetVehicleByPlate

-- Test Runner / Assertions
local function assertEqual(expected, actual, message)
    if expected ~= actual then
        error(string.format("Assertion failed: %s\n  Expected: %s\n  Got: %s", message, tostring(expected), tostring(actual)))
    end
end

-- Test scenarios
local function runTests()
    print("Running tests for GetVehicleByPlate...")

    -- Test 1: Empty vehicle list
    mockVehicles = {}
    local result1 = GetVehicleByPlate("ABC 123")
    assertEqual(nil, result1, "Should return nil when vehicle list is empty")

    -- Test 2: Plate exists
    mockVehicles = {
        { id = 1, plate = "XYZ 789" },
        { id = 2, plate = "ABC 123" },
        { id = 3, plate = "LMN 456" },
    }
    local result2 = GetVehicleByPlate("ABC 123")
    if result2 == nil then
        error("Assertion failed: Should find vehicle with plate ABC 123, but got nil")
    end
    assertEqual(2, result2.id, "Should find correct vehicle with plate ABC 123")

    -- Test 3: Plate does not exist
    mockVehicles = {
        { id = 1, plate = "XYZ 789" },
        { id = 2, plate = "ABC 123" },
    }
    local result3 = GetVehicleByPlate("LMN 456")
    assertEqual(nil, result3, "Should return nil for non-existent plate")

    -- Test 4: Multiple vehicles, same plate (should return first found)
    mockVehicles = {
        { id = 1, plate = "ABC 123" },
        { id = 2, plate = "ABC 123" },
    }
    local result4 = GetVehicleByPlate("ABC 123")
    if result4 == nil then
        error("Assertion failed: Should find vehicle with plate ABC 123, but got nil")
    end
    assertEqual(1, result4.id, "Should return the first vehicle found with the plate")

    print("All tests passed! \226\156\148") -- Checkmark
end

runTests()
