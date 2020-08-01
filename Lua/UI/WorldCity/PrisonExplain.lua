--[[
    author:{zhanzhang}
    time:2019-11-18 17:54:36
    function:{监狱解释}
]]
local PrisonExplain = UIMgr:NewUI("PrisonExplain")

function PrisonExplain:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")

    self:OnRegister()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WordPrisonExplain)
end
function PrisonExplain:OnRegister()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("PrisonExplain")
        end
    )
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("PrisonExplain")
        end
    )
end

function PrisonExplain:OnOpen()
end

return PrisonExplain
