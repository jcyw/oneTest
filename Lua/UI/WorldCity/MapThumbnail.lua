--[[
    author:{zhanzhang}
    time:2019-06-10 19:53:13
    function:{缩略地图}
]]
local MapThumbnail = UIMgr:NewUI("MapThumbnail")
local MapModel = import("Model/MapModel")
local WorldMap = import("UI/WorldMap/WorldMap")
local PlayerDataEnum = import("Enum/PlayerDataEnum")

local mapInfo
local iconCache = {}
local tipList = {}
--地图类型枚举
local MapTipType = {
    myBase = 1,
    allianceLeader = 2,
    allianceMember = 3,
    collect = 4,
    allianceTip = 5,
    allianceMark = 6
}

function MapThumbnail:OnInit()
    local view = self.Controller.contentPane
    self._btnBack = view:GetChild("btnReplay")
    self._btnMap = view:GetChild("btnMap")
    self._btnKing = view:GetChild("btnKing")
    -- self._btnDstribution = view:GetChild("btnDstribution")
    self._btnHelp = view:GetChild("btnHelp")
    self._btnCity = view:GetChild("btnCity")

    --资源带动画
    self._animResourceBelt = view:GetChild("itemResourceBelt"):GetTransition("ResourceBelt")
    self._animBtnShrinkRetract = view:GetTransition("btnShrinkRetract")
    self._animBtnShrinkOpen = view:GetTransition("btnShrinkOpen")
    self._animScale = view:GetTransition("Scale")

    self._tagBox = view:GetChild("itemTagBox").controller
    local tagBox = view:GetChild("itemTagBox")
    self._checkBoxList = {}

    table.insert(self._checkBoxList, tagBox:GetChild("checkCity"))
    table.insert(self._checkBoxList, tagBox:GetChild("checkPresident"))
    table.insert(self._checkBoxList, tagBox:GetChild("checkMember"))
    table.insert(self._checkBoxList, tagBox:GetChild("checkCollection"))
    table.insert(self._checkBoxList, tagBox:GetChild("checkStronghold"))
    table.insert(self._checkBoxList, tagBox:GetChild("checkSign"))

    self._map = view:GetChild("itemResourceBelt")
    self._map:GetChild("map").icon = UITool.GetIcon({"world", "world_pic_map_01"})
    self._throneIcon = self._map:GetChild("icon")
    self._mapLoader = self._map:GetChild("mapLoader")
    self._ResMapController = self._map:GetController("c1")
    self._CityBtnController = view:GetController("city")
    self._HelpBtnController = view:GetController("help")

    self._groupCitys = {}
    self._itemCitys = {}
    self._clickAnim = self._map:GetChild("clickAnim")
    for i = 1, 4 do
        self._groupCitys[i] = self._map:GetChild("group" .. i)
        self._groupCitys[i].visible = false
        self._itemCitys[i] = self._map:GetChild("itemCity" .. i)
    end

    -- self._startPoint = self._map:GetChild("startPoint")
    self.isShowBtnList = true
    self.touchPanel = self._map.scrollPane
    self.graphList = {}
    self:OnRegister()
end

