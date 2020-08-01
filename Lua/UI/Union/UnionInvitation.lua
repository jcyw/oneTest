--author: 	Amu
--time:		2019-07-08 15:02:36

import("UI/Union/UnionMember/ItemMember")

local UnionInvitation = UIMgr:NewUI("UnionInvitation")

function UnionInvitation:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnNotice = self._view:GetChild("btnNotice")
    self._btnSearch = self._view:GetChild("btnSearch")

    self._textInput = self._view:GetChild("textInput")

    self._listView = self._view:GetChild("liebiao")

    self._textIconNum = self._btnNotice:GetChild("text")

    self.canSearch = true

    self.players = {}

    self._textInput.text = ""

    self:InitEvent()
end

function UnionInvitation:OnOpen(info)
    self.info = info
    self._textInput.text = ""
    local name = self._textInput.text
    Net.Alliances.SearchPlayer(name, function(msg)
        self.players = msg.Players
        self:RefreahListView()
    end)

    if Model.Player.AlliancePos >= ALLIANCEPOS.R4 then
        self:RefreshGold()
        self._btnNotice.visible = true
    else
        self._btnNotice.visible = false
    end
end

function UnionInvitation:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._btnNotice.onClick,function()--公告邀请
        if Model.Player.AlliancePos >= ALLIANCEPOS.R4 then
            UIMgr:Open("UnionRecruitPopup")
        else
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "Ui_AllianceClass_Tips"),
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)

    self:AddListener(self._textInput.onChanged,function()
        if self._textInput.text == "" then
            Net.Alliances.SearchPlayer(self._textInput.text, function(msg)
                self.players = msg.Players
                self:RefreahListView()
            end)
        end
    end)

    self:AddListener(self._btnSearch.onClick,function()--搜索
        if not self.canSearch then
             TipUtil.TipById(50242)
            return
        end

        if string.len(self._textInput.text) < 3 then
            TipUtil.TipById(50201)
            return
        end


        local name = self._textInput.text
        self.players = {}
        Net.Alliances.SearchPlayer(name, function(msg)
            self.players = msg.Players
            if #self.players <= 0 then
                TipUtil.TipById(50090)
            end
            self:RefreahListView()
        end)

        
        self:ScheduleOnce(function() 
            self.canSearch = true
        end, 2)
        self.canSearch = false
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.players[index+1], UNION_VOTITEM_TYPE.InfoItem)
    end
    
    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()

        UIMgr:Open("UnionMemberDetail2", data, self)
    end)

    self._listView:SetVirtual()
end

function UnionInvitation:DelPlayerInfo(userId)
    for k,v in pairs(self.players)do
        if v.UserId == userId then
            table.remove(self.players, k)
            break
        end
    end
    self:RefreahListView()
end

function UnionInvitation:RefreahListView( )
    self._listView.numItems = #self.players
end

function UnionInvitation:RefreshGold()
    Net.Alliances.GetWantedTimes(Model.Player.AllianceId, function(msg)
        local goldList = ConfigMgr.GetVar("AllianceRecprice")
        if (msg.Count+1) >= #goldList then
            self._textIconNum.text = goldList[#goldList]
        else
            self._textIconNum.text = goldList[msg.Count+1]
        end
    end)
end

function UnionInvitation:Close( )
    UIMgr:Close("UnionInvitation")
end

return UnionInvitation