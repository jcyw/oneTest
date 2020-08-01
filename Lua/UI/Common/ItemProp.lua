--[[
    Author: songzeming
    Function: 道具Item
]]
local GD = _G.GD
local ItemProp = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemProp", ItemProp)

function ItemProp:ctor()
    self._ctr = self:GetController("Ctr")
    self._ctr.selectedPage = "false"
    self._textHot = self:GetChild("textHot")
    self._textNew = self:GetChild("textNew")
    self._anime = self:GetTransition("iconAnim")
    self._textBg = self:GetChild("textBg")
    self._bgBox = self:GetChild("box")
    self._textHot.text = StringUtil.GetI18n(I18nType.Commmon, "Hot_Label")
    self._textNew.text = StringUtil.GetI18n(I18nType.Commmon, "New_Label")
    
    NodePool.Init(NodePool.KeyType.BackpackIconAnim, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.BackpackIconObj, "Backpack", "itemUseAnim")

    self:SetTitleActive(false)
    self:SetSeekActive(false)
    self:SetNewActive(false)
    self:SetMiddleActive(false)
    self:SetAmountActive(false)
    self:SetSafetyActive(false)
    self:SetHotActive(false)
    self:AddListener(self._btnClick.onClick,
        function()
            if self.triggerClick then
                self.triggerClick()
            end
            if self.callback ~= nil then
                self.callback(self.cbData, self)
                Event.Broadcast(EventDefines.NextNoviceStep,1011)
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
end

function ItemProp:SetPage(str)
    self._ctr.selectedPage = str
end
-- 设置图片、数量、标题 [默认使用]
function ItemProp:SetAmount(image, quality, amount, title, amountMid)
    self._icon.icon = UITool.GetIcon(image, self._icon)
    self._icon.scale = Vector2(1, 1)
    if quality then
        self._bg.url = GD.ItemAgent.GetItmeQualityByColor(quality)
    end
    if amount then
        self:SetAmountActive(true)
        self._amount.text = amount
    else
        self:SetAmountActive(false)
    end
    if title then
        self:SetTitleActive(true)
        self._title.text = title
    else
        self:SetTitleActive(false)
    end

    if amountMid then
        self:SetMiddleActive(true)
        self._amountMid.text = amountMid
        GD.ItemAgent.SetMiddleBg(self._numBg, quality)
    else
        self:SetMiddleActive(false)
    end
end

-- 设置图片、数量、数量(中间)、标题
function ItemProp:SetAmountMiddle(image, quality, amount, amountMid, title)
    self:SetMiddleActive(true)
    self._icon.icon = UITool.GetIcon(image, self._icon)
    self._icon.scale = Vector2(1, 1)
    self:SetAmountActive(true)
    self._amount.text = amount
    self._amountMid.text = amountMid
    GD.ItemAgent.SetMiddleBg(self._numBg, quality)
    if quality then
        self._bg.url = GD.ItemAgent.GetItmeQualityByColor(quality)
    end
    if title then
        self:SetTitleActive(true)
        self._title.text = title
    else
        self:SetTitleActive(false)
    end
end

-- 背包item设置
--[[
    @desc:设置item内容
    --@image:item图标
	--@quality:item品质
	--@amount:item下方得数量
	--@amountMid:item中心得数字
	--@iconSeekCb:点击放大镜得回调
    @return:
]]
function ItemProp:SetBackpackItem(image, quality, amount, amountMid, iconSeekCb)
    self._icon.url = UITool.GetIcon(image, self._icon)
    self._icon.scale = Vector2(1, 1)
    self._amount.text = amount
    self.image = image
    self:SetAmountActive(true)

    if quality then
        self._bg.url = GD.ItemAgent.GetItmeQualityByColor(quality)
    end

    if amountMid then
        self._amountMid.text = amountMid
        GD.ItemAgent.SetMiddleBg(self._numBg, quality)
        self:SetMiddleActive(true)
    else
        self:SetMiddleActive(false)
    end

    if iconSeekCb then
        self.iconSeekCb = iconSeekCb
        self:SetSeekActive(true)
    else
        self:SetSeekActive(false)
    end
end

function ItemProp:SetHotText(text)
    self._textHot.text = text
end

-- 设置是否选中状态
function ItemProp:SetChoose(flag)
    self._light.visible = flag
end
-- 获取是否选中状态
function ItemProp:GetChoose()
    return self._light.visible
end

-- 设置标题是否显示
function ItemProp:SetTitleActive(flag)
    self._title.visible = flag
end

-- 设置中间数量是否显示
function ItemProp:SetMiddleActive(flag)
    self._groupMid.visible = flag
end

-- 设置下面数量是否显示
function ItemProp:SetAmountActive(flag)
    self._amount.visible = flag
    self._textBg.visible = flag
end

function ItemProp:SetQuality(quality)
    if quality then
        self._bg.url = GD.ItemAgent.GetItmeQualityByColor(quality)
    end
end

-- 设置是否显示搜索按钮
function ItemProp:SetSeekActive(flag)
    self._iconSeek.visible = flag
end

-- 设置是否是新品
function ItemProp:SetNewActive(flag)
    self._iconNew.visible = flag
end

-- 设置安全图标是否显示
function ItemProp:SetSafetyActive(flag)
    self._iconTick.visible = flag
end

-- 设置是否是热卖
function ItemProp:SetHotActive(flag)
    self._iconHot.visible = flag
end

-- 设置点击回调
function ItemProp:SetClickItem(cbData, cb)
    self.cbData = cbData
    self.callback = cb
end

-- 设置父物体
function ItemProp:SetParent(parent)
    self.uiParent = parent
end

-- 播放动画
function ItemProp:PlayAnime(cb)
    self._anime:Play(cb)
end

function ItemProp:PlayIconAnimEffect(cb)
    -- 动画
    local anim = NodePool.Get(NodePool.KeyType.BackpackIconObj)
    GRoot.inst:AddChild(anim)
    local pos = self:LocalToRoot(Vector2.zero)
    anim.xy = pos
    anim:SetIcon(self.image)
    anim.sortingOrder = 10000
    anim:PlayAnim(function()
        if anim then
            NodePool.Set(NodePool.KeyType.BackpackIconObj, anim)
        end

        if cb then
            cb()
        end
    end)

    -- 特效
    local effect = NodePool.Get(NodePool.KeyType.BackpackIconAnim)
    effect.xy = Vector2(anim.width * 0.5, anim.height * 0.5)
    anim:AddChildAt(effect, 0)
    effect:PlayDynamicEffectSingle("effect_collect", "effect_backpackItem", function()
        if effect then
            NodePool.Set(NodePool.KeyType.BackpackIconAnim, effect)
        end
    end)
end

function ItemProp:TriggerOnclick(callback)
    self.triggerClick = callback
end

return ItemProp
