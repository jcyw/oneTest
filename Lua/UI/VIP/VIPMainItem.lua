--[[
    Author:zhangzhichao
    Function:VIP主界面列表格子
]]
local VIPMainItem = fgui.extension_class(GButton)
fgui.register_extension("ui://VIP/itemVipProp", VIPMainItem)

local VIPModel = import("Model/VIPModel")

function VIPMainItem:ctor()
    self._goodsNameL = self:GetChild("titleL")
    self._goodsDescL = self:GetChild("textL")
    self._goodsIcon = self:GetChild("itemProp")
    self._iconArrow = self:GetChild("iconArrow")
    self._ctr = self:GetController("c1")
end

function VIPMainItem:InitEvent(v1, curlevel, isRight)
    local conf1 = ConfigMgr.GetList("configVipAttrs")
    local prop = v1.vip_right
    local icon, type,color = VIPModel.GetInfoByProp(conf1, prop)
    self._goodsNameL.text = ConfigMgr.GetI18n("configI18nCommons", "Vip_Desc" .. prop) --名称显示
    self._goodsIcon:SetPage("true")
    self._goodsIcon:SetShowData(icon,color)
    self:PropType(type, curlevel, v1, isRight)
end

function VIPMainItem:PropType(type, curlevel, v1, isRight)
    local setData = function(type, v)
        if not v.num then
            v.num = 0
        end
        local value = VIPModel.GetValueByType(v.num, type) or ""
        self._goodsDescL.text = value
    end

    -- isRight为true表示是显示在右边的vipitem,sort为1代表数值无变化,2代表数值增加,3代表新加了没有的功能
    if isRight then
        self._ctr.selectedIndex = v1.sort ~= 1 and 1 or 0
        self:IsShow(v1.sort ~= 1)
        if v1.sort == 3 then
            self._goodsIcon:SetHotActive(true)
            --设置new文本
            local newText = StringUtil.GetI18n(I18nType.Commmon, "New_Label")
            self._goodsIcon:SetHotText(newText)
        end
    else
        self._ctr.selectedIndex = v1.sort == 3 and 2 or 0
        self:IsShow(false)
    end
    setData(type, v1)
end

function VIPMainItem:IsShow(bool)
    self._iconArrow.visible = bool
end

return VIPMainItem
