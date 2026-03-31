local util = require('server.util')
local TableContains = util.TableContains

local function run_tests()
    local passes = 0
    local fails = 0

    local function assert_equal(expected, actual, name)
        if expected == actual then
            passes = passes + 1
            print("PASS: " .. name)
        else
            fails = fails + 1
            print("FAIL: " .. name .. " (Expected " .. tostring(expected) .. ", got " .. tostring(actual) .. ")")
        end
    end

    print("--- Running tests for TableContains ---")

    -- Basic tests
    assert_equal(true, TableContains({1, 2, 3}, 2), "Finds existing value")
    assert_equal(false, TableContains({1, 2, 3}, 4), "Returns false for missing value")

    -- String Values
    assert_equal(true, TableContains({"a", "b", "c"}, "b"), "Finds existing string")
    assert_equal(false, TableContains({"a", "b", "c"}, "d"), "Returns false for missing string")

    -- Edge Cases
    assert_equal(false, TableContains({}, 1), "Empty table returns false")
    assert_equal(false, TableContains({1, 2}, nil), "Nil value returns false")

    -- val is a table tests
    assert_equal(true, TableContains({1, 2, 3}, {2}), "Finds single item table as value")
    assert_equal(true, TableContains({1, 2, 3}, {2, 3}), "Finds multi item table as value")
    assert_equal(true, TableContains({1, 2, 3}, {4, 2}), "Returns true when searching for multiple values and one is present")
    assert_equal(false, TableContains({1, 2, 3}, {4, 5}), "Returns false for missing item table as value")
    assert_equal(false, TableContains({1, 2, 3}, {}), "Empty table as value returns false")

    print("\n--- Summary ---")
    print("Passed: " .. passes)
    print("Failed: " .. fails)

    if fails > 0 then
        os.exit(1)
    end
end

run_tests()
