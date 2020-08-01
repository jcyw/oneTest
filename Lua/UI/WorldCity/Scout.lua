local Scout = UIMgr:NewUI("Scout")
local MapModel = import("Model/MapModel")
local MarchSpeed = 0
local PointPos = 0
local ArmiesModel = import("Model/ArmiesModel")
local MarchAnimModel = import("Model/MarchAnimModel")

function Scout:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._iconHero = view:GetChild("iconHero")
    self._titleName = view:GetChild("titleName")
    self._textName = view:GetChild("textName")
    self._numberCoordinate = view:GetChild("numberCoordinate")
    self._resIcon = view:GetChild("icon")
    self._textConsume = view:GetChild("textConsume")
    self._textRes = view:GetChild("textConsumeNumber")
    self._textUsetime = view:GetChild("textUsetime")
    self._textTime = view:GetChild("textUsetimeNumber")
    self._btnScount = view:GetChild("btnScout")

    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Investigate")
    self._textConsume.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DETEC_COST")
    self._textUsetime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DETECT_TIME")

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("Scout")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("Scout")
        end
    )
    self:AddListener(self._btnScount.onClick,
        function()
            self:OnBeginScout()

            UIMgr:Close("Scout")
        end
    )
end

function Scout:OnOpen(posNum)
    PointPos = posNum
    local town = MapModel.GetArea(posNum)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local buildName = ""
    local level = 1
    if town.OwnerId ~= "" then
        local OwerInfo = MapModel.GetMapOwner(town.OwnerId)
        -- --指挥官的名字
        local name = ""
        if OwerInfo.Alliance ~= "" then
            --侦查玩家基地
            name = "[color=#FFCC66][" .. OwerInfo.Alliance .. "][/color]"
        end
        buildName = name .. OwerInfo.Name
        level = OwerInfo.BaseLevel
        -- CommonModel.SetUserAvatar(self._iconHero, OwerInfo.Avatar, OwerInfo.UserId)
        self._iconHero:SetAvatar(OwerInfo, nil, OwerInfo.UserId)
    elseif town.Category == Global.MapTypeFort or town.Category == Global.MapTypeThrone then
        local throneBuild = ConfigMgr.GetItem("configWarZoneBuildings", town.Id)
        buildName = StringUtil.GetI18n(I18nType.Commmon, throneBuild.name)
        -- self._iconHero.icon = UITool.GetIcon(throneBuild.image)
        self._iconHero:SetAvatar(throneBuild.image, "custom")
        level = 30
    else
        buildName = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBuild_" .. town.ConfId)
        local unionBuild = ConfigMgr.GetItem("configAllianceFortresss", town.ConfId)
        -- self._iconHero.icon = UITool.GetIcon(unionBuild.build_image)
        self._iconHero:SetAvatar(unionBuild.build_image, "custom")
        level = 30
    end


    self._textName.text = buildName
    self._numberCoordinate.text = StringUtil.GetCoordinataWithLetter(posX, posY)

    local buff=BuffModel.GetInvestigationConsumption()
    self._textRes.text = math.floor((Global.SpyResNeed + level * level)*buff) 
    self._resIcon.icon = UITool.GetIcon({"Common","icon_food_0"})

    local distance = MathUtil.GetDistance(Model.Player.X - posX, Model.Player.Y - posY) 
    local blackZoneDistance = MapModel.GetDistanceCrossBlackZone(Model.Player.X, Model.Player.Y, posX, posY)
    local temp = MapModel.GetDistanceCrossBlackZone(611,628,574,598)

    --计算出征时间
    local buffValue=BuffModel.GetInvestigationSpeed()
    local minSpeed = Global.SpyMarchSpeed * buffValue
    local blackZoneTime = 0
    local blackZoneSpeed = minSpeed * Global.BlackGroundSpeed
    if blackZoneSpeed > 0 then
        blackZoneTime = math.floor(Global.MarchSpeedParamK1 * (blackZoneDistance ^ Global.MarchSpeedParamK2) / blackZoneSpeed)
    end
    if minSpeed > 0 then
        local normalDis = distance - blackZoneDistance
        self.expeditionTime = math.floor(Global.MarchSpeedParamK1 * (normalDis ^ Global.MarchSpeedParamK2) / minSpeed) + blackZoneTime
        self.expeditionTime = math.floor(self.expeditionTime * Global.SpyDurationRatio)
    else
        self.expeditionTime = 0
    end
    self._textTime.text = TimeUtil.SecondToHMS(self.expeditionTime)
    -- local minSpeed = Global.SpyMarchSpeed
    -- local blackZoneTime = 0
    -- local blackZoneSpeed = minSpeed * Global.BlackGroundSpeed
    -- if blackZoneSpeed > 0 then
    --     blackZoneTime = math.floor(Global.MarchSpeedParamK1 * (blackZoneDistance ^ Global.MarchSpeedParamK2) / blackZoneSpeed)
    -- end
    -- if minSpeed > 0 then
    --     local normalDis = distance - blackZoneDistance
    --     self.expeditionTime = math.floor(Global.MarchSpeedParamK1 * (normalDis ^ Global.MarchSpeedParamK2) / minSpeed) + blackZoneTime
    --     self.expeditionTime = math.floor(self.expeditionTime * Global.SpyDurationRatio)
    -- else
    --     self.expeditionTime = 0
    -- end
    -- self._textTime.text = TimeUtil.SecondToHMS(self.expeditionTime)
end

function Scout:OnBeginScout()
    local posX, posY = MathUtil.GetCoordinate(PointPos)
    Net.Missions.Spy(
        posX,
        posY,
        function(val)
            -- MarchAnimModel.SetLookAt(val.Event.Uuid)
            Event.Broadcast(EventDefines.UIOnMissionInfo, val.Event)
        end
    )
end

return Scout
