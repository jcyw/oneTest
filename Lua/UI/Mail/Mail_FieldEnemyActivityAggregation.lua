--author: 	Amu
--time:		2019-12-07 10:27:37

local GD = _G.GD
local Mail_FieldEnemyActivityAggregation = UIMgr:NewUI("Mail_FieldEnemyActivityAggregation")


function Mail_FieldEnemyActivityAggregation:OnInit()
    self._view = self.Controller.contentPane
    self._tilteText = self._view:GetChild("textName")

    self._authorText = self._view:GetChild("textMyTroop")

    self._bar = self._view:GetChild("itemDownBar")

    self._textLevel = self._view:GetChild("textLevel")
    self._textTime = self._view:GetChild("textTime")

    self._iconHead = self._view:GetChild("iconHead")

    self._playIcon = self._view:GetChild("iconMy")
    self._playName = self._view:GetChild("textNameMy")

    self._kill = self._view:GetChild("textEliminateNum")
    self._lost = self._view:GetChild("textLoseNum")
    self._injured = self._view:GetChild("textInjuredNum")
    self._BeastHp = self._view:GetChild("textRestHpNum")
    self._BeastLostHp = self._view:GetChild("textLostHpNum")

    self._btnDonate = self._view:GetChild("btnDonate")

    self._enemyIcon = self._view:GetChild("iconBuild")
    self._textMapName = self._view:GetChild("textMapName")
    self._textProgressBar = self._view:GetChild("textProgressBar")
    self._progressBar = self._view:GetChild("progressBar")
    self._Pos = self._view:GetChild("textCoordinate")

    self.itemList = {
        self._view:GetChild("itemProp1"),
        self._view:GetChild("itemProp2"),
        self._view:GetChild("itemProp3"),
    }

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MailKillActivityReport)
end

function Mail_FieldEnemyActivityAggregation:OnOpen(type, index, info, panel)
    self.type = type
    self.subType = info.SubCategory
    self._panel = panel
    self:_refreshData(info, index)
end

function Mail_FieldEnemyActivityAggregation:_refreshData(info, index)
    self.report = JSON.decode(info.Report)

    self.index = index
    self._info = info
    self._tilteText.text = info.Subject 

    self._authorText.text = info.Preview 
    
    -- local str = ""
    -- if self.report.Alliance and self.report.Alliance ~= "" then
    --     str = str.."["..self.report.Alliance.."]"
    -- end
    -- if self.report.Player then
    --     str = str..self.report.Player
    --     self._name.text = str
    -- end
    -- if self.report.Avatar then
    --     CommonModel.SetUserAvatar(self._iconHead, tonumber(self.report.Avatar))
    -- end

    self._textTime.text = TimeUtil:GetTimesAgo(info.CreatedAt)


    self._playIcon:SetAvatar(self.report)
    self._playName.text = self.report.Name

    local index = 1
    if self.report.Rewards == JSON.null then
        self.report.Rewards = {}
    end
    for _,v in ipairs(self.report.Rewards)do
        if self.itemList[index] then
            self.itemList[index].visible = true
            local amount = Tool.FormatAmountUnit(math.ceil(v.Amount))
            --self.itemList[index]:SetData(v)
            --self.itemList[index]:SetControl(1)
            --self.itemList[index]:SetAmount(Tool.FormatAmountUnit(math.ceil(v.Amount)))
            local icon,color,mid = GD.ItemAgent.GetShowRewardInfo(v)
            self.itemList[index]:SetShowData(icon,color,amount,nil,nil,mid)
            index = index + 1
        end
    end

    for i = index, #self.itemList do
        self.itemList[i].visible = false
    end

    self._kill.text = string.format("%.2f", (self.report.LostHp/self.report.TotalHp*100)).."%"
    self._lost.text = math.ceil(self.report.Lost)
    self._injured.text = math.ceil(self.report.Injured)


    local monsterInfo = ConfigMgr.GetItem("configMonsters", math.ceil(self.report.ConfId))
    self._enemyIcon.icon = UITool.GetIcon(monsterInfo.monster_avatar)
    self._textMapName.text = ConfigMgr.GetI18n("configI18nCommons", "MAP_MONTSTER_"..math.ceil(self.report.ConfId))
                    ..StringUtil.GetI18n(I18nType.Commmon, "Ui_Monsterlv", {number = monsterInfo.level})
    self._textProgressBar.text = string.format("%.2f", (self.report.RemainHp/self.report.TotalHp*100)).."%"
    self._progressBar.value = self.report.RemainHp/self.report.TotalHp*100

    local _BeastHp = 0
    local _BeastLostHp = 0
    for _,v in ipairs(self.report.Beasts)do
        _BeastHp = _BeastHp + v.Health
        _BeastLostHp = _BeastLostHp + v.LostHealth
    end

    self._BeastHp.text = math.ceil(_BeastHp)
    self._BeastLostHp.text =  math.ceil(_BeastLostHp)


    self._pos = {x = self.report.X, y = self.report.Y}
    self._Pos.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_PlayPlace", {x = math.ceil(self.report.X), y = math.ceil(self.report.Y)})

    self._bar:SetData(info, self)

    self.leftInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index - 1)
    self.rightInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index + 1)

    if self.leftInfo then
        self._view:GetChild("arrowL").visible = true
    else
        self._view:GetChild("arrowL").visible = false
    end

    if self.rightInfo then
        self._view:GetChild("arrowR").visible = true
    else
        self._view:GetChild("arrowR").visible = false
    end

end

function Mail_FieldEnemyActivityAggregation:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function Mail_FieldEnemyActivityAggregation:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        self:Close()
    end)


    self:AddListener(self._view:GetChild("arrowL").onClick,function()
        MailModel:ChangePanel(self, self.leftInfo, self.index-1)
    end)

    self:AddListener(self._view:GetChild("arrowR").onClick,function()
        MailModel:ChangePanel(self, self.rightInfo, self.index+1)
    end)

    self:AddListener(self._Pos.onClick,function()
        TurnModel.WorldPos(self._pos.x, self._pos.y)
    end)
end

function Mail_FieldEnemyActivityAggregation:Close()
    UIMgr:Close("Mail_FieldEnemyActivityAggregation")
end

return Mail_FieldEnemyActivityAggregation