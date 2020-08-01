--[[
    author:{zhanzhang}
    time:2019-10-19 16:11:12
    function:{军队详情}
]]
local ItemArmiesDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemArmyDetail", ItemArmiesDetail)

local primeHeight = 59

---ItemArmiesDetail   环状操作列表item
function ItemArmiesDetail:ctor()
    self._contentList:SetVirtual()

    self._contentList.itemRenderer = function(index, item)
        if index < math.ceil(self.beastNum / 2) then
            local itemIndex = index * 2 + 1
            item:Init(self.beastList[itemIndex], self.beastNum >= (itemIndex + 1) and self.beastList[itemIndex + 1], true)
        else
            local itemIndex = (index - math.ceil(self.beastNum / 2)) * 2 + 1
            item:Init(self.armyList[itemIndex], #self.armyList >= (itemIndex + 1) and self.armyList[itemIndex + 1], false)
        end
    end
end

function ItemArmiesDetail:InitItemArmyInfo(data)
    if data.Team then
        --驻扎军队
        self.armyList = data.Team.Armies
        self.beastList = data.Team.Beasts
    else
        --行军军队
        self.armyList = data.Armies
        self.beastList = data.Beasts
    end

    self.beastNum = 0
    for _,v in pairs(self.beastList) do
        self.beastNum = self.beastNum + 1
    end

    local num = 0
    for i = 1, #self.armyList do
        num = num + self.armyList[i].Amount
    end

    local itemNum = math.ceil(#self.armyList / 2) + math.ceil(self.beastNum / 2)
    self._contentList.numItems = itemNum
    self._textTotalNum.text = num
    if data.Name == "" then --更新前就存在的部队的部队信息，Name为“”，所以用UserId代替，更新后新创建的部队信息就不会走到这里了。
        local ownerInfo =MapModel.GetMapOwner(data.UserId)
        if ownerInfo then
            self._textName.text = ownerInfo.Name
        else
            self._textName.text = data.UserId 
        end
    else
        self._textName.text = data.Name
    end
    --self._textName.text = MapModel.GetMapOwner(data.UserId).Name
    self._contentList:ResizeToFit(itemNum)
    self.height = primeHeight + self._contentList.height
end

return ItemArmiesDetail
