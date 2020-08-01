--[[
    Author: songzeming
    Function: 联盟详情信息
]]
local UnionViewData = UIMgr:NewUI("UnionViewData")

local BuildModel = import("Model/BuildModel")
local UnionModel = import("Model/UnionModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionMemberModel = import("Model/Union/UnionMemberModel")
local CONTROLLER = {
    Normal = "Normal",
    Join = "Join", -- 加入联盟
    Apply = "Apply", -- 申请联盟
    CancelApply = "CancelApply", -- 取消联盟申请
    Contact = "Contact" -- 联系会长
}

function UnionViewData:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")

    self:AddListener(self._btnMessage.onClick,
        function()
            self:OnBtnMessageClick()
        end
    )
    self:AddListener(self._btnPresident.onClick,
        function()
            self:OnBtnPresidentClick()
        end
    )
    self:AddListener(self._btnMember.onClick,
        function()
            self:OnBtnMemberClick()
        end
    )
    self:AddListener(self._btnApply.onClick,
        function()
            self:OnBtnApplyClick()
        end
    )
    self:AddListener(self._btnCancelApply.onClick,
        function()
            self:OnBtnCancelApplyClick()
        end
    )
    self:AddListener(self._btnJoin.onClick,
        function()
            self:OnBtnJoinClick()
        end
    )
    self:AddListener(self._btnContact.onClick,
        function()
            self:OnBtnPresidentClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionViewData")
        end
    )
    self:AddListener(self._btnTranslate.onClick,
        function()
            if self.isTranslated then
                self.isTranslated = false
                -- self._textContent.text = content
                self._TranslateDesc = self._Desc
                self:Show(self.info)
            else
                self.isTranslated = true
                Net.Chat.Translate(3, self.data.Uuid, {self._Desc}, function(msg)
                    -- self._textContent.text = msg.Content[1]
                    self._TranslateDesc = msg.Content[1]
                    self:Show(self.info)
                end)
            end
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionManager)
end

function UnionViewData:OnOpen(allianceId, context)
    -- 初始化
    self.isTranslated = false 
    self._controller.selectedPage = CONTROLLER.Normal
    self.context = context
    self._textContent.text = ""

    if not allianceId then
        allianceId = Model.Player.AllianceId
    end
    self.allianceId = allianceId
    self.isMine = allianceId == Model.Player.AllianceId

    if self.isMine then
        -- 获取自己联盟信息
        UnionModel.GetMineUnionInfo(
            function()
                self.info = UnionInfoModel.GetInfo()
                self:Show(self.info)
                self._btnPresident.enabled = not UnionModel.CheckUnionOwner()
            end
        )
    else
        -- 获取其他联盟信息
        self._btnPresident.enabled = true
        UnionModel.GetUnionInfo(
            function(data)
                if not UnionModel.CheckJoinUnion() then
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
                self.info = data
                self:Show(data)
            end,
            allianceId
        )
        return
    end
end


-- 联盟显示
function UnionViewData:Show(data)
    --todo 容错
    if data.Language == 0 then
        data.Language = 1
    end

    self.data = data
    --self._icon.icon = UnionModel.GetUnionBadgeIcon(data.Emblem)
    self._medal:SetMedal(data.Emblem,Vector3(70,70,70))
    local conf = ConfigMgr.GetItem("configFlags", data.Flag)
    self._flag.icon = UITool.GetIcon(conf.icon)
    self._name.text = "(" .. data.ShortName .. ")" .. data.Name
    local language = ConfigMgr.GetItem("configAlliancelanguages", data.Language).local_text
    self._language.text = StringUtil.GetI18n(I18nType.Commmon, language)
    if self._language.width >189 then
        self._language.width = 189
        self._language.autoSize = 3
    end
    self._owner.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Position_Boss") .. ": " .. data.President
    self._force.text = Tool.FormatNumberThousands(data.Power)
    self._member.text = data.Member .. "/" .. data.MemberLimit
    self._Desc = data.Desc
    local content
    if not self.isTranslated then
        content = data.Desc .. "\n\n"
    else
        content = self._TranslateDesc .. "\n\n"
    end
    local i18n
    if data.FreeJoin then
        i18n = StringUtil.GetI18n(I18nType.Commmon, "Alliance_recruit_notice")
        content = content .. i18n
    else
        i18n = StringUtil.GetI18n(I18nType.Commmon, "Alliance_recruit_TXT") .. "\n\n"
        content = content .. i18n
        i18n = StringUtil.GetI18n(I18nType.Commmon, "Alliance_recruit_QA")
        content = content .. i18n .. "≥" .. data.FreeJoinLevel .. "\n\n"
        i18n = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power")
        content = content .. i18n .. "≥" .. data.FreeJoinPower
    end
    self._textContent.text = content
end

-- 点击申请入盟
function UnionViewData:OnBtnApplyClick()
    UIMgr:Open(
        "UnionApplyPopup",
        self.data.Uuid,
        function()
            self._controller.selectedPage = CONTROLLER.CancelApply
            if self.context then
                self.context._controller.selectedPage = CONTROLLER.CancelApply
            end
            TipUtil.TipById(50074)
        end
    )
end
-- 点击取消申请
function UnionViewData:OnBtnCancelApplyClick()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_Add_Cancel"),
        sureCallback = function()
            Net.Alliances.CancelApply(
                self.data.Uuid,
                function()
                    self._controller.selectedPage = CONTROLLER.Apply
                    if self.context then
                        self.context._controller.selectedPage = CONTROLLER.Apply
                    end
                    TipUtil.TipById(50140)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
-- 点击加入联盟
function UnionViewData:OnBtnJoinClick()
    Net.Alliances.Join(
        self.data.Uuid,
        function(rsp)
            SdkModel.TrackBreakPoint(10047)      --打点
            Model.Player.AllianceId = rsp.Alliance.Uuid
            Model.Player.AllianceName = rsp.Alliance.ShortName
            Model.Player.AlliancePos = Global.AlliancePosR1
            UnionInfoModel.SetInfo(rsp.Alliance)
            UIMgr:Close("UnionView/UnionView")
            UIMgr:Close("UnionViewData")
            Event.Broadcast(EventDefines.UIAllianceJoin)
            TurnModel.UnionView()
        end
    )
end
-- 点击帮会留言
function UnionViewData:OnBtnMessageClick()
    UIMgr:Open("UnionMessage", self.allianceId)
end
-- 点击联系会长
function UnionViewData:OnBtnPresidentClick()
    local info = {
        subject = self.data.PresidentId,
        subCategory = MAIL_SUBTYPE.subPersonalMsg,
        Receiver = self.data.President
    }
    UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
end
-- 点击帮会成员
function UnionViewData:OnBtnMemberClick()
    if self.isMine and next(UnionMemberModel.GetMembers()) ~= nil then
        UIMgr:ReOpen("UnionMember/UnionMember")
    else
        --断点查询没有找到数据缺失的地方，所以这里还是做个判空操作
        if not self.data.Uuid then
            return
        end
        Net.Alliances.Info(self.data.Uuid, function(rsp)
            UIMgr:ReOpen("UnionMember/UnionMember", rsp)
        end)
    end
end

return UnionViewData
