local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end

        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local props = {
    "prop_traffic_01a",
    "prop_traffic_01b",
    "prop_traffic_01d",
    "prop_traffic_03a",
    "prop_traffic_03b",
    "prop_traffic_lightset_01",
    "prop_ind_light_01a",
    "prop_ind_light_01b",
    "prop_ind_light_01c",
    "prop_ind_light_02a",
    "prop_ind_light_02b",
    "prop_ind_light_01c",
    "prop_ind_light_02a",
    "prop_ind_light_02b",
    "prop_ind_light_02c",
    "prop_ind_light_03a",
    "prop_ind_light_03b",
    "prop_ind_light_03c",
    "prop_ind_light_04",
    "prop_streetlight_01",
    "prop_streetlight_02",
    "prop_streetlight_03",
    "prop_streetlight_03b",
    "prop_streetlight_03c",
    "prop_streetlight_03d",
    "prop_streetlight_03e",
    "prop_streetlight_14a",
    "prop_streetlight_15a",
    "prop_streetlight_04",
}

Citizen.CreateThread(function()
    local propsHash = {}
    for _, prop in ipairs(props) do
        propsHash[GetHashKey(prop)] = true
    end

    while true do
        for entity in EnumerateObjects() do
            if DoesEntityExist(entity) and propsHash[GetEntityModel(entity)] then
                FreezeEntityPosition(entity, true)
                SetEntityCanBeDamaged(entity, false)
                --SetEntityCollision(entity, false, false) -- disable collision so you can drive through x props , uncheck if you want it.
            end
        end
        Citizen.Wait(100)
    end
end)
