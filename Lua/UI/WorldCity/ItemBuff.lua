--[[
    author:{chekefan}
    time:2019-05-31 14:18:23
    function:{item 行军加速}
]]
local GD = _G.GD
local ItemBuff = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/ItemBuff", ItemBuff)

local ItemType = import("Enum/ItemType")
local isClick = false

---ItemBuff   环状操作列表item
function ItemBuff:ctor()
    self._controller = self:GetController("c1")

    self:AddListener(self._btnPayAndUse.onClick,
        function()
            isClick = true
            self:ScheduleOnceFast(
                function()
                    isClick = false
                end,
                0.3
            )
            self:PayAndUse()
        end
    )
    self:AddListener(self._btnUse.onClick,
        function()
            -- local data = {
            --     content = StringUtil.GetI18n(I18nType.Commmon, "Item_Use_Confirm", {prop_name = GD.ItemAgent.GetItemNameByConfId(self.configData.id)}),
            --     sureCallback = function()
            --         self:UseItem()

            --     end
            -- }
            -- UIMgr:Open("ConfirmPopupText", data)
            if isClick then
                return
            end
            isClick = true
            self:ScheduleOnceFast(
                function()
                    isClick = false
                end,
                0.3
            )
            self:UseItem()
        end
    )
    self._price = self._btnPayAndUse:GetChild("text")
end

function ItemBuff:Init(itemInfo, itemType, val, useCallback)
    self.data = itemInfo
    self.useCb = useCallback
    local config = ConfigMgr.GetItem("configItems", itemInfo.id)
    --self._bg.url = GD.ItemAgent.GetItmeQualityByColor(config.color)
    --self._icon.icon = UITool.GetIcon(config.icon)
    self._titleName.text = GD.ItemAgent.GetItemNameByConfId(itemInfo.id)
    self._text.text = GD.ItemAgent.GetItemDescByConfId(itemInfo.id)
    self.configData = config
    self.itemType = itemType
    self.val = val
    local mid = GD.ItemAgent.GetItemInnerContent(config.id)
    --[[if mid then
        self._groupMid.visible = true
        self._amountMid.text = mid
        GD.ItemAgent.SetMiddleBg(self._numBg, config.color)
    else
        self._groupMid.visible = false
    end]]

    self._item:SetShowData(config.icon,config.color,nil,nil,mid)
    self:RefreshCount()
end

function ItemBuff:PayAndUse()
    if not UITool.CheckGem(self.configData.price_hot) then
        return
    end

    local data = {
        content = StringUtil.GetI18n(
            I18nType.Commmon,
            "Base_Buff_Buy",
            {
                diamond_num = self.configData.price,
                buff_prop_effect = GD.ItemAgent.GetItemNameByConfId(self.configData.id),
                buff_effect_time = ""
            }
        ),
        gold = self.configData.price_hot,
        sureCallback = function()
            Net.Items.Buy(
                self.configData.id,
                1,
                function(val)
                    self:UseItem()
                    Event.Broadcast(EventDefines.UIOnExpeditionLimitChange)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function ItemBuff:UseItem()
    if self.itemType == ItemType.CommonProp then
        --普通道具
    elseif self.itemType == ItemType.SpeedupProp then
        --前往集结处行军消息不同
        if self.val.marchType == MarchType.Union and not self.val.isRallyMarch then
            Net.AllianceBattle.Speedup(
                self.val.AllianceBattleId,
                self.val.Uuid,
                self.configData.id,
                function(val)
                    TipUtil.TipById(20037, {item_name = GD.ItemAgent.GetItemNameByConfId(self.configData.id)})
                end
            )
            return
        end

        --加速道具
        local id = self.val.isRallyMarch and self.val.AllianceBattleId or self.val.Uuid --如果是参与集结队员给队伍加速，传AllianceBattleId
        -- local id = (self.val.isRallyMarch or (self.val.IsRally and self.val.OwnerId ~=Model.Account.accountId) and not self.val.IsReturn) and self.val.AllianceBattleId or self.val.Uuid --如果是参与集结队员给队伍加速，传AllianceBattleId
        -- if self.val.isRallyMarch == nil then
        --     self.val.isRallyMarch = id == self.val.AllianceBattleId
        -- end
        Net.Events.SpeedupMission(
            id,
            self.configData.id,
            false,
            self.val.isRallyMarch,
            function(val)
                self:RefreshCount()
                Event.Broadcast(EventDefines.UIOnMissionInfo, val)
                SdkModel.TrackBreakPoint(10069)  
                TipUtil.TipById(20037, {item_name = GD.ItemAgent.GetItemNameByConfId(self.configData.id)})
                if self.useCb then
                    self.useCb()
                end
            end
        )
    elseif self.itemType == ItemType.ApProp then
        Net.Items.Use(
            self.configData.id,
            1,
            nil,
            function(val)
                self:RefreshCount()

                if self.useCb then
                    self.useCb()
                end
            end
        )
    elseif self.itemType == ItemType.ExpeditionLimitProp or self.itemType == ItemType.CollectBuffProp then
        local func = function()
            Net.Items.Use(
                self.configData.id,
                1,
                nil,
                function(val)
                    self:RefreshCount()
                    if self.itemType == ItemType.ExpeditionLimitProp then
                        Event.Broadcast(EventDefines.UIOnExpeditionLimitChange)
                    end
                    if self.useCb then
                        self.useCb()
                    end
                end
            )
        end

        local curBuff = Model.Find(ModelType.Buffs, self.configData.type2)
        if curBuff and curBuff.Value > 0 then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Useing"),
                sureCallback = func
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            func()
        end
    elseif self.itemType == ItemType.MarchRecell then
        Net.Events.RecallMission(
            self.val,
            false,
            function(val)
                if self.useCb then
                    self.useCb()
                end
            end
        )
    end
end
--刷新数量
function ItemBuff:RefreshCount()
    local info = GD.ItemAgent.GetItemModelById(self.configData.id)
    if not info or info.Amount == 0 then
        self._controller.selectedIndex = 0
        --self._num.text = 0
        self._price.text = self.configData.price
        self._item:SetAmountActive(false)
    else
        self._controller.selectedIndex = 1
        --self._num.text = info.Amount
        self._item:SetAmountActive(info.Amount)
    end
end

return ItemBuff
