-- author:{Amu}
-- time:2019-05-29 14:54:07
local GD = _G.GD
local JumpMap = import("Model/JumpMap")
local BuildModel = import("Model/BuildModel")

local ItemMailUnionAll = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailUnionAll", ItemMailUnionAll)

function ItemMailUnionAll:ctor()

    self._bg = self:GetChild("bg")
    self._box = self:GetChild("item")
    self.tempList = {}
    self.techItemList = {}
    self.tempList[1] = self._box

    self._item = self._box:GetChild("itemProp")
    self._itemNum_Name = self._box:GetChild("title")
    self._iitemNum = self._box:GetChild("text")

    self.btnGet = self:GetChild("btnReceive")
    self.btnHaveGet = self:GetChild("btnGreen")
    self.btnGoTo = self:GetChild("btnView")
    self.btnGet.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Get")
    self.btnHaveGet.text = ConfigMgr.GetI18n("configI18nCommons", "ShootingReward_39")
    self.btnGoTo.text = ConfigMgr.GetI18n("configI18nCommons", "FUND_VIEW_BUTTON")
    
    self._ctrView = self:GetController("c1")

    self.boxX = self._box.x
    self.boxY = self._box.y

    self._height = self.height
    self._bgH = self._bg.height

    self:InitEvent()
end

function ItemMailUnionAll:InitEvent(  )
    self:AddListener(self.btnGet.onClick,function()
        Net.Mails.Claim({self.info.Uuid},function(rsp)
            if rsp.NeedAppUpdate then
                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "Ui_UpdateWhole_Tips"),
                    -- sureBtnText = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
                    sureCallback = function()
                        Sdk.OpenBrowser("https://play.google.com/store/apps/details?id=com.global.neocrisis2")
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                if rsp.MailRewards and next(rsp.MailRewards) ~= nil then
                    local rewards = {}
    
                    for _,v in ipairs(rsp.MailRewards)do
                        if v.Category == REWARD_TYPE.Gift then
                            local conf = ConfigMgr.GetItem("configGifts", v.ConfId)
                            if conf.items then
                                for _,item in ipairs(conf.items)do
                                    item.Category = REWARD_TYPE.Item
                                    item.ConfId =  item.confId
                                    item.Amount =  item.amount
                                    table.insert(rewards, item)
                                end
                            end
                            if conf.res then
                                for _,res in ipairs(conf.res)do
                                    res.Category = REWARD_TYPE.Res
                                    res.ConfId = res.category
                                    res.Amount =  res.amount
                                    table.insert(rewards, res)
                                end
                            end
                        else
                            table.insert(rewards, v)
                        end
                    end
                    UITool.ShowReward(rewards)
                    MailModel:receiveMails(self.info.Category,{self.info.Uuid})
                    self._panel._panel:RefreshData()
                    if self.subType == MAIL_SUBTYPE.subMailSubTypeNewPlayer then
                        self._ctrView.selectedIndex = 2
                    else
                        self._ctrView.selectedIndex = 0
                    end
                    if self._time > 0 then
                        self:UnSchedule(self.timeUpdate)
                        self._timeText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UpdateWhole_Received")
                    end
                end
            end
        end)
    end)

    self:AddListener(self.btnGoTo.onClick,function()
        if self.info.MailType == 91002 then
            UIMgr:Open("PlayerDetails")
        elseif self.info.MailType == 91003 then
            Net.Vip.GetVipInfo(function(msg)
                UIMgr:Open("VIPMain", msg)
            end)
        elseif self.info.MailType == 91004 or self.info.MailType == 91036 then
            UIMgr:Open("Backpack")
        elseif self.info.MailType == 91005 then
            Sdk.AiHelpShowFAQs()
        elseif self.info.MailType == 91023 then
            -- if BuildModel.CheckExist(403000) then
            --     TipUtil.TipById(50318)
            -- else
                UIMgr:CloseAllPopPanel()
                JumpMap:JumpTo({jump = 810000, para = 403000})
            -- end
        end

        local config = ConfigMgr.GetItem("configMailTypes", math.ceil(self.info.MailType))

        if config.jump_line then
            local temp = split(config.jump_line, ",")
            local jump_line = {}
            for i = 1, #temp, 2 do
                jump_line[tonumber(temp[i])] =  temp[i+1]
            end
            if jump_line[Model.User.Language] then
                Sdk.OpenBrowser(jump_line[Model.User.Language])
            else
                Sdk.OpenBrowser(jump_line[2])
            end
        end
    end)

    self.timeUpdate = function()
        self._time = self.info.RewardExpiredAt - Tool.Time()
        if self._time > 0 then
            self._timeText.text = StringUtil.GetI18n("configI18nCommons", "Ui_UpdateWhole_Countdown", 
                {time = TimeUtil.SecondToDHMS(self._time)})
        else
            self._timeText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UpdateWhole_TimeOver")
            self:UnSchedule(self.timeUpdate)
        end
    end

    self:AddEvent(MAIL_PANEL_STATE_EVENT.MailUnionClose, function()
        print(("=======MailUnionClose========"))
        self:UnSchedule(self.timeUpdate)
    end)
