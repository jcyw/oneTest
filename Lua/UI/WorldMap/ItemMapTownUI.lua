--[[
    author:{zhanzhang}
    time:2020-4-7 10:17:55
    function:{大地图主城item}
]]
local ItemMapTownUI = {}

function ItemMapTownUI:Init(index)
    -- local resInfo = ConfigMgr.GetItem("configResourcePaths", index)
    local resInfos = ConfigMgr.GetItem("configWorldMapUIs", index)
    self.resList = {}
    self.tranSprite = GameUtil.CreateObj(resInfos.nodeSprite[1]).transform
    self.tranSprite:SetParent(WorldMap.Instance():GetNodeSprite(), false)

    self.tranScrollMessage = GameUtil.CreateObj(resInfos.nodeMix[1]).transform
    self.tranScrollMessage:SetParent(WorldMap.Instance():GetNodeMix(), false)

    self.tranTextLevel = GameUtil.CreateObj(resInfos.nodeText[1]).transform
    self.tranTextLevel:SetParent(WorldMap.Instance().NodeWhite, false)

    self.tranTextName = GameUtil.CreateObj(resInfos.nodeText[2]).transform
    self.tranTextName:SetParent(WorldMap.Instance():GetNodeText(), false)

    table.insert(self.resList, self.tranSprite)
    table.insert(self.resList, self.tranScrollMessage)
    table.insert(self.resList, self.tranTextLevel)
    table.insert(self.resList, self.tranTextName)

    self.tranImgLevelBg = self.tranSprite:Find("imgBg/imgLevelBg").transform
    self.imgLevelBg = self.tranImgLevelBg:GetComponent("Image")
    self.tranImgNameBg = self.tranSprite:Find("imgBg").transform

    self.NameplateIcon = {
        [DRESSUP_NAMEPLATE_TYPE.Bg] = {
            Image = self.tranSprite:Find("imgBg"):GetComponent("Image"),
            RectTransform = self.tranSprite:Find("imgBg"):GetComponent("RectTransform")
        },
        [DRESSUP_NAMEPLATE_TYPE.Head] = {
            Image = self.tranSprite:Find("imgBg/imgMainCityIcon"):GetComponent("Image"),
            RectTransform = self.tranSprite:Find("imgBg/imgMainCityIcon"):GetComponent("RectTransform")
        },
    }

    self._rectNameBg = self.tranSprite:Find("imgBg"):GetComponent("RectTransform")
    self._textName = self.tranTextName:GetComponent("Text")
    self._rectName = self.tranTextName:GetComponent("RectTransform")
    self._nameContentFiler = self.tranTextName:GetComponent("ContentSizeFitter")
    self._levelContentFiler = self.tranTextLevel:GetComponent("ContentSizeFitter")
    self._textLevel = self.tranTextLevel:GetComponent("Text")

    self._imgScrollBg = self.tranScrollMessage:GetComponent("Image")

    self._textScroll = self.tranScrollMessage:Find("textScroll"):GetComponent("Text")
    self.tranScrollText = self._textScroll.transform

    self._rectTextScrollBg = self.tranScrollMessage:GetComponent("RectTransform")
    self._rectTextScroll = self._textScroll:GetComponent("RectTransform")

    self._scrollContentFiler = self._rectTextScroll:GetComponent("ContentSizeFitter")

    Event.AddListener(
        EventDefines.GameReStart,
        function()
            if self._tweenDesc then
                self._tweenDesc:Kill()
                self._tweenDesc = nil
            end
        end
    )
end

function ItemMapTownUI:ChangeStatus(index)
    local isShowDesc = index == 0

    self._textScroll.enabled = isShowDesc
    self._imgScrollBg.enabled = isShowDesc
end

