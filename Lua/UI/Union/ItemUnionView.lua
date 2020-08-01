--[[
    Author: songzeming
    Function: 联盟查看Item
]]
local ItemUnionView = fgui.extension_class(GComponent)
fgui.register_extension('ui://Union/itemUnionView', ItemUnionView)

local BuildModel = import('Model/BuildModel')
local CommonModel = import('Model/CommonModel')
local UnionModel = import('Model/UnionModel')
local UnionInfoModel = import('Model/Union/UnionInfoModel')
local CONTROLLER = {
    Normal = 'Normal',
    Join = 'Join', -- 加入联盟
    Apply = 'Apply', -- 申请联盟
    CancelApply = 'CancelApply', -- 取消联盟申请
    Contact = 'Contact' -- 联系会长
}

function ItemUnionView:ctor()
    self._controller = self:GetController('Controller')

    self:AddListener(self._btnJoin.onTouchBegin,
        function()
            self.clickBtn = true
        end
    )
    self:AddListener(self._btnJoin.onClick,
        function()
            self:OnBtnJoinClick()
        end
    )

    self:AddListener(self._btnApply.onTouchBegin,
        function()
            self.clickBtn = true
        end
    )
    self:AddListener(self._btnApply.onClick,
        function()
            self:OnBtnApplyClick()
        end
    )

    self:AddListener(self._btnCancelApply.onTouchBegin,
        function()
            self.clickBtn = true
        end
    )
    self:AddListener(self._btnCancelApply.onClick,
        function()
            self:OnBtnCancelApplyClick()
        end
    )

    self:AddListener(self._btnContact.onTouchBegin,
        function()
            self.clickBtn = true
        end
    )
    self:AddListener(self._btnContact.onClick,
        function()
            self:OnBtnContactClick()
        end
    )

    self:AddListener(self.onClick,
        function()
            if self.clickBtn then
                self.clickBtn = false
                return
            end
            UIMgr:Open("UnionViewData", self.data.Uuid, self)
        end
    )
end

function ItemUnionView:Init(data)
    --todo 容错
    if data.Language == 0 then
        data.Language = 1
    end

    self.data = data
    self.applyData = false -- 是否已经申请加入该联盟

    self._icon.icon = UnionModel.GetUnionBadgeIcon(data.Emblem)
    self._name.text = '(' .. data.ShortName .. ')' .. data.Name
    self._owner.text = data.President
    self._force.text = Tool.FormatNumberThousands(data.Power)
    local language = ConfigMgr.GetItem("configAlliancelanguages", data.Language).local_text
    self._language.text = StringUtil.GetI18n(I18nType.Commmon, language)
    self._member.text = data.Member .. '/' .. data.MemberLimit
    self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem('configFlags', data.Flag).icon)

    if UnionModel.CheckJoinUnion() then
        -- 查看其他联盟
        self._controller.selectedPage = CONTROLLER.Normal
    else
        if data.Member == data.MemberLimit then
            -- 联盟人数已满 联系会长
            self._controller.selectedPage = CONTROLLER.Contact
        else
            local condLevel = BuildModel.GetCenterLevel() >= data.FreeJoinLevel
            local condPower = Model.Player.Power >= data.FreeJoinPower
            if data.FreeJoin or (condLevel and condPower) then
                -- 满足直接加入联盟的条件
                self._controller.selectedPage = CONTROLLER.Join
            else
                self.applyData = Model.Find(ModelType.AppliedAlliance, data.Uuid)
                if not self.applyData then
                    -- 申请入盟
                    self._controller.selectedPage = CONTROLLER.Apply
                else
                    -- 已经申请 显示取消申请
                    self._controller.selectedPage = CONTROLLER.CancelApply
                end
            end
        end
    end
end

-- 加入联盟
function ItemUnionView:OnBtnJoinClick()
    Net.Alliances.Join(
        self.data.Uuid,
        function(rsp)
            SdkModel.TrackBreakPoint(10047)      --打点
            Model.Player.AllianceId = rsp.Alliance.Uuid
            Model.Player.AllianceName = rsp.Alliance.ShortName
            Model.Player.AlliancePos = Global.AlliancePosR1
            UnionInfoModel.SetInfo(rsp.Alliance)
            UIMgr:Close('UnionView/UnionView')
            Event.Broadcast(EventDefines.UIAllianceJoin)
            TurnModel.UnionView()
        end
    )
end

-- 联盟申请
function ItemUnionView:OnBtnApplyClick()
    UIMgr:Open(
        'UnionApplyPopup',
        self.data.Uuid,
        function()
            self._controller.selectedPage = CONTROLLER.CancelApply
            TipUtil.TipById(50074)
        end
    )
end

-- 取消联盟申请
function ItemUnionView:OnBtnCancelApplyClick()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, 'Alliance_Add_Cancel'),
        sureCallback = function()
            Net.Alliances.CancelApply(
                self.data.Uuid,
                function()
                    self._controller.selectedPage = CONTROLLER.Apply
                    TipUtil.TipById(50140)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 联系会长
function ItemUnionView:OnBtnContactClick()
    local info = {
        subject = self.data.PresidentId,
        subCategory = MAIL_SUBTYPE.subPersonalMsg,
        Receiver = self.data.President
    }
    UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
end

return ItemUnionView
