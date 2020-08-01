--[[
    Author: songzeming
    Function: 联盟成员列表 成员详情界面
]]
local UnionMemberDetail = UIMgr:NewUI("UnionMember/UnionMemberDetail")

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local ArmiesModel = import("Model/ArmiesModel")
local UIType = _G.GD.GameEnum.UIType
local TOTAL_NUMBER = 10 --按钮总数
import("UI/Union/UnionMember/ItemUnionMemberDetail")

function UnionMemberDetail:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    GuidePanelModel:SetParentUI(self, UIType.UnionAidUI)

    self:AddListener(self._btnMask.onClick,
        function()
            self:Close()
        end
    )
end

function UnionMemberDetail:OnOpen(member, isMine, isOfficer)
    self.member = member
    -- CommonModel.SetUserAvatar(self._head, member.Avatar, member.Id)
    self._head:SetAvatar(member, nil, member.Id)
    self._name.text = member.Name
    -- self._desc.text = ""
    self._desc.visible = false
    local avatarConf = ConfigMgr.GetList("configAvatars")[member.Bust]
    self._heroImg.icon = UITool.GetIcon(avatarConf.bust)

    local isMemberOfficer = member.Officer and member.Officer > 0
    if isMemberOfficer then
        --联盟官员 增益效果
        local conf = ConfigMgr.GetItem("configOfficials", member.Officer)
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, conf.describe)
    end

    for i = 1, TOTAL_NUMBER do
        self["_btn" .. i].visible = false
    end
    local idxArr
    if isMine then
        --查看自己联盟信息
        if member.Id == Model.Account.accountId then
            --查看自己信息
            return
        else
            --查看其他成员信息
            local conf = ConfigMgr.GetItem("configManagementViews", Model.Player.AlliancePos)
            local copyArr = conf["r" .. member.Position]
            idxArr = {}
            for _, v in ipairs(copyArr) do
                local confItem = ConfigMgr.GetItem("configMemberViews", v)
                if confItem.name == "Button_Recall" then
                    if isMemberOfficer then
                        table.insert(idxArr, v)
                    end
                else
                    table.insert(idxArr, v)
                end
            end
            if _G.Tool.Time() - self.member.ActiveAt >= _G.Global.ReplacePresidentOfflineFree and Model.Player.AlliancePos <ALLIANCEPOS.R3 and member.Position == ALLIANCEPOS.R5 then
                table.insert(idxArr, 9)
            end
        end
    else
        --查看其他联盟成员信息/本联盟官员
        local conf = ConfigMgr.GetItem("configManagementViews", 0)
        idxArr = conf["r" .. member.Position]
        if not isOfficer then
            --查看其他联盟成员信息
            local arr = {}
            for _, v in ipairs(idxArr) do
                local confItem = ConfigMgr.GetItem("configMemberViews", v)
                if confItem.name ~= "Button_Recall" then
                    --查看其他联盟成员去除罢免
                    table.insert(arr, v)
                end
            end
            idxArr = arr
        end
    end
    if not idxArr then
        return
    end
    for i, v in ipairs(idxArr) do
        local conf = ConfigMgr.GetItem("configMemberViews", v)
        local item = self["_btn" .. i]
        local icon = UITool.GetIcon(conf.icon)
        local title = StringUtil.GetI18n(I18nType.Commmon, conf.name)
        if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 0 and conf.name == "Button_playerDetails" then
            if not self.guideItem then
                self.guideItem = UIMgr:CreateObject("Common", "Guide")
                self.guideItem:SetXY((item.width - self.guideItem.width)/2, (item.height - self.guideItem.height)/2)
                item:AddChild(self.guideItem)
            end
            GuidedModel._changeNamePlayerId = member.Id
        end
        item:Init(
            icon,
            title,
            function()
                self:OnBtnClick(conf.name)
            end
        )
    end
    local isGuild = GuidePanelModel:IsGuideState(UIType.UnionBtnUI)
    if isGuild then
        local isFind = false
        for k, v in pairs(idxArr) do
            local confItem = ConfigMgr.GetItem("configMemberViews", v)
            if confItem.name == GuidePanelModel.unionItemName then
                isFind = true
                break
            end
        end
        if isFind then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionAidUI)
        end
    end
