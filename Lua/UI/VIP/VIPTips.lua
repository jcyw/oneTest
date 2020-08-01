--[[
    Author:zhangzhichao
    Function:VIP温馨提示
]]
local VIPTips = UIMgr:NewUI("VIPTips")

function VIPTips:OnInit()
    local view=self.Controller.contentPane
    self._btnClose = view:GetChild("btnClose")
    self._bgMask = view:GetChild("bgMask")
    self._titleName=view:GetChild("titleName")
    self._titleName.text=StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    self._tips=view:GetChild("text")
    self._controller=view:GetController("c1")
    self._bgVIPL=view:GetChild("bgVIPL")
    self._iconVIPL=view:GetChild("iconVIPL")
    -- self._textVIPL =  view:GetChild("textVIPL")
    self._textVIPNumL=view:GetChild("textVIPNumL")
    self._textL=view:GetChild("textL")
    self._bgVIPR=view:GetChild("bgVIPR")
    self._iconVIPR=view:GetChild("iconVIPR")
    -- self._textVIPR =  view:GetChild("textVIPR")
    self._textVIPNumR =  view:GetChild("textVIPNumR")
    self._textR=view:GetChild("textR")

    self:AddListener(self._btnClose.onClick,function() 
        UIMgr:Close("VIPTips")
    end)
    self:AddListener(self._bgMask.onClick,function() 
        UIMgr:Close("VIPTips")
    end)
end

function VIPTips:OnOpen(isShop)
    if isShop then
        self._tips.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Tips2")
        self._controller.selectedIndex =1
    else
        self._tips.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Tips")
        self._controller.selectedIndex =0
        self._textVIPNumL.text=10
        self._textVIPNumR.text=10
        self._textL.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Desc_Val2")
        self._textR.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Desc_Val1")
        -- self._textVIPL.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Title")
        -- self._textVIPR.text=StringUtil.GetI18n(I18nType.Commmon, "Vip_Title")
    end
end

return VIPTips