--[[
    Author: songzeming
    Function: 玩家形象
]]
local PlayerCharacter = UIMgr:NewUI("PlayerCharacter/PlayerCharacter")
local DressUpModel = import("Model/DressUpModel")

local CommonModel = import("Model/CommonModel")
local SpineCharacter = import("Model/Animation/SpineCharacter")
--import("UI/PlayerDetail/PlayerCharacter/ItemPlayerCharacterList")
local CTR = {
    Free = "Free",
    Refresh = "Refresh",
    Gold = "Gold",
    Item = "Item"
}
-- 更新形象的Item
local DIAMOND_ID = 5

function PlayerCharacter:OnInit()
    local view = self.Controller.contentPane

    self.centerList = view:GetChild("PlayerCharacterItem")
    self.centerItem = self.centerList:GetChildAt(0)
    self._listPoint = self.centerItem:GetChild("_listPoint")
    self._btnArrowR = self.centerItem:GetChild("_btnArrowR")
    self._btnArrowL = self.centerItem:GetChild("_btnArrowL")
    self._icon = self.centerItem:GetChild("n97")
    self._btnHead = self.centerItem:GetChild("_btnHead")
    self._textTime = self.centerItem:GetChild("_textTime")
    self._list = self.centerItem:GetChild("_list")
    self._btnExchange = self.centerItem:GetChild("_btnExchange")
    self._btnGold = self.centerItem:GetChild("_btnGold")
    self._btnItem = self.centerItem:GetChild("_btnItem")
    self._bgTag = self.centerItem:GetChild("bgTag")

    self._ctr = self.centerItem:GetController("Ctr")
    self._timeCtr = self.centerItem:GetController("timeController")

    self._list.scrollPane.inertiaDisabled = true --惯性禁用
    -- self._list:SetVirtualAndLoop() --临时关闭 等加了新的人物再打开
    self._list.scrollPane.touchEffect = true
    self._list.scrollPane.mouseWheelEnabled = false
    self._list.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:Init(index + 1)
    end
    self._listPoint.touchable = false

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerCharacter/PlayerCharacter")
        end
    )
    self:AddListener(self._btnHead.onClick,
        function()
            self:OnBtnHeadClick()
        end
    )
    self:AddListener(self._btnExchange.onClick,
        function()
            self:OnBtnExchangeClick()
        end
    )
    self._bthTitle = self._btnExchange:GetChild("title")

    self._goldText = self._btnGold:GetChild("text")
    self._goldTitle = self._btnGold:GetChild("title")
    self._goldicon = self._btnGold:GetChild("icon")

    self._bthItemTitle = self._btnItem:GetChild("title")
    self._btrItemText = self._btnItem:GetChild("text")
    self._btrItemIcon = self._btnItem:GetChild("icon")

    --国际化文字显示
    self._bthTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_Update")
    self._goldTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_Update")
    self._bthItemTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_Update")

    self._btrItemText.text = 1
    local Itemconf = ConfigMgr.GetItem("configItems", GlobalItem.ItemModIfyUserAvatar)
    self._btrItemIcon.icon = UITool.GetIcon(Itemconf.icon)

    self._goldText.text = Global.ModifyUserBustCost
    local Itemconf = ConfigMgr.GetItem("configResourcess", DIAMOND_ID)
    self._goldicon.icon = UITool.GetIcon(Itemconf.icon)

    self:AddListener(self._btnGold.onClick,
        function()
            self:OnBtnExchangeClick()
        end
    )
    self:AddListener(self._btnItem.onClick,
        function()
            self:OnBtnExchangeClick()
        end
    )
    self:AddListener(self._list.scrollPane.onScroll,
        function()
            self._btnExchange.touchable = false
            self._btnGold.touchable = false
            self._btnItem.touchable = false
        end
    )
    self:AddListener(self._list.scrollPane.onScrollEnd,
        function()
            self._btnExchange.touchable = true
            self._btnGold.touchable = true
            self._btnItem.touchable = true
            self:UpdateDefaultAvatar()
        end
    )
    self:AddListener(self._btnArrowL.onClick,
        function()
            self:OnBtnArrowClick(-1)
        end
    )
    self:AddListener(self._btnArrowR.onClick,
        function()
            self:OnBtnArrowClick(1)
        end
    )

    self.updateFunc = function()
        if Model.Items[GlobalItem.ItemModIfyUserAvatar] then
            if Model.Items[GlobalItem.ItemModIfyUserAvatar].Amount > 0 then
                self.canUseItem = true
            end
        end
        self:UpdateItemShow(self.canUseItem)
        self:UpdateDefaultAvatar()
    end

    self.refreshTimeFunc = function()
        self.Count = self.Count + 1
        self:RefreshTime()
    end
