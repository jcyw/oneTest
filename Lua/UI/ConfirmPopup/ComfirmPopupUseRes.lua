--[[
    author:{laofu}
    time:2020-07-01 14:22:48
    function:{升级建筑资源不足时一键使用资源道具弹窗}
]]
local GD = _G.GD
local ComfirmPopupUseRes = UIMgr:NewUI("ComfirmPopupUseRes")

function ComfirmPopupUseRes:OnInit()
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "resource_Prop")
    self._btnUse.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CONFIRM")
    self._countText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TOTAL_RESOURCE")

    self:InitEvent()
end

function ComfirmPopupUseRes:InitEvent()
    self:AddListener(
        self._btnClose.onClick,
        function()
            UIMgr:Close("ComfirmPopupUseRes")
        end
    )
    self:AddListener(
        self._touch.onClick,
        function()
            UIMgr:Close("ComfirmPopupUseRes")
        end
    )
    self:AddListener(
        self._btnUse.onClick,
        function()
            self:BtnUseClick()
        end
    )
    self._itemList.itemRenderer = function(index, item)
        local curTotalIndex = 0
        local data = self.sortData[index + 1]
        local conf = ConfigMgr.GetItem("configItems", data.configId)
        item:SetAmount(conf.icon, conf.color, data.num, GD.ItemAgent.GetItemNameByConfId(data.configId), GD.ItemAgent.GetItemInnerContent(data.configId))
    end

    self._numList.itemRenderer = function(index, item)
        local category = self.needResList[index + 1].resType
        local num = 0
        for k,v in pairs(self.data[index + 1]) do
            num = v.num*v.value + num
        end
        
        item:GetChild("_icon").icon = UITool.GetIcon(ConfigMgr.GetItem('configResourcess', category).img)
        item:GetChild("_title").text = Tool.FormatAmountUnit(num)
    end
end

function ComfirmPopupUseRes:OnOpen(needResList,cb)--{resType,needCount}
    self.cb = cb
    self.needResList = needResList
    self.data = {}
    for k,v in pairs(needResList) do
        self.data[#self.data + 1] = GD.ItemAgent.GetUseResMininum(v.resType,v.needCount)
    end
    self.sortData = {}
    for k,v in pairs(self.data)do
        for key,value in pairs(v) do
            self.sortData[#self.sortData+1] = value 
        end
    end
    table.sort(
        self.sortData,
        function(a, b)
            return a.configId < b.configId
        end
    )
    self:RefreshContent()
end

function ComfirmPopupUseRes:RefreshContent()
    local itemListNum = 0
    for k,v in pairs(self.data) do
        for _,_ in pairs(v) do
            itemListNum = itemListNum + 1
        end
    end
    self._itemList.numItems = itemListNum
    self._numList.numItems = #self.needResList
end

function ComfirmPopupUseRes:BtnUseClick()
    local itemAmounts = {}
    local curAmount = 0
    for k,v in pairs(self.data)do
        for key,value in pairs(v) do
            local config = ConfigMgr.GetItem("configItems", value.configId)
            curAmount = curAmount + (value.num * config.value)
            table.insert(itemAmounts, {ConfId = value.configId, Amount = value.num})
        end
    end
    Net.Items.BatchUse(
        itemAmounts,
        function(rsp)
            if rsp.Fail then
                return
            end
            if self.cb then
                self.cb()
            end
            UIMgr:Close("ComfirmPopupUseRes")
            -- TipUtil.TipById(50040, Tool.FormatAmountUnit(curAmount) .. ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. self.curResType))
            -- self:RefreshList()
            -- self:RefreshResource()
        end
    )
    -- local data = {
    --     items = {
    --         [1] = {
    --             icon = GD.ResAgent.GetIconUrl(self.curResType, true),
    --             amount = "X" .. Tool.FormatAmountUnit(curAmount)
    --         }
    --     },
    --     content = ConfigMgr.GetI18n(I18nType.Commmon, "Use_All_Res"),
    --     cbOk = function()
    --         Net.Items.BatchUse(
    --             itemAmounts,
    --             function(rsp)
    --                 if rsp.Fail then
    --                     return
    --                 end

    --                 TipUtil.TipById(50040, Tool.FormatAmountUnit(curAmount) .. ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. self.curResType))
    --                 self:RefreshList()
    --                 self:RefreshResource()
    --             end
    --         )
    --     end
    -- }
end

function ComfirmPopupUseRes:OnClose()
end

return ComfirmPopupUseRes
