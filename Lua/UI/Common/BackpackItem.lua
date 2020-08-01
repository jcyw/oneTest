-- 背包列表项，装具体物品的容器
local GD = _G.GD
local BackpackItem = _G.fgui.extension_class(_G.GButton)
_G.fgui.register_extension("ui://Common/backpackListItem", BackpackItem)

import("UI/Common/ItemProp")
import("UI/Common/BackpackBox")
local BuildModel = import("Model/BuildModel")
local triggerGuide = import("Model/TriggerGuideLogic")
local UIMgr = _G.UIMgr
local Tool = _G.Tool
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local ConfigMgr = _G.ConfigMgr

local itemHeight = 180
local boxHeight = 178

local needAnimeType = {
    [1] = true,
    [3] = true,
    [4] = true,
    [8] = true,
    [14] = true
}

function BackpackItem:ctor()
    self._itemList = self:GetChild("itemList")
end

function BackpackItem:Init(index, parent)
    index = index + 1
    local box = self:GetChild("itemBackpackPopupBox")

    -- 打开下拉简介
    if index == parent.curBoxIndex then
        self.name = "DetailBox"
        self:SetSize(695, itemHeight + boxHeight)
        self._itemList:RemoveChildrenToPool()
        if box ~= nil then
            box.visible = true
        else
            box = UIMgr:CreateObject("Common", "itemBackpackPopupBox")
            box.name = "itemBackpackPopupBox"
            box:SetXY(0, boxHeight + 6) --+6为了微调上下间距
            self:AddChildAt(box, 0)
        end
        box:Init(parent.curData, parent, BackpackItem.OnBoxUseBtnClick, BackpackItem.OnBoxDetailBtnClick)
        GD.ItemAgent.SetItemBoxPane(box)
    else
        self:SetSize(695, itemHeight)
        if box ~= nil then
            box.visible = false
        end
    end

    -- 初始化物品item
    -- local realIndex = index
    self._itemList:RemoveChildrenToPool()
    self.itemData ={}
    for i = 1, parent.row do
        local item = self._itemList:AddItemFromPool()
        local dataIndex = (index - 1) * parent.row + i
        if dataIndex > parent.dataCount then
            -- local item = self._itemList:AddItemFromPool()
            -- item:GetController("emptyControl").selectedPage = "true"
            item.visible = false
        else
            item.visible = true
            local data = parent:GetData(dataIndex)
            self:InitItem(item, parent, data)
            local checkData = {
                data = data,
                parent = parent,
                row = index
            }
            item:SetClickItem(checkData, BackpackItem.OnItemClick)
            table.insert(self.itemData,{id = checkData.data.config.id, item = item})
            GD.ItemAgent.SaveItemPane(checkData.data.config.id, item)
            if GD.ItemAgent.CheckNewItem(checkData.data.config.id) then
                item:SetNewActive(true)
            else
                item:SetNewActive(false)
            end
        end
    end
end

function BackpackItem:InitItem(item, parent, data)
    local icon = data.config.icon
    local amount = Tool.FormatNumberThousands(data.model.Amount)
    local quality = data.config.color
    local seekCb = nil
    local midNum = GD.ItemAgent.GetItemInnerContent(data.config.id)

    --设置放大镜的点击回调，data.config是configItems表里的数据
    if data.config.details and data.config.details == 1 then
        seekCb = function()
            BackpackItem.OnBoxDetailBtnClick(data.config)
        end
    end

    item:SetShowData(icon, quality, amount,nil, midNum, seekCb)
    item:SetSafetyActive(data.config.safe)
    item:SetChoose(parent.curData.id == data.config.id)
    item:SetParent(self)

    if parent.curData.config and BackpackItem.CheckNeedAnim(parent.curData.config.type)
    and parent.curData.config.id == data.config.id and parent.curData.model.Amount ~= data.model.Amount
    and parent._ctr2.selectedIndex == 0 then
        item:PlayIconAnimEffect(function()
            parent.curData.model = data.model
        end)
    end
end

-- 检查物品使用后是否播放使用动画
function BackpackItem.CheckNeedAnim(type)
    return needAnimeType[type]
end

-- 点击物品
function BackpackItem.OnItemClick(cbData)
    local data = cbData.data
    local parent = cbData.parent
    local list = parent._list

    if parent.curData.index == data.index then -- 点击当前选中的物品时清空选中物品信息
        parent.curData = {}
        parent.curBoxIndex = -1
        list.numItems = math.ceil(parent.dataCount / parent.row)
        list:RefreshVirtualList()
    else -- 设置选中物品信息
        parent.curData = data
        parent.curBoxIndex = math.ceil(data.index / parent.row)
        list.numItems = math.ceil(parent.dataCount / parent.row)
        list:RefreshVirtualList()
    end
end

--@desc:打开兑换界面
function BackpackItem.Exchange(itemConfig)
    local model = GD.ItemAgent.GetItemModelById(itemConfig.id)
    local data = {
        [1] = itemConfig,
        [2] = model.Amount
    }
    UIMgr:Open("BackpackPropExchange", data)
