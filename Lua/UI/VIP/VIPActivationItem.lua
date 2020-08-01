--[[
    Author:zhangzhichao
    Function:VIP激活以及积分界面列表项
]]
local GD = _G.GD
local VIPActivationItem = fgui.extension_class(GButton)
fgui.register_extension("ui://VIP/itemVIPActivation", VIPActivationItem)

local VIPModel = import("Model/VIPModel")
local Parent, data, VIPInfo

function VIPActivationItem:ctor()
    self._itemProp = self:GetChild("itemProp")
    self._goodsName = self:GetChild("titleName")
    self._goodsDesc = self:GetChild("text")
    self._ctr = self:GetController("c1")

    self._shopAndBuyButton = self:GetChild("btnGreen")
    self._textShopAndBuyButton = self._shopAndBuyButton:GetChild("title")
    self._textBuyPrice = self._shopAndBuyButton:GetChild("text")
    self._useButton = self:GetChild("btnYellow")
    self._textUseButton = self._useButton:GetChild("title")

    self:AddListener(self._useButton.onClick,
        function()
            self:OnBtnClick(true)
        end
    )
    self:AddListener(self._shopAndBuyButton.onClick,
        function()
            self:OnBtnClick(false)
        end
    )
end

function VIPActivationItem:InitEvent(conf, parent, vipInfo, cb)
    Parent = parent
    VIPInfo = vipInfo
    self._conf = conf
    self._parent = parent
    self._isHave = conf.isHave
    self.cb = cb
    self._itemProp:SetAmount(conf.icon, conf.color, conf.Amount, nil, GD.ItemAgent.GetItemInnerContent(conf.id))
    self._goodsName.text = GD.ItemAgent.GetItemNameByConfId(self._conf.id)
    self._goodsDesc.text = GD.ItemAgent.GetItemDescByConfId(self._conf.id)

    self._ctr.selectedIndex = self._isHave and 0 or 1
    if self._isHave then
        self._textUseButton.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    else
        self._textShopAndBuyButton.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_GOLD")
        self._textBuyPrice.text = conf.price
    end
end

