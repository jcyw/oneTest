--[[
    author:{laofu}
    time:2020-05-11 17:51:49
]]
local GD = _G.GD
local UIMgr = _G.UIMgr
local ItemBackpackPropExchange = _G.fgui.extension_class(_G.GComboBox)
_G.fgui.register_extension("ui://Backpack/itemBackpackPropExchange", ItemBackpackPropExchange)

local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local UITool = _G.UITool
local Net = _G.Net
local TipUtil = _G.TipUtil
local ConfigMgr = _G.ConfigMgr
local Event = _G.Event
local EventDefines = _G.EventDefines

function ItemBackpackPropExchange:ctor()
    self._btnExchange = self:GetChild("btnExchange")
    self._sourceItem = self:GetChild("itemProp1")
    self._exchangeItem = self:GetChild("itemProp2")

    self:AddListener(self._btnExchange.onClick,
        function()
            local data = {
                id = self._rewardConfig.id,
                amount = self._exchangeTimes,
                price = self._useNum,
                mainContent = GD.ItemAgent.GetItemDescByConfId(self._rewardConfig.id),
                tipContent = StringUtil.GetI18n(I18nType.Commmon, "TIPS_EXCHANGE_ONE_ITEM"),
                title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Exchange"),
                icon = self._rewardConfig.icon,
                bg = GD.ItemAgent.GetItemModelByConfId(self._rewardConfig.id).color,
                btnIcon = UITool.GetIcon(self._itemConfig.icon),
                btnText = StringUtil.GetI18n(I18nType.Commmon, "Ui_Exchange"),
                exchangeCallBack = function(useCount)
                    --兑换奖励事件
                    Net.Activity.ExchangeReward(
                        self._exchangeData.activity_id,
                        self._exchangeData.id,
                        useCount,
                        function()
                            if useCount == 1 then
                                TipUtil.TipById(50307, {item = GD.ItemAgent.GetItemNameByConfId(self._rewardConfig.id)})
                            else
                                TipUtil.TipById(50308, {item = GD.ItemAgent.GetItemNameByConfId(self._rewardConfig.id), num = useCount})
                            end
                            --刷新兑换奖励界面的显示
                            local itemConfig = ConfigMgr.GetItem("configItems", self._exchangeData.item_id[1].id)
                            local model = GD.ItemAgent.GetItemModelById(itemConfig.id)
                            if model then
                                local data = {
                                    [1] = itemConfig,
                                    [2] = model.Amount
                                }
                                Event.Broadcast(EventDefines.ExchangeRefresh, data, self._exchangeData.id, useCount)
                            else
                                UIMgr:Close("BackpackPropExchange")
                            end
                        end
                    )
                end
            }
            UIMgr:Open("ResourceDisplayGoldBuy", data)
        end
    )
    self:AddListener(self._sourceItem.onTouchBegin,
        function()
            local title = GD.ItemAgent.GetItemNameByConfId(self._itemConfig.id)
            self:ShowPopup(title, self._sourceItem, self._itemConfig.id)
        end
    )
    self:AddListener(self._sourceItem.onTouchEnd,
        function()
            ItemBackpackPropExchange.HidePopup()
        end
    )
    self:AddListener(self._exchangeItem.onTouchBegin,
        function()
            local title = GD.ItemAgent.GetItemNameByConfId(self._rewardConfig.id)
            self:ShowPopup(title, self._exchangeItem, self._rewardConfig.id)
        end
    )
    self:AddListener(self._exchangeItem.onTouchEnd,
        function()
            ItemBackpackPropExchange.HidePopup()
        end
    )
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

--@exchangData:来自configExchanges表里的数据
--@itemNum:侦查情报道具的数量
--@remainTimes 剩余次数
function ItemBackpackPropExchange:SetData(exchangeData, itemNum, remainTimes)
    self._exchangeData = exchangeData
    self._btnExchange.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Exchange")
    self._itemConfig = ConfigMgr.GetItem("configItems", exchangeData.item_id[1].id)
    self._rewardConfig = ConfigMgr.GetItem("configItems", exchangeData.reward_id[1].id)
    self._useNum = exchangeData.item_id[1].num
    self._getNum = exchangeData.reward_id[1].num

    local itemAmount = itemNum .. "/" .. self._useNum
    self._sourceItem:SetShowData(self._itemConfig.icon, self._itemConfig.color, itemAmount, nil, nil, GD.ItemAgent.GetItemInnerContent(self._itemConfig.id))
    local rewardAmount = "x" .. self._getNum
    self._exchangeItem:SetShowData(self._rewardConfig.icon, self._rewardConfig.color, rewardAmount, nil, GD.ItemAgent.GetItemInnerContent(self._rewardConfig.id))

    --不等于-1时就是有限制次数，如果得到的可兑换值大于剩余就等于他的剩余
    self._exchangeTimes = math.floor(itemNum / self._useNum)
    if self._exchangeData.limit_num ~= -1 and self._exchangeTimes > remainTimes then
        self._exchangeTimes = remainTimes
    end

    --按钮显示文本状态
    self._btnExchange.enabled = (itemNum >= self._useNum) and (remainTimes > 0)
    self._limitText.visible = not (remainTimes == -1)
    --显示次数
    local strColor = remainTimes > 0 and "#4ba62f" or "#e55d41"
    local strAmount = "[color=" .. strColor .. "]" .. remainTimes .. "[/color]" .. "/" .. self._exchangeData.limit_num
    self._limitText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_EXCHANGE_AMOUNT") .. strAmount
end

function ItemBackpackPropExchange:ShowPopup(title, item, id)
    self.detailPop:OnShowUI(title, GD.ItemAgent.GetItemDescByConfId(id), item._icon, false)
end

function ItemBackpackPropExchange.HidePopup()
    UIMgr:HidePopup("Common", "LongPressPopupLabel")
end

return ItemBackpackPropExchange
