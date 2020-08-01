--[[
    author:Temmie
    time:
    function:金币购买道具确认界面
]]
local GD = _G.GD
local ResourceDisplayGoldBuy = UIMgr:NewUI("ResourceDisplayGoldBuy")

local VIPModel = import("Model/VIPModel")
local VipInfo = {}

function ResourceDisplayGoldBuy:OnInit()
    local view = self.Controller.contentPane
    local slideComp = view:GetChild("slideComp")
    self._itemProp = view:GetChild("itemProp")
    --self._icon = self._itemProp:GetChild("_icon")
    --self._iconBg = self._itemProp:GetChild("_bg")
    -- self._txtItemCount = view:GetChild("itemProp"):GetChild("_amountMid")
    -- self._itemCountBg = view:GetChild("itemProp"):GetChild("_groupMid")
    self._txtTitle = view:GetChild("titleName")
    self._slider = slideComp:GetChild("_slide")
    self._input = slideComp:GetChild("_text")
    self._btnAdd = slideComp:GetChild("_btnAdd")
    self._btnReduce = slideComp:GetChild("_btnDel")
    self._btnUse = view:GetChild("btnUse")
    self._txtPrice = self._btnUse:GetChild("text")
    self._txtContent = view:GetChild("text")
    self._txtTipContent = view:GetChild("title")
    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")

    --self._itemProp:GetChild("_amount").visible = false
    -- view:GetChild("itemProp"):GetChild("_bgArrow").visible = false

    self:AddListener(self._slider.onChanged,
        function()
            local value = math.floor(self._slider.value + 0.5)
            self.useCount = value < self.minValue and self.minValue or value
            local cost = self.useCount * self.price
            self._input.text = self.useCount
            self._txtPrice.text = cost
            self._txtContent.text = self:SetContent(self.data)
            if not self.data.tipContent then
                self._txtTipContent.text = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2", {diamond_num = cost})
            end
        end
    )

    self:AddListener(self._slider.onGripTouchEnd,
        function()
            self._slider.value = self.useCount
        end
    )

    -- self:AddListener(self._input.onFocusOut,function()
    --     local value = self._input.text
    --     value = tonumber(value)
    --     if value ~= nil then
    --         value = math.floor(value + 0.5)
    --         if value > self.amount then
    --             value = self.amount
    --         elseif value < self.minValue then
    --             value = self.minValue
    --         end
    --     else
    --         value = math.floor(self._slider.value)
    --     end
    --     self._input.text = value
    --     self._slider.value = value
    --     self.useCount = value
    --     self._txtPrice.text = self.useCount * self.price
    -- end)

    self:AddListener(self._btnAdd.onClick,
        function()
            self.useCount = self.useCount + 1 > self.amount and self.amount or self.useCount + 1
            local cost = self.useCount * self.price
            self._input.text = self.useCount
            self._slider.value = self.useCount
            self._txtPrice.text = cost
            self._txtContent.text = self:SetContent(self.data)
            if not self.data.tipContent then
                self._txtTipContent.text = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2", {diamond_num = cost})
            end
        end
    )

    self:AddListener(self._btnReduce.onClick,
        function()
            self.useCount = self.useCount - 1 < 1 and 1 or self.useCount - 1
            local cost = self.useCount * self.price
            self._input.text = self.useCount
            self._slider.value = self.useCount
            self._txtPrice.text = cost
            self._txtContent.text = self:SetContent(self.data)
            if not self.data.tipContent then
                self._txtTipContent.text = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2", {diamond_num = cost})
            end
        end
    )

    self:AddListener(self._btnUse.onClick,
        function()
            if self.notUse and tonumber(self._txtPrice.text) > Model.Player.Gem then
                UIMgr:Close("ResourceDisplayGoldBuy")
                UITool.GoldLack()
                return
            end

            --如果有兑换逻辑则走兑换逻辑
            if self.exchangeCallBack then
                self.exchangeCallBack(self.useCount)
                UIMgr:Close("ResourceDisplayGoldBuy")
                return
            end

            --VIP满级的时候打开
            if GD.ItemAgent.GetItemType2(self.id) == PropType.VIP.Points and VIPModel.GetVipLevel() == 10 then
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_VIP_LEVELMAX_BUY"),
                    titleText = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                    sureCallback = function()
                        UIMgr:Close("ResourceDisplayGoldBuy")
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
                return
            end

            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
                sureCallback = function()
                    if self.notUse then
                        Net.Items.Buy(
                            self.id,
                            self.useCount,
                            function(rsp)
                                if rsp.Fail then
                                    return
                                end

                                TipUtil.TipById(50199)

                                if self.buyCallBack ~= nil then
                                    self.buyCallBack()
                                end
                            end
                        )
                    else
                        Net.Items.BuyAndUse(
                            self.id,
                            self.useCount,
                            function(rsp)
                                if rsp.Fail then
                                    return
                                end

                                if self.useCallBack ~= nil then
                                    self.useCallBack(self.useCount, self.data)
                                end
                            end
                        )
                    end
                    UIMgr:Close("ResourceDisplayGoldBuy")
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )

    local btnInputBox = slideComp:GetChild("_btnInput")
    self:AddListener(btnInputBox.onClick,
        function()
            self.keyboard:Init(
                self.amount,
                function(num)
                    self.useCount = num < self.minValue and self.minValue or num
                    self._input.text = self.useCount
                    self._slider.value = self.useCount
                    local cost = self.useCount * self.price
                    self._txtPrice.text = cost
                    self._txtContent.text = self:SetContent(self.data)
                    if not self.data.tipContent then
                        self._txtTipContent.text = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2", {diamond_num = cost})
                    end
                end
            )
            UIMgr:ShowPopup("Common", "itemKeyboard", self._input)
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("ResourceDisplayGoldBuy")
        end
    )

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("ResourceDisplayGoldBuy")
        end
    )
