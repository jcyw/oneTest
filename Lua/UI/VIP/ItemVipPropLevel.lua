local ItemVipPropLevel = fgui.extension_class(GComponent)
fgui.register_extension("ui://VIP/itemVipPropLevel", ItemVipPropLevel)

local VIPModel = import("Model/VIPModel")

function ItemVipPropLevel:ctor()
    self._goodsNameL = self:GetChild("titleL")
    self._goodsDescL = self:GetChild("textL")
    self._goodsIcon = self:GetChild("itemProp")
    self._iconArrow = self:GetChild("iconArrow")
    self._ctr = self:GetController("c1")
    --self._iconNew = self:GetChild("_iconNew")
    --self._textNew = self:GetChild("textNew")
end

function ItemVipPropLevel:InitEvent(v1, curlevel, isRight)
    local conf1 = ConfigMgr.GetList("configVipAttrs")
    local prop = v1.vip_right
    local icon, type,color = VIPModel.GetInfoByProp(conf1, prop)
    self._goodsNameL.text = ConfigMgr.GetI18n("configI18nCommons", "Vip_Desc"..prop)   --名称显示
    --self._textNew.text = StringUtil.GetI18n(I18nType.Commmon, "New_Label")
    --self._goodsIcon:SetIcon(UITool.GetIcon(icon))             --图片显示
    --self._goodsIcon:SetMiddleActive(false)
    --self._goodsIcon:SetQuality(color)
    self._goodsIcon:SetShowData(icon,color)
    self._goodsIcon:SetNewText(StringUtil.GetI18n(I18nType.Commmon, "New_Label"))

    self:PropType(type, curlevel, v1, isRight)
end

function ItemVipPropLevel:PropType(type, curlevel, v1, isRight) 

    local setData = function (type, v)
        if not v1.num then
            self._goodsDescL.text = 0
            return
        end
        self._goodsDescL.text = VIPModel.GetValueByType(v.num, type) or ""
    end

    
    if isRight then
        self._ctr.selectedIndex = v1.sort ~= 1 and 1 or 0
        self:IsShow(v1.sort ~= 1)
        self:SetNew(v1.sort == 3) 
    else
        self._ctr.selectedIndex = v1.sort == 3 and 2 or 0
        self:IsShow(false)
        self:SetNew(false)
    end
    setData(type, v1)
end

function ItemVipPropLevel:IsShow(bool)
    self._iconArrow.visible = bool
end

function ItemVipPropLevel:SetNew(isNew)
	--self._iconNew.visible = isNew
    --self._textNew.visible = isNew
    self._goodsIcon:SetNewActive(isNew)
end

return ItemVipPropLevel