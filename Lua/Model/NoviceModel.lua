--[[
    Author: Baggio-Wang
    Function:新手引导数据
    Time:2019-12-25 14:23:25 
]]--

local NoviceModel = {}

local skipNovice = false
local isSkip = false
function NoviceModel.GetTotalNoviceSteps()
    local list = ConfigMgr.GetList("configNoviceGuides") 
	return list
end

function NoviceModel.GetNoviceGuideByConfId(confId, plan)
    if plan == 0 or not plan then
        return ConfigMgr.GetItem("configNoviceGuides", confId)
    elseif plan == 1 then
        return ConfigMgr.GetItem("configNoviceGuideBs", confId)
    elseif plan == 2 then
        return ConfigMgr.GetItem("configNoviceGuideCs", confId)
    elseif plan == 3 then
        return ConfigMgr.GetItem("configNoviceGuideDs", confId)
    end
    return nil
end

function NoviceModel.GetNoviceArmyById(confId)
    local item = ConfigMgr.GetItem("configNoviceCoords", confId)
    return item
end

function NoviceModel.GetNoviceFirePositionById(confId)
    local item = ConfigMgr.GetItem("configNoviceFireCoords", confId)
    return item
end

function NoviceModel.SetCanSkipNovice(value)
    skipNovice = value
end

function NoviceModel.GetCanSkipNovice()
    return skipNovice
end

function NoviceModel.SendStepToServer(stepId)
	
end

function NoviceModel:NextStep()
    if Model.Player.GuideVersion == 0 then
        if Model.Player.GuideStep == 10049 then
            if not NoviceModel.GetIsSkip() then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
            self:Close()
        else
            Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep)
        end
    elseif Model.Player.GuideVersion == 1 then
        if Model.Player.GuideStep == 10059 then
            if not NoviceModel.GetIsSkip() then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
            self:Close()
        else
            Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep)
        end
    elseif Model.Player.GuideVersion == 2 then
        if Model.Player.GuideStep == 10043 then
            if not NoviceModel.GetIsSkip() then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
            self:Close()
        else
            Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep)
        end
    elseif Model.Player.GuideVersion == 3 then
        if Model.Player.GuideStep == 10049 then
            if not NoviceModel.GetIsSkip() then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
            self:Close()
        else
            Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep)
        end 
    end
end

function NoviceModel:Close()
    --Log.Error("nextStep--------------------------{0}", Model.Player.GuideStep+1)
    Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep)
    Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, false)
    NoviceModel.SetCanSkipNovice(false)
    -- UIMgr:Close("Novice")
    NoviceModel.CloseUI()
end

function NoviceModel.CloseUI()
    ScrollModel.SetWhetherMoveScale()
    UIMgr:Close("Novice")
end

function NoviceModel.SetIsSkip(value)
    isSkip = value
end

function NoviceModel.GetIsSkip()
    return isSkip
end

return NoviceModel
