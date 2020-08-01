--[[
    author:Temmie
    time:2019-12-10 17:35:33
    function:个人排行榜点击弹出菜单
]]
local RankMessageShield = UIMgr:NewUI("RankMessageShield")

function RankMessageShield:OnInit()
    self:AddListener(self._btnMail.onClick,function()
        local info = {}
        info.subCategory = MAIL_SUBTYPE.subPersonalMsg
        info.subject = self.info.UserId
        info.Receiver = self.info.Name
        UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
        UIMgr:Close("RankMessageShield")
    end)

    self:AddListener(self._btnView.onClick,function()
        TurnModel.PlayerDetails(self.info.UserId)
        UIMgr:Close("RankMessageShield")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("RankMessageShield")
    end)
end

function RankMessageShield:OnOpen(info)
    self.info = info
    self._textName.text = info.Name
end

return RankMessageShield