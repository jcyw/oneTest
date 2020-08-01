local GD = _G.GD
local ItemBaseGainDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/BaseGain_barSmall", ItemBaseGainDetail)

local BuffItemModel = import("Model/BuffItemModel")

function ItemBaseGainDetail:ctor()
    local itemProp = self:GetChild("itemProp")
    --self._icon = itemProp:GetChild("_icon")
    --self._txtItemNum = itemProp:GetChild("_amount")
    --self._itemBg = itemProp:GetChild("_bg")
    -- self._itemLight = itemProp:GetChild("_light")
    self._txtName = self:GetChild("title")
    self._txtDesc = self:GetChild("text")
    self._txtGold = self:GetChild("btnGreen"):GetChild("text")
    self._btnControl = self:GetController("btnControl")

    --itemProp:GetChild("_groupMid").visible = false
    --itemProp:GetChild("_iconTick").visible = false
    --itemProp:GetChild("_iconNew").visible = false
    --itemProp:GetChild("_iconHot").visible = false
    --itemProp:GetChild("_iconSeek").visible = false
    --itemProp:GetChild("_light").visible = false

    local btnGreen = self:GetChild("btnGreen")
    self:AddListener(btnGreen.onClick,function()
        local curBuff = BuffItemModel.GetModelByIdType(self.itemConfig.type2, Global.TypedBuffItem)
        local content = ""
        if curBuff and curBuff.Source == Global.TypedBuffItem and curBuff.ExpireAt > Tool.Time() then
            content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Confirm", 
            {
                diamond_num = self.itemConfig.price,
                buff_prop_effect = GD.ItemAgent.GetItemNameByConfId(self.itemConfig.id),
                buff_effect_time = ""
            })
        else
            content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Buy", 
            {
                diamond_num = self.itemConfig.price,
                buff_prop_effect = GD.ItemAgent.GetItemNameByConfId(self.itemConfig.id),
                buff_effect_time = ""
            })
        end

        local data = {
            content = content,
            gold = self.itemConfig.price,
            sureCallback = function()
                Net.Items.BuyAndUse(self.itemConfig.id, 1, function(rsp)
                    if rsp.Fail then
                        return
                    end

                    TipUtil.TipById(20037, {item_name = GD.ItemAgent.GetItemNameByConfId(self.itemConfig.id)})
                    self.callback()
                end)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)
    
    local btnYellow = self:GetChild("btnYellow")
    self:AddListener(btnYellow.onClick,function()  
        local curBuff = BuffItemModel.GetModelByIdType(self.itemConfig.type2, Global.TypedBuffItem)
        local func_use = function()
            Net.Items.Use(self.itemConfig.id, 1, nil, function(rsp)
                if rsp.Fail then
                    return
                end

                TipUtil.TipById(20037, {item_name = GD.ItemAgent.GetItemNameByConfId(self.itemConfig.id)})
                self.callback()
            end)
        end

        if curBuff and curBuff.Source == Global.TypedBuffItem and curBuff.ExpireAt > Tool.Time() then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Useing"),
                sureCallback = func_use
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            func_use()
        end

    end)
end

function ItemBaseGainDetail:Init(itemConfig, callBack)
    local itemModel = GD.ItemAgent.GetItemModelById(itemConfig.id)
    local mid = GD.ItemAgent.GetItemInnerContent(itemConfig.id)
    local buffModel = BuffItemModel.GetModelByIdSourceId(itemConfig.type2, itemConfig.id)
    local curBuffModel = BuffItemModel.GetModelByConfigId(itemConfig.type2)
    self.itemConfig = itemConfig
    self.callback = callBack
    self._txtName.text = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
    self._txtDesc.text = GD.ItemAgent.GetItemDescByConfId(itemConfig.id)
    local amount = nil
    if itemModel == nil or itemModel.Amount <= 0 then
        self._txtGold.visible = true
        self._txtGold.text = itemConfig.price
        self._btnControl.selectedPage = "buy"
    else
        self._btnControl.selectedPage = "use"
        amount =itemModel.Amount
    end
    self._itemProp:SetShowData(itemConfig.icon,self.itemConfig.color,amount,nil,mid)

    if buffModel ~= nil and buffModel.SourceId == itemConfig.id and buffModel.SourceId == curBuffModel.SourceId 
    and Model.ServerShield < buffModel.ExpireAt and buffModel.ExpireAt > Tool.Time() then
        self:SetEffect(true)
    else
        self:SetEffect(false)
    end
end

function ItemBaseGainDetail:SetEffect(flag)
    if flag then
        if self.effect == nil then
            self.effect = UIMgr:CreateObject("Effect", "EmptyNode")
            self.effect.xy = Vector2(-3, -6)
            self:AddChild(self.effect)
            DynamicRes.GetBundle("effect_collect", function()
                DynamicRes.GetPrefab("effect_collect", "effect_base_gain", function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    self.effect:GetGGraph():SetNativeObject(GoWrapper(object))
                end)
            end)
        end
    else
        if self.effect then
            self.effect:Dispose()
            self.effect = nil
        end
    end
end

return ItemBaseGainDetail