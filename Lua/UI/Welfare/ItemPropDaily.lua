local GD = _G.GD
local ItemPropDaily = fgui.extension_class(GButton)
fgui.register_extension("ui://Welfare/itemPropDaily", ItemPropDaily)

function ItemPropDaily:ctor()
    self._ctr = self:GetController("c1")
    self._ctr2 = self:GetController("c2")
    -- self._amountMid=self:GetChild("_amountMid")
end

function ItemPropDaily:OnClick(callback)
    self:AddListener(self._itemProp.onClick,
        function()
            if self.datas and not self.datas.Signed then
                callback()
            end
        end
    )
end

function ItemPropDaily:SetState(index)
    self._ctr.selectedIndex = index
    if self.effect then
        NodePool.Set(NodePool.KeyType.SevenDaySignInEffect, self.effect)
        self.effect = nil
    end
    if self._ctr.selectedIndex == 2 then
        self:Effect()
    end
    if self._ctr.selectedIndex == 0 then
        self._itemProp:SetMask(true)
        self._itemProp:SetPickTypeMidde(true)
    end
end

function ItemPropDaily:SetData(data)
    self.datas = data
    self:refreshIcon()
end

function ItemPropDaily:refreshIcon()
    local bonus = self.datas.Bonus
    local item = ConfigMgr.GetItem("configItems", bonus.ConfId)
    local image = item.icon
    local amount = bonus.Amount
    local mid = GD.ItemAgent.GetItemInnerContent(bonus.ConfId)
    --[[if mid then
        self._groupMid.visible = true
        self._amountMid.text = mid
        GD.ItemAgent.SetMiddleBg(self._numBg, item.color)
    else
        self._groupMid.visible = false
    end
    self._icon.icon = UITool.GetIcon(image, self._icon)
    self._bgLight.icon = GD.ItemAgent.GetItmeQualityByColor(item.color)]]
    self._textAmount.text = amount
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_DAYS", {num = self.datas.Day})
    if self.datas.Day == 7 then
        local posx = self.x
        self._ctr2.selectedIndex = 1
        self.x = posx
    end
    self._itemProp:SetShowData(image,item.color,nil,nil,mid)
end

function ItemPropDaily:Effect()
    NodePool.Init(NodePool.KeyType.SevenDaySignInEffect, "Effect", "EffectNode")
    self.effect = NodePool.Get(NodePool.KeyType.SevenDaySignInEffect)
    self:AddChild(self.effect)
    self.effect.xy = Vector2(self.width / 2, self.height / 2 + 41)
    self.effect:PlayEffectLoop("effects/signineffect/prefab/effect_qirijiangli_biankuang", Vector3(1, 1, 1))
end

return ItemPropDaily