end

-- 下拉框点击使用按钮
function BackpackItem.OnBoxUseBtnClick(item, id)
    --如果道具类型是11则直接走兑换界面，下面内容就不走
    if item._data.config.type == 11 then
        BackpackItem.Exchange(item._data.config)
        return
    end
    local model = GD.ItemAgent.GetItemModelById(id)

    local canUse, tip = GD.ItemAgent.CheckItemLimit(id)
    if not canUse then
        if tip then
            tip()
        end
        return
    end

    if item._data.config.useall and item._data.config.useall > 0 and model.Amount > 1 then
        local itemAmount = model.Amount
        if item._data.config.id == _G.MILITARY_SUPPLY.MSItemConfId then
            local canAddNum = BuildModel.GetMilitarySuppliesCanAddTime()
            itemAmount = canAddNum > model.Amount and model.Amount or canAddNum
        end
        -- 可一次使用多个的物品
        local tipData = {item_name = GD.ItemAgent.GetItemNameByConfId(item._data.id)}
        local data = {
            config = item._data.config,
            amount = itemAmount,
            initAmount = (item._data.config.useall and item._data.config.useall == 1) and model.Amount or 1,
            title = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_InfoTitle"),
            context = StringUtil.GetI18n(I18nType.Commmon, "Use_Broadcast_Tips", tipData)
        }
        UIMgr:Open("ResourceDisplayUse", data)
    else
        -- 一次只能使用一个的物品
        local contentData = {item_name = GD.ItemAgent.GetItemNameByConfId(item._data.id)}
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Use_Broadcast_Tips", contentData),
            sureCallback = function()
                GD.ItemAgent.UseItem(item._data.id)
            end
        }
        if not triggerGuide.IsGuideTriggering() then
            UIMgr:Open("ConfirmPopupText", data)
        else
            GD.ItemAgent.UseItem(item._data.id)
        end
    end
end

-- 下拉框点击详细按钮
function BackpackItem.OnBoxDetailBtnClick(itemConfig)
    --如果道具类型是11则直接走兑换界面，下面内容就不走
    if itemConfig.type == 11 then
        BackpackItem.Exchange(itemConfig)
        return
    end

    local items = {}
    local isRandom = false
    local giftConfig = ConfigMgr.GetItem("configGifts", itemConfig.value)
    if giftConfig ~= nil then
        if giftConfig.res then
            for _, v in pairs(giftConfig.res) do
                local resConfig = ConfigMgr.GetItem("configResourcess", v.category)
                if resConfig ~= nil then
                    local data = {
                        icon = GD.ResAgent.GetIconInfo(v.category),
                        quality = tostring((resConfig.color == nil and 0 or resConfig.color)),
                        title = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. resConfig.id),
                        amount = "X" .. v.amount
                    }
                    table.insert(items, data)
                end
            end
        end
        if giftConfig.items then
            for _, v in pairs(giftConfig.items) do
                local curItemConfig = ConfigMgr.GetItem("configItems", v.confId)
                if curItemConfig ~= nil then
                    local data = {
                        id = curItemConfig.id,
                        icon = curItemConfig.icon,
                        quality = tostring((curItemConfig.color == nil and 0 or curItemConfig.color)),
                        title = GD.ItemAgent.GetItemNameByConfId(curItemConfig.id),
                        amount = "X" .. v.amount,
                        tip = GD.ItemAgent.GetItemInnerContent(v.confId)
                    }
                    table.insert(items, data)
                end
            end
        end
        if giftConfig.pools then
            for _, v in pairs(giftConfig.pools) do
                local poolConfig = ConfigMgr.GetItem("configGiftPools", v.pool_id)
                for _, v1 in pairs(poolConfig.pool) do
                    local curItemConfig = ConfigMgr.GetItem("configItems", v1.conf_id)
                    if curItemConfig ~= nil then
                        local data = {
                            id = curItemConfig.id,
                            icon = curItemConfig.icon,
                            quality = tostring((curItemConfig.color == nil and 0 or curItemConfig.color)),
                            title = GD.ItemAgent.GetItemNameByConfId(curItemConfig.id),
                            amount = "X" .. v1.amount,
                            tip = GD.ItemAgent.GetItemInnerContent(v1.conf_id)
                        }
                        table.insert(items, data)
                        isRandom = true
                    end
                end
            end
        end
    end

    local data = {
        items = items,
        isRandom = isRandom,
        title = StringUtil.GetI18n(I18nType.Commmon, "MAP_DETAILCHECK_BUTTON"),
        content = "",
        btnOkTitle = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    }
    UIMgr:Open("BackpackRewardDetailView", data)
end

function BackpackItem:GetEntityItem(configId)
    for _, v in pairs(self.itemData) do
        if v.id == configId then
            return v.item
        end
    end
    return nil
end

--触发式引导
function BackpackItem:TriggerOnclick(callBack)
        self.callBack = callBack
end

return BackpackItem
