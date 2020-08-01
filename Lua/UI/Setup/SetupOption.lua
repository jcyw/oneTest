--author: 	Amu
--time:		2020-01-03 10:35:25

local SetupOption = UIMgr:NewUI("SetupOption")

function SetupOption:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiao")

    -- self._itemList = {
    --     {
    --         type = SET_TYPE.SoundVolume
    --     },
    --     {
    --         type = SET_TYPE.Clear
    --     },
    -- }

    self._itemList = ConfigMgr.GetList("configSystemSettings")

    self:InitEvent()
end

function SetupOption:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        return "ui://Setup/itemSetupOptionUpdate"
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._itemList[index+1], self)
    end
end

function SetupOption:OnOpen()
    self:RefreshListView()
    self._listView.scrollPane:ScrollTop()
end

function SetupOption:RefreshListView( )
    self._listView.numItems = #self._itemList
end

function SetupOption:Close()
    UIMgr:Close("SetupOption")
end

return SetupOption