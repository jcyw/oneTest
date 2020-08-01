local GD = _G.GD
local ItemSevenDayActivities = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemSevenDayActivities", ItemSevenDayActivities)

local TaskModel = import("Model/TaskModel")
local WelfareModel = import("Model/WelfareModel")
local JumpMap = import("Model/JumpMap")

function ItemSevenDayActivities:ctor()
    self._list = self:GetChild("liebiao")
    self._title = self:GetChild("title")
    self._btnFree = self:GetChild("btnFree")
    self._btnGray = self:GetChild("btnGray")
    self._btnGreen = self:GetChild("btnGreen")
    self._textTime = self:GetChild("textTime")
    self._textNum = self:GetChild("textNum")
    self._ctr = self:GetController("c1")
    self:AddListener(
        self._btnGreen.onClick,
        function()
            if self.day > self.today or not self.data then
                return
            end
            if not self.data.CurrentProcess then
                if not self.data.Acknowledged then
                    local rewards = {}
                    for _, item in ipairs(self.itemDatas) do
                        local reward = {
                            Category = item.isRes and Global.RewardTypeRes or Global.RewardTypeItem,
                            ConfId = item.confId,
                            Amount = item.amount
                        }
                        table.insert(rewards, reward)
                    end
                    local id = self.data.Id
                    WelfareModel.GetSevenDaysTaskReward(
                        id,
                        function(rsp)
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.RookieGrowth.Id, -1)
                            UITool.ShowReward(rewards)
                            --刷新页面排序
                            Event.Broadcast(EventDefines.SevenDayContentRefresh, id, self.day)
                        end
                    )
                end
            end
        end
    )
    self:AddListener(
        self._btnFree.onClick,
        function()
            if self.day > self.today or not self.data then
                return
            end
            local conf = ConfigMgr.GetItem("configSevenDayTasks", self.data.Id)
            local jump = conf.jump
            local jumpId = jump.jump
            local para = jump.para

            Event.Broadcast(EventDefines.WelareCenterClose)
            if jumpId == 0 then
                return
            elseif para == 0 then
                JumpMap:JumpSimple(jumpId)
            else
                local finish = conf.finish
                JumpMap:JumpTo(jump, finish)
            end
            --成长之路前往打点
            local strId = tostring(conf.id)
            Net.UserInfo.RecordLog(
                4202,
                strId,
                function(rsp)
                end
            )
        end
    )

    self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ONE_TASK_SCHEDULE")
    self._list.itemRenderer = function(index, item)
        local itemInfo = self.itemDatas[index + 1]
        --item:SetControl(1)
        --item:SetImg(itemInfo.image)
        --item:SetQuality(itemInfo.color)
        --item:SetAmount(itemInfo.amount)
        --item:SetAmountMid(itemInfo.confId)

        local mid = GD.ItemAgent.GetItemInnerContent(itemInfo.confId)
        item:SetShowData(itemInfo.image,itemInfo.color,itemInfo.amount,nil,mid)

        local title = nil
        local desc = nil
        if itemInfo.isRes then
            local key = ConfigMgr.GetItem("configResourcess", itemInfo.confId).key
            title = StringUtil.GetI18n(I18nType.Commmon, key)
            desc = title .. "X" .. itemInfo.amount
        else
            desc = GD.ItemAgent.GetItemDescByConfId(itemInfo.confId)
            title = GD.ItemAgent.GetItemNameByConfId(itemInfo.confId) .. "X" .. itemInfo.amount
        end

        self:ClearListener(item.onTouchBegin)
        self:ClearListener(item.onTouchEnd)
        self:ClearListener(item.onRollOut)
        self:AddListener(
            item.onTouchBegin,
            function()
                self.detailPop:OnShowUI(title, desc, item._icon, false)
            end
        )
        self:AddListener(
            item.onTouchEnd,
            function()
                self.detailPop:OnHidePopup()
            end
        )
        self:AddListener(
            item.onRollOut,
            function()
                self.detailPop:OnHidePopup()
            end
        )
    end

    --self:SetListener(self._list.onTouchMove,
    --    function()
    --        UIMgr:HidePopup("Common", "LongPressPopupLabel")
    --    end
    --)
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function ItemSevenDayActivities:SetData(data)
    self.data = data
    self:RefreshInfos()
end

function ItemSevenDayActivities:SetDay(day, today)
    self.day = day
    self.today = today
end

function ItemSevenDayActivities:RefreshInfos()
    local item = ConfigMgr.GetItem("configSevenDayTasks", self.data.Id)
    local name, desc, info = TaskModel:GetTaskNameByType(item)
    self._title.text = name

    local giftId = item.gift

    local itemInfos, itemCount = WelfareModel.GetResOrItemByGiftId(giftId)
    self.itemDatas = itemInfos
    self._list.numItems = itemCount

    local num = self.data.CurrentProcess or item.finish.para2
    num = math.min(num, item.finish.para2)
    local formatNum = Tool.FormatNumberThousands(num)
    local sumFormatNum = Tool.FormatNumberThousands(item.finish.para2)
    self._textNum.text = formatNum .. "/" .. sumFormatNum


    if self.data.Acknowledged then
        self._ctr.selectedIndex = 1
        self._btnGray.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
    elseif not self.data.Acknowledged and not self.data.CurrentProcess then
        self._ctr.selectedIndex = 3
        self._btnGreen.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    else
        self._ctr.selectedIndex = 0
        self._btnFree.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    end
end

return ItemSevenDayActivities
