--author: 	Amu
--time:		2020-04-08 11:01:20

local UnionModel = import("Model/UnionModel")
local UnionMemberModel = import("Model/Union/UnionMemberModel")

local MailAllInformation = UIMgr:NewUI("Mail/MailAllInformation")

function MailAllInformation:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._listView = self._view:GetChild("liebiao")

    self.selectList = {}


    self:InitEvent()
end

function MailAllInformation:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)
    
    self:AddListener(self._mask.onClick,function()
        self:Close()
    end)

    self._btnUse.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Confirm")
    self:AddListener(self._btnUse.onClick,function()
        local len = 0
        for _,v in pairs(self.selectList) do
            len = len + 1
        end
        if len == 0 then
            TipUtil.TipById(50295)
            return
        end
        self.cb(self.selectList)
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.members[#self.members - index], #self.members - index)
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local index = item:GetIndex()
        local flag = false
        local i = 0
        for k,v in pairs(self.selectList)do
            if index == v then
                flag = true
                i = k
                break
            end
        end
        if flag then
            item:SetSeclect(false)
            table.remove(self.selectList, i)
        else
            item:SetSeclect(true)
            table.insert(self.selectList, index)
        end
        local a = 1
    end)
end

function MailAllInformation:OnOpen(cb)
    self.cb = cb
    self.selectList = {}

    UnionModel.GetMineUnionInfo(function()
        self.members = UnionMemberModel.FormatMembers(UnionMemberModel.GetMembers())
        self:RefreshPanel()
    end)
end

function MailAllInformation:RefreshPanel()
    self._listView.numItems = #self.members
end

function MailAllInformation:Close( )
    UIMgr:Close("MailAllInformation")
end

return MailAllInformation