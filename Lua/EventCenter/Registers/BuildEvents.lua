local BuildEvent = {}

local EventModel = import("Model/EventModel")
local BuildModel = import("Model/BuildModel")
local NoviceModel = import("Model/NoviceModel")

function BuildEvent.init()
    -- 建筑建造完成通知
    Event.AddListener(
        EventDefines.UIBuildingFinish,
        function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            local buildObj = BuildModel.GetObject(rsp.BuildingId)
            if buildObj then
                buildObj:UpgradeEnd(rsp.BuildingLevel)
                local build = Model.Buildings[rsp.BuildingId]
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, build.ConfId, {build.Level, 3})
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, build.ConfId, build.Level)
            else
                Log.Error("ERROR: Building Create Complete Notify Failed. rsp:", table.inspect(rsp))
            end
        end
    )

    -- 建筑升级完成通知
    Event.AddListener(
        EventDefines.UIBuildingUpgrade,
        function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            BuildModel.GetObject(rsp.BuildingId):UpgradeEnd(rsp.BuildingLevel)
            local build = Model.Buildings[rsp.BuildingId]
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, build.ConfId, {build.Level, 3})
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, build.ConfId, build.Level)
        end
    )

    -- 建筑拆除通知
    Event.AddListener(
        EventDefines.UIBuildingDestroy,
        function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            BuildModel.GetObject(rsp.BuildingId):RemoveEnd()
        end
    )

    -- 建筑升级事件刷新
    Event.AddListener(
        EventDefines.UIUpgradeEvent,
        function(rsp)
            Model.Create(ModelType.UpgradeEvents, rsp.Uuid, rsp)
            local node
            if rsp.Category == Global.EventTypeBuilding then
                node = BuildModel.GetObject(rsp.TargetId)
            elseif rsp.Category == Global.EventTypeTech then
                local building = BuildModel.FindByConfId(Global.BuildingScience)
                node = BuildModel.GetObject(building.Id)
            elseif rsp.Category == Global.EventTypeCure then
                local building = BuildModel.FindByConfId(Global.BuildingHospital)
                node = BuildModel.GetObject(building.Id)
            end
            if node then
                node:ResetCD()
            end
        end
    )

    -- 资源建筑新增通知
    Event.AddListener(
        EventDefines.UIResBuilAdd,
        function(rsp)
            Model.Create(ModelType.ResBuilds, rsp.Id, rsp)
            local node = BuildModel.GetObject(rsp.Id)
            if node then
                node:ResetHarest()
            end
        end
    )

    -- 资源建筑通知
    Event.AddListener(
        EventDefines.UIResBuils,
        function(rsp)
            if rsp.ResBuilds then
                for _, v in pairs(rsp.ResBuilds) do
                    Model.Create(ModelType.ResBuilds, v.Id, v)
                    BuildModel.GetObject(v.Id):ResetHarest()
                end
            end
        end
    )

    -- 删除资源建筑的资源产生信息
    Event.AddListener(
        EventDefines.UIResBuilsDelete,
        function(rsp)
            for k, v in pairs(Model[rsp.Name]) do
                if v.Id == rsp.Id then
                    Model[rsp.Name][k] = nil
                    return
                end
            end
        end
    )

    -- 建筑队列通知
    Event.AddListener(
        EventDefines.UIBuilder,
        function(rsp)
            if rsp.ExpireAt == -1 then
                Model.Builders[BuildType.QUEUE.Free] = rsp
            else
                Model.Builders[BuildType.QUEUE.Charge] = rsp
            end
        end
    )

    -- 造兵完成通知
    Event.AddListener(
        EventDefines.UIArmyTrainFinish,
        function(rsp)
            local confId = BuildModel.GetConfIdByArmId(rsp.ArmyId)
            local id = BuildModel.FindByConfId(confId).Id
            EventModel.SetTrainEnd(rsp.EventId)
            local item = BuildModel.GetObject(id)
            if item then
                item:TrainAnim(true)
            end
        end
    )

    --0点刷新
    Event.AddListener(
        TIME_REFRESH_EVENT.Refresh,
        function()
            --刷新 特惠商城 免费动画
            local id = BuildModel.FindByConfId(433000).Id
            BuildModel.GetObject(id):ResetTrade()
        end
    )
end

-- 通知礼物可以领取
Event.AddListener(
    EventDefines.UIGiftFinish,
    function(isShow)
        local giftID = BuildModel.GetObjectByConfid(Global.BuildingBridge)
        local buildItem = BuildModel.GetObject(giftID)
        if not isShow then
            buildItem._playGift=true
        end
        buildItem:GiftAnim(isShow)
    end
)

Event.AddListener(
    EventDefines.UIGiftFinishing,
    function(rsp)
        local giftID = BuildModel.GetObjectByConfid(Global.BuildingBridge)
        local buildItem = BuildModel.GetObject(giftID)
        local complete = buildItem:GetBtnComplete()
        buildItem:ResetGiftCD(rsp)
        --设置时间
    end
)
return BuildEvent
