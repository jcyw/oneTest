--[[
    author:{laofu}
    time:2020-07-29 10:36:46
    function:{触发引导数据模块}
]]
local GD = _G.GD
local TriggerGuideAgent = GD.LVar("TriggerGuideAgent", {})
local AgentDefine = GD.AgentDefine

local TechModel = _G.import("Model/TechModel")
local SkillModel = _G.import("Model/SkillModel")
local BuildModel = _G.import("Model/BuildModel")
local NoviceModel = _G.import("Model/NoviceModel")
local WelfareModel = _G.import("Model/WelfareModel")
local BuildQueueModel = _G.import("Model/CityMap/BuildQueueModel")

local Net = _G.Net
local Model = _G.Model
local Event = _G.Event
local UIMgr = _G.UIMgr
local ABTest = _G.ABTest
local Global = _G.Global
local SdkModel = _G.SdkModel
local ConfigMgr = _G.ConfigMgr
local BuildType = _G.BuildType
local GlobalVars = _G.GlobalVars
local EventDefines = _G.EventDefines
local TriggerType = GD.GameEnum.TriggerType
local SYSTEM_SETTING_EVENT = _G.SYSTEM_SETTING_EVENT

local TriggerData = {}
local BStashTrigger = false

local OnInitTriggerData  --保存触发引导表中的数据
local CheckIsTriggerStatus  --检测触发引导限制点击按钮状态
local GetTriggerGuideByConfId  --获得Trigger表的某个id数据
local GetTriggerId  --获得configTriggerGuides表的数据
local CheackTriggerState  --检测触发条件是否满足
local CompleteTrigger  --触发引导完成
local SetLocalTriggerData  --设置引导步骤数据到玩家身上
local CityHaveStashTriggerJudge  --内城是否有触发引导缓存
local WorldHaveStashTriggerJudge  --外城是否有触发引导缓存
local IsFinishTrigger  --该触发引导是否完成

--@desc:保存触发引导表中的数据
function OnInitTriggerData()
    local list = ConfigMgr.GetList("configTriggerGuides")
    for i = 1, #list do
        if TriggerData[list[i].type1.type] == nil then
            TriggerData[list[i].type1.type] = {}
            table.insert(TriggerData[list[i].type1.type], list[i])
        else
            table.insert(TriggerData[list[i].type1.type], list[i])
        end
    end
end

--@desc:检测触发引导限制点击按钮状态
function CheckIsTriggerStatus()
    if GlobalVars.IsTriggerStatus then
        local nowId = GlobalVars.NowTriggerId
        local triggerInfo = ConfigMgr.GetItem("configTriggerGuides", nowId)
        --在页面内触发或者不是内外城触发
        local isLimitClick = (triggerInfo.inCity ~= 2 or triggerInfo.isCloseWindow == 0) and triggerInfo.isActive == 1
        if isLimitClick then
            return true
        else
            return false
        end
    else
        return false
    end
end

--@desc:获得Trigger表的某个id数据
function GetTriggerGuideByConfId(confId)
    local item = ConfigMgr.GetItem("configTriggerGuides", confId)
    return item
end

