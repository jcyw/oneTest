local VipEvent = {}

local EventModel = import("Model/EventModel")

function VipEvent.init()
    Event.AddListener(
        EventDefines.UIVipInfo,
        function(rsp)
            Model.InitOtherInfo(ModelType.VipInfo, rsp)
            Model.Player.VipActivated = rsp.VipIsActivated
            Model.Player.VipLevel = rsp.VipLevel
            Model.Player.VipPoints = rsp.VipPoints

            --刷新队列
            Event.Broadcast(EventDefines.UIResetBuilder)
            if not Model.Player.VipActivated then
                --刷新建筑
                local BuildModel = import("Model/BuildModel")
                for _, v in pairs(Model.Buildings) do
                    local obj = BuildModel.GetObject(v.Id)
                    if obj._btnComplete and obj._btnComplete:GetAnimType() == BuildType.ANIMATION.Free then
                        obj:FreeAnim(false)
                        obj:ResetCD()
                    end
                end
            end
        end
    )
end

return VipEvent
