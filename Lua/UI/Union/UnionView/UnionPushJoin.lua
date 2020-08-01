--[[
    Author: songzeming
    Function: 联盟加入推送
]]
local UnionPushJoin = UIMgr:NewUI("UnionView/UnionPushJoin")

local UnionModel = import("Model/UnionModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")

function UnionPushJoin:OnInit()
    self.Controller.BgUI.visible = false
    local view = self.Controller.contentPane
    self._guide = view:GetChild("guide")
    self._bg = view:GetChild("bg")
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnView.onClick,
        function()
            self:OnBtnViewClick()
        end
    )
    self:AddListener(self._btnJoin.onClick,
        function()
            self:OnBtnJoinClick()
            self:GuideShow(false)
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:GuideShow(false)
        end
    )
    self:AddListener(self._bg.onClick,
        function()
            self:GuideShow(false)
        end
    )
end

function UnionPushJoin:OnOpen(data)
    if UnionModel.CheckJoinUnion() then
        self:Close()
        return
    end
    self.data = data
    self._unionIcon.icon = UnionModel.GetUnionBadgeIcon(data.Avatar)
    self._unionName.text = "(" .. data.ShortName .. ")" .. data.Name
    self._unionDesc.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Recommend_Txt"..math.random(1,3))
    self._playerName.text = data.President
    self:GuideShow(true)
end

function UnionPushJoin:Close()
    UIMgr:Close("UnionView/UnionPushJoin")
end

--查看联盟
function UnionPushJoin:OnBtnViewClick()
    self:Close()
    UIMgr:Open("UnionView/UnionView")
end

--加入联盟
function UnionPushJoin:OnBtnJoinClick()
    Net.Alliances.Join(
        self.data.AllianceId,
        function(rsp)
            SdkModel.TrackBreakPoint(10047)      --打点
            Model.Player.AllianceId = rsp.Alliance.Uuid
            Model.Player.AllianceName = rsp.Alliance.ShortName
            Model.Player.AlliancePos = Global.AlliancePosR1
            UnionInfoModel.SetInfo(rsp.Alliance)
            Event.Broadcast(EventDefines.UIAllianceJoin)
            self:Close()
            TurnModel.UnionView()
        end
    )
end

function UnionPushJoin:GuideShow(flag)
    self._guide.visible = flag
end

return UnionPushJoin