function MapThumbnail:OnRegister()
    self:AddListener(self._btnMap.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
    self:AddListener(self._btnKing.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
    self:AddListener(self._btnBack.onClick,
        function()
            UIMgr:Close("MapThumbnail")
        end
    )
    self:AddListener(self._mapLoader.onClick,
        function(val)
            if not self.isClicking then
                local pointX, pointY = self:GoMapPos(val.inputEvent.x, val.inputEvent.y)
                if pointX > (1200 - mapOffset) or pointX < mapOffset or pointY > (1200 - mapOffset) or pointY < mapOffset then
                    return
                end
                self:GotoPoint(pointX, pointY)
            end
        end
    )

    self:AddListener(self._btnHandle.onClick,
        function()
            if self.isAniming then
                return
            end
            self.isAniming = true
            if (self.isShowBtnList) then
                self._animBtnShrinkRetract:Play(
                    function()
                        self.isShowBtnList = false
                        self.isAniming = false
                    end
                )
            else
                self._animBtnShrinkOpen:Play(
                    function()
                        self.isShowBtnList = true
                        self.isAniming = false
                    end
                )
            end
            -- self._animBtnShrinkOpen
        end
    )
    self:AddListener(self._btnCity.onClick,
        function()
            if self._ResMapController.selectedIndex == 1 then
                self._ResMapController.selectedIndex = 0
                self._animResourceBelt:Play()
            else
                self._ResMapController.selectedIndex = 1
            end
        end
    )

    for i = 1, #self._checkBoxList do
        self:AddListener(self._checkBoxList[i].onChanged,
            function()
                self:ChangeTipStauts(i, not self._checkBoxList[i].selected)
            end
        )
    end

    self.RefreshTime = function()
        self:RefreshProjectTime()
    end
    self.isAniming = false
    self.ResoureList = {
        --我的主城
        "world_sign_myvilla_01",
        --会长标记
        "world_sign_master_01",
        --成员标记
        "world_sign_member_01",
        --收藏标记
        "world_sign_favorite_01",
        --联盟堡垒
        "Building_402000",
        --联盟标记
        "world_sign_union_01"
    }
    -- for i = 1, #self.ResoureList do
    NodePool.Init(NodePool.KeyType.MapThumbnailTip, "WorldCity", "mapTip")
    -- end
    self.rectHeight = self._mapLoader.height / 2
    self.rectWidth = self._mapLoader.width / 2
    self:AddListener(self._throneIcon.onClick,
        function()
            self:GotoPoint(600, 600)
        end
    )
    Event.AddListener(
        EventDefines.KingInfoChange,
        function()
            self:RefreshMapInfo(self.data)
        end
    )
end

function MapThumbnail:OnOpen(data, posNum)
    self.isClicking = false
    SdkModel.TrackBreakPoint(10075) --打点
    self.data = data
    self:RefreshMapInfo(data)
    self:RecycleTip()
    local list = {}
    table.insert(list, {data.BasePos})
    table.insert(list, {data.AlliancePresidentPos})
    table.insert(list, data.AlliesPos)
    table.insert(list, data.FavoritePos)
    table.insert(list, data.AllianceFortressPos)
    table.insert(list, data.AllianceMarkPos)
    self.showSelectList = PlayerDataModel:GetData(PlayerDataEnum.MapThumbnailSelect)
    if not self.showSelectList then
        self.showSelectList = {true, true, true, true, true, true}
    end
    for i = 1, #self.showSelectList do
        self._checkBoxList[i].selected = not self.showSelectList[i]
    end

    self._ResMapController.selectedIndex = 1
    self._CityBtnController.selectedIndex = 0
    self._HelpBtnController.selectedIndex = 0

    self:OnShowMapTip(list)
    local basePosX, basePosY = self:GetTipPos(posNum)
    self:ShowClickTip(basePosX, basePosY)
    self.screenRatioX, self.screenRatioY = MathUtil.ScreenRatio(Screen.width / 2, Screen.height / 2)
    self.touchPanel:SetPosX(basePosX - self.screenRatioX, false)
    self.touchPanel:SetPosY(basePosY - self.screenRatioY, false)
    self._animScale:PlayReverse()
end

function MapThumbnail:RefreshMapInfo(data)
    self:UnSchedule(self.RefreshTime)
    --服务器姓名


    self._textTopName.text = StringUtil.GetI18n(I18nType.Commmon, "THUMBNAIL_SERVER_NAME", {server_id = data.ServerName})
    --市长姓名     -- THUMBNAIL_COMMANDER
    self._textPlayerName.text = StringUtil.GetI18n(I18nType.Commmon, "THUMBNAIL_COMMANDER") .. data.King
    -- 城市国旗 没有国旗的时候默认为联合国国旗
    local flagName = string.len(data.Flag)>0 and data.Flag or 241
    local flagCfg = ConfigMgr.GetItem("configFlags", flagName)
    self._iconCityFlag.icon = UITool.GetIcon(flagCfg.icon)

    --战区状态
    local warInfo = _G.RoyalModel.GetKingWarInfo()
    local status, _ = _G.RoyalModel.GetRoyalStatus()
    if status == _G.RoyalModel.RoyalStatusType.Ready or status == _G.RoyalModel.RoyalStatusType.Vita then
        self._textPlayerName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Free_Position")
    elseif status == _G.RoyalModel.RoyalStatusType.Ulichukua then
        local text = string.len(warInfo.KingInfo.AllianceShortName) > 0
        and string.format("(%s)%s", warInfo.KingInfo.AllianceShortName,warInfo.KingInfo.Name)
        or warInfo.KingInfo.Name
        self._textPlayerName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_CurrentOccupier", {player_name = text})
    else
        local text = string.len(warInfo.KingInfo.AllianceShortName) > 0
        and string.format("[%s]%s", warInfo.KingInfo.AllianceShortName,warInfo.KingInfo.Name)
        or warInfo.KingInfo.Name
        self._textPlayerName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_KingName", {player_name = text})
    end
    self:Schedule(self.RefreshTime, 1, true)
end

function MapThumbnail:OnShowMapTip(list)
    for i = #list, 1, -1 do
        if (not tipList[i]) then
            tipList[i] = {}
        end
        for j = 1, #list[i] do
            if list[i][j] ~= 0 then
                local mapTip = NodePool.Get(NodePool.KeyType.MapThumbnailTip)
                mapTip:Init(
                    self.ResoureList[i],
                    function()
                        self:GotoPoint(MathUtil.GetCoordinate(list[i][j]))
                    end
                )
                -- local icon = self:GetMapTip(self.ResoureList[i])
                --当图片为联盟堡垒时特殊处理
                if i == 5 then
                -- icon.autoSize = false
                -- icon.shrinkOnly = true
                -- icon.width = 70
                -- icon.height = 49
                end
                self._map:AddChild(mapTip)

                local posX, posY = self:GetTipPos(list[i][j])
                mapTip.x = posX - 15
                mapTip.y = posY - mapTip.height / 2
                table.insert(tipList[i], mapTip)

            -- if  then
            end
        end
    end
    for i = 1, #self.showSelectList do
        for j = 1, #tipList[i] do
            tipList[i][j].visible = self.showSelectList[i]
        end
    end

    -- mapTip.visible = self.showSelectList[#list - i]
end

--修改图标状态
function MapThumbnail:ChangeTipStauts(mType, isShow)
    if (tipList[mType]) then
        for i = 1, #tipList[mType] do
            tipList[mType][i].visible = isShow
        end
    end
    self.showSelectList[mType] = isShow
    PlayerDataModel:SetData(PlayerDataEnum.MapThumbnailSelect, self.showSelectList)
end

function MapThumbnail:OnHideMapTip()
    for k, v in ipairs(tipList) do
        for i = 0, #v do
            v[i].visible = false
        end
    end
end

function MapThumbnail:OnClose()
    self:UnSchedule(refreshTime)
end

function MapThumbnail:RefreshProjectTime()
    local warInfo = _G.RoyalModel.GetKingWarInfo()
    local i18nkey = not warInfo.InWar and "THUMBNAIL_PROTECT_STATUS" or "THUMBNAIL_BATTLE_STATUS"
    local lasttime = warInfo.NextTime - _G.Tool.Time()
    if lasttime>=0 then
        self._textProtectTime.text = StringUtil.GetI18n(I18nType.Commmon, i18nkey) .. _G.TimeUtil.SecondToDHMS(lasttime)
    end
end

--实际坐标转为图上位置
function MapThumbnail:GetTipPos(posNum)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local newOff = 600 - mapOffset
    posX = (posX - mapOffset)
    posY = (posY - mapOffset)
    local w = self.rectWidth / newOff
    local h = self.rectHeight / newOff
    local ScreenX = ((posY - posX) * w / 2 + self.rectWidth) + self._mapLoader.x
    local ScreenY = ((posX + posY) * h / 2) + self._mapLoader.y
    return ScreenX, ScreenY
end

function MapThumbnail:GoMapPos(touchPosX, touchPosY)
    --物理屏幕坐标转换为逻辑屏幕坐标
    local logicScreenPos = GRoot.inst:GlobalToLocal(CS.UnityEngine.Vector2(touchPosX, touchPosY))
    --UI元件坐标与逻辑屏幕坐标之间的转换
    local uiPos = self._mapLoader:RootToLocal(logicScreenPos)

    local w = self.rectWidth / (600 - mapOffset)
    local h = self.rectHeight / (600 - mapOffset)
    local xlength = math.floor((-uiPos.x + self.rectWidth) / w + (uiPos.y) / h) + mapOffset
    local ylength = math.floor((uiPos.x - self.rectWidth) / w + (uiPos.y) / h) + mapOffset
    if xlength < (1200 - mapOffset) and xlength > mapOffset and ylength < (1200 - mapOffset) and ylength > mapOffset then
        self:ShowClickTip(uiPos.x, uiPos.y)
        self.touchPanel:SetPosX(uiPos.x - self.screenRatioX, true)
        self.touchPanel:SetPosY(uiPos.y - self.screenRatioY, true)
    end

    return xlength, ylength
end

function MapThumbnail:ShowClickTip(tipPosX, tipPosY)
    self._clickAnim.x = tipPosX
    self._clickAnim.y = tipPosY
end

function MapThumbnail:RecycleTip()
    if not tipList then
        tipList = {}
        return
    end

    for i = 1, #tipList do
        for j = 1, #tipList[i] do
            NodePool.Set(NodePool.KeyType.MapThumbnailTip, tipList[i][j])
            -- self:SetMapTip(tipList[i][j])
        end
    end
    tipList = {}
end

function MapThumbnail:GotoPoint(pointX, pointY)
    --防止连续点击
    if self.isClicking then
        return
    end

    self.isClicking = true
    local basePosX, basePosY = self:GetTipPos(MathUtil.GetPosNum(pointX, pointY))
    self:ShowClickTip(basePosX, basePosY)
    self.touchPanel:SetPosX(basePosX - self.screenRatioX, true)
    self.touchPanel:SetPosY(basePosY - self.screenRatioY, true)
    self._animScale:Play(
        function()
            --进入跳转地图流程
            UIMgr:ClosePopAndTopPanel()
            -- Event.Broadcast(EventDefines.OpenWorldMap, pointX, pointY)
            -- WorldMap.AddEventAfterMap(
            --     function()
            WorldMap.Instance():MoveToPoint(pointX, pointY, false)
        end
        -- )
        -- end
    )
end

return MapThumbnail
