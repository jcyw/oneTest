--[[
    author:{zhanzhang}
    time:2019-07-08 15:08:36
    function:{兵力援助确认框}
]]
local UnionSoldierAssistancePopup = UIMgr:NewUI("UnionSoldierAssistancePopup")

function UnionSoldierAssistancePopup:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnCancel = view:GetChild("btnCancel")
    self._btnClose = view:GetChild("btnClose")
    self._btnGo = view:GetChild("btnGo")
    self._progressBar = view:GetChild("ProgressBar")
    self._textProgress = view:GetChild("textProgressBar")
    self:OnRegister()
end

function UnionSoldierAssistancePopup:OnRegister()
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnGo.onClick,
        function()
            self:Close()

            local data = {
                openType = self.type,
                posNum = self.posNum,
                amryLimit = math.floor(self._progressBar.max),
                assistId = self.targetId
            }

            if self.agg then
                UIMgr:Open("Aggregation", self.posNum)
            else
                UIMgr:Open("Expedition", data)
            end
        end
    )
end
function UnionSoldierAssistancePopup:OnOpen(posNum, maxVal, nowVal, type, targetId, agg)
    self.posNum = posNum
    self._progressBar.max = maxVal
    self._progressBar.value = nowVal
    self._textProgress.text = nowVal .. "/" .. maxVal
    self._btnGo.enabled = nowVal < maxVal
    self.type = type
    self.targetId = targetId
    self.agg = agg
end

function UnionSoldierAssistancePopup:Close()
    UIMgr:Close("UnionSoldierAssistancePopup")
end

return UnionSoldierAssistancePopup
