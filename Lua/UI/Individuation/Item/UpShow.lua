--author: 	Amu
--time:		2020-07-07 16:07:15

local DressUpModel = import("Model/DressUpModel")

local UpShow = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/UpShow", UpShow)

function UpShow:ctor()
    self._ctrView = self:GetController("page")

    self._selectText = self._item:GetChild("n10")
    self._isUseText = self._item:GetChild("n11")

    self:InitEvent()
end

function UpShow:InitEvent()
    self:AddEvent(DRESSUP_EVENT.SubChoseChange, function()
        self:RefreshById()
    end)

    self:AddEvent(DRESSUP_EVENT.ChoseChange, function(dressUpTyp)
        self.dressUpType = dressUpTyp
        self:RefreshById()
    end)
end

function UpShow:Refresh(dressUpType, dressUpId)
    if self.dressUpType == dressUpType then
        return
    end
    self.dressUpType = dressUpType

    self:RefreshById()
end

function UpShow:RefreshById()
    local info = DressUpModel.GetDressUpInfoById(DressUpModel.curSubSelect)
    if info then
        self._selectText.text = StringUtil.GetI18n(I18nType.Commmon, info.config.i18n_name)
    end

    if self.dressUpType == DRESSUP_TYPE.Nameplate then
        self._ctrView.selectedIndex = 0
        self._itemNameplate:SetData(DressUpModel.curSubSelect)
    elseif self.dressUpType  == DRESSUP_TYPE.Avatar then
        self._ctrView.selectedIndex = 1
        self._itemAvatar:Refresh()
    elseif self.dressUpType  == DRESSUP_TYPE.Bubble then
        self._ctrView.selectedIndex = 2
        self._itemBubble:Refresh()
    end

    local _dressUpList = DressUpModel.GetSelectDressUp(DressUpModel.curSubSelect)
    local using = false
    for _,v in ipairs(_dressUpList)do
        if v.DressUpConId == DressUpModel.usingDressUp[DressUpModel.curSelect].DressUpConId then
            using = true
            break
        end
    end
    if using then
        self._isUseText.visible = true
    else
        self._isUseText.visible = false
    end
end

return UpShow