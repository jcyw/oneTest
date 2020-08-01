--author: 	Amu
--time:		2019-07-19 11:21:00


local UnionMessageShield = UIMgr:NewUI("UnionMessageShield")

function UnionMessageShield:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")

    self._group = self._view:GetChild("group")

    self._textNameDaily = self._view:GetChild("textNameDaily")

    self._listView = self._view:GetChild("liebiao")

    -- self._listView.touchable = false

    self._h = self._listView.height

    self.config = ConfigMgr.GetList("configShieldButtons")

    self._btnList = {}

    self:InitEvent()
end

--1  屏蔽该指挥官留言
--2  屏蔽该联盟留言
--3  发送邮件
--4  查看首领信息
--5  删除留言
function UnionMessageShield:OnOpen(type, info)
    self.info = info
    self.type = type
    self.btnType = 0

    if type == PLAYER_CONTACT_BOX_TYPE.ChatBox then
        if self.info.SelfAllianceId ~= "" then  --被查看玩家是否有联盟
            --有联盟
            if Model.Player.AllianceId == self.info.AllianceId then  --是否在自己联盟查看
                --在自己联盟查看
                if Model.Player.AllianceId == self.info.SelfAllianceId then --和查看玩家是否同一联盟
                    --和被查看在同一联盟
                    if Model.Player.AlliancePos < ALLIANCEPOS.R4 then
                        self.btnType = 7
                    elseif Model.Player.AlliancePos == ALLIANCEPOS.R4 then
                        self.btnType = 4
                    elseif Model.Player.AlliancePos == ALLIANCEPOS.R5 then
                        self.btnType = 1
                    end
                else
                    --和被查看在不同一联盟
                    if Model.Player.AlliancePos < ALLIANCEPOS.R4 then
                        self.btnType = 8
                    elseif Model.Player.AlliancePos == ALLIANCEPOS.R4 then
                        self.btnType = 5
                    elseif Model.Player.AlliancePos == ALLIANCEPOS.R5 then
                        self.btnType = 2
                    end
                end
            else
                self.btnType = 10
            end
        else  --被查看玩家没有联盟
            if Model.Player.AllianceId == self.info.AllianceId then --是否在自己联盟查看
                if Model.Player.AlliancePos < ALLIANCEPOS.R4 then
                    self.btnType = 9
                elseif Model.Player.AlliancePos == ALLIANCEPOS.R4 then
                    self.btnType = 6
                elseif Model.Player.AlliancePos == ALLIANCEPOS.R5 then
                    self.btnType = 3
                end
            else
                self.btnType = 10
            end
        end
        if info.Alliance ~= "" then
            self._textNameDaily.text = string.format("(%s)%s", info.Alliance, info.Sender)
        else
            self._textNameDaily.text = info.Sender
        end
    elseif type == PLAYER_CONTACT_BOX_TYPE.RankBox then
        self.btnType = 10
        if info.Alliance ~= "" then
            self._textNameDaily.text = string.format("(%s)%s", info.AllianceName, info.Name)
        else
            self._textNameDaily.text = info.Name
        end
    end
    self._btnList = ConfigMgr.GetItem("configShieldButtons", self.btnType).button
    self:RefreshListView()
end

function UnionMessageShield:InitEvent( )
    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        local type = self._btnList[index + 1]
        if not type then
            return
        end
        local str = ""
        if type == 1 then
            str = StringUtil.GetI18n(I18nType.Commmon, "Button_Shield_Player")
        elseif type == 2 then
            str = StringUtil.GetI18n(I18nType.Commmon, "Button_Shield_Alliance")
        elseif type == 3 then
            str = StringUtil.GetI18n(I18nType.Commmon, "Button_Send_Mail")
        elseif type == 4 then
            str = StringUtil.GetI18n(I18nType.Commmon, "Button_View_Player")
        elseif type == 5 then
            str = StringUtil.GetI18n(I18nType.Commmon, "Button_Delete_Messgae")
        end
        self._btnH = item.height
        item:SetData(str, type)
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local type = item:getData()

        self:ClickEvent(type)
    end)
end

function UnionMessageShield:ClickEvent(type)
    if type == 1 then--屏蔽该指挥官留言
        Net.AllianceMessage.RequestBanPlayer(self.info.SenderId, function()
            TipUtil.TipById(50243)
            Event.Broadcast(UNION_MSG_BAN.BanPlayer, self.info.SenderId)
            self:Close()
       end)
    elseif type == 2 then--屏蔽该联盟留言
        Net.AllianceMessage.RequestBanAlliance(self.info.SelfAllianceId, function()
            TipUtil.TipById(50244)
            Event.Broadcast(UNION_MSG_BAN.BanAlliance, self.info)
            self:Close()
       end)
    elseif type == 3 then--发送邮件
        local info = {}
        info.subCategory = MAIL_SUBTYPE.subPersonalMsg
        if self.type == PLAYER_CONTACT_BOX_TYPE.ChatBox then
            info.subject = self.info.SenderId
            info.Receiver = self.info.Sender
        elseif self.type == PLAYER_CONTACT_BOX_TYPE.RankBox then
            info.subject = self.info.UserId
            info.Receiver = self.info.Name
        end
        UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
        self:Close()
    elseif type == 4 then--查看首领信息
        UIMgr:Close("PlayerDetails")
        if self.type == PLAYER_CONTACT_BOX_TYPE.ChatBox then
            TurnModel.PlayerDetails(self.info.SenderId)
        elseif self.type == PLAYER_CONTACT_BOX_TYPE.RankBox then
            TurnModel.PlayerDetails(self.info.UserId)
        end
        self:Close()
    elseif type == 5 then--删除留言
        Net.AllianceMessage.RequestDeleteMessage(self.info.Uuid, function()
            TipUtil.TipById(50222)
           Event.Broadcast(UNION_MSG_EVENT.Del, self.info.Uuid)
           self:Close()
       end)
    end
end

function UnionMessageShield:RefreshListView()
    self._listView.numItems = #self._btnList
    self._listView.height = self._h - (4 - #self._btnList)*(self._btnH)
end

function UnionMessageShield:Close( )
    UIMgr:Close("UnionMessageShield")
end

return UnionMessageShield