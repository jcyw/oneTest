--author: 	Amu
--time:		2019-08-15 11:07:56


local UnionTaskActiveRewardPopup = UIMgr:NewUI("UnionTaskActiveRewardPopup")
UnionTaskActiveRewardPopup.selectItem = nil

function UnionTaskActiveRewardPopup:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnClose = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._listView = self._view:GetChild("liebiao")

    self._btnConfirm = self._view:GetChild("btnConfirm")

    self:InitEvent()
end

--itemInfos
-- {
--     {
--         id       物品id
--         amount   物品数量
--     }
-- }
function UnionTaskActiveRewardPopup:OnOpen(type, itemInfos, isShowGet, cb)
    self.type = type
    self._btnConfirm.visible = isShowGet
    self.cb = cb
    if self.type == ITEM_TYPE.Item then
        self.itemInfos = itemInfos
    elseif self.type == ITEM_TYPE.Gift then
        self.itemInfos = {}
        for _,v in ipairs(itemInfos)do
            local conf = ConfigMgr.GetItem("configGifts", v.id)
            if conf.items then
                for _,item in ipairs(conf.items)do
                    table.insert(self.itemInfos, item)
                end
            end
            if conf.res then
                for _,res in ipairs(conf.res)do
                    table.insert(self.itemInfos, res)
                end
            end
        end
    end
    self:RefreshListView()
end

function UnionTaskActiveRewardPopup:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnConfirm.onClick,function()
        self.cb()
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.type, self.itemInfos[index+1])
    end

    -- self:AddListener(self._listView.onClickItem,function(context)
    --     local item = context.data
    --     local data = item:GetData()
    -- end)

    self._listView:SetVirtual()

end


function UnionTaskActiveRewardPopup:RefreshListView()
    self._listView.numItems = #self.itemInfos
end

function UnionTaskActiveRewardPopup:Close( )
    UIMgr:Close("UnionTaskActiveRewardPopup")
end

return UnionTaskActiveRewardPopup