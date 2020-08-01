local TechEvents = {}

local EventModel = import("Model/EventModel")
local TechModel = import("Model/TechModel")

function TechEvents.init()
    -- 科技研究完成通知
    Event.AddListener(
        EventDefines.UITechResearchFinish,
        function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            TechModel.UpdateTechModel({ConfId = rsp.ConfId, Level = rsp.TechLevel, Type = rsp.TechType})

            if rsp.TechType == Global.NormalTech then
                Model.ResearchGift = true
            else
                Model.BeastResearchGift = true
            end

            local building = TechModel.GetTechBuilding(rsp.TechType)
            if building then
                local buildObj = BuildModel.GetObject(building.Id)
                buildObj:ResetCD()
            end

            -- 显示科技完成奖励气泡
            for _, v in pairs(Model.Buildings) do
                if rsp.TechType == Global.BeastTech and v.ConfId == Global.BuildingBeastScience then
                    BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                elseif rsp.TechType == Global.NormalTech and v.ConfId == Global.BuildingScience then
                    BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                end
            end

            Event.Broadcast(EventDefines.UIRefreshTechResearchFinish, rsp.ConfId)

            local config = TechModel.GetDisplayConfigItem(rsp.TechType, rsp.ConfId)
            TipUtil.TipById(30105, {tech_name =  TechModel.GetTechName(rsp.ConfId)}, config.icon)
        end
    )
end

return TechEvents