end

function PlayerCharacter:OnOpen(cb)
    self.cb = cb
    local conf = ConfigMgr.GetList("configAvatars")
    local avatars = {}
    for _,v in pairs(conf) do
        if v.path then
            table.insert(avatars, v)
        end
    end
    self.num = #avatars
    self._listPoint.numItems = self.num
    self._list.numItems = self.num
    self._list:EnsureBoundsCorrect()

    if GRoot.inst.height / 1334 > 1 then
        self.centerItem.height = self.centerList.scrollPane.viewHeight
    end
    --Model.Player.Avatar 可以是玩家自己设定的Url 此时defaultAvatar值位nil
    self.defaultAvatar = tonumber(Model.Player.Avatar)
    -- if self.defaultAvatar then
    --     --系统默认头像或玩家偏好选择的头像
    --     self._list.scrollPane.currentPageX = self.defaultAvatar - 1
    --     CommonModel.SetUserAvatar(self._icon)
    -- else
        --玩家自定义头像 url
        self._list.scrollPane.currentPageX = Model.Player.Bust - 1
        -- CommonModel.SetUserAvatar(self._icon)
        self._icon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    -- end

    self:ScheduleOnceFast(
        function()
            self:RefreshCharacter()
        end, GlobalVars.ScrollDelayTime
    )

    self.canUseItem = false
    if Model.Items[GlobalItem.ItemModIfyUserAvatar] then
        if Model.Items[GlobalItem.ItemModIfyUserAvatar].Amount > 0 then
            self.canUseItem = true
        end
    end
    self:UpdateItemShow(self.canUseItem)
    self:UpdateDefaultAvatar()

    self:AddEvent(EventDefines.UIPlayerInfoExchange, self.updateFunc)
    self:AddEvent(EventDefines.UIPlayerUpdateHead, self.refreshTimeFunc)

    self._timeCtr.selectedPage = "hide"
    Net.UserInfo.ModifyAvatarCoolInfo(
        function(rsp)
            if rsp.Fail then
                return
            end

            self.Count = rsp.Count
            self.CoolAt = rsp.CoolAt
            self:RefreshTime(rsp)
        end
    )
end

function PlayerCharacter:OnClose()
    Event.RemoveListener(EventDefines.UIPlayerInfoExchange, self.updateFunc)
    Event.RemoveListener(EventDefines.UIPlayerUpdateHead, self.refreshTimeFunc)
    self:UnScheduleFast(
        function()
            self:RefreshCharacter()
        end
    )
    SpineCharacter.Clear()
    if self.cb then
        self.cb()
    end
end

function PlayerCharacter:RefreshCharacter()
    local index = self._list.scrollPane.currentPageX % 4
    local childIndex = self._list:ItemIndexToChildIndex(index)
    if childIndex >= self._list.numChildren then
        childIndex = 0
        self._list.scrollPane.currentPageX = 0
    end
    self._list:GetChildAt(childIndex):Init(index + 1)
end

function PlayerCharacter:UpdateItemShow(flag)
    if flag then
        self._ctr.selectedPage = CTR.Item
    else
        self._ctr.selectedPage = CTR.Gold
    end
end

