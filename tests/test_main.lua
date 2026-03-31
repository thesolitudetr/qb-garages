local function TableContains(tab, val)
    if type(val) == "table" then -- checks if atleast one the values in val is contained in tab
        for _, value in ipairs(tab) do
            if TableContains(val, value) then
                return true
            end
        end
        return false
    else
        for _, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
    end
    return false
end

local function run_tests()
    local passed = 0
    local failed = 0

    local function assert_eq(actual, expected, name)
        if actual == expected then
            passed = passed + 1
            print("PASS: " .. name)
        else
            failed = failed + 1
            print("FAIL: " .. name .. " (Expected " .. tostring(expected) .. ", got " .. tostring(actual) .. ")")
        end
    end

    print("Running TableContains tests...")

    -- Flat tables
    assert_eq(TableContains({1, 2, 3}, 2), true, "Flat table contains element")
    assert_eq(TableContains({1, 2, 3}, 4), false, "Flat table does not contain element")

    -- Nested tables (as used in qb-garages category checks)
    assert_eq(TableContains({"car", "boat", "plane"}, {"boat", "plane"}), true, "Flat tab contains elements from val table")
    assert_eq(TableContains({"car", "boat"}, {"plane", "helicopter"}), false, "Flat tab contains no elements from val table")

    -- Deep nested tables (Issue specific edge cases)
    -- Testing how TableContains behaves when tab itself contains nested tables
    local tab_nested = {{1, 2}, 3}
    assert_eq(TableContains(tab_nested, {1, 2}), true, "Nested tab contains val table")
    assert_eq(TableContains(tab_nested, 1), false, "Nested tab does not contain primitive inside its tables")

    -- When both tab and val are deeply nested
    local tab_deep = {1, {2, 3}, {4, {5, 6}}}
    assert_eq(TableContains(tab_deep, {{4}, 1}), true, "Deep nested val finds element in deep nested tab")
    assert_eq(TableContains(tab_deep, {{8}, 9}), false, "Deep nested val finds no element in deep nested tab")

    print(string.format("Test Results: %d passed, %d failed", passed, failed))
    if failed > 0 then
        os.exit(1)
    end
end

run_tests()
