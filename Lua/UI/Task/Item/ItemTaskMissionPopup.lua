--[[
    author:{maxiaolong}
    time:2019-10-31 19:45:31
    function:{主线任务推荐}
]]
local GD = _G.GD
local ItemTaskMissionPopup = fgui.extension_class(GComponent)
fgui.register_extension("ui://Task/itemTaskMissionPopup", ItemTaskMissionPopup)

function ItemTaskMissionPopup:ctor()
    self._title = self:GetChild("title")
    self._textNume = self:GetChild("textNum")
    self._icon = self:GetChild("n75")
end

function ItemTaskMissionPopup:SetData(data)
    self.data = data
    self._title.text = self.data.title
    self._icon.icon = UITool.GetIcon(self.data.image)
    if self.data.isRes then
        self._textNume.text = string.format("%d", self.data.amount)
    else
         self._textNume.text = string.format("%d", self.data.amount)
    end
end

return ItemTaskMissionPopup
