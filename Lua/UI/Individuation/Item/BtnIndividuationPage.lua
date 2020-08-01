--author: 	Amu
--time:		2020-07-10 14:43:22

local DressUpModel = import("Model/DressUpModel")

local BtnIndividuationPage = fgui.extension_class(GButton)
fgui.register_extension("ui://Individuation/btnIndividuationPage", BtnIndividuationPage)

function BtnIndividuationPage:ctor()

    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    self._ctrView = self:GetController("button")

    self:InitEvent()
end

function BtnIndividuationPage:InitEvent()
    self:AddListener(self.onClick,function()
        if DressUpModel.curSelect ~= self.dressUpType then
            DressUpModel.curSelect = self.dressUpType
            DressUpModel.RevertDefaultDressUp(DressUpModel.curSelect)
            DressUpModel.GetDressUpType(self.dressUpType, function()
                if DressUpModel.curSelect ~= self.dressUpType then
                    return
                end
                Event.Broadcast(DRESSUP_EVENT.ChoseChange, self.dressUpType)
            end)
        end
    end)

    self:AddEvent(DRESSUP_EVENT.ChoseChange, function(dressUpType)
        if dressUpType == self.dressUpType then
            self._ctrView.selectedIndex = 1
        else
            self._ctrView.selectedIndex = 0
        end
    end)
end

function BtnIndividuationPage:SetData(info)
    self.dressUpType = info.types
    self._icon.icon = UITool.GetIcon(info.symbol)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, info.i18n_name)

    if DressUpModel.curSelect == self.dressUpType then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end
end

return BtnIndividuationPage