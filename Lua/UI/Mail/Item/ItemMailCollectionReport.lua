-- author:{Amu}
-- _time:2019-05-28 10:26:22
local GD = _G.GD
local ItemMailCollectionReport = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailCollectionReport", ItemMailCollectionReport)

function ItemMailCollectionReport:ctor()
    self._mineName = self:GetChild("textName")
    self._pos = self:GetChild("textCoordinate")
    self._time = self:GetChild("textTime")

    -- self._box = self:GetChild("bgBox1")
    self._itemIcon = self:GetChild("State1"):GetChild("icon")
    self._itemName = self:GetChild("State1"):GetChild("propName")
    self._itemNum = self:GetChild("State1"):GetChild("propNumeber")

    self.tempList = {}
    self.tempList[1] = self:GetChild("State1")

    -- self._boxH = self._box.height
    self._boxH = self.tempList[1].height
    self._H = self.height

    self:InitEvent()
end

function ItemMailCollectionReport:InitEvent(  )
    self:AddListener(self._pos.onClick,function()
        TurnModel.WorldPos(self.pos.x, self.pos.y)
    end)
end

function ItemMailCollectionReport:SetData(index, _info)
    local report = JSON.decode(_info.Report)
    self.pos = {x = report.X, y = report.Y}
    local _z = math.modf(report.ConfId/1000)
    local _y = math.fmod(report.ConfId, 1000)
    local data = {
        level = math.ceil(_y)
    }
    self._mineName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_RESOURCETYPE_".._z, data)

    self._pos.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_PlayPlace", {x = math.ceil(report.X), y = math.ceil(report.Y)})
    self._time.text = TimeUtil:StampTimeToYMDHMS(_info.CreatedAt)

    if report.Rewards == JSON.null then
        return
    end

    self:SetSize(self.width, self._H + self._boxH*(#report.Rewards - 1))
    -- self._box:SetSize(self._box.width, self._boxH*#report.Rewards)

    local index = 1
    for i,v in ipairs(report.Rewards) do
        if not self.tempList[i] then
            local temp = UIMgr:CreateObject("Mail", "itemMailCollectionReportState1")
            self:AddChild(temp)
            self.tempList[i] = temp
        end
        self.tempList[i].y = self:GetChild("State1").y + self.tempList[i].height*(i-1)
        self.tempList[i].visible = true
        local icon = nil
        local color = 0
        local mid = GD.ItemAgent.GetItemInnerContent(v.ConfId)
        local item = self.tempList[i]:GetChild("_item")
        if v.Category == REWARD_TYPE.Res then
            self.tempList[i]:GetChild("propName").text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(v.ConfId))
            local resConfigInfo = ConfigMgr.GetItem("configResourcess", math.ceil(v.ConfId))
            icon = GD.ResAgent.GetIconInfo(v.ConfId)
            color = resConfigInfo.color
        elseif v.Category == REWARD_TYPE.Item then
            icon = ConfigMgr.GetItem("configItems", math.ceil(v.ConfId)).icon
            self.tempList[i]:GetChild("propName").text =  GD.ItemAgent.GetItemNameByConfId(math.ceil(v.ConfId))
            local itemConfigInfo = ConfigMgr.GetItem("configItems", math.ceil(v.ConfId))
            color = itemConfigInfo.color
        end
        item:SetShowData(icon,color,nil,nil,mid)
        self.tempList[i]:GetChild("propNumeber").text = "+"..math.ceil(v.Amount)
        index = index + 1
    end

    for i = index, #self.tempList do
        self.tempList[i].visible = false
    end
end

return ItemMailCollectionReport