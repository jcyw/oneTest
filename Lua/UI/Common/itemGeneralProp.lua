--[[
    Function:通用道具组件
    author:{tiantiuan}
    time:2020-07-13 11:15:19
]]
local GD = _G.GD
local ItemGeneralProp = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemGeneralProp", ItemGeneralProp)

function ItemGeneralProp:ctor()
    self._ctr = self:GetController("Ctr")
    self._itemquality = self:GetController("itemquality") --品质 1-6
    self._light = self:GetController("light") --选中高亮 0 false 1 true
    self._itemSign = self:GetController("itemsign") --标签 0 new 1 hot 2正常状态
    self._rightTop = self:GetController("righttop") --搜索 0 显示 1 不显示
    self._leftBottom = self:GetController("leftbottom") --标签 0 安全 1提升 2正常状态
    self._pickType = self:GetController("picktype") --挑选 0 左下角 1 中心 2正常状态
    self._lockType = self:GetController("locktype") --锁 0 中心 1 左上角 2正常状态

    NodePool.Init(NodePool.KeyType.BackpackIconAnim, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.BackpackIconObj, "Backpack", "itemUseAnim")

    self:AddListener(self._btnClick.onClick,
        function()
            if self.callback ~= nil then
                self.callback(self.cbData, self)
                Event.Broadcast(EventDefines.NextNoviceStep,1011)
            end
            if self.triggerClick then
                self.triggerClick()
            end
        end
    )
    self:AddListener(self._iconSeek.onClick,
        function()
            if self.iconSeekCb then
                self.iconSeekCb()
            else
                TipUtil.TipById(50259)
            end
        end
    )
    -- 初始化显示
    self:SetShowData(nil,0)
    self._ctr.selectedIndex = 0
    self._itemquality.selectedIndex = 0
    self._light.selectedIndex = 0
    self._itemSign.selectedIndex = 2
    self._rightTop.selectedIndex = 1
    self._leftBottom.selectedIndex = 2
    self._pickType.selectedIndex = 2
    self._lockType.selectedIndex = 2
    self:SetMask(false)
    self:SetHotText(StringUtil.GetI18n(I18nType.Commmon, "Hot_Label"))
    self._textNew.text = StringUtil.GetI18n(I18nType.Commmon, "New_Label")
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
function ItemGeneralProp:SetShowData(image, quality, amount, title, amountMid, SeekCb)
    self:SetIcon(image)
    if image and not quality then
        quality = 0
    end
    self:SetQuality(quality)
    self:SetAmountActive(amount)
    self:SetTitleActive(title)
    self:SetMiddleActive(amountMid)
    self:SetSeekActive(SeekCb)
end
--设置图标显示
function ItemGeneralProp:SetIcon(image)
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
function ItemGeneralProp:SetQuality(quality)
    if quality then
        self._bg.visible = true
        self._itemquality.selectedIndex = quality
    else
        self._bg.visible = false
    end
    self.quality = quality
end
--设置数量显示
function ItemGeneralProp:SetAmountActive(amount)
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
function ItemGeneralProp:SetTitleActive(title)
    if title then
        self._title.visible = true
        self._title.text = title
    else
        self._title.visible = false
    end
end
--设置名字颜色
function ItemGeneralProp:SetTitleColor(color)
    self._title.color = color
end
--设置美术字数量显示
function ItemGeneralProp:SetMiddleActive(amountMid)
    if amountMid then
        self._groupMid.visible = true
        self._amountMid.text = amountMid
    else
        self._groupMid.visible = false
    end
end
--设置热卖文本
function ItemGeneralProp:SetHotText(text)
    self._textHot.text = text
end
--设置显示页 Ctr
function ItemGeneralProp:SetPage(str)
    self._ctr.selectedPage = str
end
-- 设置是否显示搜索按钮
function ItemGeneralProp:SetSeekActive(iconSeekCb)
    self.iconSeekCb = iconSeekCb
    self._rightTop.selectedIndex = iconSeekCb and 0 or 1
end
-- 设置是否选中状态
function ItemGeneralProp:SetChoose(flag)
    self._light.selectedIndex = flag and 1 or 0
end
-- 获取是否选中状态
function ItemGeneralProp:GetChoose()
    return self._light.selectedIndex == 1
end
--设置是否是热卖 0新的 1热卖 2普通
function ItemGeneralProp:SetNewActive(flag)
    self._itemSign.selectedIndex = flag and 0 or 2
end
--设置是否是热卖 0新的 1热卖 2普通
function ItemGeneralProp:SetHotActive(flag)
    self._itemSign.selectedIndex = flag and 1 or 2
end
-- 设置安全图标是否显示 0安全 1提升 2普通
function ItemGeneralProp:SetSafetyActive(flag)
    self._leftBottom.selectedIndex = flag and 0 or 2
end
-- 设置提升图标是否显示 0安全 1提升 2普通
function ItemGeneralProp:SetUpActive(flag)
    self._leftBottom.selectedIndex = flag and 1 or 2
end
--设置左下角勾选标记 0左下 1 中心
function ItemGeneralProp:SetPickTypeLeftBottom(flag)
    self._pickType.selectedIndex = flag and 0 or 2
end
--设置中心勾选标记 0左下 1 中心
function ItemGeneralProp:SetPickTypeMidde(flag)
    self._pickType.selectedIndex = flag and 1 or 2
end
--设置中心锁标记 0 中心 1左上
function ItemGeneralProp:SetLockTypeMidde(flag)
    self._lockType.selectedIndex = flag and 0 or 2
end
--设置左上锁标记 0 中心 1左上
function ItemGeneralProp:SetLockTypeTopLeft(flag)
    self._lockType.selectedIndex = flag and 1 or 2
end
--蒙版
function ItemGeneralProp:SetMask(flag)
    self._mask.visible = flag
end
-- 设置点击回调
function ItemGeneralProp:SetClickItem(cbData, cb)
    self.cbData = cbData
    self.callback = cb
end
-- 设置父物体
function ItemGeneralProp:SetParent(parent)
    self.uiParent = parent
end
function ItemGeneralProp:GetEffect()
    return self._effect
end
function ItemGeneralProp:PlayIconAnimEffect(cb)
    -- 动画
    local anim = NodePool.Get(NodePool.KeyType.BackpackIconObj)
    GRoot.inst:AddChild(anim)
    local pos = self:LocalToRoot(Vector2.zero)
    anim.xy = pos
    anim:SetIcon(self.image)
    anim.sortingOrder = 10000
    anim:PlayAnim(
        function()
            if anim then
                NodePool.Set(NodePool.KeyType.BackpackIconObj, anim)
            end

            if cb then
                cb()
            end
        end
    )

    -- 特效
    local effect = NodePool.Get(NodePool.KeyType.BackpackIconAnim)
    effect.xy = Vector2(anim.width * 0.5, anim.height * 0.5)
    anim:AddChildAt(effect, 0)
    effect:PlayDynamicEffectSingle(
        "effect_collect",
        "effect_backpackItem",
        function()
            if effect then
                NodePool.Set(NodePool.KeyType.BackpackIconAnim, effect)
            end
        end
    )
end
--引导回调
function ItemGeneralProp:TriggerOnclick(callback)
    self.triggerClick = callback
end
return ItemGeneralProp