--@areaId 坐标
function ItemMapTownUI:Refresh(areaId, position)
    self.tranSprite.position = position
    self.tranScrollMessage.position = self.tranImgNameBg.position + CVector3(0, -0.18, 0)
    self.tranTextName.position = self.tranImgNameBg.position -- position + CVector3(0, 0, 0)

    self.area = MapModel.GetArea(areaId)

    if self.area.Category == Global.MapTypeAllianceDomain or self.area.Category == Global.MapTypeAllianceStore then
        --联盟堡垒
        self.cache = self.area
        local posX, posY = MathUtil.GetCoordinate(self.area.Id)
        self:ChangeStatus(1)
        self.tranTextLevel.position = CVector3.one * 1000
        self.imgLevelBg.enabled = false

        local fortressConfig = ConfigMgr.GetItem("configAllianceFortresss", self.area.ConfId)
        local statusStr = MapModel.GetAllianceDomainStatus(self.area)
        if statusStr ~= "" then
            statusStr =  ConfigMgr.GetI18n(I18nType.Commmon, MapModel.GetAllianceDomainStatus(self.area))
        end
        local buildName = StringUtil.GetI18n(I18nType.Commmon, fortressConfig.building_name)
        if self.area.Params ~= "" then
            if statusStr ~= "" then
                self._textName.text = string.format("[%s]%s(%s)", self.area.Params, buildName, statusStr) --"[" .. self.area.Params .. "]" .. buildName .. "(" .. statusStr .. ")"
            else
                self._textName.text = string.format("[%s]%s", self.area.Params, buildName)
            end
            self:RefreshTextColor(self.area)
            self._nameContentFiler:SetLayoutHorizontal()
            local length = (self._rectName.rect.width + 60) > 200 and (self._rectName.rect.width + 60) or 200
            self._rectNameBg.sizeDelta = CVector2(length, self._rectNameBg.sizeDelta.y)
        else
            --用于处理老玩家数据
            Net.AllianceBuildings.BuildingMapInfo(
                self.area.AllianceId,
                self.area.ConfId,
                function(rsp)
                    self._textName.text = string.format("[%s]%s(%s)", rsp.AllianceName, buildName, statusStr)
                    self:RefreshTextColor(self.area)
                    self._nameContentFiler:SetLayoutHorizontal()
                    local length = (self._rectName.rect.width + 60) > 200 and (self._rectName.rect.width + 60) or 200
                    self._rectNameBg.sizeDelta = CVector2(length, self._rectNameBg.sizeDelta.y)
                end
            )
        end
    else
        --self.tranTextLevel.localEulerAngles = CVector3(-15, -50, 18)
        self.imgLevelBg.enabled = true
        --玩家城市
        self.UserId = self.area.OwnerId
        self.Info = MapModel.GetMapOwner(self.UserId)
        if not self.Info then
            return
        end
        --刷新信息
        self:RefreshUserInfo()
        self.tranTextLevel.position = self.tranImgLevelBg.position --+ CVector3(-0.03, 0, 0.02)
    end
end