end

function ItemMailUnionAll:SetData(index, _info, panel, subType)
    self.info = _info
    self._panel = panel
    self.subType = subType

    if self.info.IsClaimed then
        if self.subType == MAIL_SUBTYPE.subMailSubTypeNewPlayer then
            self._ctrView.selectedIndex = 2
        else
            self._ctrView.selectedIndex = 0
        end
    else
        self._ctrView.selectedIndex = 1
    end

    if self.info.MailType == 20010 then  -- 联盟仓库 退回资源 特殊处理
        self._ctrView.selectedIndex = 3
    end

    self:initListView()
end

function ItemMailUnionAll:initListView(  )
    -- local rewards = self.info.Rewards
    -- self.info.RewardExpiredAt = self.info.RewardExpiredAt or 0
    self._time = 0
    local rewards = {}

    self.btnGet.enabled = true
    if self.info.RewardExpiredAt and self.info.RewardExpiredAt > 0 then
        self._timeText.visible = true
        self._time = self.info.RewardExpiredAt - Tool.Time()
        if self.info.IsClaimed then
            self:UnSchedule(self.timeUpdate)
            self._timeText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UpdateWhole_Received")
        else
            if self._time > 0 then
                self._timeText.text = StringUtil.GetI18n("configI18nCommons", "Ui_UpdateWhole_Countdown", 
                    {time = TimeUtil.SecondToDHMS(self._time)})
                self:Schedule(self.timeUpdate, 1)
            else
                self._timeText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UpdateWhole_TimeOver")
                self:UnSchedule(self.timeUpdate)
                self.btnGet.enabled = false
            end
        end
    else
        self._timeText.visible = false
        self:UnSchedule(self.timeUpdate)
    end
    

    table.sort(self.info.Rewards, function(a, b)
        return a.Category < b.Category
    end)

    for _,v in ipairs(self.info.Rewards)do
        if v.Category == REWARD_TYPE.Gift then
            local conf = ConfigMgr.GetItem("configGifts", v.ConfId)
            if conf.items then
                for _,item in ipairs(conf.items)do
                    item.Category = REWARD_TYPE.Item
                    item.ConfId =  item.confId
                    item.Amount =  item.amount
                    table.insert(rewards, item)
                end
            end
            if conf.res then
                for _,res in ipairs(conf.res)do
                    res.Category = REWARD_TYPE.Res
                    res.ConfId = res.category
                    res.Amount =  res.amount
                    table.insert(rewards, res)
                end
            end
        else
            table.insert(rewards, v)
        end
    end
    table.sort(rewards, function(a, b)
        return a.ConfId < b.ConfId
    end)

    if rewards == JSON.null or #rewards <= 0 then
        -- self._panel:HideBtn(true)
        self._bg.visible = false
    else
        self._bg.visible = true
    end

    local itemIndex = 1
    local techItemIndex = 1
    self._itemHeight = 0
    for i,v in ipairs(rewards) do
        local _list
        local index
        if v.Category == REWARD_TYPE.Tech then
            index = techItemIndex
            techItemIndex = techItemIndex + 1
            if not self.techItemList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemTeachMailUnion")
                self:AddChild(temp)
                self.techItemList[index] = temp
            end
            _list = self.techItemList
        else
            index = itemIndex
            itemIndex = itemIndex + 1
            if not self.tempList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemMailUnion")
                self:AddChild(temp)
                self.tempList[index] = temp
            end
            _list = self.tempList
        end
        _list[index].x = self.boxX
        _list[index].y = self.boxY + self._itemHeight + 5
        self._itemHeight = _list[index].height + self._itemHeight
        local icon
        local color
        local amount = nil
        local title = nil
        local mid = nil
        if v.Category == REWARD_TYPE.Res then
            local resConfigInfo = ConfigMgr.GetItem("configResourcess", math.ceil(v.ConfId))
            icon = GD.ResAgent.GetIcon(math.ceil(v.ConfId))
            color = resConfigInfo.color
            _list[index]:GetChild("title").text =  ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(v.ConfId))
        elseif v.Category == REWARD_TYPE.Item then
            local itemConfigInfo = ConfigMgr.GetItem("configItems", math.ceil(v.ConfId))
            icon = ConfigMgr.GetItem("configItems", math.ceil(v.ConfId)).icon
            color = itemConfigInfo.color
            amount = math.ceil(v.Amount)
            mid = GD.ItemAgent.GetItemInnerContent(v.ConfId)
            _list[index]:GetChild("title").text = GD.ItemAgent.GetItemNameByConfId(math.ceil(v.ConfId))
        elseif v.Category == REWARD_TYPE.Tech then
            local report
            v.ConfId = math.ceil(v.ConfId/100)*100
            local itemConfigInfo = ConfigMgr.GetItem("configTechDisplays", math.ceil(v.ConfId))
            icon = itemConfigInfo.icon
            color = 1
            amount = math.ceil(v.Amount)
            _list[index]:GetChild("title").text = ConfigMgr.GetI18n("configI18nTechs", math.ceil(v.ConfId).."_NAME")

            if self.info.Report ~= "" and self.info.Report ~= JSON.null then
                _list[index]:GetChild("text").visible = true
                _list[index]:GetChild("numberBg").visible = true
                report = JSON.decode(self.info.Report)
                _list[index]:GetChild("text").text = math.ceil(report.TechLevel) .. "/" .. itemConfigInfo.max_lv
            else
                _list[index]:GetChild("text").visible = false
                _list[index]:GetChild("numberBg").visible = false
            end
        end

        if v.Category == REWARD_TYPE.Tech then
            -- UITool.GetIcon(icon, _list[index]:GetChild("icon"))
            _list[index]:GetChild("icon").icon = UITool.GetIcon(icon)
        else
            _list[index]:GetChild("itemProp"):SetShowData(icon, color, nil, title, mid)
            _list[index]:GetChild("text").text =  math.ceil(v.Amount)
        end
        _list[index].visible = true
    end

    for i = itemIndex, #self.tempList do
        self.tempList[i].visible = false
    end

    for i = techItemIndex, #self.techItemList do
        self.techItemList[i].visible = false
    end

    self:SetSize(self.width, self._height + self._itemHeight- self._box.height)
    -- self._bg.y = self._box.y - 10
    self._bg:SetSize(self._bg.width, self._bgH + self._itemHeight - self._box.height)
end

function ItemMailUnionAll:GetHeight(  )
    
end

return ItemMailUnionAll