local itemSetupShield = fgui.extension_class(GComponent)
fgui.register_extension("ui://Setup/itemSetupShield", itemSetupShield)

local CommonModel = import("Model/CommonModel")
local BlockListModel = import("Model/BlockListModel")
function itemSetupShield:ctor( ... )
	self._textAlliName = self:GetChild("textName")
	self._textName = self:GetChild("textNameNum")
	self._icon = self:GetChild("icon")
	self._btnBlockList = self:GetChild("btnBlacklist")
	self._btnBlockList.text = StringUtil.GetI18n(I18nType.Commmon, "System_Banlist_Button")
	self:AddListener(self._btnBlockList.onClick, 
		function()
            BlockListModel.RemoveFromBlockList(self.data.UserId, function (rsp)
				TipUtil.TipById(50121, {name = self.data.Name})
            	self._par:RefreshBlockList()
            end)
        end
    )
end

function itemSetupShield:SetData(data, _par)
	self.data = data
	self._par = _par
	self:updateInfo()
end

function itemSetupShield:updateInfo()
	self._textName.text = self.data.Name
	if self.data.Alliance ~= "" then
		self._textAlliName.text = "["..self.data.Alliance.."] "
	else
		self._textAlliName.text = ""
	end

	-- CommonModel.SetUserAvatar(self._icon, self.data.Avatar, self.data.UserId)
    self._icon:SetAvatar(self.data, nil, self.data.UserId)
end

return itemSetupShield
