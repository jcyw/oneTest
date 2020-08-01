--[[
    author:{laofu}
    time:2020-07-17 14:45:15
    function:{属性列表}
]]
local ItemAircraftAttributeBonus = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAircraftAttributeBonus", ItemAircraftAttributeBonus)

local function SetItemBg(item, index, haveBg)
    local c1 = item:GetController("bg")
    if index % 2 == 0 and haveBg then
        c1.selectedIndex = 0
    else
        c1.selectedIndex = 1
    end
end

function ItemAircraftAttributeBonus:ctor()
    self._title = self:GetChild("title")
    self._list = self:GetChild("list")
    self._bgCtr = self:GetController("c1")

    self._title.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_ADD_ATTR_TEXT")

    self._list.itemRenderer = function(index, item)
        local buffInfo = self.buffList[index + 1]
        SetItemBg(item, index, self._haveBg)
        item:GetChild("desc").text = buffInfo.desc
        item:GetChild("additionNum").text = buffInfo.num
    end
end

function ItemAircraftAttributeBonus:SetList(planeId, haveBg)
    self._bgCtr.selectedIndex = haveBg and 0 or 1
    self._haveBg = haveBg
    local planeInfo = _G.ConfigMgr.GetItem("configPlanes", planeId)
    if not planeInfo.buff_type then
        self._list.numItems = 0
        return
    end
    self.buffList = {}
    for _, buffName in pairs(planeInfo.buff_show) do
        local buffInfo = {
            desc = _G.StringUtil.GetI18n(_G.I18nType.Commmon, buffName.name),
            num = buffName.num
        }
        table.insert(self.buffList, buffInfo)
    end
    self._list.numItems = #self.buffList
end

return ItemAircraftAttributeBonus
