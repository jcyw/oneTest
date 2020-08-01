--[[
    Author: songzeming
    Function: 玩家设置界面
]]
local PlayerSetup = UIMgr:NewUI("PlayerSetup")
local BlockListModel = import("Model/BlockListModel")

function PlayerSetup:OnInit()
    self.itemList = {}

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerSetup")
        end
    )

    self:AddEvent(
        EventDefines.UIPlayerInfoExchange,
        function()
            self:SetFlag()
        end
    )

    self.conf = ConfigMgr.GetList("configSettingss")
    self._list.numItems = #self.conf
    for k, v in ipairs(self.conf) do
        local item = self._list:GetChildAt(k - 1)
        item.title = StringUtil.GetI18n(I18nType.Commmon, v.text)
        if v.text == "System_Title10" then
            self.itemFlag = item
            self:SetFlag()
        else
            item.icon = UITool.GetIcon(v.icon)
        end
        self:AddListener(item.onClick,
            function()
                self:OnBtnClick(k)
            end
        )
        self.itemList[k] = item
    end

    self:AddEvent(SDK_BIND_EVNET.BindEvnet, function()
        self:RefreshRedPoint(1)
    end)

    self:AddEvent(GM_MSG_EVENT.NewMsgNotRead, function()
        self:RefreshRedPoint(5)
    end)

    self:AddEvent(GM_MSG_EVENT.MsgIsRead, function()
        self:RefreshRedPoint(5)
    end)
end

function PlayerSetup:OnOpen(cb)
    self.cb = cb
    --倒计时显示
    local show_func = function()
        self._time.text = os.date("%Y/%m/%d %H:%M:%S", TimeUtil.UTCTime(), TimeUtil.UTCTime()/1000)
        self._version.text = StringUtil.GetI18n(I18nType.Commmon, "UI_VERSION_TEXT").." "..GameVersion.GetLocalVersion().String
        self._pkgversion.text = StringUtil.GetI18n(I18nType.Commmon, "PKG_VERSION_TEXT").." "..GameVersion.GetInAppVersion().String
    end
    show_func()
    self.cd_func = function()
        show_func()
    end
    self:Schedule(self.cd_func, 1)
    for k, v in ipairs(self.conf) do
        self:RefreshRedPoint(k)
    end
end

function PlayerSetup:OnClose()
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if self.cb then
        self.cb()
    end
end

function PlayerSetup:RefreshRedPoint(index)
    local isShow = false
    local amount = 0
    if index == 1 then
        --账号
        amount = UserModel:NotReadPlayerNumber()
    elseif index == 2 then
        --选项
    elseif index == 3 then
        --消息通知
        -- elseif index == 4 then
        --     --兑换码
    elseif index == 5 then
        --GM
        amount = UserModel:GetGmMsgNotReadAmount()
    -- elseif index == 6 then
    --     --粉丝活动
    elseif index == 7 then
        --游戏说明
    elseif index == 8 then
        --已屏蔽用户
    elseif index == 9 then
        --旗帜
    elseif index == 10 then
        --语言
        -- elseif index == 11 then
        --     --提交BUG
        --     Sdk.RequestSDKFAQView()
    elseif index == 12 then
        --切换线路
        -- elseif index == 13 then
        --     --自动诊断
    elseif index == 14 then
    --隐私保护政策
    elseif index == 15 then
        --跳转facebook
    end
    if amount > 0 then
        isShow = true
    end
    self.itemList[index]:GetChild("redPoint"):SetData(isShow, amount)
end

function PlayerSetup:OnBtnClick(index)
    if index == 1 then
        --账号
        if self.triggerFunc then
            self.triggerFunc()
        end
        UIMgr:Open("SetupAccountNumber")
    elseif index == 2 then
        --选项
        UIMgr:Open("SetupOption")
    elseif index == 3 then
        --消息通知
        UIMgr:Open("SetupMessageNotification")
    elseif index == 4 then
        --兑换码
        UIMgr:Open("Rename",_G.CheckValidModel.From.CDKey)
    elseif index == 5 then
        -- elseif index == 6 then
        --     --粉丝活动
        --GM

        -- 屏蔽权限提示
        -- if not Sdk.CanAccessGM() then
        --     local data = {
        --         content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Gm_Upload_Permission"),
        --         buttonType= "double",
        --         sureCallback = function()
        --             Sdk.RequestGM()
        --         end
        --     }
        --     UIMgr:Open("ConfirmPopupText", data)
        -- else
        local serverId = ""
        local accountId = "" 
        if Auth and Auth.WorldData then
            serverId = Auth.WorldData.sceneId
            accountId = string.gsub(Auth.WorldData.accountId, "#", "-")
        end
        Sdk.AiHelpShowConversation(accountId, serverId)
        SdkModel.GmNotRead = 0
        Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
        -- end
    elseif index == 6 then
        --facebook
        Sdk.OpenBrowser("https://www.facebook.com/FinalOrderOfficial/")
    elseif index == 7 then
        --游戏说明
        Sdk.AiHelpShowFAQs()
    elseif index == 8 then
        --已屏蔽用户
        BlockListModel.GetBlockList(
            function(rsp)
                UIMgr:Open("SetupShield")
            end
        )
    elseif index == 9 then
        --旗帜
        UIMgr:Open("PlayerFlag", FLAG_TYPE.Player)
    elseif index == 10 then
        -- elseif index == 11 then
        --     --提交BUG
        --     Sdk.RequestSDKFAQView()
        --语言
        UIMgr:Open("SetupLanguage")
    elseif index == 12 then
        -- elseif index == 13 then
        --     --自动诊断
        --切换线路
        UIMgr:Open("SetupSwitchingLinePopup")
    elseif index == 14 then
        --隐私保护政策
        Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1008).article_id)
    elseif index == 15 then
        --facebook
        Sdk.OpenBrowser("https://www.facebook.com/FinalOrderOfficial/")
    else
        TipUtil.TipById(50259)
    end
end

--设置旗帜
function PlayerSetup:SetFlag()
    local flag = Model.Player.Flag
    if self.flag == flag then
        return
    end
    self.flag = flag
    if self.itemFlag then
        self.itemFlag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", self.flag).icon)
    end
end

function PlayerSetup:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return PlayerSetup