function ItemMapTownUI:RefreshUserInfo()
    if self._tweenDesc then
        self._tweenDesc:Kill()
    end
    if self.descMove_func then
        Scheduler.UnSchedule(self.descMove_func)
    end
    local name = ""
    if self.Info.Alliance ~= "" then
        name = "[" .. self.Info.Alliance .. "]"
    end
    if self.Info.UserDesc == "" then
        self:ChangeStatus(1)
    else
        self:ChangeStatus(0)
        self._textScroll.text = self.Info.UserDesc
        self._scrollContentFiler:SetLayoutHorizontal()
        --self.tranScrollText.localPosition = CVector3.zero
        if self._rectTextScroll.rect.width > self._rectTextScrollBg.rect.width then
            local startVal = (self._rectTextScroll.rect.width - self._rectTextScrollBg.rect.width) / 2
            self.tranScrollText.localPosition = CVector3(startVal, 0, 0)
            -- * 0.004
            local val1 = -(self._rectTextScrollBg.rect.width + self._rectTextScroll.rect.width) / 2
            -- / 100
            --local val2 = (self._rectTextScroll.rect.width - self._rectTextScrollBg.rect.width) / 2 / 100
            local delayTime1 = self._rectTextScroll.rect.width / 30
            local delayTime2 = self._rectTextScrollBg.rect.width / 30
            local posY = self.tranScrollText.localPosition.y / 100
            local posZ = self.tranScrollText.localPosition.z / 100
            self.descMove_func = function()
                self._tweenDesc = DOTween.Sequence()
                self._tweenDesc:Append(
                    self.tranScrollText:DOLocalMoveX(val1, delayTime1):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
                        function()
                            self.tranScrollText.localPosition = CVector3(startVal, posY, posZ)
                        end
                    )
                ):Append(self.tranScrollText:DOLocalMoveX(startVal, delayTime2):SetEase(CS.DG.Tweening.Ease.Linear))
                self._tweenDesc:SetLoops(-1)
            end
            Scheduler.ScheduleOnce(self.descMove_func, delayTime2)
        else
            self.tranScrollText.localPosition = CVector3.zero
        end
    end
    if self.UserId == Model.Account.accountId then
        name = name .. StringUtil.GetI18n(I18nType.Commmon, "TEXT_MY_BASE")
    else
        name = name .. self.Info.Name
    end

    self._textName.text = name
    self._textLevel.text = self.Info.BaseLevel
    self._levelContentFiler:SetLayoutHorizontal()
    self._nameContentFiler:SetLayoutHorizontal()
    local length = (self._rectName.rect.width + 50) > 200 and (self._rectName.rect.width + 50) or 200
    self._rectNameBg.sizeDelta = CVector2(length, self._rectNameBg.sizeDelta.y)

    --判断颜色
    self:RefreshTextColor(self.area)

    self:RefreshDressUp()
end

--刷新装扮

local _setSprite = function(_type, obj, pkg, url)
    DynamicRes.GetTexture2D(pkg, url, function(tex)
        if Util.SpriteCreate then
            local sprite = Util.SpriteCreate(tex, Rect(0, 0, tex.width, tex.height), Vector2(0.5, 0.5))
            obj.Image.sprite = sprite
            if _type == DRESSUP_NAMEPLATE_TYPE.Head then
                obj.RectTransform.sizeDelta = Vector2(tex.width, tex.height)
            end
        end
    end)
end

function ItemMapTownUI:RefreshDressUp( )
    for _,v in ipairs(self.Info.DressUpUsing) do
        if v.DressType == DRESSUP_TYPE.Nameplate then
            local config = ConfigMgr.GetItem("configDressups", v.DressUpConId)
            if config.default == 0 then -- 默认
                self.NameplateIcon[DRESSUP_NAMEPLATE_TYPE.Head].Image.sprite = ResMgr.Instance:GetSprite("uiatlas/worldmapui", "icon_pt_mp_01")
                self.NameplateIcon[DRESSUP_NAMEPLATE_TYPE.Head].RectTransform.sizeDelta = Vector2(100, 40)
                self.NameplateIcon[DRESSUP_NAMEPLATE_TYPE.Bg].Image.sprite = ResMgr.Instance:GetSprite("uiatlas/worldmapui", "icon_pt_mp_02")
            else
                for _,v in pairs(config.urls)do
                    if self.NameplateIcon[v.id] then
                        _setSprite(v.id, self.NameplateIcon[v.id], v.pkg, v.url)
                    end
                end
            end

        end
    end
end

function ItemMapTownUI:RefreshTextColor(areaInfo)
    local status = MapModel.CheckOwnerType(areaInfo)
    if status >= 10 then
        status = math.floor(status / 10)
    end

    if status == 1 then
        self._textName.color = Color(101/255,190/255,79/255)
    elseif status == 2 then
        self._textName.color = Color(104/255,192/255,250/255)
    else
        self._textName.color = Color(213/255,224/255,224/255)
    end
end

function ItemMapTownUI:OnClose()
    local tempVec3 = CVector3.one * 1000
    for i = 1, #self.resList do
        self.resList[i].transform.position = tempVec3
    end

    if self._tweenDesc then
        self._tweenDesc:Kill()
        self._tweenDesc = nil
    end
end

return ItemMapTownUI
