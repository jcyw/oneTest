--author: 	Amu
--time:		2020-03-12 14:48:19

local BuildModel = import("Model/BuildModel")

local BeautyUpperLimit = UIMgr:NewUI("BeautyUpperLimit")

function BeautyUpperLimit:OnInit()
    self._view = self.Controller.contentPane

    self._btnClose = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._titleName = self._view:GetChild("titleName")

    self._listView = self._view:GetChild("liebiao")

    self.configInfo = ConfigMgr.GetList("configBases")

    self:InitEvent()
end

function BeautyUpperLimit:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()--返回
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        -- local grilInfo = self.girlsInfo[self._selectGirlIndex]
        local power = ConfigMgr.GetItem("configBuildingUpgrades", self.configInfo[index+1].id).power
        item:SetData(index+1, power, self.configInfo[index+1].rose_upperlimt)
    end

end

function BeautyUpperLimit:OnOpen()
    
    self._titleName.text = StringUtil.GetI18n("configI18nCommons", "rank_hqlevel")..tonumber(BuildModel.GetCenterLevel())
    self:RefreshListView()
end

function BeautyUpperLimit:RefreshListView()
    self._listView.numItems = #self.configInfo
end

function BeautyUpperLimit:Close( )
    UIMgr:Close("BeautyUpperLimit")
end

return BeautyUpperLimit