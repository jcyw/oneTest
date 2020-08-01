
local SetupShield = UIMgr:NewUI("SetupShield")
local BlockListModel = import("Model/BlockListModel")

function SetupShield:OnInit()
	self._view = self.Controller.contentPane
	self._ctrView = self._view:GetController("c1")
	self._listView = self._view:GetChild("liebiao")
	self._textName = self._view:GetChild("textName")
	self._btnReturn = self._view:GetChild("btnReturn")
	self._textNoBanPlayer = self._view:GetChild("textShieldNo")
	self._textNoBanPlayer.text = StringUtil.GetI18n(I18nType.Commmon, "System_Banlist_Text")
	
	self:InitI18n()
	self:InitEvent()
end

function SetupShield:InitI18n()
	self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "System_Title9")
end

function SetupShield:InitEvent()
    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("SetupShield")
    end)
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        index = index + 1
        item:SetData(self.blockList[index],self)
    end
    self._listView:SetVirtual()
end

function SetupShield:OnOpen()
	self.blockList = BlockListModel.GetList()
	self:RefreshBlockList()
end

function SetupShield:RefreshBlockList()
	local num = #self.blockList
	self._ctrView.selectedIndex = num == 0 and 1 or 0
	self._listView.numItems = #self.blockList
end

return SetupShield
