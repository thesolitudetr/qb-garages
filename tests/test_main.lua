-- Mock FiveM globals so `client/main.lua` can be loaded without error.
local mock_functions = {
    "RegisterNetEvent", "TriggerEvent", "TriggerServerEvent",
    "NetToVeh", "GetEntityCoords", "PlayerPedId", "GetEntityHeading", "Wait",
    "SetNewWaypoint", "SetVehicleHasBeenOwnedByPlayer", "SetEntityAsMissionEntity",
    "SetVehicleIsStolen", "SetVehicleIsWanted", "SetVehRadioStation", "NetworkGetNetworkIdFromEntity",
    "SetNetworkIdCanMigrate", "SetVehicleTyreBurst", "SmashVehicleWindow", "SetVehicleDoorBroken",
    "SetVehicleEngineHealth", "SetVehicleBodyHealth", "TaskLeaveVehicle", "SetVehicleDoorsLocked",
    "GetVehicleNumberPlateText", "GetVehicleClass", "GetVehicleBodyHealth", "GetVehicleEngineHealth",
    "TaskWarpPedIntoVehicle", "SetVehicleEngineOn", "NetworkRequestControlOfEntity", "NetworkGetEntityOwner",
    "NetworkPlayerIdToInt", "ClearMenu", "SetEntityHeading", "GetPedInVehicleSeat", "GetVehicleClassFromName",
    "GetVehiclePedIsIn", "GetLastDrivenVehicle", "DeleteEntity", "AddEventHandler", "CreateThread",
    "AddBlipForCoord", "SetBlipSprite", "SetBlipDisplay", "SetBlipScale", "SetBlipAsShortRange",
    "SetBlipColour", "BeginTextCommandSetBlipName", "AddTextComponentSubstringPlayerName", "EndTextCommandSetBlipName",
    "DrawMarker", "joaat", "GetEntityForwardVector"
}

for _, name in ipairs(mock_functions) do
    _G[name] = function() return nil end
end

_G.vector3 = function(x,y,z) return {x=x, y=y, z=z} end

local function make_mock_table()
    return setmetatable({}, {
        __index = function(t, k)
            return make_mock_table()
        end,
        __call = function()
            return make_mock_table()
        end
    })
end

_G.exports = make_mock_table()
_G.lib = make_mock_table()

_G.Config = {
    Garages = {},
    HouseGarages = {},
    VehicleCategories = {}
}
_G.Lang = {
    t = function() return "" end
}
_G.ComboZone = make_mock_table()
_G.PolyZone = make_mock_table()
_G.BoxZone = make_mock_table()

dofile("client/main.lua")

local function run_tests()
    local passed = 0
    local failed = 0

    local function assert_equal(expected, actual, case_name)
        if expected == actual then
            passed = passed + 1
            print("✓ PASS: " .. case_name)
        else
            failed = failed + 1
            print("✗ FAIL: " .. case_name .. " (Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual) .. ")")
        end
    end

    print("--- Running tests for IsStringNilOrEmpty ---")

    assert_equal(true, IsStringNilOrEmpty(nil), "nil input")
    assert_equal(true, IsStringNilOrEmpty(""), "empty string")
    assert_equal(false, IsStringNilOrEmpty("hello"), "normal string")

    assert_equal(false, IsStringNilOrEmpty(" "), "whitespace string")

    local ok, res = pcall(IsStringNilOrEmpty, 0)
    if ok then assert_equal(false, res, "number zero") else failed=failed+1; print("✗ FAIL: number zero - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, 1)
    if ok then assert_equal(false, res, "positive number") else failed=failed+1; print("✗ FAIL: positive number - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, -1)
    if ok then assert_equal(false, res, "negative number") else failed=failed+1; print("✗ FAIL: negative number - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, true)
    if ok then assert_equal(false, res, "boolean true") else failed=failed+1; print("✗ FAIL: boolean true - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, false)
    if ok then assert_equal(false, res, "boolean false") else failed=failed+1; print("✗ FAIL: boolean false - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, {})
    if ok then assert_equal(false, res, "empty table") else failed=failed+1; print("✗ FAIL: empty table - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, {a=1})
    if ok then assert_equal(false, res, "non-empty table") else failed=failed+1; print("✗ FAIL: non-empty table - crashed") end

    ok, res = pcall(IsStringNilOrEmpty, function() end)
    if ok then assert_equal(false, res, "function") else failed=failed+1; print("✗ FAIL: function - crashed") end

    print("\n--- Test Summary ---")
    print("Passed: " .. passed)
    print("Failed: " .. failed)

    if failed > 0 then
        os.exit(1)
    end
end

run_tests()
