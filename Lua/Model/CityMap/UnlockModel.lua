--[[
    Author: songzeming
    Function: 公用模板 天气
]]
if UnlockModel then
    return UnlockModel
end
UnlockModel = {}
local BuildModel = import("Model/BuildModel")
--指挥中心解锁类型
UnlockModel.Center = {
    Mail = "Mail", --邮件 2
    Backpack = "Backpack", --背包 2
    Union = "Union", --联盟 2
    Gift = "Gift", --礼包
    Welfare = "Welfare", --福利中心 3
    Activity = "Activiy", --活动中心 3
    Queue = "Queue", --建筑队列金锤子 3
    Gain = "Gain", --基地增益 4
    Online = "Online", --在线礼包 4
    Achievement = "Achievement", --成就墙 5
    TaskMainGuide = "TaskMainGuide", --推荐任务指引 6
    Question = "Question",  -- 问卷调查
}
--城墙解锁类型
UnlockModel.Wall = {
    Godzilla = "Godzilla", --主界面哥斯拉领奖 2
    Sidebar = "Sidebar" --侧边栏 4
}
--建筑
UnlockModel.Build = {
    BuildingBridge = "BuildingBridge"
    --停机坪
}

--指挥中心解锁
function UnlockModel:UnlockCenter(type, node,cb)
    local level = Model.Player.Level
    if Tool.Equal(type, UnlockModel.Center.Mail, UnlockModel.Center.Backpack, UnlockModel.Center.Union) then
        --邮件、背包、联盟
        return level >= Global.UnlockLevelBase2
    elseif Tool.Equal(type, UnlockModel.Center.Welfare, UnlockModel.Center.Activity) then
        --礼包、福利中心、活动中心
        node.visible = level >= Global.UnlockLevelBase3
    elseif Tool.Equal(type, UnlockModel.Center.Queue) then
        --建筑队列金锤子
        if Model.Builders[BuildType.QUEUE.Charge].ExpireAt > Tool.Time() then
            node.visible = true
        else
            node.visible = level >= Global.UnlockLevelBase3
        end
    elseif Tool.Equal(type, UnlockModel.Center.Gift, UnlockModel.Center.Gain) then
        --基地增益
        if node then
            node.visible = level >= Global.UnlockLevelBase3
        else
            return level >= Global.UnlockLevelBase3
        end
    elseif Tool.Equal(type, UnlockModel.Center.Online) then
        --增加建筑图标显示效果
        node.visible = level >= Global.UnlockLevelBase4
        if node.visible and cb then 
            cb()
        end
    elseif Tool.Equal(type, UnlockModel.Center.Achievement) then
        return level >= Global.UnlockLevelBase5
    elseif Tool.Equal(type, UnlockModel.Center.TaskMainGuide) then
        return level < Global.PlotTaskTimeBaseLevel
    elseif Tool.Equal(type, UnlockModel.Center.Question) then
        node.visible = BuildModel.GetCenterLevel() >= Global.UnlockLevelBase5
    end
end

--城墙解锁
function UnlockModel:UnlockWall(type, node)
    local level = BuildModel.FindByConfId(Global.BuildingWall).Level
    if type == UnlockModel.Wall.Godzilla then
        --主界面哥斯拉领奖
        node.visible = level >= Global.UnlockLevelWall2
    elseif type == UnlockModel.Wall.Sidebar then
        --侧边栏
        if level >= Global.UnlockLevelWall4 then
            if not UIMgr:GetUIOpen("SidebarRelated/Sidebar") then
                UIMgr:Open("SidebarRelated/Sidebar")
            end
        end
    end
end

--解锁建筑图标动画
function UnlockModel:UnlockBuildAnim(type, configId)
    local level = Model.Player.Level
    if type == UnlockModel.Build.BuildingBridge and level == Global.UnlockLevelBase4 then
        local bonusTime = Model.NextBonusTime

        if bonusTime > Tool.Time() then
            Event.Broadcast(EventDefines.UIGiftFinishing, bonusTime)
        else
            Event.Broadcast(EventDefines.UIGiftFinish, true)
        end
    end
end

return UnlockModel
