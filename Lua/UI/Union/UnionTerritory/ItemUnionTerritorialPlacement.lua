--[[
    author:{zhanzhang}
    time:2019-07-22 16:15:00
    function:{联盟建筑管理界面每个建筑项}
]]
local ItemUnionTerritorialPlacement = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTerritorialPlacement", ItemUnionTerritorialPlacement)

local UnionModel = import("Model/UnionModel")

local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")
local WorldBuildType = import("Enum/WorldBuildType")
function ItemUnionTerritorialPlacement:ctor()
    self._txtTitle = self:GetChild("textName")
    self._btnHelp = self:GetChild("btnHelp")
    self._textCoordinate = self:GetChild("textCoordinate")
    self._btnApply = self:GetChild("btnApplyAll")
    self._btnFree = self:GetChild("btnFree")
    -- self._txtHpTitle = self:GetChild("textForce")
    self._txtHp = self:GetChild("textForceNum")
    self._txtCoordinate = self:GetChild("textCoordinate")
    self._btnDetail = self:GetChild("bgMask")
    self._icon = self:GetChild("icon")
    self._txtPrice = self._btnApply:GetChild("text")
    self._controller = self:GetController("c1")

    self._textStatus = self:GetChild("textNotGarrison")

    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("UnionFortressPopup", self.info)
        end
    )
    self:AddListener(self._txtCoordinate.onClick,
        function()
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, self.posX, self.posY)
        end
    )

    local func = function()
        UIMgr:ClosePopAndTopPanel()

        local data = {}
        data.ConfId = self.config.id
        if self.config.building_type == 1 then
            data.BuildType = WorldBuildType.UnionFortress
        elseif self.config.building_type == 5 then
            data.BuildType = WorldBuildType.UnionDefenceTower
        elseif self.config.building_type == 3 then
            data.BuildType = WorldBuildType.UnionStore
        else
            data.BuildType = WorldBuildType.OtherUnionBuild
        end
        -- data.posNum = Model.Player.X * 10000 + Model.Player.Y
        local posNum = UnionTrritoryModel.GetPointPos()
        if posNum == 0 then
            Net.AllianceBuildings.GetNearbyBuildPlace(
                data.ConfId,
                function(rsp)
                    data.posNum = MathUtil.GetPosNum(rsp.X, rsp.Y)
                    data.notNeedDiamon = self.info.RebuildReason > 0
                    WorldMap.AddEventAfterMap(
                        function()
                            Event.Broadcast(EventDefines.BeginBuildingMove, data)
                        end
                    )
                    Event.Broadcast(EventDefines.OpenWorldMap, rsp.X, rsp.Y)
                end
            )
        else
            local posX, posY = MathUtil.GetCoordinate(posNum)
            data.posNum = posNum
            data.notNeedDiamon = self.info.RebuildReason > 0
            WorldMap.AddEventAfterMap(
                function()
                    Event.Broadcast(EventDefines.BeginBuildingMove, data)
                end
            )
            Event.Broadcast(EventDefines.OpenWorldMap, posX, posY)
        end
    end

    self:AddListener(self._btnApply.onClick,func)

    self:AddListener(self._btnFree.onClick,func)
end

--控制器状态 0为未解锁 1为待放置 2为已放置
function ItemUnionTerritorialPlacement:Init(data)
    local info = UnionTrritoryModel.GetTerritorDetail(data.id)
    self._txtPrice.text = Global.AllianceFortressBuildCostGem
    if not info then
        return
    end

    --[[ 服务器状态:
    LOCKED    = 0 // 未解锁
    BUILDABLE = 1 // 可建造
    BUILDING  = 2 // 建造中
    COMPLETE  = 3 // 建造完成
    ATTACKED  = 4 // 被破坏
    ]]
    self.config = ConfigMgr.GetItem("configAllianceFortresss", info.ConfId)
    self.info = info
    local name = ""
    if data.building_name == info.Name then
        name = StringUtil.GetI18n(I18nType.Commmon, info.Name)
    else
        name = info.Name
    end
    self._icon.url = UITool.GetIcon(self.config.build_image)
    self._txtTitle.text = name
    -- self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")
    self._txtHp.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")..info.ArchiValue
    self.posX, self.posY = MathUtil.GetCoordinate(info.Pos)
    self._txtCoordinate.text = "X:" .. self.posX .. " Y:" .. self.posY

    if info.State == 0 then
        self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "UI_LOCKED")
    elseif info.State == 1 then
        if self.config.Fortress_request then
            if self.config.Fortress_request <= UnionTrritoryModel.GetAmountOfCompletedFortress() then
                self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_can")
            else
                info.State = 0
                self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "UI_LOCKED")
            end
        else
            self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_can")
        end
    elseif info.State == 2 then
        self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Building")
    elseif info.State == 3 then
        self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Complete")
    elseif info.State == 4 then
        self._textStatus.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Destroy")
    end
    if info.RebuildReason > 0 and info.State == 1 then
        -- 非第一次建造不要钱
        self._controller.selectedIndex = 3
    else
        self._controller.selectedIndex = info.State > 2 and 2 or info.State
    end
    --此处写死R4以上可以控制建筑
    self._btnApply.visible = Model.Player.AlliancePos >= ALLIANCEPOS.R4
    self._btnFree.visible = Model.Player.AlliancePos >= ALLIANCEPOS.R4
end

return ItemUnionTerritorialPlacement
