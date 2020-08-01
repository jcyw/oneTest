--[[
    author:Temmie
    time:2020-06-11
    function:装备材料生产界面
]]
local EquipmentMake = _G.UIMgr:NewUI("EquipmentMake")
local GuidePanelModel = import("Model/GuideControllerModel")
local maxSlot = 5
local curQuality = 0
local EquipModel = _G.EquipModel
local UIMgr = _G.UIMgr
local Stage = _G.Stage

function EquipmentMake:OnInit()
    self.view = self.Controller.contentPane
    self._materialController = self.view:GetController("materialController")
    self._typeController = self.view:GetController("typeController")  

    self._btnWhite:GetChild("lock").visible = false
    self._btnGreen.touchable = false
    self.curTouchBtn = nil
    self.curPreSlot = nil

    self:InitAgent()

    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")

    self:AddListener(self._btnReturn.onClick, function()
        UIMgr:Close("EquipmentMake")
    end)

    self:AddListener(self._btnTagAttack.onClick, function()
        if self._typeController.selectedPage == "2" then
            self:RefreshMaterialShow()
        end
    end)

    self:AddListener(self._btnTagBalance.onClick, function()
        if self._typeController.selectedPage == "1" then
            self:RefreshMaterialShow()
        end
    end)

    self:AddListener(self._btnTagGrow.onClick, function()
        if self._typeController.selectedPage == "3" then
            self:RefreshMaterialShow()
        end
    end)

    self:AddListener(self._btnWhite.onClick, function()
        if curQuality ~= 0 then
            curQuality = 0
            self:RefreshMaterialQueue()
        end
    end)

    self:AddListener(self._btnGreen.onClick, function()
        if curQuality ~= 1 then
            curQuality = 1
            self:RefreshMaterialQueue()
        end
    end)

    self:AddListener(self._btnSwitch.onClick, function()
        UIMgr:Open("EquipmentGemVault")
    end)

    self:AddListener(self._iconMaking.onDrop, function()
        self:DoMake()
    end)

    self:AddListener(self._iconMaking.onRollOver, function()
        self:PreShowIcon()
    end)

    self:AddListener(self._iconMaking.onRollOut, function()
        self:ResetPerShowIcon()
    end)
end

function EquipmentMake:InitAgent()
    self._agent = UIMgr:CreateObject("EquipmentSystem", "itemEquipAgent")
    self._agent:SetHome(GRoot.inst)
    self._agent.touchable = false
    self._agent.draggable = true
    self._agent:SetSize(180, 180)
    self._agent.sortingOrder = 10000
end

function EquipmentMake:OnOpen(mtype, mtid)
    self._materialController.selectedPage = "white"
    if mtype then
        self._typeController.selectedPage = tostring(mtype)
    else
        self._typeController.selectedPage = "2"
    end

    self.selectedId = mtid

    self:RefreshMaterialShow()
    self:RefreshMaterialQueue()
    
    Event.Broadcast(EventDefines.HideBuidingCompleteBtn, true)
end

function EquipmentMake:OnClose()
    Event.Broadcast(EventDefines.HideBuidingCompleteBtn, false)
    --关闭引导图标指引
    if GuidePanelModel.isBeginGuide then
        Event.Broadcast(EventDefines.CloseGuide)
    end
end

--刷新当前类型材料
function EquipmentMake:RefreshMaterialShow()
    local materials = EquipModel.GetMaterialsByType(tonumber(self._typeController.selectedPage))
    for k,v in pairs(materials) do
        local btn = self["_btnMaterial"..k]
        local id = v.id
        btn:Init(v)
        btn.draggable = true

        if self.selectedId == v.id then
            btn:SetSelected(true)
        else
            btn:SetSelected(false)
        end

        self:AddListener(btn.onDragStart, function(context)
            self.curTouchBtn = btn
            btn:HideIcon(true)

            --取消掉源拖动
            context:PreventDefault();
            if self._agent.parent ~= nil then
                return
            end

			self._agent:GetChild("_icon").url = btn._icon.url;
			GRoot.inst:AddChild(self._agent);
			self._agent.xy = GRoot.inst:GlobalToLocal(Stage.inst:GetTouchPosition(context.data));
			self._agent:StartDrag(context.data);
        end)

        self:AddListener(self._agent.onDragEnd, function()
            GRoot.inst:RemoveChild(self._agent)
            local obj = GRoot.inst.touchTarget
			while obj ~= null do
				if obj:hasEventListeners("onDrop") then
					obj:RequestFocus();
					obj:DispatchEvent("onDrop")
					break;
                end
				obj = obj.parent;
			end
            
            self.curTouchBtn = nil
            btn:HideIcon(false)
            self.detailPop:OnHidePopup()
        end)

        self:AddListener(btn.onTouchBegin, function()
            local qualityConfig = EquipModel.GetQualityMaterialById(btn.config.id + curQuality + 1)
            local time = TimeUtil.SecondToHMS(qualityConfig.time)
            local name = StringUtil.GetI18n(I18nType.Equip, btn.config.name)
            self.detailPop:InitCenterLabel(name, time)
            UIMgr:ShowPopup("Common", "LongPressPopupLabel", btn, false)
            if k <= 2 then
                self.detailPop:SetPos(btn.x, btn.y - btn.height)
            else
                self.detailPop:SetPos(btn.x - self.detailPop.width, btn.y - btn.height)
            end
        end)

        self:AddListener(btn.onTouchEnd, function()
            self.detailPop:OnHidePopup()
        end)
    end
