-- author:{Amu}
-- time:2019-05-28 16:05:13


local ItemMailFieldEnemyWarReportItem = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailFieldEnemyWarReportItem", ItemMailFieldEnemyWarReportItem)

function ItemMailFieldEnemyWarReportItem:ctor()
    self._item1 = self:GetChild("prop1")
    self._item2 = self:GetChild("prop2")
    self._item3 = self:GetChild("prop3")
    self._item4 = self:GetChild("prop4")
    self._item5 = self:GetChild("prop5")

    self.itemList = {
        self._item1,
        self._item2,
        self._item3,
        self._item4,
        self._item5
    }

    self:InitEvent()
end

function ItemMailFieldEnemyWarReportItem:InitEvent(  )
end

function ItemMailFieldEnemyWarReportItem:SetData(itemInfos)
    for i = 1, #self.itemList do
        if itemInfos[i] then
            --TODO
            self.itemList[i].visible = true
            self.itemList[i]:SetData(itemInfos[i])
        else
            self.itemList[i].visible = false
        end
    end
end

return ItemMailFieldEnemyWarReportItem