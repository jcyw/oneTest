local GD = _G.GD
local VIPLevelPopup = UIMgr:NewUI("VIPLevelPopup")
local VIPModel = import("Model/VIPModel") 

function VIPLevelPopup:OnInit(index)
	local view = self.Controller.contentPane
	self._textTitle = view:GetChild("titleName")
	self._textContent = view:GetChild("content")
	self._textTips = view:GetChild("textTips")
	self._textTagL = view:GetChild("textTagLevel")
	self._textTagR = view:GetChild("textTagNext")
	self._list = view:GetChild("liebiao")
	self._btnUpgrate = view:GetChild("btnCity")
	self._btnMore = view:GetChild("btnUnion")
	self._btnClose = view:GetChild("btnClose")
	self._btnArrowL = view:GetChild("arrowL")
	self._btnArrowR = view:GetChild("arrowR")
	self._bgMask = view:GetChild("bgMask")
	self._ctr = view:GetController("c1")
	self:InitData()
end

function VIPLevelPopup:InitData()
	self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text6")
	self._textContent.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text7")
	self._textTips.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text8")
	self._btnUpgrate.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_UPGRADE")
	self._btnMore.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text9")
	self:InitEvent()
end

function VIPLevelPopup:OnOpen(vipInfo)
	self.vipInfo = vipInfo
	self.level = vipInfo.VipLevel
	self:CalRealCostItem()
	self:RefreshWindow()
end

function VIPLevelPopup:RefreshWindow()
	self._ctr.selectedIndex = #self.haveItems > 3 and 1 or 0
	self._list.numItems = #self.haveItems
	self._list:ScrollToView(0, false)
	self:SetVipTags() 
end


function VIPLevelPopup:InitEvent()
	self._list.scrollPane.touchEffect = false
	self._list.itemRenderer = function (index, item)
		local info = self.haveItems[index + 1]
		local conf = ConfigMgr.GetItem("configItems", info.ConfId)
		local midNum = GD.ItemAgent.GetItemInnerContent(info.ConfId)
		item:SetAmount(conf.icon, conf.color, info.Amount, nil, midNum)
	end

	self:AddListener(self._btnClose.onClick,function ()
		UIMgr:Close("VIPLevelPopup")
	end)

	self:AddListener(self._bgMask.onClick,function ()
		UIMgr:Close("VIPLevelPopup")
	end)

	self:AddListener(self._btnUpgrate.onClick,function ()
		Net.Items.BatchUse(self.haveItems, function(rsp)
			Event.Broadcast(EventDefines.VipPointsChange)
			if self.level < self.vipInfo.VipLevel then
				UIMgr:Open("VIPLevel",self.level,self.vipInfo.VipLevel)
			end
			UIMgr:Close("VIPLevelPopup")
		end)
	end)

	self:AddListener(self._btnArrowL.onClick,function ()
		self._list:ScrollToView(0, true)
	end)

	self:AddListener(self._btnArrowR.onClick,function ()
		self._list:ScrollToView(#self.haveItems - 1, true)
	end)

	self:AddListener(self._btnMore.onClick,function ()
		Net.Vip.GetVipInfo(function(msg) 
		    UIMgr:Open("VIPActivation",2,self.vipInfo.VipLevel,msg)
		    UIMgr:Close("VIPLevelPopup")
		end)
	end)

	self:AddEvent(
	    EventDefines.UIVipInfo,
	    function(rsp)
	        self.vipInfo = rsp
	    end)  

end

function VIPLevelPopup:CalRealCostItem()
	local haveItems = GD.ItemAgent.GetHaveItemsBysubType(PropType.ALL.Effect,PropType.VIP.Points)
	local totalValue = 0
	for _, v in ipairs(haveItems) do
		v.value = ConfigMgr.GetItem("configItems", v.ConfId).value
		totalValue = totalValue + v.value * v.Amount
	end
	table.sort(haveItems, function (a, b)
		return a.value > b.value
	end)
	local currPoints = self.vipInfo.VipPoints 
	local currLevel = self.vipInfo.VipLevel
	local level = currLevel + 1
	local conf = ConfigMgr.GetList("configVips")
	while true do
		if level > VIPModel.GetMaxVipLevel() then
			break
		end
		local _, nextPoint = VIPModel.GetLevelPropByConf(level, conf) 
		if nextPoint - currPoints > totalValue then
			break
		else
			level = level + 1
		end
	end
	if level > VIPModel.GetMaxVipLevel() then
		self.nextLevel = level - 1
		self.nextPercent = nil
		self.haveItems = {}
		local _, p = VIPModel.GetLevelPropByConf(self.nextLevel, conf)
		local remainPoint = p - currPoints
		for _, v in ipairs(haveItems) do
			local amount = math.ceil(remainPoint / v.value)
			if amount < v.Amount then
				table.insert(self.haveItems, {ConfId = v.ConfId, Amount = amount, value = v.value})
				break
			end
			table.insert(self.haveItems, {ConfId = v.ConfId, Amount = v.Amount, value = v.value})
			remainPoint = remainPoint - v.Amount * v.value			
		end
	else
		self.haveItems = haveItems
		local _, p1 = VIPModel.GetLevelPropByConf(level - 1, conf)
		local _, p2 = VIPModel.GetLevelPropByConf(level, conf)
		self.nextPercent =  math.floor((currPoints - p1 + totalValue) / (p2 - p1) * 100)
		self.nextLevel = level - 1
	end
	local _, p3 = VIPModel.GetLevelPropByConf(currLevel, conf)
	local _, p4 = VIPModel.GetLevelPropByConf(currLevel + 1, conf)
	self.currPercent = math.floor((currPoints - p3) / (p4 - p3) * 100)
end

function VIPLevelPopup:SetVipTags()
	local t1 = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = self.vipInfo.VipLevel})
	local t2 = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = self.currPercent .. "%"})
	self._textTagL.text = t1 .. t2
	local t3 = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = self.nextLevel})
	self._textTagR.text = t3
	if self.nextPercent then
		local t4 = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = self.nextPercent .. "%"})
		self._textTagR.text = self._textTagR.text .. t4
	end
end

return VIPLevelPopup