end

--刷新下方材料生产列表格
function EquipmentMake:RefreshMaterialQueue()
    self.curPreSlot = nil
    self._listMaking:RemoveChildrenToPool()

    --第一格固定为正在生产材料显示
    self:RefreshMakeSlot()

    --刷新等待队列格子
    self:RefreshWaiteSlot()
end

function EquipmentMake:RefreshMakeSlot()
    local makingInfo = EquipModel.GetMakingMaterial()
    local item = self._makingSlot--self._listMaking:AddItemFromPool()
    item:Init()
    if makingInfo then
        local qualityConfig = EquipModel.GetQualityMaterialById(makingInfo.JewelId)
        local config = EquipModel.GetMaterialByQualityId(qualityConfig.id)
        item:SetType(7)
        item:SetIcon(config.icon)
        item:SetQuality(qualityConfig.quality - 1)
        item:SetTime(makingInfo.FinishAt)
        item:PlayIconAnim()
        item:SetOnClick(function()
            UIMgr:Open("EquipPayAccelerationPopup", function()
                self:DoMakeRequire()
            end)
        end)
    else
        item:SetType(5)
        item:SetNum("")
        item:SetQuality(curQuality)
        item:SetOnDrop(function()
            self:DoMake()
        end)
        item:SetOnRollOver(function()
            self:PreShowIcon()
        end)
        item:SetOnRollOut(function()
            self:ResetPerShowIcon()
        end)
        self.curPreSlot = item
    end
end

function EquipmentMake:RefreshWaiteSlot()
    local makeInfo = EquipModel.GetMaterialMakeInfo()
    for i=1,maxSlot do
        local item = self._listMaking:AddItemFromPool()
        item:Init()
        if i > makeInfo.MaxIndex then
            --该格子未解锁
            self:LockSlot(i, item)
        else
            self:UnlockSlot(i, makeInfo, item)
        end
    end
end

function EquipmentMake:LockSlot(index, item)
    item:SetType(4)
    item:SetOnClick(function()
        local pay = EquipModel.GetUnlockMaterialMakeSlotPrice(Model.JewelMakeInfo.MaxIndex + 1)
        local curContent = StringUtil.GetI18n(I18nType.Commmon, "equip_tip_2", {num = pay})
        if pay <= 0 then
            curContent = StringUtil.GetI18n(I18nType.Commmon, "equip_tip_8")
        end
        local data = {
            content = curContent,
            sureCallback = function()
                --请求解锁
                Net.Equip.UnlockJewelColumn(function(rsp)
                    Model.JewelMakeInfo.MaxIndex = Model.JewelMakeInfo.MaxIndex + 1
                    self:RefreshMaterialQueue()
                end)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)

    local makeInfo = EquipModel.GetMakingMaterial()
    if makeInfo and index == 1 then
        JumpMap:JumpTo({jump = 822000})
    end
end

function EquipmentMake:UnlockSlot(index, makeInfo, item)
    local waitList = makeInfo.WaitList
    if index <= #waitList then
        --有等待的材料
        local qualityConfig = EquipModel.GetQualityMaterialById(waitList[index])
        local config = EquipModel.GetMaterialByQualityId(qualityConfig.id)
        local curIndex = index
        item:SetType(6)
        item:SetIcon(config.icon)
        item:SetQuality(qualityConfig.quality - 1)
        item:SetBtnDelOnClick(function()
            --取消等待
            Net.Equip.DeleteWaitJewel(curIndex, function(rsp)
                Model.JewelMakeInfo = rsp
                self:RefreshMaterialQueue()
            end)
        end)
    else
        --解锁的空格子
        item:SetType(5)
        item:SetQuality(curQuality)
        item:SetOnDrop(function()
            self:DoMake()
        end)
        item:SetOnRollOver(function()
            self:PreShowIcon()
        end)
        item:SetOnRollOut(function()
            self:ResetPerShowIcon()
        end)
        if not self.curPreSlot then
            self.curPreSlot = item
        end
    end
end

function EquipmentMake:DoMake()
    if self.curTouchBtn then
        Net.Equip.DoMakeJewel(self.curTouchBtn.config.id + curQuality + 1, function(rsp)
            Model.JewelMakeInfo = rsp
            self:DoMakeRequire()
        end)
    end
end

function EquipmentMake:DoMakeRequire()
    self:RefreshMaterialQueue()

    local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipMaterialFactory)
    local node = BuildModel.GetObject(buildId)
    if node then
        --刷新建筑倒计时条
        node:ResetCD()
    end
end

function EquipmentMake:PreShowIcon()
    if self.curTouchBtn and self.curPreSlot then
        self.curPreSlot:SetType(9)
        self.curPreSlot:SetIcon(self.curTouchBtn.config.icon)
    end
end

function EquipmentMake:ResetPerShowIcon()
    if self.curPreSlot then
        self.curPreSlot:SetType(5)
    end
end

return EquipmentMake