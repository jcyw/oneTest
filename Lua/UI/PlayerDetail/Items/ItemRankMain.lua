--[[
    Author: songzeming
    Function: 排行榜主界面item
]]
local ItemRankMain = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemRankMain", ItemRankMain)

function ItemRankMain:ctor()
    self:AddListener(self.onClick,
        function()
            --todo
            UIMgr:Open("RankList", self.info.rank_type1, self.info.rank_type2)
        end
    )
end

function ItemRankMain:Init(info)
    self.info = info
    self._icon.url = UITool.GetIcon(info.image)
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", info.buildingtype_name)
end

return ItemRankMain
