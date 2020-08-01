--[[
    Author: zixiao
    Function: 怪兽图鉴
]]
local MonsterOverview = UIMgr:NewUI("MonsterOverview")
local MonsterModel = import("Model/MonsterModel")

function MonsterOverview:OnInit()
	local view = self.Controller.contentPane
	self._textTitle = view:GetChild("textName")
	self._btnHelp = view:GetChild("btnHelp")
	self._btnReturn = view:GetChild("btnReturn")
	self._list = view:GetChild("liebiao")
	self._textTip = view:GetChild("textTip")
	self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "TIPS_BEAST_BASE")
	self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_BASE_IMG")
	self:InitEvent()
end

function MonsterOverview:InitEvent()
	self:AddListener(self._btnHelp.onClick,function ()
		local data = {
		    title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
		    info = StringUtil.GetI18n(I18nType.Commmon, "TIPS_BEAST_HAND_BOOK")
		}
		UIMgr:Open("ConfirmPopupTextCentered", data)
	end)

	self:AddListener(self._btnReturn.onClick,function ()
		UIMgr:Close("MonsterOverview")
	end)
end

function MonsterOverview:OnOpen(info)
	self.info = info
	table.sort(self.info, function(a, b)
		return a.Id < b.Id
	end)
	self:RefreshWindow()
end

function MonsterOverview:RefreshWindow()
	local beasts = MonsterModel.GetBeastModels()
	local curBeasts = {}
	for _,v in pairs(beasts) do
		table.insert(curBeasts, v)
	end
	table.sort(curBeasts, function(a, b)
		return a.Id < b.Id
	end)

	local index = 0
	self._list:RemoveChildrenToPool()
	for _,v in pairs(curBeasts) do 
		index = index + 1
		local item = self._list:AddItemFromPool()
		local info, curIndex = self:GetActiveInfo(v.Id)
		if info then
			item:SetData(self.info, curIndex)
		else
			item:SetLock(v)
		end
	end

	local item = self._list:AddItemFromPool()
	item:SetMoreState({"Laboratory", "com_icon_Serpent"})

	local item = self._list:AddItemFromPool()
	item:SetMoreState({"Laboratory", "com_icon_snake"})
end

function MonsterOverview:GetActiveInfo(id)
	local index = 0
	for _,v in pairs(self.info) do
		index = index + 1
		if v.Id == id and MonsterModel.IsUnlock(v.Id) then
			return v, index
		end
	end
end

return MonsterOverview