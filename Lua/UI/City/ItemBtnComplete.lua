--[[
    Author: songzeming
    Function: 建筑上的状态按钮
]]
local ItemBtnComplete = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/btnComplete", ItemBtnComplete)

local GuidePanelModel = import("Model/GuideControllerModel")

local CTR = BuildType.ANIMATION
local NameList = {
    [CTR.Train] = "btnTrain",
    [CTR.Free] = "btnFree",
    [CTR.Harest] = "btnHarvest",
    [CTR.Help] = "btnHelp",
    [CTR.Gift] = "btnGiftPackage",
    [CTR.Special] = "btnSpecial",
    [CTR.ScienceAward] = "btnScienceAward",
    [CTR.Gm] = "btnGm",
    [CTR.Beauty] = "btnBeauty",
    [CTR.Range] = "btnRange",
    [CTR.MilitarySupply] = "btnMilitarySupply",
    [CTR.UnionWarfare] = "btnUnionWarfare",
    [CTR.ActivityCenter] = "btnActivityCenter",
    [CTR.FalconActivity] = "btnFalcon",
    [CTR.Welfare] = "btnWelfare",
    [CTR.EquipMake] = "btnEquipMake",
    [CTR.EquipMaterialMake] = "btnEquipMaterialMake",
    [CTR.DressUp] = "btnDressUp",
}

function ItemBtnComplete:ctor()
    self:AddListener(self.onClick,
        function()
            if self.cb then
                self.cb()
            else
                self.context:BuildClick()
            end
        end
    )
    self.animType = nil
    self.animNode = nil

    self.curVisible = false
    self.visibleLock = false -- 锁住状态不显示气泡
end

function ItemBtnComplete:AddBubble(state)
    local node = UIMgr:CreateObject("Build", NameList[state])
    node.xy = Vector2(self.width / 2, self.height)
    node.scale = Vector2(1.6, 1.6)
    self:AddChild(node)
    return node
end

function ItemBtnComplete:SetController(state)
    if not self.animNode then
        self.animNode = self:AddBubble(state)
    end
    if self.animType ~= state then
        self.animNode:Dispose()
        self.animNode = self:AddBubble(state)
    end
    self.animType = state
    self.curVisible = true
    if self.visibleLock then
        self.visible = false
    else
        self.visible = true
    end

    if self.animType == CTR.Free then
        self.animNode:GetChild("_touchMask").visible = GuidePanelModel:IsGuideState() or GlobalVars.IsTriggerStatus
        self:PlayFreeEffect()
    end
end

function ItemBtnComplete:EqueController(...)
    return self.visible and Tool.Equal(self.animType, ...)
end

function ItemBtnComplete:PlayAnim(animType, flag, cb)
    self.cb = cb
    -- self.curVisible = flag
    Event.Broadcast(EventDefines.UISidebarPoint)
    if not flag then
        if animType == BuildType.ANIMATION.Help then
            --帮助
            if self:EqueController(CTR.Free) then
                return
            end
        elseif animType == BuildType.ANIMATION.Harest then
            --资源收集
            if self:EqueController(CTR.Help) then
                return
            end
            if self:EqueController(CTR.Free) then
                return
            end
        end
        if not animType then
            self.visible = false
            return
        end
        self:SetController(animType)
        self.curVisible = false
        self.visible = false
        return
    end
    --优先级 免费>联盟帮助>训练>资源收集>其他
    if animType == BuildType.ANIMATION.Free then
        self:SetController(CTR.Free)
        if (GlobalVars.IsNoviceGuideStatus == true and Tool.Equal(Model.Player.GuideVersion, 1, 2, 3) and Tool.Equal(Model.Player.GuideStep, 10044, 10037, 10036)) then
            Event.Broadcast(EventDefines.BuildingCenterFreeClick)
        end
    elseif animType == BuildType.ANIMATION.Help then
        if self:EqueController(CTR.Free) then
            return
        end
        self:SetController(CTR.Help)
    elseif animType == BuildType.ANIMATION.Harest then
        if self:EqueController(CTR.Help) then
            return
        end
        if self:EqueController(CTR.Free) then
            return
        end
        self:SetController(CTR.Harest)
    elseif animType == BuildType.ANIMATION.Train then
        self:SetController(CTR.Train)
    elseif animType == BuildType.ANIMATION.Gift then --礼物
        self:SetController(CTR.Gift)
    elseif animType == BuildType.ANIMATION.Special then --特价
        self:SetController(CTR.Special)
    elseif animType == BuildType.ANIMATION.ScienceAward then
        self:SetController(CTR.ScienceAward)
    elseif animType == BuildType.ANIMATION.Gm then
        self:SetController(CTR.Gm)
    elseif animType == BuildType.ANIMATION.Beauty then
        self:SetController(CTR.Beauty)
    elseif animType == BuildType.ANIMATION.Range then
        self:SetController(CTR.Range)
    elseif animType == BuildType.ANIMATION.MilitarySupply then
        self:SetController(CTR.MilitarySupply)
    elseif animType == BuildType.ANIMATION.UnionWarfare then
        self:SetController(CTR.UnionWarfare)
    elseif animType == BuildType.ANIMATION.ActivityCenter then --活动中心
        self:SetController(CTR.ActivityCenter)
    elseif animType == BuildType.ANIMATION.FalconActivity then
        self:SetController(CTR.FalconActivity)
    elseif animType == BuildType.ANIMATION.Welfare then
        self:SetController(CTR.Welfare)
    elseif animType == BuildType.ANIMATION.EquipMake then
        self:SetController(CTR.EquipMake)
    elseif animType == BuildType.ANIMATION.EquipMaterialMake then
        self:SetController(CTR.EquipMaterialMake)
    end
