Net.Plane = {}

-- 请求-请求购买零件
function Net.Plane.BuyPlanePart(...)
    local fields = {
        "PartId", -- int32
    }
    Network.RequestDynamic("BuyPlanePartParams", fields, ...)
end

-- 请求-出售零件
function Net.Plane.SellPart(...)
    local fields = {
        "Uuids", -- array-string
    }
    Network.RequestDynamic("SellPartParams", fields, ...)
end

-- 请求-解锁一个飞机
function Net.Plane.UnlockPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("UnlockPlaneParams", fields, ...)
end

-- 请求-启动一个飞机
function Net.Plane.LaunchPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("LaunchPlaneParams", fields, ...)
end

-- 请求-取消启动一个飞机
function Net.Plane.UnlaunchPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("UnlaunchPlaneParams", fields, ...)
end

-- 请求-一键启动一个飞机
function Net.Plane.OnekeyLaunchPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("OnekeyLaunchPlaneParams", fields, ...)
end

-- 请求-添加常用的飞机
function Net.Plane.AddCollectPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("AddCollectPlaneParams", fields, ...)
end

-- 请求-移除一个常用的飞机
function Net.Plane.DelCollectPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("DelCollectPlaneParams", fields, ...)
end

return Net.Plane