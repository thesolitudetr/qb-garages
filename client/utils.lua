function TableContains(tab, val)
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
