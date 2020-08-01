--author: 	Amu
--time:		2019-11-18 19:17:29


local SetupRoleSelect = UIMgr:NewUI("SetupRoleSelect")

function SetupRoleSelect:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiao")

    self._roleList = {}

    self:InitEvent()
end

function SetupRoleSelect:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        return "ui://Setup/itemSetupRoleSelect"
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._bindList[index + 1])
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local info = item:GetData()
        if info then
            if info.RoleId ~= UserModel.data.accountId then
                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "TAB_CHARACTER", {character_name = info.Name}),
                    sureCallback = function()
                        UserModel.SwitchRole(info.RoleId)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                
            end
        else
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "CREATE_CHARACTER"),
                sureCallback = function()
                    UserModel.StartNewGame()
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)
end

function SetupRoleSelect:OnOpen(relesInfo)
    self._bindList = {}
    for _,v in ipairs(relesInfo.Roles)do
        table.insert(self._bindList, v)
    end

    self:RefreshListView()
end

function SetupRoleSelect:RefreshListView( )
    self._listView.numItems = 5
end

function SetupRoleSelect:Close()
    UIMgr:Close("SetupRoleSelect")
end

return SetupRoleSelect