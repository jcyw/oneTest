--author: 	Amu
--time:		2020-07-11 15:31:00

local DressUpModel = import("Model/DressUpModel")

local Individuationdialog = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/Individuationdialog", Individuationdialog)

function Individuationdialog:ctor()

    self._item1:SetData({
        name = StringUtil.GetI18n("configI18nRoles", "Novice_10001_ROLE"),
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander"),
        avatar = "",
        avatarCase = 80001001,
    })
    self._item2:SetData({
        name = TextUtil.GetFormatPlayName(Model.Player.AllianceName, Model.Player.Name),
        content = StringUtil.GetI18n(I18nType.Commmon, "UI_DressUp_BubbleExplan1"),
        avatar = Model.Player.Avatar,
        avatarCase = DressUpModel.usingDressUp[DRESSUP_TYPE.Avatar].DressUpConId,
        bubble = DressUpModel.usingDressUp[DRESSUP_TYPE.Bubble].DressUpConId,
        dressUpType = DRESSUP_TYPE.Bubble
    })
    self._item3:SetData({
        name = StringUtil.GetI18n("configI18nRoles", "Novice_10007_ROLE"),
        content = StringUtil.GetI18n(I18nType.Commmon, "UI_DressUp_BubbleExplan2"),
        avatar = "",
        avatarCase = 80001001,
    })
    self:InitEvent()
end

function Individuationdialog:InitEvent()
    self:AddEvent(DRESSUP_EVENT.SubChoseChange, function()
        if DressUpModel.curSelect == DRESSUP_TYPE.Bubble then
            self:Refresh()
        end
    end)
end

function Individuationdialog:Refresh()
    self._item2:RefreshData({
        avatar = Model.Player.Avatar,
        avatarCase = DressUpModel.usingDressUp[DRESSUP_TYPE.Avatar].DressUpConId,
        bubble = DressUpModel.curSubSelect,
        dressUpType = DRESSUP_TYPE.Bubble
    })
end

return Individuationdialog