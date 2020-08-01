--[[
    Author: songzeming and zhanzhang
    Function: 建筑功能列表 图标按钮
]]
local ItemDetailTitle = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemBuildCompleteTag", ItemDetailTitle)

-- local MissionEventModel = import("Model/MissionEventModel")
local WorldMap = import("UI/WorldMap/WorldMap")

local CONTROLLER = {
    WorldRes = 0,
    WorldOther = 1,
    MarchSelf = 2,
    MarchOther = 3,
    UnionBuilding = 4
}
local FavoriteModel = import("Model/FavoriteModel")
function ItemDetailTitle:ctor()
    self._title = self:GetChild("textName")
    self._level = self:GetChild("textLevel")

    self._titleWorld = self:GetChild("textWorldName")
    self._posWorld = self:GetChild("textCoordinate")
    --需要居中的坐标
    self._posWorld2 = self:GetChild("textCoordinate2")
    self._bulidHP = self:GetChild("textBulidingHP")

    self._controller = self:GetController("Controller")
    self._btnCollection = self:GetChild("btnCollection")
    self._btnShare = self:GetChild("btnShare")
    self._resIcon = self:GetChild("resIcon")
    self:AddListener(self.onClick,
        function()
            if self.callback then
                self.callback()
            end
        end
    )
    self:AddListener(self._btnShare.onClick,
        function()
            local info = MapModel.GetArea(self.posNum)
            GameShareModel.ShareCoordinateToUnion(Global.CoordinateShareAlliance, Global.CoordinateShareNormal, 0, self._xPos, self._yPos)
        end
    )

    self:AddListener(self._btnCollection.onClick,
        function()
            if (FavoriteModel.IsFavorite(self.posNum)) then
                UIMgr:Open("Favorites")
            else
                local area = MapModel.GetArea(self.posNum)
                if area and area.Category == Global.MapTypeAllianceDomain then
                    local posX, posY = MathUtil.GetCoordinate(self.posNum)
                    Net.AllianceBuildings.FortressInfo(
                        posX,
                        posY,
                        function(rsp)
                            UIMgr:Open("AddFavorite", self.posNum, rsp)
                        end
                    )
                else
                    UIMgr:Open("AddFavorite", self.posNum)
                end
            end
        end
    )

    self:AddListener(self._btnCoordinate.onClick,
        function()
            if self.showX then
                Event.Broadcast(EventDefines.UICloseMapDetail)
                local clickPos = function()
                    WorldMap.Instance():ChooseLogicPos(MathUtil.GetPosNum(self.showX, self.showY))
                end
                WorldMap.AddEventAfterMap(clickPos)
                WorldMap.Instance():GotoPoint(self.showX, self.showY)

            end
        end
    )

    self.RefreshMineFunc = function()
        self:RefreshMineInfo()
    end

    self:AddEvent(
        EventDefines.UIOnCloseItemDetail,
        function()
            self:UnSchedule(self.RefreshMineFunc)
            if self.RefreshHPFunc then
                self:UnSchedule(self.RefreshHPFunc)
                self.RefreshHPFunc = nil
            end
        end
    )
end

--世界地图打开功能列表
function ItemDetailTitle:WorldInit(posNum)
    self:UnSchedule(self.RefreshMineFunc)
    self.posNum = posNum
    self._xPos, self._yPos = MathUtil.GetCoordinate(posNum)
    self.info = MapModel.GetArea(posNum)
    if self.info then
        self.config = ConfigMgr.GetItem("configAllianceFortresss", self.info.ConfId)
    else
        self.config = nil
    end
    if self.info and self.info.Category == Global.MapTypeMine then
        self._controller.selectedIndex = CONTROLLER.WorldRes
        self._titleWorld.text = self.info.Value
        local mineInfo = ConfigMgr.GetItem("configMines", self.info.ConfId)
        local icon = ConfigMgr.GetItem("configResourcess", mineInfo.category).img
        self._resIcon.icon = UITool.GetIcon(icon)
        -- self._resIcon.visible = true
        if self.info.OwnerId ~= "" then
            local miner = MapModel.GetMineOwner(self.posNum)
            self:Schedule(self.RefreshMineFunc, 1, true)
        end
    elseif self.info and (self.info.Category == Global.MapTypeAllianceDomain 
                    or self.info.Category == Global.MapTypeAllianceStore 
                    or self.info.Category == Global.MapTypeAllianceDefenceTower) then
                        self._posWorld2.text = StringUtil.GetCoordinataWithLetter(self._xPos, self._yPos)
        self._controller.selectedIndex = CONTROLLER.UnionBuilding
        self._titleWorld.text = ""
        --设置联盟建筑的建筑值
        if self.info.Category == Global.MapTypeAllianceStore then
            Net.AllianceBuildings.FortressInfo(
                self._xPos,
                self._yPos,
                function(rsp)
                    -- rsp 结构为 AllianceBuilding
                    if rsp.Fail then
                        return
                    end
                    self.unionBulidingInfo = rsp.Building
                    self:SetBulidHPText()
                end
            )
        elseif self.info.Category == Global.MapTypeAllianceDomain then
            Net.AllianceBuildings.FortressInfo(
                self._xPos,
                self._yPos,
                function(rsp)
                    -- rsp 结构为 AllianceBuilding
                    if rsp.Fail then
                        return
                    end
                    self.unionBulidingInfo = rsp.Building
                    self:SetBulidHPText()
                end
            )
        end
    else
        self._posWorld2.text = StringUtil.GetCoordinataWithLetter(self._xPos, self._yPos)
        self._controller.selectedIndex = CONTROLLER.WorldOther
        self._titleWorld.text = ""
    end

    self._posWorld.text = StringUtil.GetCoordinataWithLetter(self._xPos, self._yPos)
