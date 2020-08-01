local PlayerAchievementSharing = UIMgr:NewUI("PlayerAchievementSharing")

function PlayerAchievementSharing:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self:InitEvent()
end

function PlayerAchievementSharing:InitEvent()
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)
end

function PlayerAchievementSharing:OnOpen(data)
end

function PlayerAchievementSharing:Close()
    UIMgr:Close("PlayerAchievementSharing")
end

return PlayerAchievementSharing