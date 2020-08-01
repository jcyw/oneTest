--author: 	Amu
--time:		2019-07-26 10:22:26

local ShopModel = import("Model/ShopModel")

local ConfirmPopupShade = UIMgr:NewUI("ConfirmPopupShade")

function ConfirmPopupShade:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnClose")

    self._bgMask = self._view:GetChild("bgMask")
    self._btnCity = self._view:GetChild("btnCity")
    self._btnUnion = self._view:GetChild("btnUnion")

    self._goldText = self._btnCity:GetChild("text")

    self._iconGold = self._view:GetChild("iconGold")
    self._textGold = self._view:GetChild("textGold")

    self:InitEvent()
end

function ConfirmPopupShade:OnOpen(type, params)
    self.type = type
    self.params = params

    self.index = (Model.ChatShareTimes + 1) > #Global.MailBattleShareConsume and #Global.MailBattleShareConsume or (Model.ChatShareTimes + 1)
    self._goldText.text = Global.MailBattleShareConsume[self.index]
end

function ConfirmPopupShade:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnCity.onClick,function()
        if Global.MailBattleShareConsume[self.index] > ShopModel:GetGoldNumByGoldType(RES_TYPE.Diamond) then
            ShopModel:GoldNotEnoughTipByType(RES_TYPE.Diamond)
            self:Close()
            return
        end
        SdkModel.TrackBreakPoint(10052)      --打点
        Net.Chat.SendChat("World", Model.Account.accountId, "", self.type, self.params, function()
            TipUtil.TipById(50065)
            self:Close()
            Model.ChatShareTimes = Model.ChatShareTimes + 1
        end)
    end)

    self:AddListener(self._btnUnion.onClick,function()
        if Model.Player.AllianceId == "" then
            TipUtil.TipById(50108)
            return
        end
        SdkModel.TrackBreakPoint(10051)      --打点
        Net.Chat.SendChat(Model.Player.AllianceId, Model.Account.accountId, "", self.type, self.params, function()
            TipUtil.TipById(50065)
            self:Close()
        end)
    end)
end

function ConfirmPopupShade:Close( )
    UIMgr:Close("ConfirmPopupShade")
end

return ConfirmPopupShade
