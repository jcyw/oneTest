--[[
    author:{maxaiolong}
    time:2020-01-13 20:04:11
    function:{desc}
]]
local ItemStoredValue_AccumulatedStorage = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemStoredValue_AccumulatedStorage", ItemStoredValue_AccumulatedStorage)

function ItemStoredValue_AccumulatedStorage:ctor()
    self._textName = self:GetChild("textName")
    self._timeText = self:GetChild("textTiem")
    self._itemList = self:GetChild("liebiao")
    self._defaultHeight = self.height - self._itemList.height
end

function ItemStoredValue_AccumulatedStorage:SetData(data, title)
    self._textName.text = title
    self.height = self._defaultHeight
    self._itemList:RemoveChildrenToPool()
    self._itemList:AddItemFormPool()
    self._itemList:SetData()
    if self._itemList.numChildren==0 then 
        self._itemList:ResizeToFit(self._itemList.numChildren)
        self.height=self._defaultHeight+self._itemList.scrollPane.contentHeight
    else
    end
end

return ItemStoredValue_AccumulatedStorage
