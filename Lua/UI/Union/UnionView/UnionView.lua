--[[
    Author: songzeming
    Function: 联盟查看
]]
local UnionView = UIMgr:NewUI("UnionView")

local BuildModel = import("Model/BuildModel")
local UnionModel = import("Model/UnionModel")
import("UI/Union/ItemUnionView")
local CONTROLLER = {
    CreateFree = "CreateFree",
    CreateGold = "CreateGold",
    CreateBan = "CreateBan",
    View = "View"
}

function UnionView:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")

    self._list.itemRenderer = function(index, item)
        if next(self.unionList) == nil then
            return
        end
        item:Init(self.unionList[index + 1])
    end
    self._list:SetVirtual()
    self:AddListener(self._list.scrollPane.onPullUpRelease,function()
        if not self.isSearch then
            self:UnionListShow()
        end
    end)

    self._textGold = self._btnCreateGold:GetChild("text")
    self._textGold.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Create2")
    self:AddListener(self._btnCreateGold.onClick,function()
        self:ShowCreate()
    end)
    self:AddListener(self._btnCreate.onClick,function()
        self:ShowCreate()
    end)
    self:AddListener(self._btnCreateGray.onClick,function()
        TipUtil.TipById(50182)
    end)
    self:AddListener(self._btnSearch.onClick,function()
        self:DoSearch()
    end)
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("UnionView/UnionView")
    end)
end

function UnionView:OnOpen()
    UIMgr:Close("FalconActivitisePopup")
    self.unionList = {}
    self.isSearch = false
    self._inputSearch.text = ""
    self._list.numItems = 0
    self:CheckCreate()
    self.offset = 0
    self:UnionListShow()

    --联盟加入创建推送
    self:PushCreate()
end

function UnionView:GetController(state)
    return self._controller.selectedPage == state
end

function UnionView:SetController(state)
    self._controller.selectedPage = state
end

function UnionView:ShowCreate()
    UIMgr:Open("UnionView/UnionCreate")
end

--检查是否可以创建联盟
function UnionView:CheckCreate()
    if UnionModel.CheckJoinUnion() then
        --已经加入联盟
        self:SetController(CONTROLLER.View)
        return
    end

    local centerLv = BuildModel.GetCenterLevel()
    if centerLv < Global.AllianceCreateByGemLv then
        --无法创建联盟
        self:SetController(CONTROLLER.CreateBan)
    elseif centerLv >= Global.AllianceCreateByFreeLv then
        --免费创建联盟
        self:SetController(CONTROLLER.CreateFree)
    else
        --金币创建联盟
        self:SetController(CONTROLLER.CreateGold)
    end
end

--搜索联盟
function UnionView:DoSearch()
    local name = self._inputSearch.text
    if name == "" then
        TipUtil.TipById(50089)
        return
    end
    Net.Alliances.Search(name, function(rsp)
        local count = #rsp.Alliances
        if count == 0 then
            TipUtil.TipById(50300)
            return
        end
        self:CheckCreate()
        self.isSearch = true
        self.unionList = rsp.Alliances
        self._list.numItems = #self.unionList
        self._list:RefreshVirtualList()
    end)
end

--联盟下拉列表展示
function UnionView:UnionListShow()
    Net.Alliances.GetPage(self.offset, UnionType.VIEW_UNION_COUNT, function(rsp)
        if next(rsp.Alliances) == nil then
            if self._list.numChildren == 0 then
                TipUtil.TipById(50185)
            end
            return
        end
        Tool.MergeDiffTables(self.unionList, rsp.Alliances)
        self.offset = rsp.Offset
        self._list.numItems = rsp.Offset
        self._list:RefreshVirtualList()
    end)
end

--联盟加入创建推送
function UnionView:PushCreate()
    --是否已经有联盟
    if UnionModel.CheckJoinUnion() then
        return
    end
    --是否已经加入(创建)过联盟
    if not Model.Player.FirstJoinUnion then
        return
    end
    --不满足创建联盟要求
    if Model.Player.Level < Global.AllianceCreateByGemLv then
        return
    end

    UIMgr:Open("UnionView/UnionPushJoinCreate")
end

return UnionView
