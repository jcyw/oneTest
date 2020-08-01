--author: 	Amu
--time:		2019-11-01 14:50:48


local UnionInstructionsPopup = UIMgr:NewUI("UnionInstructionsPopup")

function UnionInstructionsPopup:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._listView = self._view:GetChild("liebiao")

    self._orderList = ConfigMgr.GetList('configAllianceOrdes')

    self.isBind = false

    self:InitEvent()
end

function UnionInstructionsPopup:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        return "ui://Union/itemUnionInstructionsPopup"
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._orderList[index+1])
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local id = item:GetType()
    
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Ui_Instructions_confirm"),
            -- sureBtnText = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
            sureCallback = function()
                if self.type == 1 then       -- 单个
                    Net.Alliances.AllianceOrder(self.userId, id, function()
                        TipUtil.TipById(50240)
                    end)
                elseif self.type == 2 then   -- 全体
                    Net.Alliances.AllianceOrder("", id, function()
                        TipUtil.TipById(50240)
                    end)
                end
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)
end

function UnionInstructionsPopup:OnOpen(type, userId)
    self.type = type
    self.userId = userId and userId or ""

    self:RefreshListView()
end

function UnionInstructionsPopup:RefreshListView( )
    self._listView.numItems = #self._orderList
end

function UnionInstructionsPopup:Close()
    UIMgr:Close("UnionInstructionsPopup")
end

return UnionInstructionsPopup