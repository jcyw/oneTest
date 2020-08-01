local GD = _G.GD
local UIMgr = _G.UIMgr
local PlaneModel = _G.PlaneModel
local ConfigMgr = _G.ConfigMgr
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local TipUtil = _G.TipUtil
local GlobalVars = _G.GlobalVars
local AircraftAccessories = UIMgr:NewUI("AircraftAccessories")
local EventDefines = _G.EventDefines
local RESBOND = ConfigMgr.GetVar("ResBond")
AircraftAccessories.PAGENAME = {
    store = "store",
    bag = "bag"
}
-- 零件的状态  同步ItemAccessBackpack下的STATUS
local partSTATUS = {
    Normal = "normal",
    Occupy = "occupy",
    Waitcheck = "waitcheck",
    Check = "check"
}
local pageStatus = {
    store = "store",
    bagNormal = "bagNormal",
    bagMultiSelect = "bagMultiSelect"
}
function AircraftAccessories:OnInit()
    --获取部件
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._btnSwitch = view:GetChild("btnSwitch")
    self._banner = view:GetChild("_banner")
    self._btnStore = view:GetChild("btnStore")
    self._btnbag = view:GetChild("btnbag")
    self._listBag = view:GetChild("listBag")
    self._listStore = view:GetChild("listStore")
    self._btnSelectAll = view:GetChild("btnSelectAll")
    self._btncancel = view:GetChild("btncancel")
    self._btnsell = view:GetChild("btnsell")
    self._btnMultiSelect = view:GetChild("btnSellAll")
    self._banner = view:GetChild("_banner")
    self._page = view:GetController("page")
    self.Price = view:GetChild("Price")
    self.btnHelp = view:GetChild("btnHelp")
    self._SellPriceTxt = view:GetChild("SellPriceTxt")
    self._sellPriceCount = view:GetChild("sellPriceCount")

    --列表数据
    self._listBagInfos = {}
    self._listStoreInfos = {}
    --当前页面位置
    self.currentPage = nil
    -- 当前是否处于多选模式
    self.isMultiSelect = false
    self.sellPriceCount = 0
    --列表render
    self._listBag:SetVirtual()
    self._listBag.itemRenderer = function(index, item)
        self:SetBagList(index,item)
    end
    --列表render
    self._listStore:SetVirtual()
    self._listStore.itemRenderer = function(index, item)
        self:SetStoreList(index, item)
    end
     --事件
     self:AddListener(self._btnStore.onClick,
        function()
            self:SwitchPage(AircraftAccessories.PAGENAME.store)
        end
    )
    self:AddListener(self._btnbag.onClick,
        function()
            self:SwitchPage(AircraftAccessories.PAGENAME.bag)
        end
    )
    self:AddListener(self._btnSwitch.onClick,
        function()
            UIMgr:Open("AircraftHangar")
            UIMgr:Close("AircraftAccessories")
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("AircraftAccessories")
        end
    )
    self:AddListener(self._btnSelectAll.onClick,
        function()
            self:RestBagListcheck()
        end
    )
    self:AddListener(self._btncancel.onClick,
        function()
            self.isMultiSelect = false
            self:RestBagListStatus()
        end
    )
    self:AddListener(self._btnMultiSelect.onClick,
        function ()
            self.isMultiSelect = true
            self.sellPriceCount = 0
            self:SellPriceCount(self.sellPriceCount)
            self:SetBagMultiSelect()
        end
    )
    self:AddListener(self._btnsell.onClick,
        function ()
            self:Masssale()
        end
    )
    self:AddListener(self.btnHelp.onClick,
        function()
            local dataui = {
                content = StringUtil.GetI18n(_G.I18nType.Commmon, "TIPS_BUY_PLANE_COMPONETS"),
                sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_PLANE_GET"),
                sureCallback = function()
                    PlaneModel.GetResBond()
                end
            }
            UIMgr:Open("ConfirmPopupText", dataui)
        end
    )
    -- 点击购买零件
    self:AddListener(self._listStore.onClickItem,function(context)
        local item = context.data
        local index = item:GetIndex()
        local itemInfo = self._listStoreInfos[index]
        local BuyClick = function ()
            if GD.ResAgent.Amount(RESBOND, false) >= itemInfo.buy_price then
                PlaneModel.BuyPlanePart(itemInfo.id, function ()
                    TipUtil.TipById(50199)
                end)
            else
                local dataui = {
                    content = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_PLANE_POINT_UNENOUGH"),
                    sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_PLANE_GET"),
                    sureCallback = function()
                        PlaneModel.GetResBond()
                    end
                }
                UIMgr:Open("ConfirmPopupText", dataui)
            end
        end
        local ItemClick = function()
            local data = {
                title = "BUTTON_BUY_COMPONETS",
                name = itemInfo.name,
                image = itemInfo.image,
                color = itemInfo.color,
                buy_price = itemInfo.buy_price,
                sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_LABEL_BUY"),
                callback = BuyClick
            }
            UIMgr:Open("AircraftStorePopup",data)
        end
        ItemClick()
    end)
     -- 点击出售零件
     self:AddListener(self._listBag.onClickItem,function(context)
        local item = context.data
        if item:IsOccupy() then
            TipUtil.TipById(50358)
            return
        end
        local index = item:GetIndex()
        local itemInfo = self._listBagInfos[index]
        if not itemInfo then
            return
        end
        local SellCb = function ()
            TipUtil.TipById(50356)
        end
        local SellClick = function ()
            PlaneModel.SellPlanePart({itemInfo.partInfo.Uuid}, SellCb)
        end
        local ItemSelectClick= function ()
            if itemInfo.status ==  partSTATUS.Waitcheck then
                itemInfo.status = partSTATUS.Check
                self.sellPriceCount = self.sellPriceCount+itemInfo.config.buy_price
                self:SellPriceCount(self.sellPriceCount)
                item:SetCheck()
            elseif itemInfo.status ==  partSTATUS.Check then
                itemInfo.status = partSTATUS.Waitcheck
                self.sellPriceCount = self.sellPriceCount-itemInfo.config.buy_price
                self:SellPriceCount(self.sellPriceCount)
                item:SetWaitcheck()
            end
        end
        local ItemClick = function()
            if self.isMultiSelect then
                ItemSelectClick()
                return
            end
            local data = {
                title = "UI_LABEL_SELL",
                name = itemInfo.config.name,
                image = itemInfo.config.image,
                color = itemInfo.config.color,
                buy_price = itemInfo.config.buy_price,
                sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_LABEL_SELL"),
                callback = SellClick
            }
            UIMgr:Open("AircraftStorePopup",data)
        end
        ItemClick()
    end)
    self:AddEvent(
        EventDefines.UpdataPartInfos,
        function()
            if UIMgr:GetUIOpen("AircraftAccessories") then
                if self.currentPage ~= AircraftAccessories.PAGENAME.bag then
                    return
                end
                self:SetBagListInfo()
            end
        end
    )
    self:AddEvent(
        EventDefines.UIResourcesAmount,
        function()
            self:SetResBondView()
        end
    )
    -- 加载_banner
    self._banner.icon = _G.UITool.GetIcon({"equip_plane","storebanner"})

    -- 国际化
    self._SellPriceTxt.text = ("%s:"):format(StringUtil.GetI18n(I18nType.Commmon,"Ui_AllianceTech_Total"))
    self._btnMultiSelect.title = StringUtil.GetI18n(I18nType.Commmon,"BUTTON_BATCH_SELL")
    self._btncancel.title = StringUtil.GetI18n(I18nType.Commmon,"BUTTON_NO")
    self._btnsell.title = StringUtil.GetI18n(I18nType.Commmon,"BUTTON_SELL_ALL")
    self._btnSelectAll.title = StringUtil.GetI18n(I18nType.Commmon,"Button_Choose_All")
