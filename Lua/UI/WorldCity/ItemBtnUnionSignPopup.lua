--[[
    author:{author}
    time:2019-09-05 10:49:49
    function:{联盟标记子按钮}
]]
local ItemBtnUnionSignPopup = fgui.extension_class(GButton)
fgui.register_extension("ui://WorldCity/btnUnionSignPopup", ItemBtnUnionSignPopup)
local FavoriteModel = import("Model/FavoriteModel")

-- 默认解锁一个，VIP解锁一个，其他三个是科技解锁的

function ItemBtnUnionSignPopup:ctor()
    self._text = self:GetChild("text")
end

function ItemBtnUnionSignPopup:Init(index)
    local info = FavoriteModel.GetUnionSignByType(index - 1)
    if not info then
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLIANCEMARK_DEFAULT")
        return
    end
    self._text.text = StringUtil.GetCoordinataWithLetter(info.X, info.Y)
end

function ItemBtnUnionSignPopup:slideOnChange(self)
end

return ItemBtnUnionSignPopup
