--[[
    Author: songzeming
    Function: 特殊建筑点击
]]
local SpecialBuildModel = {}

local BuildModel = import("Model/BuildModel")
local FuncListModel = import("Model/FuncListModel")

function SpecialBuildModel.OnBuildClick(confId)
    if confId == Global.BuildingSpecialMall then
        --特价商城
        SpecialBuildModel.SpecialMall()
    elseif confId == Global.BuildingParadeSquare then
        --阅兵广场
        UIMgr:Open("TroopsDetails")
    elseif confId == 405000 then
        --停机坪
        --添加等级限制
        if Model.Player.Level >= Global.UnlockLevelBase4 then
            Event.Broadcast(EventDefines.OnlineGiftOpen)
        end
    elseif confId == Global.BuildingRank then
        --排行榜
        if BuildModel.GetCenterLevel() < Global.RankOpenLevel then
            TipUtil.TipById(50004)
        else
            Net.Rank.RankInfo(
                Global.RankByAlliancePower,
                1,
                0,
                function(rsp)
                    if rsp.Fail then
                        return
                    end
                    UIMgr:Open("RankMain", rsp)
                end
            )
        end
    elseif confId == Global.BuildingResourceHub then
        --资源枢纽
        UIMgr:Open("ResourceProductionDetail")
    elseif confId == Global.BuildingCustomerService then
        --客服中心
        FuncListModel.GameCustomerService()
    elseif confId == Global.BuildingActivityCenter then
        --活动中心
        if BuildModel.GetUnlockByConfId(confId) then
            UIMgr:Open("ActivityCenter")
        else
            local level = ConfigMgr.GetItem("configBuildings", Global.BuildingActivityCenter).unlock_level
            TipUtil.TipById(30602, {base_name = BuildModel.GetName(Global.BuildingCenter), base_level = level})
        end
    elseif confId == Global.BuildingDiamond then
        --钻石基金
        local conf = ConfigMgr.GetItem("configBuildings", confId)
        if Model.Player.Level < conf.unlock_level then
            local data = {
                base_name = BuildModel.GetName(Global.BuildingCenter),
                base_level = conf.unlock_level
            }
            TipUtil.TipById(30602, data)
        else
            FuncListModel.DiamondsFundPrice()
        end
    elseif confId == Global.BuildingEquipMaterialFactory then
        --材料工厂
        if BuildModel.GetUnlockByConfId(confId) then
            UIMgr:Open("EquipmentMake")
        else
            local level = ConfigMgr.GetItem("configBuildings", Global.BuildingEquipMaterialFactory).unlock_level
            TipUtil.TipById(30602, {base_name = BuildModel.GetName(Global.BuildingCenter), base_level = level})
        end
    end
end

--特价商城
function SpecialBuildModel.SpecialMall()
    if BuildModel.GetCenterLevel() >= ConfigMgr.GetVar("SpecialShopUnlock") then
        Net.SpecialShop.GetGoodsList(
            function(msg)
                UIMgr:Open("Trade/Trade", msg)
                local showTime = PlayerDataModel:GetData(PlayerDataEnum.SpecialShowTime)
                if not showTime then
                    PlayerDataModel:SetData(PlayerDataEnum.SpecialShowTime, Tool.Time() + 10800)
                elseif showTime < Tool.Time() then
                    PlayerDataModel:SetData(PlayerDataEnum.SpecialShowTime, Tool.Time() + 10800)
                end
                local id = BuildModel.FindByConfId(433000).Id
                BuildModel.GetObject(id):ResetTrade()
            end
        )
    else
        TipUtil.TipById(50061)
    end
end

return SpecialBuildModel
