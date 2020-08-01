--[[
    author:{laofu}
    time:2020-07-28 21:07:40
    function:{钻石月卡弹窗}
]]
local MonthlyCardPopup = UIMgr:NewUI("Welfare/MonthlyCardPopup")
local WelfareModel = import("Model/WelfareModel")

function MonthlyCardPopup:OnInit()
    self._banner.icon = UITool.GetIcon(_G.GlobalBanner.MonthlyCardPopupBanner)
    self._bigIcon.icon = UITool.GetIcon({"icon", "item203101"})

    self._btnGoto.title = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_config")
    self._text1.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_text_1")
    self._text2.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Store_Hot")
    self._text3.text = "1000%"
    self._text4.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_text_2")
    self._text5.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_text_3")
    self._text6.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_text_4")
    self._text7.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DiamondFund_text_5")
    self._text8.text = 500
    self._text9.text = 5100

    self:InitEvent()
end

function MonthlyCardPopup:InitEvent()
    self:AddListener(
        self._maskTouch.onClick,
        function()
            UIMgr:Close("MonthlyCardPopup")
        end
    )
    self:AddListener(
        self._btnClose.onClick,
        function()
            UIMgr:Close("MonthlyCardPopup")
        end
    )
    self:AddListener(
        self._btnGoto.onClick,
        function()
            UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY)
            UIMgr:Close("MonthlyCardPopup")
        end
    )
end

return MonthlyCardPopup