--Boot steps获得configTriggerGuides表的数据
--根据type1字段判断，如果有些建筑有特殊处理的逻辑就需要特殊判断
--这里是添加触发引导的触发条件
function GetTriggerId(type, para1, para2)
    local triggerId = {}
    local tableFunc = {
        [TriggerType.MainType.Level] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    local switch = {
                        [11500] = function()
                            local GetCurPage = SkillModel.GetCurPage
                            local battlePoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillBattle, GetCurPage())
                            local progrPoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillProgress, GetCurPage())
                            local assistPoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillAssist, GetCurPage())
                            local point = (battlePoint == 0 and progrPoint == 0 and assistPoint == 0)
                            if Model.Player.HeroLevel >= 4 and point then
                                local haveSame = false
                                for j = 1, #Model.Player.TriggerGuides do
                                    if Model.Player.TriggerGuides[j].Id == 13200 then
                                        haveSame = true
                                    end
                                end
                                if haveSame == false then
                                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                end
                            end
                        end,
                        [13200] = function()
                            local haveSame = false
                            for j = 1, #Model.Player.TriggerGuides do
                                if Model.Player.TriggerGuides[j].Id == 11500 then
                                    haveSame = true
                                end
                            end
                            if haveSame == false then
                                table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                            end
                        end
                    }
                    if switch[para1] then
                        switch[para1]()
                    end
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.StartLvUp] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.type1.para2 == para2 and v.isActive == 1 then
                    local switch = {
                        [3] = function()
                            local item = GD.ItemAgent.GetItemModelById(200120)
                            if Model.Player.VipActivated == false and item then
                                table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                            end
                        end,
                        [4] = function()
                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                        end,
                        [5] = function()
                            Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
                            Event.Broadcast(EventDefines.RefreshTaskPlotGuide)
                            local mainPanel = UIMgr:GetUI("MainUIPanel")
                            if mainPanel._taskController.selectedIndex == 1 then
                                table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                            else
                                table.insert(triggerId, {Step = 3, Id = v.turnId.id})
                            end
                        end
                    }
                    if para1 == 400000 and switch[para2] then
                        switch[para2]()
                    end
                    break
                end
            end
            if para1 == 424000 and para2 == 4 then
                Event.Broadcast(EventDefines.TriggerGuideJudge, TriggerType.MainType.LvUpOrEndLvUp, para1, para2)
            end
            return triggerId
        end,
        [TriggerType.MainType.EndLvUp] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.type1.para2 == para2[1] and v.isActive == 1 then
                    local para1Switch = {
                        [400000] = {
                            [2] = function()
                                local turnIdSwitch = {
                                    [11000] = function()
                                        local item = GD.ItemAgent.GetItemModelById(200512)
                                        if item and Model.Player.GuideVersion == 0 then
                                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                        end
                                    end,
                                    [14000] = function()
                                        if Model.Player.GuideVersion == 0 and not ABTest.BeautySystemTrigger() then
                                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                        end
                                    end
                                }
                                if turnIdSwitch[v.turnId.id] then
                                    turnIdSwitch[v.turnId.id]()
                                end
                            end,
                            [3] = function()
                                if ABTest.Task_ABLogic() == 2002 then
                                    if ABTest.GodzilaGuideAB_Logic() == 6001 then
                                        if v.turnId.id == 14800 then
                                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                        end
                                    end
                                else
                                    if v.turnId.id == 14800 then
                                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                    end
                                end
                            end,
                            [4] = function()
                                if v.turnId.id == 12500 then -- 需要建筑队列的引导
                                    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
                                    if freeQueue.IsWorking == false or BuildQueueModel.GetChargeCanUse() == true then
                                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                    end
                                end
                            end,
                            [5] = function()
                                if ABTest.Kingkong_ABLogic() and v.turnId.id == 14900 then
                                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                elseif not ABTest.Kingkong_ABLogic() and v.turnId.id == 14600 then
                                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                end
                            end,
                            [8] = function()
                                if ABTest.Task_ABLogic() == 2002 and ABTest.GodzilaGuideAB_Logic() == 6002 then
                                    if v.turnId.id == 15600 then
                                        local GetBuildLock = BuildModel.GetBuildLock
                                        local BeastBaseLock = GetBuildLock(Global.BuildingBeastBase)
                                        if BeastBaseLock then
                                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                        elseif not BeastBaseLock and GetBuildLock(Global.BuildingGodzilla) then
                                            table.insert(triggerId, {Step = 3, Id = v.turnId.id})
                                        end
                                    end
                                end
                            end
                        },
                        [403000] = {
                            [1] = function()
                                if v.turnId.id == 11100 then -- 需要建筑队列的引导
                                    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
                                    if TechModel.CheckLearnTechHave() then
                                        return triggerId
                                    end
                                    if freeQueue.IsWorking == false or BuildQueueModel.GetChargeCanUse() == true then
                                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                    end
                                end
                            end
                        },
                        [419000] = {
                            [3] = function()
                                if v.turnId.id == 11800 then
                                    if ABTest.Kingkong_ABLogic() then
                                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                    end
                                end
                            end,
                            [4] = function()
                                if v.turnId.id == 15000 then
                                    local WelfarePageType = WelfareModel.WelfarePageType
                                    local isExist = WelfareModel.CheckActiviyExist(WelfarePageType.FALCON_ACTIVITY)
                                    if not isExist then
                                        return triggerId
                                    end
                                    local haveSame = false
                                    for j = 1, #Model.Player.TriggerGuides do
                                        if Model.Player.TriggerGuides[j].Id == 15100 then
                                            haveSame = true
                                        end
                                    end
                                    if haveSame == false then
                                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                    end
                                end
                            end,
                            [5] = function()
                                if not SdkModel.IsBind() then -- 没有绑定才触发
                                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                end
                            end
                        },
                        [423000] = {
                            [2] = function()
                                if ABTest.TwelveHourSendSoldier() then
                                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                                end
                            end
                        }
                    }

                    if para1Switch[para1] and para1Switch[para1][para2[1]] then
                        para1Switch[para1][para2[1]]()
                    else
                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    end
                end
            end
            if para1 == 424000 and para2[1] == 4 then
                Event.Broadcast(EventDefines.TriggerGuideJudge, TriggerType.MainType.LvUpOrEndLvUp, para1, para2[1])
            end
            return triggerId
        end,
        [TriggerType.MainType.ActiveSkill] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.JoinUnion] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.ClickWorld] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id, params = para2})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.HaveInjure] = function()
            if not BuildModel.GetIdleHospital() then
                return {}
            end
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.OpenUI] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    local turnIdSwitch = {
                        [15100] = function()
                            local haveSame = false
                            for j = 1, #Model.Player.TriggerGuides do
                                if Model.Player.TriggerGuides[j].Id == 15000 then
                                    haveSame = true
                                end
                            end
                            if haveSame == false then
                                table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                            end
                        end,
                        [15700] = function()
                            if BuildModel.GetBuildLock(Global.BuildingBeastBase) then
                                table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                            end
                        end
                    }

                    if turnIdSwitch[v.turnId.id] then
                        turnIdSwitch[v.turnId.id]()
                    else
                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    end
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.ClickTask] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.LvUpOrEndLvUp] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    if para1 == 424000 and para2 == 4 then
                        if v.turnId.id == 13900 and BuildQueueModel:GetChargeLock() == true then
                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                        end
                    end
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.SendSoldierEnd] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.isActive == 1 then
                    table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    break
                end
            end
            return triggerId
        end,
        [TriggerType.MainType.NoTrigger] = function()
            for _, v in pairs(TriggerData[type]) do
                if v.type1.para1 == para1 and v.type1.para2 <= para2 and v.isActive == 1 then
                    if v.turnId.id == 17100 then
                        if Model.Player.Gem >= 500 then
                            table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                        end
                    else
                        table.insert(triggerId, {Step = 0, Id = v.turnId.id})
                    end
                end
            end
            return triggerId
        end
    }
    --执行对应类型的方法
    if tableFunc[type] then
        return tableFunc[type]()
    else
        return {}
    end
