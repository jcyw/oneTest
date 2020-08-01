-- author:{Amu}
-- time:2019-06-13 11:51:58


local MailAllianceSystemInformation = UIMgr:NewUI("MailAllianceSystemInformation")


function MailAllianceSystemInformation:OnInit()
    self._view = self.Controller.contentPane
    self._tilteText = self._view:GetChild("textName")
    self._authorText = self._view:GetChild("textTagName")

    self._bar = self._view:GetChild("itemDownBar")

    self._textTime = self._view:GetChild("textTime")

    self._iconHead = self._view:GetChild("iconHead")
    self._name = self._view:GetChild("textSystemName")

    self._content = self._view:GetChild("textContent")

    self._btnDonate = self._view:GetChild("btnDonate")

    self:InitEvent()
end

function MailAllianceSystemInformation:OnOpen(type, index, info, panel)
    self.type = type
    self.subType = info.SubCategory
    self._panel = panel
    self:_refreshData(info, index)
end

function MailAllianceSystemInformation:_refreshData(info, index)
    self.report = JSON.decode(info.Report)

    self.index = index
    self._info = info
    self._tilteText.text = info.Subject 
    self._authorText.text = info.Preview
    -- self._btnDonate.text = info.Preview
    
    -- local str = ""
    -- if self.report.Alliance and self.report.Alliance ~= "" then
    --     str = str.."["..self.report.Alliance.."]"
    -- end
    -- if self.report.Player then
    --     str = str..self.report.Player
    --     self._name.text = str
    -- end
    if self.report.Avatar then
        -- CommonModel.SetUserAvatar(self._iconHead, self.report.Avatar)
        self._iconHead:SetAvatar(self.report)
    end

    self._textTime.text = TimeUtil:GetTimesAgo(info.CreatedAt)


    self._content.text = info.Content

    self._bar:SetData(info, self)

    self.leftInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index - 1)
    self.rightInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index + 1)

    if self.leftInfo then
        self._view:GetChild("arrowL").visible = true
    else
        self._view:GetChild("arrowL").visible = false
    end

    if self.rightInfo then
        self._view:GetChild("arrowR").visible = true
    else
        self._view:GetChild("arrowR").visible = false
    end

end

function MailAllianceSystemInformation:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailAllianceSystemInformation:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailAllianceSystemInformation")
    end)


    self:AddListener(self._view:GetChild("arrowL").onClick,function()
        MailModel:ChangePanel(self, self.leftInfo, self.index-1)
    end)

    self:AddListener(self._view:GetChild("arrowR").onClick,function()
        MailModel:ChangePanel(self, self.rightInfo, self.index+1)
    end)

    self:AddListener(self._btnDonate.onClick,function()
        local mailType = math.ceil(self._info.MailType)
        if mailType == 20001 then       --收集资源
            UIMgr:ClosePopAndTopPanel()
            TurnModel.MineTurnPos(RES_TYPE.Wood)
        elseif mailType == 20002 then   --帮助联盟成员
            UIMgr:Open("UnionMain/UnionHelp")
        elseif mailType == 20003 then   --邀请迁移
            Net.Items.GetAllianceFlyCityPos(function(rsp)
                UIMgr:ClosePopAndTopPanel()
                Event.Broadcast(EventDefines.OpenWorldMap, rsp.X, rsp.Y)
                local data = {}
                data.ConfId = Global.AllianceFlyCityItemID
                data.BuildType = WorldBuildType.UnionGoLeader
                data.posNum = rsp.X * 10000 + rsp.Y
                WorldMap.AddEventAfterMap(function()
                    Event.Broadcast(EventDefines.BeginBuildingMove, data)
                end)
            end)
        elseif mailType == 20004 then   --捐献联盟科技
            UIMgr:OpenHideLastFalse("UnionScienceDonate")
        elseif mailType == 20005 then   --参与联盟战争
            UIMgr:Open("UnionWarfare")
        elseif mailType == 20023 then   --参与联盟建造
            UIMgr:Open("UnionTerritorialManagement")--("UnionTerritorialManagementSingle")
        elseif mailType == 20014 or mailType == 20026 then   --联盟建筑放置通知
            TurnModel.WorldPos(self.report.X, self.report.Y)
        elseif mailType == 20009 then   --援助部队撤离通知
            TurnModel.WorldPos(self.report.X, self.report.Y)
        end
    end)
end

function MailAllianceSystemInformation:Close()
    UIMgr:Close("MailAllianceSystemInformation")
end

return MailAllianceSystemInformation