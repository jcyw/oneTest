--[[
    Author: songzeming
    Function: 联盟成员列表 职位显示Item
]]
local ItemMemberPost = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/itemUnionMember', ItemMemberPost)

local UnionMemberModel = import('Model/Union/UnionMemberModel')
local CONTROLLER = {
    Normal = 'Normal',
    Appoint = 'Appoint' --任命
}

function ItemMemberPost:ctor()
    self._controller = self:GetController('Controller')

    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )
end

function ItemMemberPost:Init(index, member, isMine)
    self.index = index
    self.member = member
    self.isMine = isMine
    self.isOwner = UnionModel.CheckUnionOwner()

    local conf = ConfigMgr.GetItem('configOfficials', index)
    self._iconSmall.icon = UITool.GetIcon(conf.small_icon)
    self._post.text = StringUtil.GetI18n(I18nType.Commmon, conf.name)

    self:SetApply()
    if not member then
        -- self._icon.icon = UITool.GetIcon(conf.head_icon)
        self._icon:SetAvatar(conf.head_icon, "custom")
        if isMine then
            if not self.isOwner then
                self._name.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Free_Position')
            end
        else
            self._name.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Free_Position')
        end
    else
        -- CommonModel.SetUserAvatar(self._icon, member.Avatar, member.UserId)
        self._icon:SetAvatar(member, nil, member.UserId)
        self._name.text = member.Name
    end
end

--申请官员列表
function ItemMemberPost:SetApply()
    self.isApply = false --成员是否申请过该职务
    self._imageAdd.visible = false
    if self.isOwner then
        --盟主
        self._imageAdd.visible = not self.member --只有盟主且该职位空着时显示
        self._controller.selectedPage = not self.member and CONTROLLER.Appoint or CONTROLLER.Normal
    else
        --成员
        self._controller.selectedPage = CONTROLLER.Normal
        local applyOfficers = UnionMemberModel.GetApplyOfficersByOfficer(self.index)
        for _, v in pairs(applyOfficers) do
            if Model.Account.accountId == v.UserId then
                self.isApply = true
                return
            end
        end
    end
end

--职位列表显示
function ItemMemberPost:OnBtnClick()
    if self.isMine then
        if self.isOwner then
            if not self.member then
                --盟主点击 任命官员
                Net.Alliances.GetApplyOfficers(function(rsp)
                    UnionMemberModel.SetApplyOfficers(rsp.ApplyOfficers)
                    UIMgr:Open("UnionMember/UnionOfficerApply", self.index)
                end)
            else
                -- 盟主点击 查看详情
                self:ShowAppiontDetail(true)
            end
        else
            if not self.member then
                --申请官员
                self:OnApply()
            else
                --查看自己联盟官员信息
                self:ShowAppiontDetail(false)
            end
        end
    else
        if self.member then
            --查看其他联盟官员信息
            self:ShowAppiontDetail(false)
        end
    end
end

--查看职务人员详情
function ItemMemberPost:ShowAppiontDetail(isOfficer)
    UIMgr:Open("UnionMember/UnionMemberDetail", self.member, self.isMine, isOfficer)
end

--点击申请职务
function ItemMemberPost:OnApply()
    if self.isApply then
        --已经申请过
        TipUtil.TipById(50148)
        return
    end
    --申请职务确认提示
    local conf = ConfigMgr.GetItem('configOfficials', self.index)
    local values = {
        post = StringUtil.GetI18n(I18nType.Commmon, conf.name)
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Management_Confirm', values),
        sureCallback = function()
            Net.Alliances.ApplyOfficer(
                Model.Account.accountId,
                self.index,
                function()
                    self.isApply = true
                    TipUtil.TipById(50149)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

return ItemMemberPost
