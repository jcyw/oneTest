local RoyalBattleActivityDesc = UIMgr:NewUI("RoyalBattleActivityDesc")
import("UI/ActivityCenter/Item/ItemRoyalBattleActivityDesc")
function RoyalBattleActivityDesc:OnInit()
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._titleName = view:GetChild("titleName")
    self._content = view:GetChild("liebiao").asList
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("RoyalBattleActivityDesc")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("RoyalBattleActivityDesc")
        end
    )
end

function RoyalBattleActivityDesc:OnOpen(configId)
    local info = ConfigMgr.GetItem("configWarZoneDescs", configId)
    self._titleName.text = ConfigMgr.GetI18n("configI18nCommons", info.title)
    local itemInfo = {}
    --self._content:RemoveChildrenToPool()
    local count = #info.subtitle
    for i = 2, count do
        itemInfo.subtitle = info.subtitle[i]
        itemInfo.detail = info.detail[i - 1]
        itemInfo.backgroundPath = info.background[1]
        itemInfo.background = info.background[i]
        local item = self._content:AddItemFromPool()
        item:init(itemInfo)
    end
end

return RoyalBattleActivityDesc