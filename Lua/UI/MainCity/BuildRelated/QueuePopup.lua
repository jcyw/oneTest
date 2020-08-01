--[[
    Author: songzeming
    Function: 队列弹窗 队列道具、金币购买队列
]]
local GD = _G.GD
local QueuePopup = UIMgr:NewUI("BuildRelated/QueuePopup")

import("UI/Common/ItemSlide")
import("UI/MainCity/BuildRelated/ItemQueuePopupProp")
local CTR = {
    QueueProp = 'QueueProp', --点击队列按钮 有道具
    QueueGold = 'QueueGold', --点击队列按钮 没有道具
    BuildProp = 'BuildProp', --建造升级 道具时间充裕
    BuildPropGold = 'BuildPropGold', --建造升级 道具时间不足
    BuildGold = 'BuildGold' --建造升级 没有道具
}

function QueuePopup:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController('Ctr')

    self._btnSureGoldText = self._btnSureGold:GetChild("text")
    self:AddListener(self._btnSureGold.onClick,
        function()
            self:OnBtnSureGoldClick()
        end
    )
    self:AddListener(self._btnUseProp.onClick,
        function()
            self:OnBtnUsePropClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnMask.onClick,
        function()
            self:Close()
        end
    )
end

function QueuePopup:OnOpen(from, time, name, cb)
    self.from = from
    self.time = time
    self.name = name
    self.cb = cb

    self.amount = 0 --金币购买个数 默认250金币买两天
    self.props = {} --使用道具总数
    self.extraDay = 0 --道具有且不足,使用额外的金币购买天数

    self.items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Queue, Global.ResQueue)
    table.sort(self.items, function(a, b) return a.id < b.id end)
    if from == "Queue" then
        --点击建筑队列按钮
        self:OnQueueShow()
    else
        --建筑建造或者升级
        self:OnBuildShow()
    end
end

function QueuePopup:Close()
    UIMgr:Close("BuildRelated/QueuePopup")
end

function QueuePopup:OnQueueShow()
    for _, v in ipairs(self.items) do
        local prop = Model.Items[v.id]
        if prop and prop.Amount > 0 then
            --有道具
            self._ctr.selectedPage = CTR.QueueProp
            --local icon = UITool.GetIcon(v.icon)
            local name = GD.ItemAgent.GetItemNameByConfId(v.id)
            local color = GD.ItemAgent.GetItemModelByConfId(v.id).color
            self._itemProp:Init(v.icon,color,nil,name)
            self._textPropDesc.text = GD.ItemAgent.GetItemDescByConfId(v.id)
            self.props[1] = {ConfId = v.id, Amount = 1}
            self._slide:Init("Normal", 1, prop.Amount, function()
                self.props[1] = {ConfId = v.id, Amount = self._slide:GetNumber()}
            end)
            return
        end
    end

    --没有道具 金币购买
    self._ctr.selectedPage = CTR.QueueGold
    self.amount = 1
    self._btnSureGoldText.text = UITool.UBBTipGoldText(Global.BuyBuilderFee * self.amount)
end

function QueuePopup:OnBuildShow()
    local builderTime = Model.Builders[BuildType.QUEUE.Charge].ExpireAt - Tool.Time()
    local ctime = builderTime > 0 and (self.time - builderTime) or self.time
    local propTime = 0
    for _, v in ipairs(self.items) do
        local prop = Model.Items[v.id]
        if prop and prop.Amount > 0 then
            --有道具
            local propIndex = #self.props + 1
            self.props[propIndex] = {}
            for i = 1, prop.Amount do
                propTime = propTime + v.value
                self.props[propIndex] = {ConfId = v.id, Amount = i}
                if propTime >= ctime then
                    --道具时间充裕
                    self._ctr.selectedPage = CTR.BuildProp
                    self:ListShow()
                    return
                end
            end
        end
    end

    local build = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_BUILD")
    local upgrade = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_UPGRADE")
    local destroy = StringUtil.GetI18n(I18nType.Commmon, "Button_Remove")
    local values = {
        building_name = self.name,
        behavior = self.from == "Build" and build or (self.from == "Upgrade" and upgrade or destroy),
        time = Tool.FormatTime(self.time)
    }
    if propTime == 0 then
        --没有道具 金币购买
        self._ctr.selectedPage = CTR.BuildGold
        if builderTime > 0 then
            self.amount = math.ceil((ctime - propTime) / Global.BuyBuilderDuration)
        else
            self.amount = math.ceil(self.time / Global.BuyBuilderDuration)
        end
        self._btnSureGoldText.text = UITool.UBBTipGoldText(Global.BuyBuilderFee * self.amount)
        self._textBuildGold.text = StringUtil.GetI18n(I18nType.Commmon, "UI_SECOND_QUEUE_DIAN", values)
    else
        --有道具 但总时间不够
        self._ctr.selectedPage = CTR.BuildPropGold
        self:ListShow()
        self.amount = math.ceil((ctime - propTime) / Global.BuyBuilderDuration)
        self._btnSureGoldText.text = UITool.UBBTipGoldText(Global.BuyBuilderFee * self.amount)
        self._textBuildPropGold.text = StringUtil.GetI18n(I18nType.Commmon, "UI_SECOND_QUEUE_DITEM", values)
    end
end

-- 设置道具列表
function QueuePopup:ListShow()
    self._list.numItems = #self.props
    for i = 1, self._list.numChildren do
        local prop = self.props[i]
        local icon = ConfigMgr.GetItem("configItems", prop.ConfId).icon
        local color = ConfigMgr.GetItem("configItems", prop.ConfId).color
        local name = GD.ItemAgent.GetItemNameByConfId(prop.ConfId)
        self._list:GetChildAt(i - 1):Init(icon,color,prop.Amount,name)
    end
end

--点击确定 金币购买
function QueuePopup:OnBtnSureGoldClick()
    if not UITool.CheckGem(Global.BuyBuilderFee * self.amount) then
        return
    end
    Net.Buildings.BuyBuilder(true, self.amount, function(rsp)
        Model.Builders[BuildType.QUEUE.Charge].ExpireAt = rsp.ExpireAt
        Event.Broadcast(EventDefines.UIResetBuilder)
        self:Close()
        TipUtil.TipById(30109)
        if self.cb then
            self.cb()
        end
    end)
end

--点击使用
function QueuePopup:OnBtnUsePropClick()
    --使用额外的金币购买
    if self.amount > 0 then
        self:OnBtnSureGoldClick()
    end
    Net.Items.BatchUse(self.props, function()
        Event.Broadcast(EventDefines.UIResetBuilder)
        self:Close()
        TipUtil.TipById(30110)
        if self.cb then
            self.cb()
        end
    end)
end

return QueuePopup
