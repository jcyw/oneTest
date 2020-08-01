Net.Chapter = {}

-- 请求-获取章节任务的所有信息
function Net.Chapter.GetChapterInfo(...)
    Network.RequestDynamic("GetChapterInfoParams", {}, ...)
end

-- 请求-获取剧情任务的奖励
function Net.Chapter.GetPlotTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetPlotTaskAwardParams", fields, ...)
end

-- 请求-获取章节的奖励
function Net.Chapter.GetChapterAward(...)
    Network.RequestDynamic("GetChapterAwardParams", {}, ...)
end

return Net.Chapter