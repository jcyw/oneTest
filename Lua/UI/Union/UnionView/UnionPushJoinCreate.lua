--[[
    Author: songzeming
    Function: 创建联盟弹窗推送
]]
local UnionPushJoinCreate = UIMgr:NewUI("UnionView/UnionPushJoinCreate")
local UnionInfoModel = import("Model/Union/UnionInfoModel")

local CTR = {
    Join = 'Join',
    Create = 'Create'
}

function UnionPushJoinCreate:OnInit()
    self.Controller.BgUI.visible = false
    local view = self.Controller.contentPane
    self._ctr = view:GetController('Ctr')

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
    self:AddListener(self._btnCreate.onClick,
        function()
            self:OnBtnCreateClick()
        end
    )

    self._goldNum.text = "x" .. GlobalAlliance.FirstJoinReward

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionPushJoinCreate)
end

function UnionPushJoinCreate:OnOpen()
    if Model.Player.Level < Global.AllianceCreateByGemLv then
        self:Close()
    elseif Model.Player.Level < Global.AllianceCreateByFreeLv then
        self._ctr.selectedPage = CTR.Join
    else
        self._ctr.selectedPage = CTR.Create
    end
end

function UnionPushJoinCreate:Close()
    UIMgr:Close("UnionView/UnionPushJoinCreate")
end

function UnionPushJoinCreate:OnBtnCreateClick()
    if self._ctr.selectedPage == CTR.Create then
        self:Close()
        UIMgr:Open("UnionView/UnionCreate", true)
    else
        Net.Alliances.FastJoin(
            function(rsp)
                if rsp.Result == 0 then
                    SdkModel.TrackBreakPoint(10047)      --打点
                    Model.Player.AllianceId = rsp.Alliance.Uuid
                    Model.Player.AllianceName = rsp.Alliance.ShortName
                    Model.Player.AlliancePos = Global.AlliancePosR1
                    UnionInfoModel.SetInfo(rsp.Alliance)
                    Event.Broadcast(EventDefines.UIAllianceJoin)
                    self:Close()
                    TurnModel.UnionView()
                elseif rsp.Result == 1 then
                    TipUtil.TipById(50376)
                end
            end
        )
    end
end

return UnionPushJoinCreate
