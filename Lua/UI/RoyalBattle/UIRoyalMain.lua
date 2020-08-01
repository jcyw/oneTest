--[[
    Author: tiantian
    Function:王城主界面
]]
local UIRoyalMain = _G.UIMgr:NewUI("UIRoyalMain")

function UIRoyalMain:OnInit()
    local view = self.Controller.contentPane
    self.view = view
    self._funcName.text = "城市大厅"
    self:OnAddEvent()
end
function UIRoyalMain:OnAddEvent()
    --注册监听事件
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("UIRoyalMain")
        end
    )
    self:AddListener(
        self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(_G.ConfigMgr.GetItem("configWindowhelps", 1011).article_id)
        end
    )
    self:AddListener(
        self._flagIcon.onClick,
        function()
            _G.UIMgr:Open("PlayerFlag",FLAG_TYPE.Royal)
        end
    )
end
function UIRoyalMain:OnOpen()

end
function UIRoyalMain:OnClose()
end
return UIRoyalMain
