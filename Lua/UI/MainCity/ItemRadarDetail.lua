--[[
    author:{zhanzhang}
    time:2019-06-26 20:27:18
    function:{攻击预警详细条目}
]]
local ItemRadarDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadarDetail", ItemRadarDetail)

function ItemRadarDetail:ctor()
    self._nameText = self:GetChild("textName")
    self._bg = self:GetChild("bg")
    -- self._btnClose = self:GetChild("arrow")
    self._iconDown = self:GetChild("iconDown")
    self._contentList = self:GetChild("liebiao")

    self:OnRegister()
end

function ItemRadarDetail:OnRegister()
    self._contentList.itemRenderer = function(index, item)
        item:SetData(index, self.data.Armies[index + 1])
    end
    self._contentList:SetVirtual()

    self:AddListener(self._bg.onClick,
        function()
            self.visible = false
        end
    )
end

function ItemRadarDetail:Init(data)
    self.data = data
    self._contentList.numItems = #data.Armies
end

return ItemRadarDetail
