--[[
    Author: songzeming
    Function: 创建联盟弹窗推送 天选之人
]]
local UnionPushCreateGodLike = UIMgr:NewUI("UnionView/UnionPushCreateGodLike")

local UnionModel = import("Model/UnionModel")

function UnionPushCreateGodLike:OnInit()
    self.Controller.BgUI.visible = false
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnCreate.onClick,
        function()
            self:OnBtnCreateClick()
        end
    )
end

function UnionPushCreateGodLike:OnOpen()
    if UnionModel.CheckJoinUnion() then
        self:Close()
        return
    end
end

function UnionPushCreateGodLike:Close()
    UIMgr:Close("UnionView/UnionPushCreateGodLike")
end

function UnionPushCreateGodLike:OnBtnCreateClick()
    UIMgr:Open("UnionView/UnionCreate", true)
end

return UnionPushCreateGodLike