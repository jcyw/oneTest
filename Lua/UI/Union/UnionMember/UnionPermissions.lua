--[[
    Author: songzeming
    Function: 联盟成员列表 查看联盟详情
]]
local UnionPermissions = UIMgr:NewUI("UnionMember/UnionPermissions")

local UnionModel = import("Model/UnionModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
import('UI/Union/UnionMember/ItemUnionPermissions')
local StateType = {
    Normal = 1,
    Edit = 2,
    Save = 3
}

function UnionPermissions:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController('Controller')

    self._btnCmpt = UIMgr:CreateObject('Union', 'itemUnionPermissionsBtn')
    self._btn = self._btnCmpt:GetChild('btn')
    self:AddListener(self._btn.onClick,
        function()
            if self.state == StateType.Edit then
                self:OnBtnEditClick()
            elseif self.state == StateType.Save then
                self:OnBtnSaveClick()
            end
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionMember/UnionPermissions')
        end
    )
end

function UnionPermissions:OnOpen()
    local conf = ConfigMgr.GetList('configAlliancePermissions')
    self._list.numItems = #conf
    for k, v in pairs(conf) do
        local item = self._list:GetChildAt(k - 1)
        item:Init(v)
    end
    self.state = StateType.Normal

    if UnionModel.CheckUnionOwner() then
        self.state = StateType.Edit
        self._list:AddChild(self._btnCmpt)
        self:SetBtnText('Button_Modify_Permissions')
    end
end

function UnionPermissions:SetBtnText(state)
    self._btn.title = StringUtil.GetI18n(I18nType.Commmon, state)
end

function UnionPermissions:OnBtnEditClick()
    self.state = StateType.Save
    for i = 1, self._list.numChildren - 1 do
        local item = self._list:GetChildAt(i - 1)
        item:ShowEdit()
    end
    self:SetBtnText('Button_Save')
end

function UnionPermissions:OnBtnSaveClick()
    local data = {}
    local disabledPermissions = {}
    for i = 1, self._list.numChildren - 1 do
        local item = self._list:GetChildAt(i - 1)
        local modify = item:GetModify()
        if modify then
            for _, v in pairs(modify) do
                table.insert(data, v)
                if not v.Enable then
                    disabledPermissions[v.Permission] = v
                end
            end
        end
    end
    Net.Alliances.SetPermission(
        data,
        function()
            self.state = StateType.Edit
            for i = 1, self._list.numChildren - 1 do
                local item = self._list:GetChildAt(i - 1)
                item:ShowSave()
            end
            self:SetBtnText('Button_Modify_Permissions')
            TipUtil.TipById(50159)

            UnionInfoModel.SetPermissions(disabledPermissions)
        end
    )
end

return UnionPermissions
