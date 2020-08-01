--[[
    Function:剧情任务配置
]]
local TaskPlotModel = {}
local IsTaskPlotGuide=false
function TaskPlotModel.GetGuideData()
    local level = Model.Player.Level
    local data = ConfigMgr.GetItem("configPlotTaskGuides", level)
    return data
end

function TaskPlotModel.SetGuideStage(flag)
    IsTaskPlotGuide=flag
end

function TaskPlotModel.GetGuideStage()
return IsTaskPlotGuide
end

return TaskPlotModel