function VIPActivationItem:OnBtnClick(value)
    if value == true then --物品使用
        if self._conf.Amount > 1 then -- 有多个物品时候
            local data = {
                config = self._conf,
                amount = self._conf.Amount,
                title = GD.ItemAgent.GetItemNameByConfId(self._conf.id),
                context = StringUtil.GetI18n(I18nType.Commmon, "Use_Broadcast_Tips", {item_name = GD.ItemAgent.GetItemNameByConfId(self._conf.id)}),
                valueChangeCallBack = function(item)
                    if self._conf.type2 == 11 then
                        self.SetContent(item, VIPInfo)
                    end
                end,
                vipInfo = VIPInfo,
                useCallBack = function(useCount)
                    -- local isClear = true
                    -- local curModel = GD.ItemAgent.GetItemModelById(self._conf.id)
                    -- if curModel.Amount > 0 then
                    --     isClear = false
                    -- end

                    if self._conf.type2 == PropType.VIP.Points then
                        TipUtil.TipById(20031, {number = self._conf.value * useCount})
                    else
                        TipUtil.TipById(50189, {buff_prop_effect = GD.ItemAgent.GetItemNameByConfId(self._conf.id)}, nil, nil, "x" .. useCount)
                    end
                    Parent:RequestCallback()
                end
            }
            UIMgr:Open("ResourceDisplayUse", data)
        else -- 只有一个物品时候
            local content
            if self._conf.type2 == PropType.VIP.Day then
                content = StringUtil.GetI18n(I18nType.Commmon, "Use_Broadcast_Tips", {item_name = GD.ItemAgent.GetItemNameByConfId(self._conf.id)})
            else
                local name = GD.ItemAgent.GetItemNameByConfId(self._conf.id)
                local beforeLevel = VIPInfo.VipLevel --当前等级
                local point = VIPInfo.VipPoints --当前积分
                if VIPInfo.VipLevel == VIPModel.GetMaxVipLevel() then
                    TipUtil.TipById(50190)
                    return
                end
                local config = ConfigMgr.GetList("configVips")
                local list, beforePoint = VIPModel.GetLevelPropByConf(beforeLevel, config) --根据当前等级获得左端积分值
                local list, nextPoint = VIPModel.GetLevelPropByConf(beforeLevel + 1, config) --根据下一等级获得右端积分值
                local num = string.format("%.0f", (((point - beforePoint) / (nextPoint - beforePoint)) * 100))
                if (self._conf.value + point) > 240000 then
                    local newNextLevel = 9
                    local newNum = 100
                    content =
                        StringUtil.GetI18n(
                        I18nType.Commmon,
                        "Vip_Point_Tips",
                        {prop_name = name, vip_level = beforeLevel, vip_percent = num .. "%", vip_new_level = newNextLevel - 1, vip_new_percent = newNum .. "%"}
                    )
                else
                    local newPoint = point + self._conf.value --使用一个道具之后积分
                    local newNextLevel, newNextPoint = VIPModel.GetInfoByPiont(newPoint) --通过新积分获得右端对应等级和积分
                    local list, newBeforePoint = VIPModel.GetLevelPropByConf(newNextLevel - 1, config) --通过右端等级获得左端积分
                    local newNum = string.format("%.0f", (((newPoint - newBeforePoint) / (newNextPoint - newBeforePoint)) * 100))
                    content =
                        StringUtil.GetI18n(
                        I18nType.Commmon,
                        "Vip_Point_Tips",
                        {prop_name = name, vip_level = beforeLevel, vip_percent = num .. "%", vip_new_level = newNextLevel - 1, vip_new_percent = newNum .. "%"}
                    )
                end
            end

            local data = {
                content = content,
                sureCallback = function()
                    GD.ItemAgent.UseItem(
                        self._conf.id,
                        1,
                        function()
                            Parent:RequestCallback()
                        end
                    )
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    else --物品购买
        data = {
            vipInfo = VIPInfo,
            id = self._conf.id,
            amount = math.floor(Model.Player.Gem / self._conf.price),
            type2 = self._conf.type2,
            price = self._conf.price,
            itemCount = self._conf.value,
            itemCountType = self._conf.show_num,
            icon = self._conf.icon,
            bg = self._conf.color,
            title = GD.ItemAgent.GetItemNameByConfId(self._conf.id),
            mainContent = StringUtil.GetI18n(I18nType.Commmon, "Vip_Time_Tips1", {prop_name = GD.ItemAgent.GetItemNameByConfId(self._conf.id)}),
            tipContent = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
            useCallBack = function(useCount, data)
                if data.type2 == PropType.VIP.Points then
                    TipUtil.TipById(20031, {number = data.itemCount * useCount})
                else
                    TipUtil.TipById(50189, {buff_prop_effect = GD.ItemAgent.GetItemNameByConfId(data.id)}, nil, nil, "x" .. useCount)
                end
                Parent:RequestCallback()
            end
        }
        if data.amount >= 1 then
            UIMgr:Open("ResourceDisplayGoldBuy", data)
        else
            UITool.GoldLack()
        end
    end
end

function VIPActivationItem.SetContent(item, VipInfo)
    local name = GD.ItemAgent.GetItemNameByConfId(item.id)
    local beforeLevel = VipInfo.VipLevel --当前等级
    local Point = VipInfo.VipPoints --当前积分
    if VipInfo.VipLevel == VIPModel.GetMaxVipLevel() then
        TipUtil.TipById(50190)
        UIMgr:Close("ResourceDisplayUse")
        return
    end
    local conf = ConfigMgr.GetList("configVips")
    local list, beforePoint = VIPModel.GetLevelPropByConf(beforeLevel, conf) --根据当前等级获得左端积分值
    local list, nextPoint = VIPModel.GetLevelPropByConf(beforeLevel + 1, conf) --根据下一等级获得右端积分值
    local num = math.floor(((Point - beforePoint) / (nextPoint - beforePoint)) * 100)
    local percent = string.format("%.0f", num)
    if ((item.amount * item.itemCount) + Point) > 240000 then
        local count = (240000 - Point) / item.itemCount
        item._slider.max = math.ceil((240000 - Point) / item.itemCount) --向下取整数获得滑动条最大值
        item.amount = math.floor(item._slider.max)
        item.amount = math.floor(item._slider.max)
    else --金币所能购买的积分不大于240000，滑动条最大值就为物品数量
        item._slider.max = item.amount
    end
    local newPoint = Point + (item.useCount * item.itemCount) --滑动之后积分
    local newNextLevel
    local newNextPoint
    local newPercent
    if newPoint >= 240000 then
        newNextLevel = 10
        newPercent = 100
    else
        newNextLevel, newNextPoint = VIPModel.GetInfoByPiont(newPoint) --通过新积分获得右端对应等级和积分
        local list, newBeforePoint = VIPModel.GetLevelPropByConf(newNextLevel - 1, conf) --通过右端等级获得左端积分
        local newNum = math.floor(((newPoint - newBeforePoint) / (newNextPoint - newBeforePoint)) * 100)
        newPercent = string.format("%.0f", newNum)
    end
    item._txtDetail.text =
        StringUtil.GetI18n(
        I18nType.Commmon,
        "Vip_Point_Tips",
        {prop_name = name, vip_level = beforeLevel, vip_percent = percent .. "%", vip_new_level = newNextLevel - 1, vip_new_percent = newPercent .. "%"}
    )
end

return VIPActivationItem