--刷新头像
function PlayerCharacter:UpdateDefaultAvatar()
    -- CommonModel.SetUserAvatar(self._icon)
    self._icon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    local bust = self._list.scrollPane.currentPageX % self.num + 1
    self.defaultAvatar = tonumber(Model.Player.Avatar)
    if self.defaultAvatar then
        if Model.Player.Bust == bust then
            -- self._btnExchange.enabled = false
            if Model.Player.Avatar == tostring(bust) then
                self._ctr.selectedPage = CTR.Free
            else
                self._ctr.selectedPage = CTR.Refresh
            end
        else
            self:UpdateItemShow(self.canUseItem)
        end
    else
        --当玩家自定义头像后 可以通过更新形象来恢复系统默认头像
        if Model.Player.Bust == bust then
            self._ctr.selectedPage = CTR.Refresh
        else
            self:UpdateItemShow(self.canUseItem)
        end
    end
    --刷新下方点标识
    for i = 1, self._listPoint.numChildren do
        local item = self._listPoint:GetChildAt(i - 1)
        local _ctr = item:GetController("c1")
        _ctr.selectedPage = i == bust and "down" or "up"
    end

    if not self.defaultAvatar then
        --用户自定义头像 不需要根据半身像变化
        return
    end

    -- self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configAvatars", tonumber(Model.Player.Avatar)).avatar)
    self._icon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
end

--点击更换头像按钮
function PlayerCharacter:OnBtnHeadClick()
    UIMgr:Open("BackpackImageModification", _G.BackpackImageModificationType.Head, function()
        UIMgr:Close("PlayerCharacter/PlayerCharacter")
    end)

    -- 屏蔽自定义头像
    if false then
        if Model.Player.Level < Global.PlayerChangeImage then
            TipUtil.TipById(50122)
            return
        end
        local cb_func = function(img)
            --todo 玩家自定义头像(更换头像成功)
            CuePointModel.CheckPlayerName(true)
        end
        Net.UserInfo.CanUploadAvatar(
            function(rsp)
                if rsp.Result == 1 then
                    TipUtil.TipById(50028)
                elseif rsp.Result == 2 then
                    UITool.GoldLack()
                else
                    UIMgr:Open("PlayerCharacter/PlayerCharacterCamera", self.canUseItem, cb_func)
                end
            end
        )
    end
end

--点击箭头切换形象
function PlayerCharacter:OnBtnArrowClick(dir)
    local index = self._list.scrollPane.currentPageX + dir
    self._list.scrollPane:SetCurrentPageX(index, true)
    self:UpdateDefaultAvatar()
end

--点击更换形象
function PlayerCharacter:OnBtnExchangeClick()
    local exg_func = function()
        --修改形象
        local bust = self._list.scrollPane.currentPageX % self.num + 1
        local avatar = tostring(bust)
        local net_bust_func = function()
            --修改形象成功
            TipUtil.TipById(50123)
            self.defaultAvatar = tonumber(Model.Player.Avatar)
            if self.defaultAvatar or Model.Player.Bust == bust then
                Model.Player.Avatar = avatar
            end
            Model.Player.Bust = bust
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
            -- self:OnOpen()
            UIMgr:Close("PlayerCharacter/PlayerCharacter")
        end
        Net.UserInfo.ModifyUserAvatarAndBust(tonumber(bust), net_bust_func)
    end
    if self._ctr.selectedPage == CTR.Refresh then
        --免费修改形象
        exg_func()
    else
        if self.canUseItem then
            --道具修改形象
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_ChangeTips"),
                sureBtnIcon = UITool.GetIcon(ConfigMgr.GetItem("configItems", GlobalItem.ItemModIfyUserAvatar).icon),
                itemNum = 1,
                sureCallback = exg_func
            }

            UIMgr:Open("ConfirmPopupText", data)
        else
            --钻石修改形象
            local values = {
                number = Global.ModifyUserBustCost
            }
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_ChangeTips", values),
                gold = Global.ModifyUserBustCost,
                sureCallback = exg_func
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end
end

function PlayerCharacter:RefreshTime()
    if self.timeFunc then
        self:UnSchedule(self.timeFunc)
    end

    if self.Count >= 2 then
        local time = Tool.Time()
        local ct = self.CoolAt - time
        if ct > 0 then
            self._timeCtr.selectedPage = "show"
            self.timeFunc = function()
                ct = ct - 1
                if ct > 0 then
                    self._textTime.text = Tool.FormatTime(ct)
                else
                    if self.timeFunc then
                        self:UnSchedule(self.timeFunc)
                    end
                    self._timeCtr.selectedPage = "hide"
                end
            end
            self.timeFunc()
            self:Schedule(self.timeFunc, 1)
        end
    end
end

return PlayerCharacter
