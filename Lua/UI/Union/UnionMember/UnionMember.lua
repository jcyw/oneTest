--[[
    Author: songzeming
    Function: 联盟成员列表界面
]]
local UnionMember = UIMgr:NewUI("UnionMember/UnionMember")

local UnionModel = import('Model/UnionModel')
local UnionMemberModel = import('Model/Union/UnionMemberModel')
import('UI/Union/UnionMember/ItemMemberPost')
import('UI/Union/UnionMember/ItemMemberSort')
local function GetPos(index)
    return 5 - index + 1
end

function UnionMember:OnInit()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionMember/UnionMember")
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("UnionMember/UnionPermissions")
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceMemberUpdate,
        function()
            self.isUpdate = false
            self:UpdateData()
        end
    )
    self:AddEvent(EventDefines.RefreshUnionOfficer, function()
        self:ListPostShow() 
    end)
end

function UnionMember:OnOpen(unionInfo)
    self.unionInfo = unionInfo

    if not unionInfo then
        --自己联盟
        self.isMine = true
        self.members = UnionMemberModel.GetMembers()
    else
        --其他联盟
        self.isMine = false
        self.members = unionInfo.Members
    end
    self._btnHelp.visible = self.isMine --自己联盟显示联盟权限
    self.isUpdate = false
    self:UpdateData()
end

function UnionMember:UpdateData()
    self:ShowList()
    self:ListPostShow() --官员列表
    self:ListSortShow() --成员列表
    self.isUpdate = true
end

--检测是否显示申请列表
function UnionMember:CheckShowApply()
    return self.isMine and UnionModel.CheckViewApply()
end

--设置列表显示
function UnionMember:ShowList()
    self.postNum = UnionType.MEMBER_POST_COUNT
    self.sortNum = UnionType.MEMBER_SORT_COUNT
    if self:CheckShowApply() then
        --有权限审批 获取入盟申请
        Net.Alliances.GetAllApplies(Model.Player.AllianceId, function(rsp)
            UnionMemberModel.SetApplys(rsp.AllianceApplies)
            self:ListSortShow()
            --刷新提示点
            CuePointModel.SubType.Union.UnionMember.NumberN = #rsp.AllianceApplies
            CuePointModel:CheckUnion()
            Event.Broadcast(EventDefines.UIUnionMainMember)
        end)
    else
        self.sortNum = self.sortNum - 1
    end
    self.totalNum = self.postNum + self.sortNum
    self._list.numItems = self.totalNum
end

--展示官员列表
function UnionMember:ListPostShow()
    local arr = {}
    for _, v in pairs(self.members) do
        if v.Officer and v.Officer > 0 then
            arr[v.Officer] = v
        end
    end
    for i = 1, self.postNum do
        local item = self._list:GetChildAt(i - 1)
        item:Init(i, arr[i], self.isMine)
    end
end

--展示成员列表
function UnionMember:ListSortShow()
    local sortMembers = UnionMemberModel.FormatMembers(self.members)
    for i = self.postNum + 1, self.totalNum do
        local item = self._list:GetChildAt(i - 1)
        local index = GetPos(i - self.postNum)
        local member = sortMembers[index]
        item:InitMember(index, member, self.isMine, self.isUpdate)
        if not self.isMine then
            local name = UnionModel.GetAppellation(index, self.unionInfo.Alliance)
            item:SetAppellation(name)
        end
    end
end

return UnionMember
