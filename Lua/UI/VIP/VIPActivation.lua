--[[
    Author:zhangzhichao
    Function:VIP激活以及积分界面
]]
local GD = _G.GD
local VIPActivation = UIMgr:NewUI("VIPActivation")

local VIPMainItem = import("UI/VIP/VIPMainItem")
local vipInfo = {}

function VIPActivation:OnInit()
    local view = self.Controller.contentPane
    --按钮
    self._btnReturn = view:GetChild("btnReturn")
    self._btnGold = view:GetChild("btnGold")
    --列表
    self._liebiao = view:GetChild("liebiao")
    --文本
    self._textName = view:GetChild("textName")
    self._textIntegral = view:GetChild("textIntegral")
    self._textIntegralNum = view:GetChild("textIntegralNum")

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("VIPActivation")
        end
    )
    self:AddEvent(
        EventDefines.UIVipInfo,
        function(rsp)
            vipInfo = rsp
        end
    )
end

function VIPActivation:OnOpen(index, level, msg)
    self.level = level
    self.index = index
    vipInfo = msg
    self.datas = {}
    self.curData = {} -- 当前选择物品的数据
    self.curTag = 0
    self.curBoxIndex = -1 -- 当前选择物品的序号

    self:RefreshList()
end

function VIPActivation:RefreshList()
    if self.level < vipInfo.VipLevel then
        UIMgr:Open("VIPLevel", self.level, vipInfo.VipLevel)
        self.level = vipInfo.VipLevel
    end
    if self.index == 3 then
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Activate_Title") --激活界面标题设置
        self:Reset(vipInfo.ExpirationTime) --时间显示设置
    else
        self:SetActive(false)
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Point_Title") --积分界面标题设置
        self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Point_Now", {vip_now_point = vipInfo.VipPoints}) --当前积分
    end

    local haveItems, AllItems = self:goodsInfoAndNum(self.index)
    for i = #AllItems, 1, -1 do
        local ishave, Amount = self:CheckIsHaveItem(AllItems[i].id, haveItems)
        if Amount == 0 and not AllItems[i].price then
            table.remove(AllItems, i)
        end
    end
    table.sort(
        AllItems,
        function(a, b)
            return a.value < b.value
        end
    )

    self._liebiao.numItems = #AllItems
    for k, info in pairs(AllItems) do
        local ishave, Amount = self:CheckIsHaveItem(info.id, haveItems)
        local confItem = GD.ItemAgent.GetItemModelByConfId(info.id)
        confItem.Amount = Amount
        if confItem.Amount == 0 then
            confItem.isHave = false
        else
            confItem.isHave = true
        end
        local item = self._liebiao:GetChildAt(k - 1)
        item:InitEvent(
            confItem,
            self,
            vipInfo,
            function(isUse)
            end
        )
    end
end

function VIPActivation:goodsInfoAndNum(index)
    if index == 3 then --VIP天数道具
        local AllItems = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, PropType.VIP.Day)
        local haveItems = self:FindHaveItem(AllItems, Model.Items)
        return haveItems, AllItems
    else --VIP点数道具
        local AllItems = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, PropType.VIP.Points)
        local haveItems = self:FindHaveItem(AllItems, Model.Items)
        return haveItems, AllItems
    end
end

function VIPActivation:CheckIsHaveItem(confId, list)
    for k, v in pairs(list) do
        if v.ConfId == confId then
            return true, v.Amount
        end
    end
    return false, 0
end

function VIPActivation:FindHaveItem(AllItems, ModelItems)
    local curHaveItem = {}
    local num = 0
    for k, v in pairs(AllItems) do
        for k1, v1 in pairs(ModelItems) do
            if v.id == v1.ConfId then
                table.insert(curHaveItem, v1)
            end
        end
    end
    return curHaveItem
end

function VIPActivation:Reset(timeNum)
    if self.cd_func then --剩余时间提示
        self:UnSchedule(self.cd_func)
    end
    if timeNum == Tool.Time() then
        self._textIntegral.visible = false
    end
    local mCtime = function()
        return timeNum - Tool.Time()
    end
    local ctime = mCtime()
    if mCtime() > 0 then
        self._textIntegral.visible = true
        local bar_func = function(t)
            self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Activate_Time", {vip_active_time = (Tool.FormatTime(t))})
        end
        bar_func(ctime)
        self.cd_func = function()
            ctime = mCtime()
            if ctime >= 0 then
                bar_func(ctime)
                return
            end
            self._textIntegral.text = false
        end
        self:Schedule(self.cd_func, 1)
    else
        self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_UnActivate_Title")
    end
end

-- 设置倒计时是否显示
function VIPActivation:SetActive(flag)
    self.visible = flag
    if flag then
        return
    end
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
end

function VIPActivation:RequestCallback()
    self:RefreshList()
    Event.Broadcast(EventDefines.VipPointsChange)
end

return VIPActivation
