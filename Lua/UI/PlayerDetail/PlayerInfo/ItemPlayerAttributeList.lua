--[[
    Author: songzeming
    Function: 玩家信息属性item 列表
]]
local ItemPlayerAttributeList = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerAttributeList", ItemPlayerAttributeList)

import("UI/PlayerDetail/PlayerInfo/ItemPlayerAttributeListStrip")

local Tool = _G.Tool

local function GET_PERCENT(value)
    return Tool.FormatFloat(Tool.GetPreciseDecimal(value, 1))
end

function ItemPlayerAttributeList:ctor()
    self._list.touchable = false
    self.defaultHeight = self.height - self._list.height
end

local function GetValue(ny, by, v)
    local fv = ny == 1 and Tool.FormatNumberThousands(math.abs(v)) or GET_PERCENT(math.abs(v) / 100) .. "%"
    if by == 1 then
        return "+" .. fv
    elseif by == 2 then
        return v == 0 and fv or "-" .. fv
    elseif by == 3 then
        return v >= 0 and ("+" .. fv) or "-" .. fv
    else
        return fv
    end
end

--显示自己的信息属性
function ItemPlayerAttributeList:InitMine(keyIndex, title, data)
    self._title.text = title
    self.height = self.defaultHeight

    self._list:RemoveChildrenToPool()
    for _, v in pairs(data) do
        for _, vv in pairs(v.value) do
            if vv.Category == keyIndex then
                if vv.Category == 1000 or vv.Value > 0 then
                    local item = self._list:AddItemFromPool()
                    local name = StringUtil.GetI18n(I18nType.Commmon, v.name)
                    local value = GetValue(v.number_type, v.buff_type, vv.Value)
                    item:Init(name, value)
                end
                break
            end
        end
    end
    if self._list.numChildren == 0 then
        self.parent:RemoveChildToPool(self)
    else
        self._list:ResizeToFit(self._list.numChildren)
        self.height = self.defaultHeight + self._list.scrollPane.contentHeight
    end
end

--显示其他玩家的战斗信息
function ItemPlayerAttributeList:InitOther(title, data)
    self._title.text = title
    self.height = self.defaultHeight

    self._list:RemoveChildrenToPool()
    for _, v in pairs(CommonType.PLAYER_DETAIL_BATTLE) do
        local item = self._list:AddItemFromPool()
        local name = StringUtil.GetI18n(I18nType.Commmon, v.i18n)
        local value = data[v.netKey]
        if v.netKey == "Winrate" then
            value = math.ceil(value * 100) .. "%"
        else
            value = Tool.FormatNumberThousands(value)
        end
        item:Init(name, value)
    end

    self._list:ResizeToFit(self._list.numChildren)
    self.height = self.defaultHeight + self._list.scrollPane.contentHeight
end

return ItemPlayerAttributeList
