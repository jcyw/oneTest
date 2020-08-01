--[[
    author:{maxiaolong}
    time:2019-09-19 19:50:37
    function:{取消投资Popup}
]]
local ConductFinancialTransactionsTips = UIMgr:NewUI("ConductFinancialTransactionsTips")

function ConductFinancialTransactionsTips:OnInit()
    self._view = self.Controller.contentPane
    self._title = self._view:GetChild("titleName")
    self._contentText = self._view:GetChild("_content")
    self._coinText = self._view:GetChild("textSub")
    self._coninNum = self._view:GetChild("_textNum")
    self._confirmText = self._view:GetChild("_confirm")
    self._btnUse = self._view:GetChild("_btnUse")
    self._btnUseTitle = self._btnUse:GetChild("title")
    self._bgMask = self._view:GetChild("_bgMask")
    --取消投资
    self:AddListener(self._btnUse.onClick,
        function()
            self.Close()
            Net.ChargeActivity.CancelInvest(
                self.data.id,
                function(params)
                    if (params.OK == true) then
                        if (self.handler ~= nil) then
                            self.handler()
                        end
                    end
                end
            )
        end
    )

    self:AddListener(self._bgMask.onClick,
        function()
            self.Close()
        end
    )
end

function ConductFinancialTransactionsTips:OnOpen(data, handler)
    self.data = data
    self.handler = handler
    self._title.text = data.title
    self._contentText.text = data.content
    self._coinText.text = data.capitalText
    self._coninNum.text = data.capitalNum
    self._confirmText.text = data.confirmText
    self._btnUseTitle.text=StringUtil.GetI18n(I18nType.Commmon,"BUTTON_CONFIRM")
    -- self.id = data.id
    -- self.capital = data.Capital
end
function ConductFinancialTransactionsTips.Close()
    UIMgr:Close("ConductFinancialTransactionsTips")
end
return ConductFinancialTransactionsTips
