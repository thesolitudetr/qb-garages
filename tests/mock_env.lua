-- Mocks for FiveM and QBCore

exports = setmetatable({}, {
    __index = function(t, k)
        return setmetatable({}, {
            __index = function(_, method)
                return function()
                    if method == "GetCoreObject" then
                        return {
                            Functions = {
                                CreateClientCallback = function() end
                            }
                        }
                    end
                    return {}
                end
            end,
            __call = function(_, ...)
                if type(...) == "string" then
                    return function() end
                end
                return {}
            end
        })
    end,
    __call = function(_, name, func)
        if type(name) == "string" and type(func) == "function" then
            _G[name] = func
        end
    end
})

RegisterNetEvent = function() end
AddEventHandler = function() end
CreateThread = function() end
Wait = function() end

Config = {
    OXNotify = false,
    Garages = {},
    HouseGarages = {},
    HouseGarageCategories = {},
    JobVehicles = {},
    VehicleSettings = {},
    VehicleCategories = {},
}
Lang = {
    t = function(str) return str end
}
lib = {
    notify = function() end,
    registerContext = function() end,
    showContext = function() end,
    removeRadialItem = function() end,
    addRadialItem = function() end,
    showTextUI = function() end,
    hideTextUI = function() end,
    onCache = function() end,
}

PolyZone = { Create = function() return { onPlayerInOut = function() end, destroy = function() end } end }
ComboZone = { Create = function() return { onPlayerInOut = function() end } end }
BoxZone = { Create = function() return { onPlayerInOut = function() end } end }

-- vector3
vector3_mt = {
    __sub = function(a, b)
        return setmetatable({x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}, getmetatable(a))
    end,
    __add = function(a, b)
        return setmetatable({x = a.x + b.x, y = a.y + b.y, z = a.z + b.z}, getmetatable(a))
    end,
    __mul = function(a, scalar)
        return setmetatable({x = a.x * scalar, y = a.y * scalar, z = a.z * scalar}, getmetatable(a))
    end,
    __len = function(v)
        return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
    end
}
vector3 = function(x, y, z)
    return setmetatable({x=x or 0, y=y or 0, z=z or 0}, vector3_mt)
end

vector2 = function(x, y)
    return {x=x or 0, y=y or 0}
end

-- Natives
GetEntityCoords = function() return vector3(0,0,0) end
GetEntityHeading = function() return 0 end
PlayerPedId = function() return 1 end
NetToVeh = function() return 1 end
SetNewWaypoint = function() end
GetVehicleClass = function() return 0 end
GetVehicleClassFromName = function() return 0 end
joaat = function(str) return str end
GetEntityForwardVector = function() return vector3(1,0,0) end
NetworkPlayerIdToInt = function() return 1 end
table.unpack = table.unpack or unpack
