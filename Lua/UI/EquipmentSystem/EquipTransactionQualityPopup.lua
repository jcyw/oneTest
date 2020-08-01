local EquipTransactionQualityPopup =  _G.UIMgr:NewUI("EquipTransactionQualityPopup")
function EquipTransactionQualityPopup:OnInit()
    -- 获取部件
    local view = self.Controller.contentPane
    self._btnClose = view:GetChild("_mask")
    self._btnSureSingle = view:GetChild("_btnSureSingle")
    self._btnProbability = {}
    for i = 1, 6 do
        self._btnProbability[i] = view:GetChild("btnProbability"..i)
    end

    -- 回调
    self.callback = nil
    -- 事件
    self:AddListener(self._btnClose.onClick,
        function()
            _G.UIMgr:Close("EquipTransactionQualityPopup")
        end
    )
    self:AddListener(self._btnSureSingle.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            if self.callback then
                self.callback()
            end
            _G.UIMgr:Close("EquipTransactionQualityPopup")
        end
    )
end
function EquipTransactionQualityPopup:OnOpen(data)
    self.callback = data.sureCallback
    for i = 1, #self._btnProbability do
        local item = self._btnProbability[i]
        item:GetChild("title").text = ("%.2f"):format((data.qualitysRatio[i]*100)).."%"
    end
end

function EquipTransactionQualityPopup:TriggerOnclick(callback)
    self.triggerFunc = callback
end
return EquipTransactionQualityPopup