end

function ItemDetailTitle:SetBulidHPText()
    self._bulidHP.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")..math.floor(self.unionBulidingInfo.ArchiValue)
    if self.unionBulidingInfo.State == 4 then --破坏中
        self.curBulidHP = self.unionBulidingInfo.ArchiValue - (Tool.Time() - self.unionBulidingInfo.ChangeTime) * self.unionBulidingInfo.OperationSpeedPerSec
    elseif self.unionBulidingInfo.State == 2 then --修建中
        self.curBulidHP = self.unionBulidingInfo.ArchiValue + (Tool.Time() - self.unionBulidingInfo.ChangeTime) * self.unionBulidingInfo.OperationSpeedPerSec
    else
        self.curBulidHP = self.unionBulidingInfo.ArchiValue
    end
    if self.RefreshHPFunc then
        self:UnSchedule(self.RefreshHPFunc)
        self.RefreshHPFunc = nil
    end
    self.RefreshHPFunc = function()
        if self.unionBulidingInfo.State == 4 then --破坏中
            self.curBulidHP = self.curBulidHP - self.unionBulidingInfo.OperationSpeedPerSec * 3
        elseif self.unionBulidingInfo.State == 2 then --修建中
            self.curBulidHP = self.curBulidHP + self.unionBulidingInfo.OperationSpeedPerSec * 3
        end
        if not self.config or self.curBulidHP <=0 or self.curBulidHP >= self.config.build_hp then
            self:UnSchedule(self.RefreshHPFunc)
            self.RefreshHPFunc = nil
            return
        end
        self._bulidHP.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")..math.floor(self.curBulidHP)
    end
    self:Schedule(self.RefreshHPFunc, 3)
end

function ItemDetailTitle:MarchUnitInit(mission)
    if mission.UserId == Model.Account.accountId then
        self._controller.selectedIndex = CONTROLLER.MarchSelf
        self.showX = mission.IsReturn and mission.StartX or mission.StopX
        self.showY = mission.IsReturn and mission.StartY or mission.StopY
        self._btnCoordinate.text = "To: " .. StringUtil.GetCoordinataWithLetter(self.showX, self.showY)
    else
        self._controller.selectedIndex = CONTROLLER.MarchOther
        self:releaseSchedulerHandle()
        self.timerHandle = function()
            local remainTime = mission.FinishAt - Tool.Time()
            if remainTime <= 0 then
                self:releaseSchedulerHandle()
                return
            end
            -- local text = TimeUtil.SecondToHMS(remainTime)
            -- print(text)
            self._textTimer.text = TimeUtil.SecondToHMS(remainTime)
        end
        self:Schedule(self.timerHandle, 1, true)
    end
    local userInfo = MapModel.GetMapOwner(mission.OwnerId) or {}

    if mission.IsReturn then
        self._textMission.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_RETURN_BUTTON")
    else
        local queueId = mission.Category * 100 + 10000 --+ mission.Status
        local queueConfig = ConfigMgr.GetItem("configMapQueues", queueId)
        self._textMission.text = StringUtil.GetI18n(I18nType.Commmon, queueConfig.statusText2)
    end
    if mission.UserId == Model.Account.accountId then
        self._textUser.text = Model.Player.Name
    else
        self._textUser.text = userInfo.Name
    end
    if mission.Category == Global.MissionAISiege then
        self._textUser.text = mission.TargetName
    end
end

function ItemDetailTitle:releaseSchedulerHandle()
    if self.timerHandle then
        self:UnSchedule(self.timerHandle)
        self.timerHandle = nil
    end
end

function ItemDetailTitle:RefreshMineInfo()
    if not self.info then
        self:UnSchedule(self.RefreshMineFunc)
        return
    end

    local num = self.info.Value - MapModel.CalCollection(self.posNum)
    if num <= 0 then
        self._titleWorld.text = 0
        Event.Broadcast(EventDefines.UIOffAnim)
        self:UnSchedule(self.RefreshMineFunc)
        return
    end
    self._titleWorld.text = num
end

function ItemDetailTitle:OnClose()

end

return ItemDetailTitle
