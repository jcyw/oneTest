--[[
    Author: songzeming
    Function: 联盟帮助
]]
local UnionHelp = UIMgr:NewUI("UnionMain/UnionHelp")

import('UI/Union/UnionMain/ItemUnionHelp')
local UnionHelpModel = import("Model/Union/UnionHelpModel")
local CONTROLLER = {
    Help = 'Help',
    No = 'No',
    HelpNo = 'HelpNo'
}

function UnionHelp:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController('Controller')

    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnHelpAll.onClick,
        function()
            self:OnBtnHelpAllClick()
        end
    )
    self:AddListener(view:GetChild("btnHelp").onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1004).article_id)
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceHelpInfoExg,
        function()
            self:UpdateData()
        end
    )
end

function UnionHelp:OnOpen()
    self:UpdateData()
end

function UnionHelp:Close()
    UIMgr:Close("UnionMain/UnionHelp")
end

function UnionHelp:UpdateData()
    local selfInfo = UnionHelpModel.GetUnionHelpSelfInfo()
    local otherInfo = UnionHelpModel.GetUnionHelpOtherInfo()
    if next(selfInfo) == nil and next(otherInfo) == nil then
        --没有帮助信息
        self._list.numItems = 0
        self:SetController(CONTROLLER.No)
        return
    end
    if next(otherInfo) == nil then
        --没有他人帮助信息
        self:SetController(CONTROLLER.HelpNo)
    else
        self:SetController(CONTROLLER.Help)
    end

    self._list.numItems = #selfInfo + #otherInfo
    local sorInfo = Tool.MergeTables(selfInfo, otherInfo)
    for k, v in pairs(sorInfo) do
        local item = self._list:GetChildAt(k - 1)
        item:Init(v, function()
            self:UpdateData()
        end)
    end
end

function UnionHelp:OnBtnHelpAllClick()
    Net.AllianceHelp.All(
        Model.Player.AllianceId,
        function()
            TipUtil.TipById(50120)
            UnionHelpModel.ClearUnionHelpOtherInfo()
        end
    )
end

function UnionHelp:SetController(state)
    if state then
        self._controller.selectedPage = state
        return
    end
    if self._list.numChildren == 0 then
        self._controller.selectedPage = CONTROLLER.No
    else
        self._controller.selectedPage = CONTROLLER.HelpNo
    end
end

return UnionHelp