end

--[[
    id 物品配置id
    amount 可购买最大数量
    price 物品价格
    minValue 可购买最小数量
    useCallBack 点击购买按钮后的回调
    exchangeCallBack 兑换按钮回调
    mainContent 图标旁边的信息
    tipContent 滑动条上方的信息
    title 窗口标题
    btnTitle 按钮显示内容
    icon 物品图标
    bg 物品品质框
    itemCount 物品内数量，没有就不传
    btnIcon 按钮图标
    btnText 按钮标题
]]
function ResourceDisplayGoldBuy:OnOpen(data)
    VipInfo = data.vipInfo
    self.minValue = 1
    self.data = data
    self.id = data.id
    self.amount = data.amount
    self.price = data.price
    self.useCount = self.minValue
    self.useCallBack = data.useCallBack
    self.exchangeCallBack = data.exchangeCallBack
    self.notUse = data.notUse

    self.buyCallBack = data.buyCallBack
    self._txtContent.text = self:SetContent(self.data)
    self._txtTitle.text = data.title
    self._txtTipContent.text = data.tipContent and data.tipContent or StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2", {diamond_num = self.useCount * self.price})
    -- self._txtPrice.text = data.btnTitle
    self._txtPrice.text = self.price * self.minValue
    --self._icon.url = data.icon
    --self._iconBg.url = data.bg
    self._slider.max = data.amount
    self._slider.value = self.useCount
    self._input.text = self.useCount

    self._btnIcon = self._btnUse:GetChild("icon")
    self.btnText = self._btnUse:GetChild("title")
    if data.btnIcon then
        self._btnIcon.url = data.btnIcon
    else
        self._btnIcon.url = "ui://Common/icon_diamond_02"
    end
    if data.btnText then
        self.btnText.text = data.btnText
    else
        self.btnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Buy")
    end

    --self._itemProp:SetAmountMid(self.id, true)

    if self.price > Model.Player.Gem then
        self._txtPrice.color = Color(0.98, 0.36, 0.25)
    else
        self._txtPrice.color = Color.white
    end

    local mid = GD.ItemAgent.GetItemInnerContent(self.id)
    self._itemProp:SetShowData(data.icon,data.bg,nil,nil,mid)
end

function ResourceDisplayGoldBuy:SetContent(data)
    if data.type2 == PropType.VIP.Points then
        return self:IntegralProp(data)
    else
        return data.mainContent
    end
end

function ResourceDisplayGoldBuy:IntegralProp(data) --积分道具使用context的显示
    local name = GD.ItemAgent.GetItemNameByConfId(data.id)
    local beforeLevel = VipInfo.VipLevel --当前等级
    local Point = VipInfo.VipPoints --当前积分
    if VipInfo.VipLevel == 10 then
        TipUtil.TipById(50190)
        UIMgr:Close("ResourceDisplayGoldBuy")
        return
    end
    local conf = ConfigMgr.GetList("configVips")
    local list, beforePoint = VIPModel.GetLevelPropByConf(beforeLevel, conf) --根据当前等级获得左端积分值
    local list, nextPoint = VIPModel.GetLevelPropByConf(beforeLevel + 1, conf) --根据下一等级获得右端积分值
    local num = math.floor(((Point - beforePoint) / (nextPoint - beforePoint)) * 100)
    local percent = string.format("%.0f", num)
    if ((data.amount * data.itemCount) + Point) > 240000 then --金币所能购买的积分大于240000
        self._slider.max = math.ceil((240000 - Point) / data.itemCount) --向下取整数获得滑动条最大值
        data.amount = math.floor(self._slider.max)
        self.amount = math.floor(self._slider.max)
    else --金币所能购买的积分不大于240000，滑动条最大值就为物品数量
        self._slider.max = data.amount
    end
    local newPoint = Point + (self.useCount * data.itemCount) --滑动之后积分
    local newNextLevel
    local newNextPoint
    local newPercent
    if newPoint >= 240000 then
        newNextLevel = 11
        newPercent = 0
    else
        newNextLevel, newNextPoint = VIPModel.GetInfoByPiont(newPoint) --通过新积分获得右端对应等级和积分
        local list, newBeforePoint = VIPModel.GetLevelPropByConf(newNextLevel - 1, conf) --通过右端等级获得左端积分
        local newNum = math.floor(((newPoint - newBeforePoint) / (newNextPoint - newBeforePoint)) * 100)
        newPercent = string.format("%.0f", newNum)
    end

    return StringUtil.GetI18n(
        I18nType.Commmon,
        "Vip_Point_Tips2",
        {prop_name = name, vip_level = beforeLevel, vip_percent = percent .. "%", vip_new_level = newNextLevel - 1, vip_new_percent = newPercent .. "%"}
    )
end

return ResourceDisplayGoldBuy
