-- 废弃
local TroopsArmyDetailDismiss = fgui.extension_class(GButton)
fgui.register_extension("ui://MainCity/itemTroopsDetailsDismiss", TroopsArmyDetailDismiss)

function TroopsArmyDetailDismiss:ctor()
    self._dismissSlider = self:GetChild("slide")
    self._dismissText = self:GetChild("textInput")
    self._dismissBtnSub = self:GetChild("btnReduce")
    self._dismissBtnAdd = self:GetChild("btnAdd")
    self._dismissBtnOk = self:GetChild("btnDismiss2")

    self:AddListener(self._dismissSlider.onChanged,function()
        self._dismiss = math.floor(self._dismissSlider.value + 0.5)
        self._dismissText.text = self._dismiss
    end)

    self:AddListener(self._dismissSlider.onGripTouchEnd,function()
        self._dismissSlider.value = self._dismiss
    end)

    self:AddListener(self._dismissText.onFocusOut,function()
        local value = self._dismissText.text
        value = tonumber(value)
        if value ~= nil then
            value = math.floor(value + 0.5)
            if value > self._amount then
                value = self._amount
            elseif value < 0 then
                value = 0
            end
        else
            value = math.floor(self._dismissSlider.value)
        end
        self._dismissText.text = value
        self._dismissSlider.value = value
        self._dismiss = value
    end)

    self:AddListener(self._dismissBtnSub.onClick,function()
        self._dismiss = self._dismiss-1 < 0 and 0 or self._dismiss-1
        self._dismissText.text = self._dismiss
        self._dismissSlider.value = self._dismiss
    end)

    self:AddListener(self._dismissBtnAdd.onClick,function()
        self._dismiss = self._dismiss+1 > self._amount and self._amount or self._dismiss+1
        self._dismissText.text = self._dismiss
        self._dismissSlider.value = self._dismiss
    end)

    self:AddListener(self._dismissBtnOk.onClick,function()
        -- 发送解散信息
        if self._dismiss <= 0 then
            TipUtil.TipById(50114)
            return
        end
        self.visible = false
        local armies = {
            {
                ConfId = self._configId,
                Amount = self._dismiss,
            }
        }
        Net.Armies.Delete(armies)
    end)

    local btnDismissMask = self:GetChild("bgMask2")
    self:AddListener(btnDismissMask.onClick,function()
        self.visible = false
    end)
end

function TroopsArmyDetailDismiss:Refresh(configId, amount)
    self._dismiss = 0
    self._amount = amount
    self._configId = configId
    self._dismissSlider.max = self._amount
    self._dismissSlider.value = 0
    self._dismissText.text = 0
end

return TroopsArmyDetailDismiss