end

--@desc:检测触发条件是否满足
function CheackTriggerState(noviceID)
    if GlobalVars.NowTriggerId > 0 then
        local configItem = TriggerGuideAgent.GetTriggerGuideByConfId(GlobalVars.NowTriggerId)
        if not configItem then
            return false
        end
        --这个type是 触发式引导表|configTriggerGuide type1字段的第一个参数
        local configType = configItem.type1.type
        local params = configItem.type1.para1
        local params2 = configItem.type1.para2
        local configTypeSwitch = {
            [2] = function()
                local isExist = BuildModel.CheckExist(params)
                if not isExist then
                    return false
                end
                local building = BuildModel.FindByConfId(params)
                --等级是否满足
                local centerObj = BuildModel.GetObject(building.Id)
                --看是否等级满足条件
                if noviceID and noviceID == 11405 then
                    return (building.Level == params2 - 1 and centerObj._playFree) and true or false
                else
                    return (building.Level == params2 - 1 and not centerObj._playFree) and true or false
                end
            end,
            [3] = function()
                local isExist = BuildModel.CheckExist(params)
                if not isExist then
                    return false
                end
                local building = BuildModel.FindByConfId(params)
                return (building.Level == params2) and true or false
            end,
            [9] = function()
                --没有任务状态的医院的
                local building = BuildModel:GetIdleHospital()
                return building and true or false
            end
        }
        if configTypeSwitch[configType] then
            return configTypeSwitch[configType]()
        else
            return true
        end
    end
    return false
