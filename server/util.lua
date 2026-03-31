local util = {}

function util.TableContains (tab, val)
    if type(val) == "table" then
        for _, value in ipairs(tab) do
            if util.TableContains(val, value) then
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

return util