end

function ItemBtnComplete:SetIcon(keyStr, icon)
    self:SetBubbleIcon(icon)
end

function ItemBtnComplete:SetCb(cb)
    self.cb = cb
end

function ItemBtnComplete:PlayAnimBySetIcon(animType, flag, keyStr, resParamTab,  cb)
    self:PlayAnim(animType, flag, cb)
    if self.animNode then
        self:SetBubbleIcon(UITool.GetIcon(resParamTab))
    end
end

function ItemBtnComplete:PlayAnimBySetDynamicIcon(animType, flag, keyStr, resParamTab,  cb)
    self:PlayAnim(animType, flag, cb)
    if self.animNode and resParamTab then
        self:SetDynamicBubbleIcon(resParamTab)
    end
end

function ItemBtnComplete:SetContext(context)
    self.context = context
end

function ItemBtnComplete:GetAnimType()
    return self.animType
end

function ItemBtnComplete:GetBtnNode()
    return self.animNode
end

function ItemBtnComplete:SetBubbleIcon(icon)
    if self.animNode then
        self.animNode.icon = icon
    end
end

function ItemBtnComplete:SetDynamicBubbleIcon(icon)
    if self.animNode then
        self.animNode.icon = UITool.GetIcon(icon, self.animNode:GetChild("icon"))
    end
end

function ItemBtnComplete:GetBubbleVisible()
    return self.visible and self.animNode and self.animNode.visible
end

function ItemBtnComplete:SetHarestImage(category)
    local conf = ConfigMgr.GetItem("configResourcess", category)
    self:SetBubbleIcon(UITool.GetIcon(conf.img))
end

function ItemBtnComplete:SetTrainImage(confId)
    local index = 42
    if confId == Global.BuildingTankFactory then
        index = 42
    elseif confId == Global.BuildingHelicopterFactory then
        index = 44
    elseif confId == Global.BuildingWarFactory then
        index = 43
    elseif confId == Global.BuildingVehicleFactory then
        index = 44
    elseif confId == Global.BuildingSecurityFactory then
        index = 25
    end
    local conf = ConfigMgr.GetItem("configBuildingFuncs", index)
    self:SetBubbleIcon(UITool.GetIcon(conf.img))
end

function ItemBtnComplete:SetVisibleLock(isHide)
    if isHide then
        self.visibleLock = true
        self.visible = false
    else
        self.visibleLock = false
        self.visible = self.curVisible
    end
end

function ItemBtnComplete:GetCutBtn()
    if self.animType == CTR.Free then
        self.animNode:GetChild("_touchMask").visible = true
    end
    if self.animNode and self:EqueController(CTR.Free, CTR.Train, CTR.Gift) then
        return self.animNode
    else
        return nil
    end
end

function ItemBtnComplete:PlayFreeEffect()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    if self.effectFree then
       return
    end
    self.effectFree = true

    if not self.animNode then
        return
    end

    --动态资源加载
    local _graph = self.animNode:GetChild("_graph")
    local _graphTop = self.animNode:GetChild("_graphTop")
    _graph.xy = Vector2(52, 55)
    _graphTop.xy = Vector2(52, 55)
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "effect_free", function(prefab)
            local object = GameObject.Instantiate(prefab)
            object.transform.localScale = Vector3(100, 100, 100)
            _graph:SetNativeObject(GoWrapper(object))
        end)
        DynamicRes.GetPrefab("effect_collect", "effect_free_light", function(prefab)
            local object = GameObject.Instantiate(prefab)
            object.transform.localScale = Vector3(100, 100, 100)
            _graphTop:SetNativeObject(GoWrapper(object))
        end)
    end)
end

return ItemBtnComplete
