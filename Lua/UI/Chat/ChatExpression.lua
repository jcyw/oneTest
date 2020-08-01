--author: 	Amu
--time:		2019-07-17 16:23:02

local ChatExpression = UIMgr:NewUI("Chat/ChatExpression")
ChatExpression.selectItem = nil

function ChatExpression:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiao")


    self:InitEvent()
end

function ChatExpression:OnOpen(shopInfo)
    self:RefreshPanel()
end

function ChatExpression:RefreshPanel()
end

function ChatExpression:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.shopInfo[index+1])
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()
        if self.selectItem then
            self.selectItem:SetChoose(false)
        end
        self.selectItem = item
        self.selectItem:SetChoose(true)
    end)

    self._listView:SetVirtual()

    self:AddEvent(SHOPEVENT.MarkEvent, function(id)
        for _,v in ipairs(self.shopInfo)do
            if v.ConfId == id then
                v.Mark = v.Mark + 1
                break
            end
        end
        self:RefreshPanel() 
    end)
end


function ChatExpression:InitListView()
    self._listView.numItems = #self.shopInfo
end

function ChatExpression:Close( )
    UIMgr:Close("ChatExpression")
end

return ChatExpression