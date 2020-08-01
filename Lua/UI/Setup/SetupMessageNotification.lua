--author: 	Amu
--time:		2020-02-05 16:02:32
local SetupMessageNotification = UIMgr:NewUI("SetupMessageNotification")

function SetupMessageNotification:OnInit()
	self._view = self.Controller.contentPane
	self._btnReturn = self._view:GetChild("btnReturn")
	self._listView = self._view:GetChild("liebiao")
    self._textName = self._view:GetChild("textName")

    self._configList = ConfigMgr.GetList("configNotifySettings")
    -- self._notifySet = Model.GetMap(ModelType.NotifySettings)
    
	self:InitEvent()
end


function SetupMessageNotification:InitEvent()
    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("SetupMessageNotification")
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self._configList[index + 1])
    end
    self._listView:SetVirtual()
end

function SetupMessageNotification:OnOpen()
    self:RefreshListView()
end

function SetupMessageNotification:RefreshListView()
    self._listView.numItems = #self._configList
end


return SetupMessageNotification