local GD = _G.GD
local GuideAgent = GD.LVar("GuideAgent",{})
local AgentDefine = GD.AgentDefine
local Model        = _G.Model
local ModelType    = _G.ModelType
local JumpMapModel = _G.JumpMapModel
local EventDefines = _G.EventDefines
local TaskModel    = _G.TaskModel
local Event        = _G.Event
local Net          = _G.Net


--:function declare
local SetGuideClick
local SetGuideStep
local SetTriggerGuideStep

--:function implementation
function SetGuideClick(GuideFinishType)
    if Model.Player.Level < 6 then
        local guideStage = JumpMapModel:GuideStage() and JumpMapModel:GetJumpId() == 813300
        --关闭引导
        Event.Broadcast(EventDefines.CloseGuide)
        if not TaskModel.GetGuideFreeStageByKey(GuideFinishType) and guideStage then
            TaskModel.SetGuideFreeData(GuideFinishType)
        end
    end
end

function SetGuideStep(CurrentStep, isFinished, cb)
    isFinished = isFinished == nil and false or isFinished

    -- do --test
    --     dump(Model.Player.GuideStep, "simon.引导打点开始")
    --     Model.Player.GuideStep = Model.Player.GuideStep + 1
    --     dump(Model.Player.GuideStep, "simon.引导打点完成")
    --     return
    -- end
--

    Net.Logins.SetGuideStep(CurrentStep, Model.Player.GuideVersion, isFinished,function()
        Model.Player.GuideStep = Model.Player.GuideStep + 1
        Event.Broadcast(EventDefines.NoviceGuide, Model.Player.GuideStep, Model.Player.GuideVersion)
        if cb then
            cb()
        end
    end)
end

function SetTriggerGuideStep(step, id, IsFinish, cb)
    Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = IsFinish}, function()
        if cb then
            cb()
        end
    end)
end

--:function define
AgentDefine(GuideAgent, "SetGuideClick", SetGuideClick)
AgentDefine(GuideAgent, "SetGuideStep", SetGuideStep)
AgentDefine(GuideAgent, "SetTriggerGuideStep", SetTriggerGuideStep)

return GuideAgent
