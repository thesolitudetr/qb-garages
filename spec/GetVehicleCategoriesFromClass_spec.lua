describe("GetVehicleCategoriesFromClass", function()
    local GetVehicleCategoriesFromClass

    before_each(function()
        -- Setting up mock VehicleClassMap globally
        -- In busted, we can just define it globally, or inject it
        _G.VehicleClassMap = {
            [0] = {"car"},
            [8] = {"motorcycle"},
            [14] = {"boat"},
            [15] = {"helicopter"},
            [16] = {"plane"}
        }

        local code = io.open("client/main.lua"):read("*a")

        -- Extract the local function GetVehicleCategoriesFromClass
        local func_body = code:match("local function GetVehicleCategoriesFromClass%(class%).-end")

        -- Add a return statement so we can grab the function
        local lua_code = func_body .. "\nreturn GetVehicleCategoriesFromClass"
        GetVehicleCategoriesFromClass = assert(load(lua_code))()
    end)

    it("should return correct category for valid car class", function()
        assert.are.same({"car"}, GetVehicleCategoriesFromClass(0))
    end)

    it("should return correct category for valid motorcycle class", function()
        assert.are.same({"motorcycle"}, GetVehicleCategoriesFromClass(8))
    end)

    it("should return correct category for valid boat class", function()
        assert.are.same({"boat"}, GetVehicleCategoriesFromClass(14))
    end)

    it("should return correct category for valid helicopter class", function()
        assert.are.same({"helicopter"}, GetVehicleCategoriesFromClass(15))
    end)

    it("should return correct category for valid plane class", function()
        assert.are.same({"plane"}, GetVehicleCategoriesFromClass(16))
    end)

    it("should return nil for unknown class", function()
        assert.is_nil(GetVehicleCategoriesFromClass(99))
    end)

    it("should return nil when class is nil", function()
        assert.is_nil(GetVehicleCategoriesFromClass(nil))
    end)
end)
