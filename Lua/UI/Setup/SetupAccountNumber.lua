--author: 	Amu
--time:		2019-10-19 14:58:25

local BuildModel = import("Model/BuildModel")
local DressUpModel = import("Model/DressUpModel")

local SetupAccountNumber = UIMgr:NewUI("SetupAccountNumber")

function SetupAccountNumber:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnSwitch = self._view:GetChild("btnSwitch")

    self._btnNewGame = self._view:GetChild("btnNewGame")

    self._listView = self._view:GetChild("liebiao")

    self._groupRisk = self._view:GetChild("groupRisk")
    self._textRisk = self._view:GetChild("textRisk")

    self._icon = self._view:GetChild("btnHead")

    self._name = self._view:GetChild("textPlayerName")
    self._id = self._view:GetChild("textID")
    self._level = self._view:GetChild("textLevel")
    self.isBind = false

    self.textList = {
        [1] = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Text1"),
        [2] = StringUtil.GetI18n(I18nType.Commmon, "UidBind5"),
        [3] = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Text2")
    }

    self:InitEvent()
end

function SetupAccountNumber:InitEvent()
    self:AddListener(
        self._btnReturn.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(
        self._btnSwitch.onClick,
        function()
            UIMgr:Open("SetupSwitchAccount")
        end
    )

    self:AddListener(
        self._btnNewGame.onClick,
        function()
            Net.UserInfo.GetRoles(
                function(msg)
                    UIMgr:Open("SetupRoleSelect", msg)
                end
            )
        end
    )
    self._listView.itemProvider = function(index)
        if not index then
            return
        end
        if index == 0 or index == 1 or index == (#self.bindList - 1) then
            return "ui://Setup/SetupText"
        end
        Log.Info("  itemProvider  " .. self.bindList[index + 1].isBind)
        if self.bindList[index + 1].isBind == "0" then
            return "ui://Setup/btnBind"
        elseif self.bindList[index + 1].isBind == "1" then
            -- return "ui://Setup/btnUnbind"
            return "ui://Setup/btnBind"
        else
            return "ui://Setup/btnBind"
        end
    end
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        if index == 0 or index == 1 or index == (#self.bindList - 1) then
            item:GetChild("textDescribe").text = self.bindList[index + 1]
        else
            item:SetData(self.bindList[index + 1], 1)
        end
    end

    self:AddListener(
        self._listView.onClickItem,
        function(context)
            if self.triggerFunc then
                self.triggerFunc()
            end
            local item = context.data
            local type = item:GetType()

            if item:GetBind() == "1" then
                -- local data = {
                --     content = StringUtil.GetI18n("configI18nCommons", "UNBIND_SURE"),
                --     sureCallback = function()
                --         Sdk.UnbindPlatform(type)
                --     end
                -- }
                -- UIMgr:Open("ConfirmPopupText", data)
                TipUtil.TipById(50303)
            else
                Sdk.BindPlatform(type)
            end
        end
    )

    self:AddEvent(
        SDK_BIND_EVNET.BindEvnet,
        function()
            self:RefreshPanel()
        end
    )

    --复制玩家ID
    self:AddListener(
        self._btnCopyId.onClick,
        function()
            self:OnCopyIdClick()
        end
    )
end

function SetupAccountNumber:OnOpen()
    -- CommonModel.SetUserAvatar(self._icon)
    self._icon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    self._name.text = Model.Player.Name
    self._id.text = StringUtil.GetI18n("configI18nCommons", "CHARACTER_ID", {playerid = Model.Account.accountId})
    self._level.text = StringUtil.GetI18n("configI18nCommons", "CHARACTER_LEVEL", {num = BuildModel.GetCenterLevel()})
    self:RefreshPanel()
end

function SetupAccountNumber:RefreshPanel()
    if SdkModel.IsBind() then
        self._groupRisk.visible = false
        --请求服务器发送奖励
        Net.UserInfo.AccountBind(
            function()
                local uid = SdkModel.GetUserId()
                PlayerDataModel:SetData(PlayerDataEnum.BindReward .. uid, uid)
            end
        )
    end
    self._bindList = SdkModel.GetBindList()
    self.bindList = {}
    for i = 1, 2 do
        table.insert(self.bindList, self.textList[i])
    end
    for i = 1, #self._bindList do
        table.insert(self.bindList, self._bindList[i])
    end
    table.insert(self.bindList, self.textList[3])
    self:RefreshListView()
end

function SetupAccountNumber:RefreshListView()
    self._listView.numItems = 0
    self._listView.numItems = #self.bindList
end

function SetupAccountNumber:Close()
    UIMgr:Close("SetupAccountNumber")
end

function SetupAccountNumber:GetFaceBookBtn()
    if self._listView.numChildren > 0 then
        return self._listView:GetChildAt(2)
    end
    return nil
end

function SetupAccountNumber:TriggerOnclick(callback)
    self.triggerFunc = callback
end

function SetupAccountNumber:OnCopyIdClick()
    GUIUtility.systemCopyBuffer = Model.Account.accountId
    TipUtil.TipById(50126)
end

return SetupAccountNumber