end

--@desc:触发引导完成
function CompleteTrigger(id, cb)
    local net_func = function()
        GlobalVars.IsTriggerStatus = false
        GlobalVars.IsAllowPopWindow = true
        NoviceModel.CloseUI()
        --设置遮罩可点击
        NoviceModel.SetCanSkipNovice(true)
        if UIMgr:GetUIOpen("GuideMask") then
            Event.Broadcast(EventDefines.GuideMask, false)
        end
        GlobalVars.NowTriggerId = 0
        BStashTrigger = false
        for i = 1, #Model.Player.TriggerGuides do
            local triggerGuideInfo = Model.Player.TriggerGuides[i]
            if triggerGuideInfo.Finish == false and triggerGuideInfo.Id == id then
                Model.Player.TriggerGuides[i].Finish = true
            end
        end
        if cb then
            cb()
        end
    end
    local step = 0
    Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = true}, net_func)
end

--@desc:设置引导步骤数据到玩家身上
function SetLocalTriggerData(id, step)
    for i = 1, #Model.Player.TriggerGuides do
        if id == Model.Player.TriggerGuides[i].Id then
            Model.Player.TriggerGuides[i].Step = step
            break
        end
    end
end

--@desc:内城是否有触发引导缓存
function CityHaveStashTriggerJudge()
    BStashTrigger = false
    if not Model.Player then
        return BStashTrigger
    end
    for _, v in pairs(Model.Player.TriggerGuides) do
        local triggerInfo = TriggerGuideAgent.GetTriggerGuideByConfId(v.Id)
        -- 如果有没有完成的，触发条件是在内城触发的，并且现在在内城
        local inCityTrigger = (triggerInfo.inCity == 1 or triggerInfo.inCity == 2)
        if triggerInfo and v.Finish == false and inCityTrigger and GlobalVars.IsInCityTrigger == true then
            BStashTrigger = true
        end
    end

    return BStashTrigger
end

--@desc:外城是否有触发引导缓存
function WorldHaveStashTriggerJudge()
    BStashTrigger = false
    if not Model.Player then
        return BStashTrigger
    end
    for _, v in pairs(Model.Player.TriggerGuides) do
        local triggerInfo = TriggerGuideAgent.GetTriggerGuideByConfId(v.Id)
        -- 如果有没有完成的，触发条件是在内城触发的，并且现在在外城
        local inWorldTrigger = (triggerInfo.inCity == 0 or triggerInfo.inCity == 2)
        if triggerInfo and v.Finish == false and inWorldTrigger and GlobalVars.IsInCityTrigger == false then
            BStashTrigger = true
        end
    end

    return BStashTrigger
end

--@desc:该触发引导是否完成
function IsFinishTrigger(id)
    for i = 1, #Model.Player.TriggerGuides do
        if id == Model.Player.TriggerGuides[i].Id and Model.Player.TriggerGuides[i].Finish == true then
            return true
        end
    end
    return false
end

AgentDefine(TriggerGuideAgent, "OnInitTriggerData", OnInitTriggerData)
AgentDefine(TriggerGuideAgent, "CheckIsTriggerStatus", CheckIsTriggerStatus)
AgentDefine(TriggerGuideAgent, "GetTriggerGuideByConfId", GetTriggerGuideByConfId)
AgentDefine(TriggerGuideAgent, "GetTriggerId", GetTriggerId)
AgentDefine(TriggerGuideAgent, "CheackTriggerState", CheackTriggerState)
AgentDefine(TriggerGuideAgent, "CompleteTrigger", CompleteTrigger)
AgentDefine(TriggerGuideAgent, "SetLocalTriggerData", SetLocalTriggerData)
AgentDefine(TriggerGuideAgent, "CityHaveStashTriggerJudge", CityHaveStashTriggerJudge)
AgentDefine(TriggerGuideAgent, "WorldHaveStashTriggerJudge", WorldHaveStashTriggerJudge)
AgentDefine(TriggerGuideAgent, "IsFinishTrigger", IsFinishTrigger)

return TriggerGuideAgent
