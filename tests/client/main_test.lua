-- tests/client/main_test.lua
-- Tests for GetClosestLocation

-- Simple test runner implementation
local passed = 0
local failed = 0

local function assert_equal(expected, actual, message)
    if expected == actual then
        passed = passed + 1
    else
        failed = failed + 1
        print("FAIL: " .. (message or "") .. " | Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual))
    end
end

local function assert_not_nil(val, message)
    if val ~= nil then
        passed = passed + 1
    else
        failed = failed + 1
        print("FAIL: " .. (message or "") .. " | Expected not nil")
    end
end

local function assert_nil(val, message)
    if val == nil then
        passed = passed + 1
    else
        failed = failed + 1
        print("FAIL: " .. (message or "") .. " | Expected nil, Got: " .. tostring(val))
    end
end

-- Mock FiveM globals for testing
-- We need to mock the vector distance operation #(a - b)
local vector3_mt = {
    __sub = function(a, b)
        local result = {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}
        setmetatable(result, getmetatable(a))
        return result
    end,
    __len = function(t)
        return math.sqrt(t.x*t.x + t.y*t.y + t.z*t.z)
    end
}

_G.vector3 = function(x, y, z)
    local v = {x = x, y = y, z = z}
    setmetatable(v, vector3_mt)
    return v
end

-- Mock GetEntityCoords and PlayerPedId
local currentMockCoords = vector3(0.0, 0.0, 0.0)
_G.PlayerPedId = function() return 1 end
_G.GetEntityCoords = function(ped, alive) return currentMockCoords end

-- =====================================================================
-- Load function under test dynamically from main.lua
-- =====================================================================
-- Read the main.lua file
local f = io.open("client/main.lua", "r")
if not f then
    print("Could not open client/main.lua for testing.")
    os.exit(1)
end
local content = f:read("*all")
f:close()

-- We extract the local GetClosestLocation function and run it in this environment
-- Since it's local in the file, we can append a return statement to the file content
-- or just use string manipulation to extract the function.
-- An easier way to get a local function is to load the file and return the function.
local loadStr = content .. "\nreturn GetClosestLocation"
local chunk, err = load(loadStr, "client/main.lua")
if not chunk then
    print("Failed to load client/main.lua: " .. tostring(err))
    os.exit(1)
end

-- We execute the chunk to get the local function.
-- Since FiveM scripts often have other side effects, we mock out some globals just in case.
_G.TableContains = function(table, element) return false end
_G.SetVehicleHasBeenOwnedByPlayer = function() end
_G.SetEntityAsMissionEntity = function() end
_G.SetVehicleIsStolen = function() end
_G.SetVehicleIsWanted = function() end
_G.Config = { VehicleCategories = {} }
_G.QBCore = { Functions = { GetPlayerData = function() return { job = { name = 'police' }, gang = { name = 'ballas' } } end } }

local GetClosestLocation = chunk()
-- =====================================================================

-- Tests
local function run_tests()
    print("Running tests for GetClosestLocation...")

    -- Test 1: Basic distance calculation
    local locations1 = {
        {x = 10.0, y = 0.0, z = 0.0},
        {x = 20.0, y = 0.0, z = 0.0},
        {x = 30.0, y = 0.0, z = 0.0}
    }
    local loc1 = vector3(0.0, 0.0, 0.0)
    local idx, dist, loc = GetClosestLocation(locations1, loc1)

    assert_equal(1, idx, "Test 1: Should find first location")
    assert_equal(10.0, dist, "Test 1: Distance should be 10.0")
    assert_not_nil(loc, "Test 1: Location should not be nil")
    assert_equal(10.0, loc.x, "Test 1: Location x should be 10.0")

    -- Test 2: Closest is last
    local loc2 = vector3(40.0, 0.0, 0.0)
    local idx2, dist2, locResult2 = GetClosestLocation(locations1, loc2)
    assert_equal(3, idx2, "Test 2: Should find last location")
    assert_equal(10.0, dist2, "Test 2: Distance should be 10.0")
    assert_equal(30.0, locResult2.x, "Test 2: Location x should be 30.0")

    -- Test 3: Uses GetEntityCoords if loc is nil
    currentMockCoords = vector3(15.0, 0.0, 0.0)
    local idx3, dist3, locResult3 = GetClosestLocation(locations1, nil)
    -- Both 1 and 2 are 5.0 units away. The function uses > distance, so the first one found (index 1) will be kept if distance is equal
    assert_equal(1, idx3, "Test 3: Should find first location due to strict >")
    assert_equal(5.0, dist3, "Test 3: Distance should be 5.0")

    -- Test 4: Empty locations list
    local idx4, dist4, locResult4 = GetClosestLocation({}, loc1)
    assert_equal(-1, idx4, "Test 4: Should return -1 for empty list")
    assert_equal(-1, dist4, "Test 4: Should return -1 distance for empty list")
    assert_nil(locResult4, "Test 4: Location should be nil")

    -- Test 5: 3D distance
    local locations5 = {
        {x = 0.0, y = 0.0, z = 0.0},
        {x = 3.0, y = 4.0, z = 0.0}, -- Distance 5.0
        {x = 0.0, y = 0.0, z = 10.0} -- Distance 10.0
    }
    local loc5 = vector3(0.0, 0.0, 0.0)
    local idx5, dist5, locResult5 = GetClosestLocation(locations5, loc5)
    assert_equal(1, idx5, "Test 5: Should find first location (0,0,0)")
    assert_equal(0.0, dist5, "Test 5: Distance should be 0")

    local loc6 = vector3(3.0, 4.0, 0.0)
    local idx6, dist6, locResult6 = GetClosestLocation(locations5, loc6)
    assert_equal(2, idx6, "Test 6: Should find second location")
    assert_equal(0.0, dist6, "Test 6: Distance should be 0")

    -- Test 7: Null locations argument (should error, assuming locations is expected to be a table)
    -- But we don't handle error throwing gracefully here, so we skip it.

    -- Test 8: All distances are the same
    local locations8 = {
        {x = 10.0, y = 0.0, z = 0.0},
        {x = -10.0, y = 0.0, z = 0.0},
        {x = 0.0, y = 10.0, z = 0.0},
        {x = 0.0, y = -10.0, z = 0.0}
    }
    local loc8 = vector3(0.0, 0.0, 0.0)
    local idx8, dist8, locResult8 = GetClosestLocation(locations8, loc8)
    assert_equal(1, idx8, "Test 8: Should return first index when all distances are equal")
    assert_equal(10.0, dist8, "Test 8: Distance should be 10.0")

    print("\nTest Results: " .. passed .. " passed, " .. failed .. " failed.")
    if failed > 0 then
        os.exit(1)
    end
end

run_tests()
