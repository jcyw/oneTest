--[[
    Author: songzeming
    Function: 确认弹窗 资源不足
]]
local ConfirmPopupDissatisfaction = UIMgr:NewUI("ConfirmPopupDissatisfaction")

function ConfirmPopupDissatisfaction:OnInit()
    self._textGold = self._btnSure:GetChild("text")
    self._btnGetMore.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Get_More")
    self:AddListener(
        self._btnSure.onClick,
        function()
            self:OnBtnSureClick()
        end
    )
    self:AddListener(
        self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._btnGetMore.onClick,
        function()
            self:OnBtnGetMoreClick()
        end
    )
end

--[[
    data = {
        textTip = 提示文本
        gold = 消耗金币
        lackRes = 缺少资源
        textBtnSure = 按钮文本
        cbBtnSure = 点击确定按钮回调
        cbBtnGetMore = 点击获取更多按钮回掉
    }
]]
function ConfirmPopupDissatisfaction:OnOpen(data)
    self.data = data

    self:UpdataData()
end

function ConfirmPopupDissatisfaction:Close()
    UIMgr:Close("ConfirmPopupDissatisfaction")
end

function ConfirmPopupDissatisfaction:UpdataData()
    --提示内容
    self._textTip.text = self.data.textTip
    self._btnSure.title = self.data.textBtnSure
    --缺少资源
    local gold = 0
    self._list.numItems = #self.data.lackRes
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local res = self.data.lackRes[i]
        local conf = ConfigMgr.GetItem("configResourcess", res.Category)
        local amount = math.floor(res.Amount)
        local formatAmount = Tool.FormatNumberThousands(amount)
        local title = StringUtil.GetI18n(I18nType.Commmon, conf.key)
        item:SetAmount(conf.img, conf.color, formatAmount, title)
        gold = gold + Tool.ResTurnGold(res.Category, amount)
    end
    self.gold = gold
    self._textGold.text = gold

    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentWidth > self._list.width
end

--点击获取更多按钮
function ConfirmPopupDissatisfaction:OnBtnGetMoreClick()
    UIMgr:Close("ConfirmPopupDissatisfaction")
    local resType = self.data.lackRes[1].Category
    UIMgr:Open("ResourceDisplay", resType)
    if self.data.cbBtnGetMore then
        self.data.cbBtnGetMore()
    end
end

--点击确认按钮
function ConfirmPopupDissatisfaction:OnBtnSureClick()
    if not UITool.CheckGem(self.gold) then
        return
    end
    if
        self.data.isBuild and self.data.updateTime and self.data.titleText and
            not BuildModel.CheckBuilder(
                self.data.isBuild and "Build" or "Upgrade",
                self.data.updateTime,
                self.data.titleText,
                function()
                    Net.Items.BuyRes(
                        self.data.lackRes,
                        function()
                            if self.data.cbBtnSure then
                                self.data.cbBtnSure()
                            end
                            UIMgr:Close("ConfirmPopupDissatisfaction")
                        end
                    )
                end
            )
     then
    else
        --购买资源
        Net.Items.BuyRes(
            self.data.lackRes,
            function()
                if self.data.cbBtnSure then
                    self.data.cbBtnSure()
                end
                UIMgr:Close("ConfirmPopupDissatisfaction")
            end
        )
    end
end

return ConfirmPopupDissatisfaction
