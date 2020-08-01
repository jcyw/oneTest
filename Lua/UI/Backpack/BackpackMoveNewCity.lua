--[[
    author:{zhanzhang}
    time:2020-05-18 15:00:58
    function:{新手迁服显示列表}
]]
local BackpackMoveNewCity = UIMgr:NewUI("BackpackMoveNewCity")

local ItemMoveNewCity = import("UI/Backpack/ItemMoveNewCity")

function BackpackMoveNewCity:OnInit()
    local view = self.Controller.contentPane
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("BackpackMoveNewCity")
        end
    )

    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self.serverList[index + 1])
    end
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TRANSFER_ZONE_TITLE")
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TRANSFER_ZONE_DESC")
end

function BackpackMoveNewCity:OnOpen(data)
    self.data = data
    self.serverList = data.Servers
    -- self:UpdateData()
    self._list.numItems = #self.serverList
    self._list.scrollPane:SetPosY(0)
end

function BackpackMoveNewCity:UpdateData()
end

return BackpackMoveNewCity
