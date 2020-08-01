Net.BackStage = {}

-- 请求-清除地块
function Net.BackStage.CleanMapRec(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("BackstageCleanMapRecParams", fields, ...)
end

return Net.BackStage