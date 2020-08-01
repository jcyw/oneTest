--[[
    author:{zhanzhang}
    time:2019-06-13 20:30:09
    function:{野矿说明}
]]
local ItemCollectionInstructions = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemCollectionInstructions", ItemCollectionInstructions)

function ItemCollectionInstructions:ctor()
    self._bg = self:GetChild("MapBg1")
    self._title = self:GetChild("titleTagName1")
    self._desc = self:GetChild("textExplain1")

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WordPrisonExplain)
end

function ItemCollectionInstructions:init(mineInfo)
    self._bg = UIPackage.GetItemURL(mineInfo.backgroundPath, mineInfo.background)
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", mineInfo.subtitle)
    self._desc.text = ConfigMgr.GetI18n("configI18nCommons", mineInfo.detail)
end

function ItemCollectionInstructions:slideOnChange(self)
end

return ItemCollectionInstructions
