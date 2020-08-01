--author: 	Amu
--time:		2019-10-29 11:01:25

local SetupSwitchAccount = UIMgr:NewUI("SetupSwitchAccount")

function SetupSwitchAccount:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiao")

    self._bindList = {}

    self:InitEvent()
end

function SetupSwitchAccount:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        return "ui://Setup/btnBind"
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._bindList[index+1], 2)
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local type = item:GetType()

        -- Sdk.SqSDKLogin(type)
        SdkModel.SqSDKLogin(type)
    end)
end

function SetupSwitchAccount:OnOpen()
    self._bindList = {}
    -- if not self.isBind and KSUtil.IsAndroid() then
        table.insert(self._bindList, SDK_BIND_TYPE.FACEBOOK_TYPE)
        table.insert(self._bindList, SDK_BIND_TYPE.GOOGLE_TYPE)
    -- else
        
    -- end

    self:RefreshListView()
end

function SetupSwitchAccount:RefreshListView( )
    self._listView.numItems = #self._bindList
end

function SetupSwitchAccount:Close()
    UIMgr:Close("SetupSwitchAccount")
end

return SetupSwitchAccount