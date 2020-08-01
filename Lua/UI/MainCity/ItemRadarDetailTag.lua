--[[
    author:{zhanzhang}
    time:2019-06-26 20:27:18
    function:{攻击预警页签}
]]
local ItemRadarDetailTag = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadarDetailTag", ItemRadarDetailTag)

function ItemRadarDetailTag:ctor()
    self._textTagName = self:GetChild("textTagName")
    self._controller = self:GetController("c1")
    self._contentList = self:GetChild("liebiao")
    self._contentList:SetVirtual()

    self._contentList.itemRenderer = function(index, item)
        item:SetData(index, self.data.Armies[index + 1])
    end

    self:AddListener(self._btnDetail.onClick,
        function()
            self._controller.selectedIndex = math.abs(self._controller.selectedIndex - 1)
        end
    )
end

function ItemRadarDetailTag:Init(data)
    local isAssist = data.Category == Global.MissionAssit
    self._textTagName.text = (isAssist and StringUtil.GetI18n(I18nType.Commmon, "UI_Friend_Army") or StringUtil.GetI18n(I18nType.Commmon, "UI_Enemy_Army"))
    self.data = data
    self._contentList.numItems = #data.Armies
end

return ItemRadarDetailTag
