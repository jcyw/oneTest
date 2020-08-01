--[[
    author:{author}
    time:2020-01-15 17:16:13
    function:{desc}
]]
local GD = _G.GD
local ItemRankingAwardLiebiaoBg = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemRankingAwardLiebiaoBg", ItemRankingAwardLiebiaoBg)
function ItemRankingAwardLiebiaoBg:ctor()
    self._list = self:GetChild("liebiao")
    self._list.scrollPane.touchEffect = false
    self._list.itemRenderer = function(index, item)
        local pos = self.index*5+index+1
        local data =  self.items[pos]
        local id = data.confId
        local icon = data.image
        local amount = data.amount
        local quality = data.color

        local mid = GD.ItemAgent.GetItemInnerContent(id)
        local name = data.title
        local desc = data.desc
        item:SetShowData(icon,quality,amount,nil,mid)
        item:SetTipsData({name,desc})
    end
end

function ItemRankingAwardLiebiaoBg:SetData(index, num, itemsData)
    self.index = index
    self.items = itemsData
    self._list.numItems = num
end

return ItemRankingAwardLiebiaoBg
