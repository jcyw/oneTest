local ArmyEvent = {}

local BuildModel = import("Model/BuildModel")

function ArmyEvent.init()
    -- 军队数量变化通知
    Event.AddListener(
        EventDefines.UIArmyAmount,
        function(rsp)
            for _, v in pairs(rsp.Armies) do
                Model.Create(ModelType.Armies, v.ConfId, v)
            end
            Event.Broadcast(EventDefines.UIArmiesRefresh)
        end
    )

    -- 单一兵种数量变化通知
    Event.AddListener(
        EventDefines.UIArmyChange,
        function(rsp)
            Model.Create(ModelType.Armies, rsp.ConfId, rsp)
        end
    )

    -- 伤兵数量变化通知
    Event.AddListener(
        EventDefines.UIInjuredArmyAmount,
        function(rsp)
            for _, v in pairs(rsp.InjuredArmies) do
                Model.Create(ModelType.InjuredArmies, v.ConfId, v)
            end
            Event.Broadcast(EventDefines.UIInjuredArmyAmountExg)
        end
    )

    -- 完成治疗士兵通知
    Event.AddListener(
        EventDefines.UIArmyCureFinish,
        function(rsp)
            Model.Delete(ModelType.CureEvents, rsp.EventId)
            --士兵
            for _, v in pairs(rsp.Armies) do
                Model.Create(ModelType.Armies, v.ConfId, v)
            end
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingHospital then
                    BuildModel.GetObject(v.Id):CureEnd()
                end
            end
        end
    )

    -- 士兵治疗事件刷新
    Event.AddListener(
        EventDefines.UICureEvent,
        function(rsp)
            Model.Create(ModelType.CureEvents, rsp.Uuid, rsp)
            BuildModel.CheckBuildHospital()
        end
    )
    -- 怪兽治疗事件刷新
    Event.AddListener(
        EventDefines.UIMonsterCureEvent,
        function(rsp)
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingBeastHospital then
                    BuildModel.GetObject(v.Id):ResetCD(true)
                end
            end
        end
    )
end

return ArmyEvent
