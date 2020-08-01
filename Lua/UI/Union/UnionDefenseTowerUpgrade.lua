--[[
    author:{zhanzhang}
    time:2019-07-29 14:17:24
    function:{联盟防御塔升级}
]]
local UnionDefenseTowerUpgrade = UIMgr:NewUI("UnionDefenseTowerUpgrade")

function UnionDefenseTowerUpgrade:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnClose = view:GetChild("btnClose")
    self._iconSkill = view:GetChild("icon")
    self._textSkillName = view:GetChild("textName")
    self._textContent = view:GetChild("textContent")

    self._iconCondition = view:GetChild("icon2")
    self._textAllianceEnergyNum = view:GetChild("textAllianceEnergyNum")
    self._btnObtain = view:GetChild("btnObtain")
    self._btnUpgrade = view:GetChild("btnGreen2")

    self:OnRegister()
end

function UnionDefenseTowerUpgrade:OnRegister()
    --前往获取资源
    self:AddListener(self._btnObtain.onClick,
        function()
        end
    )
    self:AddListener(self._btnUpgrade.onClick,
        function()
        end
    )
end
function UnionDefenseTowerUpgrade:OnOpen()
end

return UnionDefenseTowerUpgrade
