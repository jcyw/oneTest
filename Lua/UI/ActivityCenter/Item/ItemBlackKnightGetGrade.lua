--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻个人获得积分Item}
]]
local ItemBlackKnightGetGrade = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightGetGrade", ItemBlackKnightGetGrade)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightGetGrade:ctor()
end

function ItemBlackKnightGetGrade:Init(index, data)
    self._textLevel.text = "lv." .. index
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, data.I18n)
    self._textNum.text = data.integral
end

return ItemBlackKnightGetGrade
