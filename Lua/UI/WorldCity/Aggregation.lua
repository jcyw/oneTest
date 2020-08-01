--[[
    author:{zhanzhang}
    time:2019-05-29 15:32:07
    func:{集结进攻选择}
]]
local Aggregation = UIMgr:NewUI("Aggregation")

function Aggregation:OnInit()
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._titleName = view:GetChild("titleName")
    self._text = view:GetChild("text")

    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Assemble")
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Assemble_Txt")
    local I18nKey = {"Ui_Assemble_5min","Ui_Assemble_10min","Ui_Assemble_30min","Ui_Assemble_60min"}
    self._btnList = {}
    for i = 1, 4 do
        self._btnList[i] = view:GetChild("btnTime" .. i)
        self._btnList[i].text = StringUtil.GetI18n(I18nType.Commmon, I18nKey[i])
    end

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("Aggregation")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("Aggregation")
        end
    )

    self:OnRegister()
end

function Aggregation:OnRegister()
    for i = 1, 4 do
        self:AddListener(self._btnList[i].onClick,
            function()
                UIMgr:Close("Aggregation")

                local data = {
                    openType = ExpeditionType.UnionAttack,
                    posNum = self.posNum,
                    aggregation = i - 1,
                    monsterId = self.monsterId
                }

                UIMgr:Open("Expedition", data)
            end
        )
    end
end

function Aggregation:OnOpen(posNum, monsterId)
    self.posNum = posNum
    self.monsterId = monsterId
end

return Aggregation
