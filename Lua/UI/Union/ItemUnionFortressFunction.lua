--[[
    author:{zhanzhang}
    time:2019-10-28 15:51:16
    function:{联盟堡垒描述}
]]
local ItemUnionFortressFunction = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionFortressFunction", ItemUnionFortressFunction)


function ItemUnionFortressFunction:ctor()
end

function ItemUnionFortressFunction:Init(data)
    -- self._icon:GetChild("_icon").url = UITool.GetIcon(data.buff_image)
    self._icon:SetAmount(data.buff_image)
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, data.name_id)
    self._textContent.text = StringUtil.GetI18n(I18nType.Commmon, data.description_id)
end

return ItemUnionFortressFunction
