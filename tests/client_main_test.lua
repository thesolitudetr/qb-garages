dofile("tests/mock_env.lua")

-- Read client/main.lua and append return statement to expose locals
local file = io.open("client/main.lua", "r")
local content = file:read("*a")
file:close()

local exposed_code = content .. [[

return {
    TableContains = TableContains,
    IsStringNilOrEmpty = IsStringNilOrEmpty,
    GetSuperCategoryFromCategories = GetSuperCategoryFromCategories,
    GetClosestLocation = GetClosestLocation,
    GetVehicleTypeFromModelOrHash = GetVehicleTypeFromModelOrHash
}
]]

-- Load the modified code as a function
local f, err = load(exposed_code, "client/main.lua", "t", _G)
if not f then
    error("Failed to load client/main.lua: " .. tostring(err))
end

-- Execute it to get the locals table
local locals = f()

local test_cases_passed = 0
local test_cases_failed = 0

local function assert_eq(expected, actual, msg)
    if expected == actual then
        test_cases_passed = test_cases_passed + 1
    else
        test_cases_failed = test_cases_failed + 1
        print("FAILED: " .. (msg or ""))
        print("Expected: " .. tostring(expected) .. ", Actual: " .. tostring(actual))
    end
end

local function run_tests()
    -- GetVehicleTypeFromModelOrHash
    print("Testing GetVehicleTypeFromModelOrHash...")
    assert_eq("automobile", locals.GetVehicleTypeFromModelOrHash("adder"), "adder should be an automobile")

    -- Submersible should return submarine
    submersible = joaat("submersible")
    assert_eq("submarine", locals.GetVehicleTypeFromModelOrHash(submersible), "submersible should be a submarine")

    local old_GetVehicleClassFromName = GetVehicleClassFromName
    GetVehicleClassFromName = function(model)
        if model == joaat("sanchez") or model == "sanchez" then
            return 8 -- bike
        elseif model == joaat("buzzard") or model == "buzzard" then
            return 15 -- heli
        elseif model == joaat("tropic") or model == "tropic" then
            return 14 -- boat
        end
        return 0 -- automobile
    end

    assert_eq("bike", locals.GetVehicleTypeFromModelOrHash("sanchez"), "sanchez should be a bike")
    assert_eq("heli", locals.GetVehicleTypeFromModelOrHash("buzzard"), "buzzard should be a heli")
    assert_eq("boat", locals.GetVehicleTypeFromModelOrHash("tropic"), "tropic should be a boat")

    GetVehicleClassFromName = old_GetVehicleClassFromName

    -- TableContains
    print("Testing TableContains...")
    assert_eq(true, locals.TableContains({1, 2, 3}, 2), "TableContains({1, 2, 3}, 2) should return true")
    assert_eq(false, locals.TableContains({1, 2, 3}, 4), "TableContains({1, 2, 3}, 4) should return false")
    assert_eq(true, locals.TableContains({'car', 'bike'}, 'bike'), "TableContains({'car', 'bike'}, 'bike') should return true")
    assert_eq(true, locals.TableContains({'car', 'bike'}, {'car'}), "TableContains({'car', 'bike'}, {'car'}) should return true")
    assert_eq(false, locals.TableContains({'car', 'bike'}, {'boat'}), "TableContains({'car', 'bike'}, {'boat'}) should return false")

    -- IsStringNilOrEmpty
    print("Testing IsStringNilOrEmpty...")
    assert_eq(true, locals.IsStringNilOrEmpty(nil), "IsStringNilOrEmpty(nil) should return true")
    assert_eq(true, locals.IsStringNilOrEmpty(''), "IsStringNilOrEmpty('') should return true")
    assert_eq(false, locals.IsStringNilOrEmpty('hello'), "IsStringNilOrEmpty('hello') should return false")

    -- GetSuperCategoryFromCategories
    print("Testing GetSuperCategoryFromCategories...")
    assert_eq('car', locals.GetSuperCategoryFromCategories({'car'}), "GetSuperCategoryFromCategories({'car'}) should return 'car'")
    assert_eq('air', locals.GetSuperCategoryFromCategories({'plane'}), "GetSuperCategoryFromCategories({'plane'}) should return 'air'")
    assert_eq('air', locals.GetSuperCategoryFromCategories({'helicopter'}), "GetSuperCategoryFromCategories({'helicopter'}) should return 'air'")
    assert_eq('sea', locals.GetSuperCategoryFromCategories({'boat'}), "GetSuperCategoryFromCategories({'boat'}) should return 'sea'")
    assert_eq('car', locals.GetSuperCategoryFromCategories({'bike'}), "GetSuperCategoryFromCategories({'bike'}) should return 'car' (fallback)")

    -- GetClosestLocation
    print("Testing GetClosestLocation...")
    local locations = {
        {x=0, y=0, z=0},
        {x=10, y=0, z=0},
        {x=10, y=10, z=0}
    }
    local idx, dist, loc = locals.GetClosestLocation(locations, vector3(1, 0, 0))
    assert_eq(1, idx, "GetClosestLocation should return index 1")
    assert_eq(1, dist, "GetClosestLocation should return distance 1")
    assert_eq(locations[1], loc, "GetClosestLocation should return first location")

    local idx2, dist2, loc2 = locals.GetClosestLocation(locations, vector3(10, 5, 0))
    assert_eq(2, idx2, "GetClosestLocation should return index 2")
    assert_eq(5, dist2, "GetClosestLocation should return distance 5")
    assert_eq(locations[2], loc2, "GetClosestLocation should return second location")

    print("\nTests completed.")
    print("Passed: " .. test_cases_passed)
    print("Failed: " .. test_cases_failed)

    if test_cases_failed > 0 then
        os.exit(1)
    end
end

run_tests()
