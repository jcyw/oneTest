--[[
    Author: songzeming
    Function: 联盟成员列表 盟主查看职务申请列表
]]
local UnionOfficerApply = UIMgr:NewUI("UnionMember/UnionOfficerApply")

local SearchUtil = import('Utils/SearchUtil')
local UnionMemberModel = import('Model/Union/UnionMemberModel')
import('UI/Union/UnionMember/ItemMemberSort')

function UnionOfficerApply:OnInit()
    self:AddListener(self._btnSearch.onClick,
        function()
            self:DoSearch()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionMember/UnionOfficerApply')
        end
    )
    self._list.numItems = 2
end

function UnionOfficerApply:OnOpen(officer)
    self.officer = officer
    local applyOfficers = UnionMemberModel.GetApplyOfficersByOfficer(officer)
    local members = UnionMemberModel.GetMembers()

    local conf = ConfigMgr.GetItem('configOfficials', officer)
    local appoint = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Appoint') --任命
    self.post = StringUtil.GetI18n(I18nType.Commmon, conf.name) --职务名称
    self._title.text = appoint .. self.post
    self._inputSearch.text = ''

    local cb_func = function(member)
        self:OnAppiont(member)
    end
    --申请成员列表
    self.listApply = {}
    for _, v in pairs(applyOfficers) do
        for _, vv in pairs(members) do
            if v.UserId == vv.Id and vv.Officer == 0 then
                table.insert(self.listApply, vv)
                break
            end
        end
    end
    --满足可被任命条件的人员(去除已被任命的成员)
    self.listMember = {}
    for _, v in pairs(members) do
        if v.Id ~= Model.Account.accountId then
            table.insert(self.listMember, v)
        end
    end
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        if i == 1 then
            local title = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Management_Applicant')
            item:InitOfficer(cb_func, UITool.GetIcon({"Union", "icon_member_02"}), title, self.listApply)
        elseif i == 2 then
            local title = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Management_All')
            item:InitOfficer(cb_func, UITool.GetIcon({"Union", "icon_member_03"}), title, self.listMember)
        end
    end
end

--点击任命
function UnionOfficerApply:OnAppiont(member)
    local values = {
        player_name = member.Name,
        alliance_position = self.post
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Management_AddConfirm', values),
        sureCallback = function()
            Net.Alliances.SetOfficer(
                member.Id,
                self.officer,
                function()
                    SdkModel.TrackBreakPoint(10050)      --打点
                    member.Officer = self.officer
                    TipUtil.TipById(50156, values)
                    UIMgr:Close('UnionMember/UnionOfficerApply')
                    Event.Broadcast(EventDefines.RefreshUnionOfficer)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--点击搜索
function UnionOfficerApply:DoSearch()
    local text = self._inputSearch.text
    if text == '' then
        TipUtil.TipById(50089)
        return
    end
    local listApply = {}
    for _, v in pairs(self.listApply) do
        if SearchUtil.FuzzySearch(v.Name, text) then
            table.insert(listApply, v)
        end
    end
    local listMember = {}
    for _, v in pairs(self.listMember) do
        if SearchUtil.FuzzySearch(v.Name, text) then
            table.insert(listMember, v)
        end
    end

    local cb_func = function(member)
        self:OnAppiont(member)
    end
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        if i == 1 then
            item:SearchOfficer(cb_func, listApply)
        elseif i == 2 then
            item:SearchOfficer(cb_func, listMember)
        end
    end

    if next(listApply) == nil and next(listMember) == nil then
        TipUtil.TipById(50184)
    end
end

return UnionOfficerApply
