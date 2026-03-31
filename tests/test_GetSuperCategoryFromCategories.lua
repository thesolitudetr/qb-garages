-- test_GetSuperCategoryFromCategories.lua

-- Mocking TableContains function from client/main.lua
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

-- Function to be tested
local function GetSuperCategoryFromCategories(categories)
    local superCategory = 'car'
    if TableContains(categories, {'car'}) then
        superCategory = 'car'
    elseif TableContains(categories, {'plane', 'helicopter'}) then
        superCategory = 'air'
    elseif TableContains(categories, 'boat') then
        superCategory = 'sea'
    end
    return superCategory
end

-- Simple assertion function
local function assertEquals(expected, actual, message)
    if expected ~= actual then
        error(string.format("Assertion failed: %s. Expected '%s', got '%s'", message or "", tostring(expected), tostring(actual)))
    end
end

local function runTests()
    print("Running tests for GetSuperCategoryFromCategories...")

    -- Test case 1: 'car' category
    assertEquals('car', GetSuperCategoryFromCategories({'car'}), "Should return 'car' for ['car']")
    assertEquals('car', GetSuperCategoryFromCategories({'sedan', 'car', 'suv'}), "Should return 'car' if 'car' is in the list")

    -- Test case 2: 'plane' or 'helicopter' category -> 'air'
    assertEquals('air', GetSuperCategoryFromCategories({'plane'}), "Should return 'air' for ['plane']")
    assertEquals('air', GetSuperCategoryFromCategories({'helicopter'}), "Should return 'air' for ['helicopter']")
    assertEquals('air', GetSuperCategoryFromCategories({'jet', 'plane'}), "Should return 'air' if 'plane' is in the list")

    -- Test case 3: 'boat' category -> 'sea'
    assertEquals('sea', GetSuperCategoryFromCategories({'boat'}), "Should return 'sea' for ['boat']")
    assertEquals('sea', GetSuperCategoryFromCategories({'yacht', 'boat'}), "Should return 'sea' if 'boat' is in the list")

    -- Test case 4: Default fallback
    assertEquals('car', GetSuperCategoryFromCategories({}), "Should default to 'car' for empty list")
    assertEquals('car', GetSuperCategoryFromCategories({'motorcycle'}), "Should default to 'car' for unknown categories")

    -- Test case 5: Precedence ('car' should take precedence over others based on the order of if statements)
    assertEquals('car', GetSuperCategoryFromCategories({'boat', 'car'}), "Should return 'car' if both 'car' and 'boat' are present")
    assertEquals('air', GetSuperCategoryFromCategories({'boat', 'plane'}), "Should return 'air' if both 'plane' and 'boat' are present")

    print("All tests passed!")
end

runTests()