end

function UnionMemberDetail:OnBtnClick(name)
    if name == "Button_Invitation_move" then
        -- 邀请迁移
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Ui_Instructions_confirm"),
            sureCallback = function()
                Net.Alliances.AllianceOrder(
                    self.member.Id,
                    20003,
                    function()
                        TipUtil.TipById(50240)
                    end
                )
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    elseif name == "Button_playerDetails" then
        if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 0 then
            GuidedModel._changeNameStep = 1
            if self.guideItem then
                self.guideItem:RemoveFromParent()
            end
        end
        TurnModel.PlayerDetails(self.member.Id)
        self:Close()
    elseif name == "Button_AssistanceForce" then
        self:OnBtnArmyHelpClick()
    elseif name == "BUTTON_AIDRESOURCES" then
        self:OnBtnResHelpClick()
    elseif name == "Button_AllianceOrder" then
        -- 联盟指令
        UIMgr:Open("UnionInstructionsPopup", 1, self.member.Id)
    elseif name == "Button_Expulsion" then
        self:OnBtnRemoveClick()
    elseif name == "Button_Promotion" then
        self:OnBtnChangePos(1)
    elseif name == "Button_AllianceDemotion" then
        self:OnBtnChangePos(-1)
    elseif name == "Button_Replace" then
        self:OnBtnReplaceClick()
    elseif name == "Ui_ApplicationInformation" then
        -- 申请信息
        local msg = ""
        if self.member.Msg == "" then
            msg = StringUtil.GetI18n(I18nType.Commmon, "Ui_Application_None")
        else
            msg = self.member.Msg
        end
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = msg
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    elseif name == "Button_Agree" then
        self:OnBtnReviewClick(true)
    elseif name == "Button_Disagree" then
        self:OnBtnReviewClick(false)
    elseif name == "Button_Mail" then
        -- 信件
        local info = {}
        info.subject = self.member.Id
        info.subCategory = MAIL_SUBTYPE.subPersonalMsg
        info.Receiver = self.member.Name
        UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
        self:Close()
    elseif name == "Ui_Replace_Boss" then
        self:OnBtnTransferClick()
    elseif name == "Button_Recall" then
        self:OnBtnRecallClick()
    end
end

-- 关闭界面
function UnionMemberDetail:Close()
    UIMgr:Close("UnionMember/UnionMemberDetail")
end

function UnionMemberDetail:OnClose()
    Event.Broadcast(EventDefines.CloseGuide)
end

--部队援助
function UnionMemberDetail:OnBtnArmyHelpClick()
    if ArmiesModel.CheckMissionLimit() then
        self:Close()
        return
    end

    local confId = Global.BuildingUnionBuilding -- 联盟大厦
    if BuildModel.CheckExist(confId) then
        Net.AllianceBattle.AssistLimit(
            self.member.Id,
            self.member.X,
            self.member.Y,
            function(rsp)
                if rsp.Fail then
                    return
                end

                if rsp.Max > 0 then
                    local posNum = self.member.X * 10000 + self.member.Y
                    UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.JoinUnionDefense)
                    UIMgr:Close("UnionMember/UnionMemberDetail")
                else
                    TipUtil.TipById(50070)
                end
            end
        )
    else
        TipUtil.TipById(50071)
    end
end

--资源援助
function UnionMemberDetail:OnBtnResHelpClick()
    if ArmiesModel.CheckMissionLimit() then
        self:Close()
        return
    end

    local confId = Global.BuildingTransferStation -- 资源中转站
    if BuildModel.CheckExist(confId) then
        Net.AllianceAssist.AssistInfo(
            self.member.Id,
            function(rsp)
                if rsp.Fail then
                    return
                end
                UIMgr:Open("UnionWarehouseAccessResources", 1, rsp)
                UIMgr:Close("UnionMember/UnionMemberDetail")
            end
        )
    else
        TipUtil.TipById(50202)
    end
end

