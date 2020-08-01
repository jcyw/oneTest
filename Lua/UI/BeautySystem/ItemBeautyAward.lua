--[[
    author:{maxiaolong}
    time:2019-11-16 09:44:51
    function:{美女item}
]]
local GD = _G.GD
local ItemBeautyAward = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyAward", ItemBeautyAward)
local WelfareModel = import("Model/WelfareModel")

function ItemBeautyAward:ctor()
    self._bg = self:GetChild("bg")
    self._textName1 = self:GetChild("textName1")
    self._textName2 = self:GetChild("textName2")
    self._listView = self:GetChild("liebiao")
    self._btnAllReceive = self:GetChild("btnAllReceive")
    self._textState = self:GetChild("text")
    self._controller = self:GetController("c1")
    --self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self:InitEvent()
end

function ItemBeautyAward:InitEvent()
    --按钮事件
    self:AddListener(self._btnAllReceive.onClick,
        function()
            if self.category == nil then
                return
            end
            --这里要改，加上美女在线奖励的
            Net.Beauties.GetOnlineBonus(
                self.category - 1,
                function(val)
                    --设置界面上得倒计时
                    Event.Broadcast(EventDefines.RefreshMainUIBeauty, val.NextIndex, val.NextAvaliableAt)
                    UITool.GiftReward(self.giftId)
                    --如果下个奖励的ID已经大于最大数量
                    if val.NextIndex == -1 then
                        local mainPanel = UIMgr:GetUI("MainUIPanel")
                        --关闭在线按钮
                        mainPanel:SetBeutyBtnVisble(false)
                        UIMgr:Close("BeautyOnlineRewards")
                        --设置界面Icon的位置
                        Event.Broadcast(EventDefines.RefreshSetIconPos)
                        return
                    end
                    self._controller.selectedIndex = 2
                    --刷新列表
                    Event.Broadcast(EventDefines.BeautyOnlineRefresh)
                end
            )
        end
    )
    --列表渲染
    self._listView.itemRenderer = function(index, item)
        local icon = self.items[index + 1].image
        local color = self.items[index + 1].color
        local amount = self.items[index + 1].amount
        local midStr = self.items[index + 1].midStr
        local title = self.items[index + 1].title
        local des = self.items[index + 1].desc
        item:SetAmount(icon, color, amount, nil, midStr)
        item:SetData({title, des})
    end
    --列表事件
    --self:SetListener(self._listView.onTouchMove,
    --    function()
    --        UIMgr:HidePopup("Common", "LongPressPopupLabel")
    --    end
    --)
end

function ItemBeautyAward:SetData(giftId, info, isReceived, maxIndex)
    local tempId = giftId % 10
    self.indexId = tempId
    self.maxIndex = maxIndex
    self.giftId = giftId
    local str1 = info[2]
    local str2 = info[3]
    self._textName1.text = str1
    self._textName2.text = str2
    if info[1] == nil then
        self._controller.selectedIndex = 2
        if isReceived == true then
            local str = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
            self._textState.text = str
            self._textState.color = Color.gray
        else
            local str = StringUtil.GetI18n(I18nType.Commmon, "GodzillaOnlineReward14")
            self._textState.text = str
            self._textState.color = Color.red
        end
    else
        if info[1].status > 0 then
            self.category = info[1].category
            self._controller.selectedIndex = 0
            local receiveAward = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_AWARD_ALL")
            self._btnAllReceive:GetChild("title").text = receiveAward
        elseif info[1].status == 0 then
            self.category = info[1].category
            local finishAt = info[1].finishAt
            self._controller.selectedIndex = 1
            self:RefreshTime(finishAt)
        end
    end
    self.items, self.itemNum = WelfareModel.GetResOrItemByGiftId(giftId)
    self._listView.numItems = self.itemNum
end

--[[
    @desc:计时器
    --@finishAt:下一个领取时间
]]
function ItemBeautyAward:RefreshTime(finishAt)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function time_func()
        return finishAt - Tool.Time()
    end
    if time_func() > 0 then
        local timeTextFunc = function(t)
            local timeText = Tool.FormatTime(t)
            self._textState.text = timeText
            self._textState.color = Color.green
        end
        self.cd_func = function()
            local ctime = time_func()
            if ctime >= 0 then
                timeTextFunc(ctime)
                return
            else -- 计时结束时
                self._controller.selectedIndex = 0
                local receiveAward = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_AWARD_ALL")
                self._btnAllReceive:GetChild("title").text = receiveAward
                --Event.Broadcast(EventDefines.BeautyOnlineRefresh)
                self:UnSchedule(self.cd_func)
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end

return ItemBeautyAward
