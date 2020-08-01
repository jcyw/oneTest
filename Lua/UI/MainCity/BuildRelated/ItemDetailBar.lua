--[[
    Author: songzeming
    Function: 信息条 详情
]]
local ItemDetailBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/detailBarNumber", ItemDetailBar)

function ItemDetailBar:ctor()
    for i = 1, self._itemText.numChildren do
        self["text" .. i] = self._itemText:GetChild("text" .. i)
    end
    self._colorControl = self._itemText:GetController("c1")
    self._bgControl = self:GetController("c1")
end

function ItemDetailBar:UpdateContent(args)
    for k, v in ipairs(args) do
        if tonumber(v) then
            if Tool.Integer(v) then
                v = Tool.FormatNumberThousands(v)
            else
                v = math.floor(v)
            end
        end
        self["text" .. k].text = v
    end
    local single = args[1] % 2 == 1
    -- self._barBgLight.visible = single
    -- self._barBgDark.visible = not single
    self._bgControl.selectedIndex = (args[1] + 1 ) % 2
    -- self._barBgLight.visible = false
    -- self._barBgDark.visible = true
    self._choose.visible = false
    self._colorControl.selectedIndex = 0
end

function ItemDetailBar:Init(...)
    local args = {...}
    UITool.FormatListText(self._itemText, #args)
    self:UpdateContent(args)
end

function ItemDetailBar:RadarInit(...)
    local args = {...}
    UITool.RadarFormatListText(self._itemText, #args)
    self:UpdateContent(args)
end

function ItemDetailBar:SetChoose()
    --self._choose.visible = true
    self._colorControl.selectedIndex = 1
    --self._barBgLight.visible = false
    --self._barBgDark.visible = false
end

return ItemDetailBar
