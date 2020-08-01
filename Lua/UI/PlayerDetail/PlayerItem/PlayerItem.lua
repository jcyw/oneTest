--[[
    Author: songzeming
    Function: 玩家道具使用 增加经验等级/体力
]]
local GD = _G.GD
local PlayerItem = UIMgr:NewUI("PlayerItem/PlayerItem")

import("UI/PlayerDetail/PlayerItem/ItemPlayerItem")
local CTR = {
    Exp = "Exp",
    Hp = "Hp"
}

function PlayerItem:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerItem/PlayerItem")
        end
    )
    self:AddListener(self._btnUse.onClick,
        function()
            self:OnBtnUseClick()
        end
    )
end

function PlayerItem:OnOpen(from)
    self.from = from
    self._ctr.selectedPage = from

    self:ShowPlayerInfo()
    self:ShowList()
end

function PlayerItem:ShowPlayerInfo()
    local level = Model.Player.HeroLevel
    local exp = Model.Player.HeroExp

    local values = {
        number = level
    }
    self._level.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Level", values)
    if self._ctr.selectedPage == CTR.Exp then
        local conf = ConfigMgr.GetItem("configPlayerUpgrades", level + 1)
        self._text.text = exp .. "/" .. conf.exp
        self._bar.value = exp / conf.exp * 100
    else
        local energy = GD.ResAgent.GetEnergy()
        self._text.text = energy .. "/" .. 100
        self._bar.value = energy
    end
end

function PlayerItem:ShowList()
    local items = {}
    if self.from == CTR.Exp then
        --经验等级
        for _, v in ipairs(GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, Global.ResPlayerExp)) do
            if Model.Items[v.id] then
                table.insert(items, v)
            end
        end
    elseif self.from == CTR.Hp then
        --体力
        items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, Global.ResHP)
    end
    self.items = items
    if next(items) == nil then
        self._list.numItems = 0
        self._btnUse.enabled = false
        return
    end
    self._btnUse.enabled = true

    self._list.numItems = #items
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        item:Init(self.from, items[i], function()
            if Model.Player.HeroLevel >= Global.MaxPlayerLevel then
                UIMgr:Close("PlayerItem/PlayerItem")
            else
                self:OnOpen(self.from)
            end
        end)
    end
    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

--点击一键使用道具
function PlayerItem:OnBtnUseClick()
    if self.from == CTR.Exp then
        self:OnUseExp()
    end
end

--一键使用经验等级道具
function PlayerItem:OnUseExp()
    local itemAmounts = {}
    local getExp = 0
    local upLevel = Model.Player.HeroLevel
    local upPercent = "0%"
    for _, v in pairs(self.items) do
        local item = Model.Items[v.id]
        if item then
            table.insert(itemAmounts, item)
            local itemConf = ConfigMgr.GetItem("configItems", item.ConfId)
            getExp = getExp + itemConf.value * item.Amount
        end
    end
    local remain = getExp + Model.Player.HeroExp
    local function up_func()
        if upLevel < Global.MaxPlayerLevel then
            local cf = ConfigMgr.GetItem("configPlayerUpgrades", upLevel + 1)
            if remain >= cf.exp then
                upLevel = upLevel + 1
                remain = remain - cf.exp
                up_func()
            else
                upPercent = math.floor(remain / cf.exp * 100)
            end
        else
            upPercent = 100
        end
    end
    up_func()

    local oldUpConf = ConfigMgr.GetItem("configPlayerUpgrades", Model.Player.HeroLevel + 1)
    local values = {
        get_exp = Tool.FormatNumberThousands(getExp),
        old_level = Model.Player.HeroLevel,
        old_percent = math.floor(Model.Player.HeroExp / oldUpConf.exp * 100),
        up_level = upLevel,
        up_percent = upPercent
    }
    local use_func = function()
        local net_func = function()
            if Model.Player.HeroLevel >= Global.MaxPlayerLevel then
                UIMgr:Close("PlayerItem/PlayerItem")
            else
                self:OnOpen(self.from)
            end
            TipUtil.TipById(50266)
        end
        Net.Items.BatchUse(itemAmounts, net_func)
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "UI_USEALL_TIPS", values),
        sureCallback = use_func
    }
    UIMgr:Open("ConfirmPopupText", data)
end

return PlayerItem
