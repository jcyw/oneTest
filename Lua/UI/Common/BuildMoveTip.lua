--[[
    Author: songzeming
    Function: 建筑移动提示框
]] 
local BuildMoveTip = UIMgr:NewUI("BuildMoveTip")

function BuildMoveTip:OnInit()
    self.Controller.BgUI.visible = false
    local view = self.Controller.contentPane
    view.width = GRoot.inst.width
    view.y = GRoot.inst.height * 0.7

    self:AddEvent(
        _G.EventDefines.UICloseMapDetail,
        function()
            _G.Event.Broadcast(_G.EventDefines.UICityBuildMove, _G.BuildType.MOVE.Reset)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
        end
    )
end

function BuildMoveTip:OnOpen()
    CityType.BUILD_MOVE_TIP = true
end

function BuildMoveTip:OnClose()
    CityType.BUILD_MOVE_TIP = false
end

return BuildMoveTip

