--author: 	Amu
--time:		2019-09-10 10:33:54

local UserModel = import("Model/UserModel")

local MailPersonalNews_AddFriends_SelectObjectCen = UIMgr:NewUI("MailPersonalNews_AddFriends_SelectObjectCen")

function MailPersonalNews_AddFriends_SelectObjectCen:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._textInput = self._view:GetChild("textSearch")
    self._listView = self._view:GetChild("liebiaoSearch")

    self._btnSearch = self._view:GetChild("btnSearch")

    self._btnOk = self._view:GetChild("btnBlue")


    self:InitEvent()
end

function MailPersonalNews_AddFriends_SelectObjectCen:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnSearch.onClick,function()
        if self._textInput.text == "" then
            self._listView.numItems  = #self.searchList
        end
        
        self:Search(self._textInput.text)
    end)

    self:AddListener(self._btnOk.onClick,function()
        if #self.selectList <= 0 then
            TipUtil.TipById(50092)
            return
        end
        Net.Mails.DelFromGroup(self.groupInfo.sessionId, self.selectList, false,function(msg)
            TipUtil.TipById(50222)
            self._panel:RefreshList()
            self:Close()
        end)
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.searchList[index+1])
    end

    self._listView:SetVirtual()


    self:AddEvent(CHAT_GROUP_EVNET.Add, function(playId)
        for _,v in ipairs(self.selectList)do
            if v == playId then
                return
            end
        end
        -- for _,v in ipairs(self.searchList)do
        --     if v.UserId == playId then
        --         return
        --     end
        -- end
        table.insert(self.selectList, playId)
    end)

    self:AddEvent(CHAT_GROUP_EVNET.Del, function(playId)
        for k,v in ipairs(self.selectList)do
            if v == playId then
                table.remove(self.selectList, k)
                break
            end
        end
    end)

end

function MailPersonalNews_AddFriends_SelectObjectCen:OnOpen(members, groupInfo, panel)
    self.selectList = {}
    self._textInput.text = ""
    self._panel = panel

    self.members = {}
    for _,v in ipairs(members)do
        if v.UserId ~= UserModel.data.accountId then
            table.insert(self.members, v)
        end
    end
    self.groupInfo = groupInfo
    self.searchList = self.members
    for _,v in ipairs(self.searchList)do
        v.selected = false
    end

    self._listView.numItems  = #self.searchList
end

function MailPersonalNews_AddFriends_SelectObjectCen:Search(str)
    self.searchList = {}
    for _,v in ipairs(self.members)do
        if string.find(v.Name, str) then
            table.insert(self.searchList, v)
        end
    end
    self._listView.numItems  = #self.searchList
end

function MailPersonalNews_AddFriends_SelectObjectCen:Close()
    UIMgr:Close("MailPersonalNews_AddFriends_SelectObjectCen")
end

return MailPersonalNews_AddFriends_SelectObjectCen