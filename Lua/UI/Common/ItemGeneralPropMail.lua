--[[
    Function:通用道具组件 84x84
    author:{tiantiuan}
    time:2020-07-13 17:55:08
]]
local ItemGeneralPropMail = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemGeneralPropMail", ItemGeneralPropMail)

function ItemGeneralPropMail:ctor()
    self._itemquality = self:GetController("itemquality") --品质 1-6
    self._itemSign = self:GetController("itemsign") --标签 0 new 1 正常状态
    self._pickType = self:GetController("picktype") --挑选 0 中心 1 正常状态
    self.detailPop = _G.UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    -- 初始化显示
    --self:SetShowData(nil, 0)
    self._itemquality.selectedIndex = 0
    self._itemSign.selectedIndex = 1
    self._pickType.selectedIndex = 1
    self:SetNewText(StringUtil.GetI18n(I18nType.Commmon, "New_Label"))

    self:InitEvent()
end

function ItemGeneralPropMail:InitEvent()
    self:AddListener(self.onTouchBegin,
        function()
            if not self._info then
                return
            end
            if(self.detailPop and self.detailPop.OnShowUI)then
                self.detailPop:OnShowUI(self._info[1], self._info[2],self._bg, false)
            end
        end
    )

    self:AddListener(self.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )
    self:AddListener(self.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end
-- item设置
--[[
     @desc:设置item内容
     --@image:item图标
    --@quality:item品质
    --@amount:item下方得数量
    --@amountMid:item中心得数字
    --@iconSeekCb:点击放大镜得回调
     @return:
 ]]
function ItemGeneralPropMail:SetShowData(image, quality, amount, title, amountMid)
    self:SetIcon(image)
    if image and not quality then
        quality = 0
    end
    self:SetQuality(quality)
    self:SetAmountActive(amount)
    self:SetTitleActive(title)
    self:SetMiddleActive(amountMid)
end
--设置图标显示
function ItemGeneralPropMail:SetIcon(image)
    if image then
        if image[1] == "Common" then
            self._icon.scale = Vector2(0.79,0.79)
        else
            self._icon.scale = Vector2(1, 1)
        end
        self._icon.visible = true
        self._icon.url = UITool.GetIcon(image, self._icon)
    else
        self._icon.visible = false
    end
    self.image = image
end
--设置底框品质显示
function ItemGeneralPropMail:SetQuality(quality)
    if quality then
        self._bg.visible = true
        self._itemquality.selectedIndex = quality
    else
        self._bg.visible = false
    end
    self.quality = quality
end
--设置数量显示
function ItemGeneralPropMail:SetAmountActive(amount)
    if amount then
        self._amount.visible = true
        self._textBg.visible = true
        self._amount.text = amount
    else
        self._amount.visible = false
        self._textBg.visible = false
    end
end
--设置名字显示
function ItemGeneralPropMail:SetTitleActive(title)
    if title then
        self._title.visible = true
        self._title.text = title
    else
        self._title.visible = false
    end
end
--设置名字颜色
function ItemGeneralPropMail:SetTitleColor(color)
    self._title.color = color
end
--设置美术字数量显示
function ItemGeneralPropMail:SetMiddleActive(amountMid)
    if amountMid then
        self._groupMid.visible = true
        self._amountMid.text = amountMid
    else
        self._groupMid.visible = false
    end
end
--设置NEW文本
function ItemGeneralPropMail:SetNewText(text)
    self._textNew.text = text
end
--设置中心勾选标记 0左下 1 中心
function ItemGeneralPropMail:SetPickTypeMidde(flag)
    self._pickType.selectedIndex = flag and 0 or 1
end
--设置是否是热卖 0新的 1普通
function ItemGeneralPropMail:SetNewActive(flag)
    self._itemSign.selectedIndex = flag and 0 or 1
end
-- 设置点击回调
function ItemGeneralPropMail:SetClickItem(cbData, cb)
    self.cbData = cbData
    self.callback = cb
end
-- 设置父物体
function ItemGeneralPropMail:SetParent(parent)
    self.uiParent = parent
end
function ItemGeneralPropMail:GetEffect()
    return self._effect
end
function ItemGeneralPropMail:SetTipsData(info)
    self._info = info
end
return ItemGeneralPropMail