end
function AircraftAccessories:OnOpen(isBag)
    self.isMultiSelect = false
    -- 如果没有设定打开页面 就打开商店
    self:SwitchPage(isBag and AircraftAccessories.PAGENAME.bag or AircraftAccessories.PAGENAME.store )
    self:SetResBondView()
end
function AircraftAccessories:SellPriceCount(price)
    self._sellPriceCount:SetCost(price)
    local widthCmp = self._sellPriceCount.width + self._SellPriceTxt.width
    self._SellPriceTxt.x = (GlobalVars.ScreenStandard.width - widthCmp)*0.5
    self._sellPriceCount.x = self._SellPriceTxt.width +self._SellPriceTxt.x
end

-- 刷新战争券显示
function AircraftAccessories:SetResBondView()
    self.Price:SetCost(GD.ResAgent.Amount(RESBOND, false))
end
function AircraftAccessories:SetBagList(index,item)
    local itemInfo = self._listBagInfos[index+1]
    item:SetData({
        quality = itemInfo.config.color,
        icon = itemInfo.config.image,
        status = itemInfo.status,
        index = index+1
    })
    if itemInfo.status == partSTATUS.Occupy then
        item:SetOccupyTxt(StringUtil.GetI18n(I18nType.Commmon,"LABEL_COMPONETS_USING"))
    end
