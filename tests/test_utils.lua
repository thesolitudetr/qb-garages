-- test_utils.lua
-- Require the script to be tested
require("client.utils")

-- A simple test runner setup
local pass_count = 0
local fail_count = 0

local function run_test(name, func)
    local status, err = pcall(func)
    if status then
        pass_count = pass_count + 1
        print("PASS: " .. name)
    else
        fail_count = fail_count + 1
        print("FAIL: " .. name .. "\n\t" .. tostring(err))
    end
end

-- Begin Tests

run_test("TableContains - Number value exists in table", function()
    local tab = {1, 2, 3, 4, 5}
    assert(TableContains(tab, 3) == true)
end)

run_test("TableContains - Number value does not exist in table", function()
    local tab = {1, 2, 4, 5}
    assert(TableContains(tab, 3) == false)
end)

run_test("TableContains - String value exists in table", function()
    local tab = {"apple", "banana", "cherry"}
    assert(TableContains(tab, "banana") == true)
end)

run_test("TableContains - String value does not exist in table", function()
    local tab = {"apple", "cherry"}
    assert(TableContains(tab, "banana") == false)
end)

run_test("TableContains - Empty table returns false", function()
    local tab = {}
    assert(TableContains(tab, 1) == false)
end)

run_test("TableContains - Nil value does not exist", function()
    local tab = {1, 2, 3}
    assert(TableContains(tab, nil) == false)
end)

run_test("TableContains - Val is table, one value matches", function()
    local tab = {"apple", "banana", "cherry"}
    local val = {"orange", "banana"}
    assert(TableContains(tab, val) == true)
end)

run_test("TableContains - Val is table, no values match", function()
    local tab = {"apple", "banana", "cherry"}
    local val = {"orange", "grape"}
    assert(TableContains(tab, val) == false)
end)

run_test("TableContains - Val is table, all values match", function()
    local tab = {"apple", "banana", "cherry"}
    local val = {"apple", "banana"}
    assert(TableContains(tab, val) == true)
end)

run_test("TableContains - Tab and Val are both empty tables", function()
    local tab = {}
    local val = {}
    assert(TableContains(tab, val) == false)
end)

run_test("TableContains - Val is empty table", function()
    local tab = {1, 2, 3}
    local val = {}
    assert(TableContains(tab, val) == false)
end)

-- Note: In the existing implementation, `if TableContains(val, value) then`
-- when `val` is a table will check if `val` (the passed in table of values)
-- contains `value` (a scalar from `tab`). So if ANY element in `tab`
-- is present in `val`, it returns true.

run_test("TableContains - Nested tables not supported (current limitation check)", function()
    -- Current logic isn't explicitly for deep nested tables but rather for matching an array of values against an array of values.
    local tab = {1, {2, 3}, 4}
    assert(TableContains(tab, 2) == false) -- this will be false because `2` is compared to `{2,3}`, then `4`.
end)

print("\n------------------------------")
print("Tests Passed: " .. pass_count)
print("Tests Failed: " .. fail_count)

if fail_count > 0 then
    os.exit(1)
end
