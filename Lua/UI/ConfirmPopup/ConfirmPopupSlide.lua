--[[
    Author: songzeming,maxiaolong
    Function: 滑动条弹窗 通用
]]
local GD = _G.GD
local ConfirmPopupSlide = UIMgr:NewUI("ConfirmPopupSlide")

local CTR = {
    Text = "Text",
    Icon = "Icon"
}

function ConfirmPopupSlide:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")

    self:AddListener(self._btnSure.onClick,
        function()
            self:OnBtnSureClick()
        end
    )
    self._textGold = self._btnSureGold:GetChild("text")
    self:AddListener(self._btnSureGold.onClick,
        function()
            self:OnBtnSureClick()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
end

--[[
    data = {
        max 滑动条最大值
        content 描述内容
        gold 金币
        icon
        item 道具信息
        ctrType 控制器类型 Text纯文本 Icon带图标
        iconContent 图标描述内容
        sureCallback 确认回调 [可不传]
        initMax 滑动条初始最大值
        slideCallback 滑动回调 [可不传]
        titleText 标题按钮内容 [可不传]
        sureBtnText 确定按钮内容 [可不传]
    }
]]
function ConfirmPopupSlide:OnOpen(data)
    self.data = data
    self._ctr.selectedPage = data.ctrType
    self._icon.visible = false
    self._item.visible = false
    if data.ctrType == CTR.Icon then
        if data.item then
            local mid = GD.ItemAgent.GetItemInnerContent(data.item.id)
            self._item:SetAmount(data.item.icon, data.item.color, nil, nil, mid)
            self._item.visible = true
        elseif data.icon then
            self._icon.icon = data.icon
            self._icon.visible = true
        end
        self._textIcon.text = data.iconContent
    end
    self._textText.text = data.content

    self._btnSureGold.visible = data.gold
    self._btnSure.visible = not data.gold
    if data.gold then
        self._textGold.text = data.gold
    end

    local slide_func = function()
        --滑动条值变化回调
        if data.slideCallback then
            local ct, gd = data.slideCallback(self._slide:GetNumber())
            if ct then
                --返回滑动后内容变化的内容
                self._textText.text = ct
            end
            if gd then
                --返回滑动后金币变化的内容
                self._textGold.text = gd
            end
        end
    end
    self._slide:Init("Army", 1, data.max, slide_func)
    self._slide:SetNumber(data.initMax and data.initMax or data.max)

    --设置标题文本
    if data.titleText then
        self._title.text = data.titleText
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    end
    --设置确定按钮文本
    if data.sureBtnText then
        self._btnSure.text = data.sureBtnText
    else
        self._btnSure.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    end
end

function ConfirmPopupSlide:Close()
    UIMgr:Close("ConfirmPopupSlide")
end

-- 点击确定按钮
function ConfirmPopupSlide:OnBtnSureClick()
    if self.data.sureCallback then
        self.data.sureCallback()
    end
    self:Close()
end

return ConfirmPopupSlide
