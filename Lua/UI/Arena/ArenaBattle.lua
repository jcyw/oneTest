--author: 	Amu
--time:		2020-06-19 14:47:43

local DressUpModel = import("Model/DressUpModel")
local callback

local ArenaBattle = UIMgr:NewUI("ArenaBattle")

function ArenaBattle:OnInit()
    self._view = self.Controller.contentPane

    self._maskBg = self._view:GetChild("bg")
    self._iconResult = self._view:GetChild("iconResult")
    self._btnReport =  self._view:GetChild("btnVombatReport")

    local _heroL = self._view:GetChild("iconL")
    local _heroR = self._view:GetChild("iconR")

    self._userName = _heroL:GetChild("textNameL")
    self._userIcon = _heroL:GetChild("n21")
    self._userIconBg = self._view:GetChild("heroL")

    self._enemyName = _heroR:GetChild("textNameL")
    self._enemyIcon = _heroR:GetChild("n21")
    self._enemyIconBg = self._view:GetChild("heroR")

    self._animIn = self._view:GetTransition("in")
    self._animReport = self._view:GetTransition("baoGao")
    self._animFail = self._view:GetTransition("defeat")

    self._ctrView = self._view:GetController("c1")

    self:InitEvent()
end

function ArenaBattle:InitEvent( )
    self:AddListener(self._maskBg.onClick,function()
        if self.isAllPlayend then
            self:Close()
        end
    end)

    self:AddListener(self._btnReport.onClick,function()
        Net.Mails.RequestMailData(Auth.WorldData.accountId, self.reportId,function(mailmsg)
            UIMgr:Open("MailWarReport", MAIL_TYPE.MailSubTypeSports, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, Auth.WorldData.accountId)
            self:Close()
        end)
    end)

    self:AddListener(self._userIcon.onClick,function()
        if not self.isAllPlayend then
            return
        end
        self._notRelClose = true
        self:Close()
        TurnModel.PlayerDetails(Model.Account.accountId, function()
            -- UIMgr:Open("ArenaBattle", self._info, true)
        end)
    end)

    self:AddListener(self._enemyIcon.onClick,function()
        if self._info.PlayerRankInfo.IsRobot or not self.isAllPlayend then
            return
        end
        self._notRelClose = true
        self:Close()
        TurnModel.PlayerDetails(self._enemyId, function()
            -- UIMgr:Open("ArenaBattle", self._info, true)
        end)
    end)

    callback = function()
        self.isAllPlayend = true
    end
end

local FormatName = function(lable, allianceName, name)
    local str = ""
    if allianceName ~= "" then
        str = str .. string.format("[%s] ", allianceName)
    end
    lable.text = str .. name
end
-- Bust
function ArenaBattle:OnOpen(info, isOpen)
    if self.wineffect and not isOpen then
        self.wineffect:RemoveFromParent()
        NodePool.Set(NodePool.KeyType.ArenaWinEffect, self.wineffect)
        self.wineffect = nil
    end
    
    self._info = info
    self._getReport = false
    self.isPlay = false
    self._isPlayEnd = false
    self.isAllPlayend = isOpen and true or false
    self._iconResult.visible = false
    self._btnReport.visible = false
    self._userIconBg.grayed = false
    self._enemyIconBg.grayed = false
    self._notRelClose = false
    self._enemyId = info.PlayerRankInfo.PlayerId
    FormatName(self._userName, Model.User.AllianceName, Model.User.Name)
    -- CommonModel.SetUserAvatar(self._userIcon, Model.User.Avatar)
    self._userIcon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    local avatarConf = ConfigMgr.GetItem("configAvatars", Model.User.Bust)
    self._userIconBg.icon = UITool.GetIcon(avatarConf.bust_pvp)
    -- self._userIconBg.icon = ""

    FormatName(self._enemyName, info.PlayerRankInfo.AllianceName, info.PlayerRankInfo.PlayerName)
    -- CommonModel.SetUserAvatar(self._enemyIcon, info.PlayerRankInfo.Avatar)
    self._enemyIcon:SetAvatar(info.PlayerRankInfo)
    if info.PlayerRankInfo.Bust then
        local avatarConf = ConfigMgr.GetItem("configAvatars",info.PlayerRankInfo.Bust)
        self._enemyIconBg.icon = UITool.GetIcon(avatarConf.bust_pvp)
    end
    -- self._enemyIconBg.icon = ""
    if isOpen then
        self._btnReport.visible = true
        return
    end

    self._animIn:Play(function()
        self._isPlayEnd = true
        self:PlayEffect()
    end)
    self._animIn:SetHook("effect", function()
        self:PlayLightEffect()
    end)

    self:ScheduleOnce(callback, 5)
end

function ArenaBattle:Refresh(msg)
    self.reportId = msg.MailId
    self._isWin = msg.IsWin
    self._getReport = true
    if self._isWin then
        self._ctrView.selectedIndex = 0
    else
        self._ctrView.selectedIndex = 1
    end
    self:PlayEffect()
end

function ArenaBattle:PlayEffect()
    if not self._isPlayEnd or not self._getReport or self.isPlay then
        return
    end
    self.isPlay = true

    if self._isWin then
        self._btnReport.visible = true
        self:PlayWinEffect()
        self._animReport:Play(function()
            self.isAllPlayend = true
            self._userIconBg.grayed = not self._isWin
            self._enemyIconBg.grayed = self._isWin
        end)
    else
        self._iconResult.visible = true
        self._btnReport.visible = true
        
        self._animFail:Play()
        self._animReport:Play(function()
            self._userIconBg.grayed = not self._isWin
            self._enemyIconBg.grayed = self._isWin
            self.isAllPlayend = true
        end)
    end
end

function ArenaBattle:PlayLightEffect()
    local effectKey = NodePool.KeyType.ArenaLightEffect

    NodePool.Init(effectKey, "Effect", "EffectNode")
    local item = NodePool.Get(effectKey)
    self.lighteffect = item
    item.y = self._maskBg.height / 2
    item.x = self._maskBg.width / 2
    self._view:AddChild(item)
    item:InitNormal()

    item:PlayDynamicEffectSingle("effect_ab/arena_win","effect_arena_pk", function()
        if self.lighteffect then
            NodePool.Set(effectKey, self.lighteffect)
            self.lighteffect:RemoveFromParent()
            self.lighteffect = nil
        end 
    end, Vector3(110, 110, 110),nil,1)
end

function ArenaBattle:PlayWinEffect()
    local effectKey = NodePool.KeyType.ArenaWinEffect

    NodePool.Init(effectKey, "Effect", "EffectNode")
    local item = NodePool.Get(effectKey)
    self.wineffect = item
    -- item.y = self._maskBg.height / 2
    item.y = 200
    item.x = self._maskBg.width / 2
    self._view:AddChild(item)
    item:InitNormal()

    item:PlayDynamicEffectSingle("effect_ab/arena_win","effect_arena_victory", function()
    end, Vector3(130, 130, 130),nil,1)
end

function ArenaBattle:Close( )
    UIMgr:Close("ArenaBattle")
end

function ArenaBattle:OnClose()
    if self.wineffect and not self._notRelClose then
        self.wineffect:RemoveFromParent()
        NodePool.Set(NodePool.KeyType.ArenaWinEffect, self.wineffect)
        self.wineffect = nil
    end
    if self.lighteffect then
        NodePool.Set(NodePool.KeyType.ArenaLightEffect, self.lighteffect)
        self.lighteffect:RemoveFromParent()
        self.lighteffect = nil
    end
    self:UnSchedule(callback)
end

return ArenaBattle