end
function AircraftAccessories:SetStoreList(index,item)
    local itemInfo = self._listStoreInfos[index+1]
    item:SetData({
        quality = itemInfo.color,
        icon = itemInfo.image,
        name = itemInfo.name,
        cost = itemInfo.buy_price,
        index = index+1
    })
end
--复位背包状态
function AircraftAccessories:RestBagListStatus()
    for _,v in pairs(self._listBagInfos) do
        v.status = v.status ~= partSTATUS.Occupy and partSTATUS.Normal or partSTATUS.Occupy
    end
    self._listBag:RefreshVirtualList()
    self._page.selectedPage = pageStatus.bagNormal
end
--全选背包
function AircraftAccessories:RestBagListcheck()
    self.sellPriceCount = 0
    self.isSeletAll = not self.isSeletAll
    for _,v in pairs(self._listBagInfos) do
        if v.status ~= partSTATUS.Occupy then
            v.status = self.isSeletAll and partSTATUS.Check or partSTATUS.Waitcheck
            if self.isSeletAll then
                self.sellPriceCount = self.sellPriceCount+v.config.buy_price
            end
        end
    end
    local l18key = self.isSeletAll and "UI_PLANE_CHOOSE_CANCEL" or "Button_Choose_All"
    self._btnSelectAll.title = StringUtil.GetI18n(I18nType.Commmon,l18key)
    self:SellPriceCount(self.sellPriceCount)
    self._listBag:RefreshVirtualList()
end
--设置背包状态为多选模式
function AircraftAccessories:SetBagMultiSelect()
    for _,v in pairs(self._listBagInfos) do
        v.status = v.status ~= partSTATUS.Occupy and partSTATUS.Waitcheck or partSTATUS.Occupy
    end
    self._listBag:RefreshVirtualList()
    self._page.selectedPage = pageStatus.bagMultiSelect
end
-- 批量出售
function AircraftAccessories:Masssale()
    local SellList = {}
    for _,v in pairs(self._listBagInfos) do
        if v.status == partSTATUS.Check then
            table.insert(SellList,v.partInfo.Uuid)
        end
    end
    if #SellList == 0 then
        TipUtil.TipById(50368)
        return
    end
    self.sellPriceCount = 0
    self:SellPriceCount(self.sellPriceCount)
    local net_func = function ()
        self.isMultiSelect = false
        self:RestBagListStatus()
        TipUtil.TipById(50356)
    end
    PlaneModel.SellPlanePart(SellList, net_func)
end
-- 换页
function AircraftAccessories:SwitchPage(page)
    if self.currentPage == page then
        return
    end
    self.isMultiSelect = false
    self.currentPage = page
    self:SetPageView()
    if self.currentPage == AircraftAccessories.PAGENAME.bag then
        self:SetBagListInfo()
        self._btnStore.selected = false
        self._btnbag.selected = true
    else
        self:SetStoreListInfo()
        self._btnStore.selected = true
        self._btnbag.selected = false
    end
end
--设置商店背包页面切换时 一些界面组件的显示隐藏 以及状态
function AircraftAccessories:SetPageView()
    self._page.selectedPage =
        self.currentPage == AircraftAccessories.PAGENAME.bag and pageStatus.bagNormal or pageStatus.store
end
function AircraftAccessories:SetBagListInfo()
    local partbag = PlaneModel.GetPartListInfos()
    if not partbag then
        return
    end
    self._listBagInfos = {}
    for _,v in pairs(partbag) do
        if v.IsShow then
            table.insert(self._listBagInfos,{
                partInfo = v,
                config = PlaneModel.GetPartConfByID(v.PartId),
                status = v.IsUsed and partSTATUS.Occupy or partSTATUS.Normal
            })
        end
    end
    table.sort(self._listBagInfos,function (a, b)
        return a.config.order < b.config.order
    end)
    self._listBag.numItems = #self._listBagInfos
    self._listBag.scrollPane:ScrollTop()
end
function AircraftAccessories:SetStoreListInfo()
    local partList = PlaneModel.GetPartsConf()
    self._listStoreInfos = {}
    for _,v in pairs(partList) do
        table.insert(self._listStoreInfos,v)
    end
    table.sort(self._listStoreInfos,function (a, b)
        return a.order < b.order
    end)
    self._listStore.numItems = #self._listStoreInfos
    self._listStore.scrollPane:ScrollTop()
end
return AircraftAccessories