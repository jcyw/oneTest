--[[
    Author: songzeming
    Function: 联盟管理界面
]]
local UnionManager = UIMgr:NewUI("UnionManager")

local UnionModel = import("Model/UnionModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionMemberModel = import("Model/Union/UnionMemberModel")
local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")
local MissionEventModel = import("Model/MissionEventModel")
import("UI/Union/ItemUnionAdministration")

function UnionManager:OnInit()
    self.conf = ConfigMgr.GetList("configManagemenButtons")
    self.itemList = {}
    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionManager)
end

function UnionManager:InitEvent()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionManager")
        end
    )

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        local confItem = self.conf[self.arr[index + 1]]
        item:SetData(confItem, StringUtil.GetI18n(I18nType.Commmon, confItem.name), UITool.GetIcon(confItem.icon))
        self.itemList[confItem.name] = item
    end

    self:AddListener(self._listView.onClickItem,
        function(context)
            local item = context.data
            local data = item:GetData()
            self:OnBtnClick(data.name)
        end
    )

    --联盟管理提示点刷新
    self:AddEvent(
        EventDefines.UIUnionMainManger,
        function(rsp)
            self:CheckCuePoint()
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceMember,
        function(rsp)
            if Model.Account.accountId == rsp.Id then
                Model.Player.AlliancePos = rsp.Position
                self:OnOpen()
            end
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceIconExchanged,
        function()
            --self._icon.icon = UnionModel.GetUnionBadgeIcon()
            self._medal:SetMedal(nil, Vector3(125, 125, 125))
        end
    )
end

function UnionManager:OnOpen()
    if Model.Player.AllianceId == "" then
        UIMgr:ClosePopAndTopPanel()
        return
    end
    self.confData = UnionModel.GetPermissionsByConf(self.conf)
    self.arr = self.confData[Model.Player.AlliancePos]
    if Model.Player.AlliancePos == Global.AlliancePosR5 then
        local members = UnionMemberModel.GetMembers()
        local isOnlyOne = Tool.GetTableLength(members) == 1
        for k, v in pairs(self.arr) do
            if isOnlyOne then
                if self.conf[v].name == "Button_Exit" then
                    table.remove(self.arr, k)
                    break
                end
            else
                if self.conf[v].name == "Button_Disband" then
                    table.remove(self.arr, k)
                    break
                end
            end
        end
    end

    self._listView.numItems = #self.arr
    self._listView.scrollPane:ScrollTop()
    --self._icon.icon = UnionModel.GetUnionBadgeIcon()
    self._medal:SetMedal(nil, Vector3(125, 125, 125))
    self:CheckCuePoint()
end

--刷新提示点
function UnionManager:CheckCuePoint()
    for i = 1, self._listView.numChildren do
        self._listView:GetChildAt(i - 1):CheckPoint()
    end
end

--点击按钮
function UnionManager:OnBtnClick(name)
    if name == "Button_Set" then
        --联盟设定
        UIMgr:Open("UnionSetup/UnionSetup")
    elseif name == "Button_View" then
        --查看联盟
        UIMgr:Open("UnionView/UnionView")
    elseif name == "Button_Self_View" then
        --查看本联盟
        UIMgr:Open("UnionViewData")
    elseif name == "Button_Release_Blacklist" then
        --解除留言黑名单
        UIMgr:Open("UnionUnshielding")
    elseif name == "Button_Whole_Command" then
        --全体联盟指令
        UIMgr:Open("UnionInstructionsPopup", 2)
    elseif name == "Button_Modify_Permissions" then
        --修改权限
        UIMgr:Open("UnionMember/UnionPermissions")
    elseif name == "Button_View_Boss" then
        --查看联盟盟主
        TipUtil.TipById(50259)
    elseif name == "Button_View_Logo" then
        --查看联盟徽章
        UIMgr:Open("UnionManager/UnionBadge")
    elseif name == "Button_Territory" then
        --联盟领地
        UnionTrritoryModel.SetPointPos(0)
        UIMgr:Open("UnionTerritorialManagement")--("UnionTerritorialManagementSingle")
    elseif name == "Button_Vote" then
        --投票
        UIMgr:Open("UnionVote")
    elseif name == "Button_Ceave_Comments" then
        --联盟留言
        UIMgr:Open("UnionMessage")
    elseif name == "Button_Contribution_Rank" then
        --贡献排名
        UIMgr:Open("UnionDonateRank")
    elseif name == "Button_Exit" or name == "Button_Disband" then
        --退出联盟、解散联盟
        self:Exit()
    end
end

--退出联盟
function UnionManager.Exit()
    if MissionEventModel.IsRallyNow() then
        --集结中
        TipUtil.TipById(50287)
        return
    end
    local isOwner = UnionModel.CheckUnionOwner()
    local exit_func = function(isExit)
        Net.Alliances.Quit(
            Model.Account.accountId,
            function()
                SdkModel.TrackBreakPoint(10048)      --打点
                UnionInfoModel.ClearInfo()
                UnionMemberModel.ClearMember()
                UIMgr:ClosePopAndTopPanel()
                if isExit then
                    TipUtil.TipById(50144)
                else
                    TipUtil.TipById(50145)
                end
                Model.Player.AllianceTechCanContri = false
                Event.Broadcast(EventDefines.UIUnionScience)
                Event.Broadcast(UNION_EVENT.Exit)
            end
        )
    end
    if not isOwner then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Out"),
            sureCallback = function()
                exit_func(true)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        local members = UnionMemberModel.GetMembers()
        if Tool.GetTableLength(members) > 1 then
            TipUtil.TipById(50270)
        else
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDissolution_Boss"),
                sureCallback = function()
                    exit_func(false)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end
end

return UnionManager
