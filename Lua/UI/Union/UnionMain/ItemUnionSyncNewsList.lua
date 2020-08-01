--[[
    author:{maxiaolong}
    time:2020-02-05 15:12:12
    function:{联盟信息页面}
]]
local ItemUnionSyncNewsList = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionSyncNewsList", ItemUnionSyncNewsList)
function ItemUnionSyncNewsList:ctor()
    self._list.itemRenderer = function(index, item)
        item:Init(self.datas[index + 1])
    end
end

function ItemUnionSyncNewsList:Init(datas)
    self.datas = datas
    self._title.text = Tool.FormatTimeSF(datas[1].CreatedAt)
    self._list.numItems = #datas
    self._list:ResizeToFit(self._list.numChildren)
end

return ItemUnionSyncNewsList