--移除联盟
function UnionMemberDetail:OnBtnRemoveClick()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Kick"),
        sureCallback = function()
            Net.Alliances.Fire(
                self.member.Id,
                function()
                    self:Close()
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--改变职位 提升/降低
function UnionMemberDetail:OnBtnChangePos(offset)
    Net.Alliances.ChangePos(
        self.member.Id,
        self.member.Position + offset,
        function()
            SdkModel.TrackBreakPoint(10049) --打点
            local values = {
                player_name = self.member.Name,
                R = self.member.Position + offset
            }
            if offset > 0 then
                TipUtil.TipById(50152, values)
            else
                TipUtil.TipById(50153, values)
            end
            self:Close()
        end
    )
end

--取代会长
function UnionMemberDetail:OnBtnReplaceClick()
    local offlineTime = _G.Tool.Time() - self.member.ActiveAt
    -- 不能被顶替
    if offlineTime <= _G.Global.ReplacePresidentOffline then
        local data = {
            content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Replace_txt"),
            btnGray = true
        }
        _G.UIMgr:Open("ConfirmPopupText", data)
    -- 花钱顶替
    elseif offlineTime <= _G.Global.ReplacePresidentOfflineFree then
        -- body
        local function cb_func()
            if _G.Model.Player.Gem < _G.Global.ReplacePresidentFee then
                _G.UITool.GoldLack()
            else
                local info = UnionInfoModel.GetInfo()
                _G.Net.Alliances.ReplacePresident(
                    info.PresidentId,
                    function()
                        _G.TipUtil.TipById(50154)
                        self:Close()
                    end
                )
            end
        end
        local data = {
            content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Replace_txt"),
            gold = _G.Global.ReplacePresidentFee,
            sureCallback = cb_func
        }
        _G.UIMgr:Open("ConfirmPopupText", data)
    --免费顶替
    else
        local function cb_func()
            local info = UnionInfoModel.GetInfo()
                _G.Net.Alliances.ReplacePresident(
                    info.PresidentId,
                    function()
                        _G.TipUtil.TipById(50154)
                        self:Close()
                    end
                )
        end
        local data = {
            content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_AllianceBoss_replace"),
            sureBtnText = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Button_AllianceBoss_replace"),
            sureCallback = cb_func
        }
        _G.UIMgr:Open("ConfirmPopupText", data)
    end
end

--审核 同意/拒绝
function UnionMemberDetail:OnBtnReviewClick(flag)
    if flag then
        -- 同意申请
        Net.Alliances.AcceptApply(
            self.member.Uuid,
            function()
                self:Close()
            end
        )
    else
        -- 拒绝申请
        Net.Alliances.RefuseApply(
            self.member.Uuid,
            function()
                Event.Broadcast(EventDefines.UIAllianceMemberUpdate)
                self:Close()
            end
        )
    end
end

--转让会长
function UnionMemberDetail:OnBtnTransferClick()
    local values = {
        player_name = self.member.Name
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Tips_GiveLeader", values),
        sureCallback = function()
            Net.Alliances.Abdicate(
                self.member.Id,
                function()
                    UIMgr:Close("UnionMember/UnionMemberDetail")
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--罢免官员
function UnionMemberDetail:OnBtnRecallClick()
    local values = {
        player_name = self.member.Name
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Management_RecallTxt", values),
        titleText = StringUtil.GetI18n(I18nType.Commmon, "Ui_Management_Recalltitle"),
        sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "Ui_Management_Recall"),
        sureCallback = function()
            local net_func = function()
                --罢免官员成功
                local conf = ConfigMgr.GetItem("configOfficials", self.member.Officer)
                local rvalues = {
                    player_name = self.member.Name,
                    alliance_position = StringUtil.GetI18n(I18nType.Commmon, conf.name)
                }
                TipUtil.TipById(50155, rvalues)
                self:Close()
                self.member.Officer = 0
                Event.Broadcast(EventDefines.RefreshUnionOfficer)
            end
            Net.Alliances.SetOfficer(self.member.Id, 0, net_func)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function UnionMemberDetail:GuildShow(btnName)
    local btnName = StringUtil.GetI18n(I18nType.Commmon, btnName)
    for i = 1, TOTAL_NUMBER do
        local listBtn = self["_btn" .. i]
        if listBtn.title == btnName then
            return listBtn
        end
    end
end
return UnionMemberDetail
