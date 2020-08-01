-- 背包主界面
local GD = _G.GD
local UIMgr = _G.UIMgr
local Backpack = UIMgr:NewUI("Backpack")

local BuildModel = import("Model/BuildModel")
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local SdkModel = _G.SdkModel
local EventDefines = _G.EventDefines
local AnimationLayer = _G.AnimationLayer
local UITool = _G.UITool
local GlobalBanner = _G.GlobalBanner
local Event = _G.Event
local AnimationType = _G.AnimationType
local ConfigMgr = _G.ConfigMgr
local GlobalItem = _G.GlobalItem
local Tool = _G.Tool
local Net = _G.Net
local TipUtil = _G.TipUtil

local TAG_NUM = 5

function Backpack:OnInit()
    local view = self.Controller.contentPane
    for i = 1, TAG_NUM do
        self["tag" .. i] = view:GetChild("btnTagSingle" .. i)
    end
    self["tag1"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_All")
    self["tag3"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_SPEEDUP")
    self._title = view:GetChild("textName")
    self._list = view:GetChild("liebiao")
    self._allUseControl = view:GetController("useAllControl")
    self._ctr1 = view:GetController("c1")
    self._ctr2 = view:GetController("c2")
    self._btnControl = view:GetController("btnControl")

    self.datas = {} -- 物品数据集，数据结构为{index--序号, id--配置id, model, config}

    self.curData = {}
    self.curTag = 0 -- 道具分类：0.all 1.war 2.speed 3.resource 4.other
    self.curBoxIndex = -1
    self.dataCount = 0
    self.row = 4

    self._btnInventory = view:GetChild("btnInventory")
    self._btnStore = view:GetChild("btnStore")
    self._btnReturn = view:GetChild("btnReturn")
    self._btnUseAll = view:GetChild("btnUse")
    self._storeList = view:GetChild("liebiaoShop")
    self:InitStoreData()

    self:InitList()

    self:InitEvent()

    self.refreshFunc = function()
        self:RefreshData()

        local isScrollTop = true
        local isClearData = true
        if self.curData ~= nil and self.curData.config ~= nil then
            isScrollTop = false
            local curModel = GD.ItemAgent.GetItemModelById(self.curData.id)
            if (curModel and curModel.Amount > 0) then
                isClearData = false
            end
        end

        self:RefreshList(isScrollTop, isClearData)
    end
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.Backpack)
end

function Backpack:InitEvent()
    self:AddListener(
        self._btnReturn.onClick,
        function()
            UIMgr:Close("Backpack")
            if self.callback ~= nil then
                self.callback()
            end
            if self.triggerCallback then
                self.triggerCallback()
            end
        end
    )

    self:AddListener(
        self._btnInventory.onClick,
        function()
            self._ctr1.selectedIndex = self.curTag
            self["tag1"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_All")
            self["tag3"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_SPEEDUP")
            self:RefreshAllUse()
        end
    )

    self:AddListener(
        self._btnUseAll.onClick,
        function()
            self:UseAllResource()
        end
    )

    self:AddListener(
        self._btnStore.onClick,
        function()
            SdkModel.TrackBreakPoint(10035) --打点
            self._ctr1.selectedIndex = self.curStoreTag
            self["tag1"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Store_Hot")
            self["tag3"].title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Shop_War")
            self:RefreshAllUse()
        end
    )

    for i = 1, TAG_NUM do
        self:AddListener(
            self["tag" .. i].onClick,
            function()
                if self._ctr2.selectedIndex == 0 then
                    if self.curTag == i - 1 then
                        return
                    end
                    self.curTag = i - 1
                    self:RefreshList(true, true)
                else
                    self.curStoreTag = i - 1
                    self:RefreshStoreList()
                end
                self:RefreshAllUse()
            end
        )
    end
end

--[[
    cb 关闭回调（可不传）
    StoreTag 指定进入背包或商场（可不传）
    SubTag 指定进入物品分类（可不传）
    itemId 指定显示物品Id（可不传）
]]
function Backpack:OnOpen(params)
    self.callback = params and params.cb or nil
    -- self._title = "物品"
    self._allUseControl.selectedPage = "hide"

    self.curData = {} -- 当前选择物品的数据
    self.curTag = 0

    self.curBoxIndex = -1 -- 当前选择物品的序号
    if params and params.StoreTag then
        self["tag1"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Store_Hot")
        self["tag3"].title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Shop_War")
        self.curStoreTag = params.StoreTag
        self._ctr1.selectedIndex = params.StoreTag
        self._ctr2.selectedIndex = 1
    else
        self["tag1"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_All")
        self["tag3"].title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_SPEEDUP")
        self.curStoreTag = 0
        self._ctr1.selectedIndex = 0
        self._ctr2.selectedIndex = 0
    end

    self:RefreshData()
    self:RefreshList(true, true)
    self:RefreshStoreList()

    if params and params.SubTag and self["tag" .. params.SubTag] then
        self["tag" .. params.SubTag]:FireClick(true)
        self["tag" .. params.SubTag].onClick:Call()
    end

    if params and params.itemId then
        self:ScrollToViewItem(params.itemId)
    end

    self:AddEvent(EventDefines.UIRefreshBackpack, self.refreshFunc)
    Event.Broadcast(EventDefines.NextNoviceStep, 1010)
end

function Backpack:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self)
end

function Backpack:OnClose()
    GD.ItemAgent.ClearNewItem()
    Event.RemoveListener(EventDefines.UIRefreshBackpack, self.refreshFunc)
    Event.Broadcast(EventDefines.NextNoviceStep, 1014)
end

function Backpack:RefreshData()
    self.datas = {}
    local models = GD.ItemAgent.GetItemModel()
    for k, v in pairs(models) do
        if v.Amount > 0 then
            local config = ConfigMgr.GetItem("configItems", k)
            if config then
                local data = {
                    index = 0,
                    id = k,
                    model = v,
                    config = config,
                    isNew = GD.ItemAgent.CheckNewItem(config.id)
                }
                table.insert(self.datas, data)
            end
        end
    end
    table.sort(self.datas, Backpack.Sort)

    -- 重新定位选中的物品
    self:RefreshSelectedData()
end

function Backpack:RefreshSelectedData()
    if next(self.curData) then
        local index = 0
        for _,v in pairs(self.datas) do
            if self.curTag == 0 or self.curTag == v.config.page then
                index = index + 1
                if self.curData.id == v.id then
                    self.curData.index = index
                    break
                end
            end
        end
    end
end

-- 初始化背包列表设置。背包列表项分两层。背包列表的项是一个容器，纵向排列。容器内再横向排列具体的物品项。
function Backpack:InitList()
    --注册列表项渲染逻辑
    self._list.itemRenderer = function(index, item)
        item:Init(index, self)
    end
    self._list:SetVirtual()

    self._storeList.itemRenderer = function(index, item)
        if not index then
            return
        end
        local data
        if self.curStoreTag == 0 then
            data = self.hotStoreData[index + 1]
        else
            data = self.curStoreData[index + 1]
        end
        item:SetData(data, self)
    end
    self._storeList:SetVirtual()
end

function Backpack:RefreshAllUse()
    if self._ctr2.selectedIndex == 0 and self.curTag == 1 then
        if self:CheckCanUseAll() then
            -- self._btnUseAll.enabled = true
            self._btnControl.selectedPage = "normal"
        else
            -- self._btnUseAll.enabled = false
            self._btnControl.selectedPage = "gray"
        end

        self._allUseControl.selectedPage = "show"
    else
        self._allUseControl.selectedPage = "hide"
    end
end

function Backpack:RefreshList(isScrollTop, isClearCurData)
    -- local temp = self.curData
    if isClearCurData then
        self.curData = {}
        self.curBoxIndex = -1
    end

    if next(self.curData) then
        self.curBoxIndex = math.ceil(self.curData.index / self.row)
    end

    GD.ItemAgent.CleanItemPanes()
    self.dataCount = self:GetCurDataAmount()
    self._list.numItems = math.ceil(self.dataCount / self.row)

    -- if not isClearCurData then
    --     local item = GD.ItemAgent.GetItemPane(temp.id)
    --     item.onClick:Call()
    -- end

    if isScrollTop then
        self._list.scrollPane:ScrollTop()
    end
end

function Backpack:RefreshStoreList()
    if self.curStoreTag == 0 then
        self._storeList.numItems = #self.hotStoreData
        return
    end
    self.curStoreData = {}
    for _, v in ipairs(self.storeData) do
        if v.page == self.curStoreTag then
            table.insert(self.curStoreData, v)
        end
    end
    self._storeList.numItems = #self.curStoreData
end

function Backpack:GetCurDataAmount()
    local amount = 0
    for _, v in pairs(self.datas) do
        if self.curTag == 0 or self.curTag == v.config.page then
            amount = amount + 1
        end
    end
    return amount
end

function Backpack:GetData(index)
    local curIndex = 0
    for _, v in pairs(self.datas) do
        if self.curTag == 0 or self.curTag == v.config.page then
            curIndex = curIndex + 1
            if curIndex == index then
                v.index = curIndex
                return v
            end
        end
    end
end

function Backpack.Sort(a, b)
    local result = false
    local orderA = a.config.order_num
    local orderB = b.config.order_num
    local idA = a.config.id
    local idB = b.config.id

    if (a.isNew and b.isNew) or (not a.isNew and not b.isNew) then
        if orderA == orderB then
            result = idA < idB
        else
            if orderA ~= nil and orderB then
                result = orderA < orderB
            end
        end
    elseif a.isNew and not b.isNew then
        return true
    else
        return false
    end

    return result
end

function Backpack:InitStoreData()
    if self.storeData then
        return
    end
    self.hotStoreData = {}
    self.storeData = {}
    local configDatas = ConfigMgr.GetList("configShops")
    for _, v in ipairs(configDatas) do
        if BuildModel.GetCenterLevel() >= v.base_lv then
            local itemConfig = ConfigMgr.GetItem("configItems", v.item_id)
            v.page = v.shop_page
            v.color = itemConfig.color
            v.icon = itemConfig.icon

            if v.store_hot then
                table.insert(self.hotStoreData, v)
            end
            if v.store_order then
                table.insert(self.storeData, v)
            end
        end
    end
    table.sort(
        self.hotStoreData,
        function(a, b)
            if a.store_hot ~= b.store_hot then
                return a.store_hot < b.store_hot
            else
                return a.id < b.id
            end
        end
    )
    table.sort(
        self.storeData,
        function(a, b)
            if a.store_order ~= b.store_order then
                return a.store_order < b.store_order
            else
                return a.id < b.id
            end
        end
    )
end

function Backpack:CheckCanUseAll()
    local can = false
    for _, v in pairs(self.datas) do
        if v.config.res_useall and v.config.page == 1 then
            if v.config.type == GlobalItem.ItemTypeEffect then
                if GD.ResAgent.CheckResUnlock(v.config.type2) then
                    can = true
                end
            end
        end
    end

    return can
end

function Backpack:UseAllResource()
    local useItems = {}
    local resItems = {}
    local otherItems = {}
    for _, v in pairs(self.datas) do
        if v.config.res_useall then
            if v.config.page == 1 then
                if v.config.type == GlobalItem.ItemTypeEffect then
                    if GD.ResAgent.CheckResUnlock(v.config.type2) then
                        if resItems[v.config.type2] then
                            resItems[v.config.type2] = resItems[v.config.type2] + v.model.Amount * v.config.value
                        else
                            resItems[v.config.type2] = v.model.Amount * v.config.value
                        end
                        table.insert(useItems, {ConfId = v.model.ConfId, Amount = v.model.Amount})
                    end
                else
                    table.insert(otherItems, v)
                    table.insert(useItems, {ConfId = v.model.ConfId, Amount = v.model.Amount})
                end
            end
        end
    end

    local items = {}
    for k, v in pairs(resItems) do
        local data = {
            icon = GD.ResAgent.GetIconUrl(k),
            title = "",
            amount = "X" .. Tool.FormatNumberThousands(v)
        }
        table.insert(items, data)
    end
    for _, v in pairs(otherItems) do
        local data = {
            icon = UITool.GetIcon(v.config.icon),
            quality = tostring((v.config.color == nil and 0 or v.config.color) + 1),
            title = GD.ItemAgent.GetItemNameByConfId(v.config.id),
            amount = "X" .. v.model.Amount,
            tip = GD.ItemAgent.GetItemInnerContent(v.config.id)
        }
        table.insert(items, data)
    end

    local data = {
        items = items,
        content = StringUtil.GetI18n(I18nType.Commmon, "Use_All_Res"),
        btnOkTitle = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM"),
        cbOk = function()
            Net.Items.BatchUse(
                useItems,
                function(rsp)
                    if rsp.Fail then
                        return
                    end

                    self:RefreshData()
                    self:RefreshList(true, true)

                    TipUtil.TipById(30403)

                    if self:CheckCanUseAll() then
                        -- self._btnUseAll.enabled = true
                        self._btnControl.selectedPage = "normal"
                    else
                        -- self._btnUseAll.enabled = false
                        self._btnControl.selectedPage = "gray"
                    end
                end
            )
        end
    }
    UIMgr:Open("BackpackUseDetails", data)
end

function Backpack:TriggerOnclick(callback)
        self.triggerCallback = callback
end

function Backpack:SetScrollTouchEffect(isEffect)
    self._list.scrollPane.touchEffect = isEffect
end

--通过道具id获取指引按钮位置
function Backpack:GetGuidePosByItem(listItem)
    self._list.scrollPane:SetPosY(listItem.y)
    local listMoveDis = (self._list.scrollPane.posY)
    local disItemY = listItem.y - listMoveDis
    return disItemY
end

--将指定物品显示在界面上
function Backpack:ScrollToViewItem(itemId)
    local index = -1
    for k, v in pairs(self.datas) do
        if v.id == itemId and (self.curTag == 0 or self.curTag == v.config.page) then
            index = k
            break
        end
    end
    if index < 0 then
        return nil
    end
    local lineIndex = math.modf(index / self.row)
    local mod = math.fmod(index, self.row)
    if mod == 0 then
        lineIndex = lineIndex - 1
    end

    self._list:ScrollToView(lineIndex)
end

return Backpack
