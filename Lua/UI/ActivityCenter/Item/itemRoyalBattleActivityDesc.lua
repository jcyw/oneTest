--[[
    author:{xiaosao}
    time:2020/6/16
    function:{王城站预热活动规则item}
]]
local ItemRoyalBattleActivityDesc = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemRoyalBattleActivityDesc", ItemRoyalBattleActivityDesc)

function ItemRoyalBattleActivityDesc:ctor()
    self._title = self:GetChild("titleTagName1")
    self._desc = self:GetChild("textExplain1")
end

function ItemRoyalBattleActivityDesc:init(itemInfo)
    self._banner.icon = UITool.GetIcon({itemInfo.backgroundPath, itemInfo.background})
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", itemInfo.subtitle)
    self._desc.text = ConfigMgr.GetI18n("configI18nCommons", itemInfo.detail)
end

return ItemRoyalBattleActivityDesc
