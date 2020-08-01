Net.ThreeClear = {}

-- 请求-获取章节信息
function Net.ThreeClear.GetChaptersInfo(...)
    Network.RequestDynamic("ThreeClearChaptersInfoParams", {}, ...)
end

-- 请求-获取指定关卡信息
function Net.ThreeClear.GetMissionInfo(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("ThreeClearMissionInfoParams", fields, ...)
end

-- 请求-选择关卡
function Net.ThreeClear.ChooseMission(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("ChooseMissionParams", fields, ...)
end

-- 请求-扫荡
function Net.ThreeClear.MopUp(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("ThreeClearMopUpMissionParams", fields, ...)
end

return Net.ThreeClear