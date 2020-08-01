--[[
    author:{zhanzhang}
    time:2019-11-07 21:30:50
    function:{迁城按钮}
]]
local GD = _G.GD
local ItemPlotSelectionBtn = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemPlotSelectionBtn", ItemPlotSelectionBtn)

local WorldBuildType = import("Enum/WorldBuildType")
local lastPosX = 0
local lastPosY = 0

function ItemPlotSelectionBtn:ctor()
    self._touch = self:GetChild("touch")
    self._btnController = self:GetController("c1")
    self._btnConfirm = self:GetChild("btnConfirm")
    self._btnNotConfirm = self:GetChild("btnNotConfirm")

    self._btnCancel = self:GetChild("btnCancel")
    self._btnGroup = self:GetChild("btnGroup")
    self._plot = self:GetChild("DragArea")
    self._buyIcon = self._btnConfirm:GetChild("icon")
    self._itemNum = self._btnConfirm:GetChild("text")
    self._notItemNum = self._btnNotConfirm:GetChild("text")
    self._notBuyIcon = self._btnNotConfirm:GetChild("icon")

    self._btnConfirm2 = self:GetChild("btnConfirm2")

    self:OnRegister()
end

-- 设置图片、数量、标题
function ItemPlotSelectionBtn:Init(dragRect)
    self.TouchMove = function()
        if self.BuildType == WorldBuildType.UnionGoLeader or not self.visible then
            return
        end
        -- Log.Error("ItemPlotSelectionBtn     self.TouchMove ")
        local posX, posY = WorldMap.Instance():ScreenToLogicPoint(MathUtil.FairyToScreeen(self.touchX, self.touchY))
        if posX < 1 + mapOffset then
            posX = 1 + mapOffset
        elseif posX > 1200 - mapOffset then
            posX = 1200 - mapOffset
        end
        if posY < 1 + mapOffset then
            posY = 1 + mapOffset
        elseif posY > 1200 - mapOffset then
            posY = 1200 - mapOffset
        end
        if math.abs(lastPosX - posX) > 0.5 or math.abs(lastPosY - posY) > 0.5 then
            lastPosX = posX
            lastPosY = posY
            local posX = math.floor(posX + 0.5)
            local posY = math.floor(posY + 0.5)
            self.posX = posX
            self.posY = posY
        end
        Event.Broadcast(EventDefines.BuildingMoveing, self.touchX, self.touchY)
    end

    local rect = dragRect:TransformRect(Rect(0, 100, dragRect.width + 150, dragRect.height + 100), GRoot.inst)
    self.dragRect = dragRect
    self._plot.dragBounds = rect
    self._plot.draggable = true
    self.visible = false
end

function ItemPlotSelectionBtn:Refresh(data)
    self.useMoney = 0
    self.BuildType = data.BuildType
    self.ConfId = data.ConfId
    self._btnController.selectedIndex = 1
    local screenPosX, screenPosY
    if data.posNum then
        self.posX, self.posY = MathUtil.GetCoordinate(data.posNum)
        screenPosX, screenPosY = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(self.posX + 0.5, self.posY + 0.5))
    else
        screenPosX, screenPosY = 375, 667
        local posX, posY = WorldMap.Instance():ScreenToLogicPos(MathUtil.FairyToScreeen(screenPosY, screenPosY))
        self.posX = math.floor(posX)
        self.posY = math.floor(posY)
    end

    if data.BuildType == WorldBuildType.MainCity then
        --迁移主城
        self:RefreshInfoByFlyCity()
    elseif data.BuildType == WorldBuildType.UnionGoLeader then
        --联盟迁城
        self:RefreshInfoByUnionGoLeader()
    else
        --修建联盟建筑
        self._buyIcon.icon = GD.ResAgent.GetDiamondSmallIcon()
        self._notBuyIcon.icon = GD.ResAgent.GetDiamondSmallIcon()
        self._notItemNum.text = Global.AllianceFortressBuildCostGem
        if data.notNeedDiamon then
            self._btnController.selectedIndex = 2
        else
            self.useMoney = tonumber(Global.AllianceFortressBuildCostGem)
            self._itemNum.text = Global.AllianceFortressBuildCostGem
            self._btnController.selectedIndex = 0
        end
    end
    self._plot.x = screenPosX
    self._plot.y = screenPosY - 120

    self._btnGroup.x = screenPosX - self._btnGroup.width / 2
    self._btnGroup.y = screenPosY + 60

    Event.Broadcast(EventDefines.BuildingMoveing, screenPosX, screenPosY + 100)
end

function ItemPlotSelectionBtn:OnRegister()
    self:AddListener(self._plot.onDragMove,
        function(context)
            if self.BuildType == WorldBuildType.UnionGoLeader then
                return
            end
            self.touchX = self._plot.x
            self.touchY = self._plot.y + 120
            local posX, posY = WorldMap.Instance():ScreenToLogicPoint(MathUtil.FairyToScreeen(self.touchX, self.touchY))

            local screenPosX, screenPosY = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(posX, posY))
            self._btnGroup.x = screenPosX - self._btnGroup.width / 2
            self._btnGroup.y = screenPosY

            if not self.isUpdate then
                GameUpdate.Inst():AddFixedUpdate(self.TouchMove)
            end
            self.isUpdate = true
        end
    )
    self:AddListener(self._plot.onTouchMove,
        function(context)
            if self.BuildType == WorldBuildType.UnionGoLeader then
                return
            end
            self.touchX, self.touchY = context.inputEvent.x, context.inputEvent.y + 120
        end
    )
    self:AddListener(self._plot.onTouchBegin,
        function(context)
            if self.BuildType == WorldBuildType.UnionGoLeader then
                return
            end
            self.touchX = self._plot.x
            self.touchY = self._plot.y - 120
            -- GameUpdate.Inst():AddFixedUpdate(self.TouchMove)
        end
    )
    self:AddListener(self._plot.onTouchEnd,
        function(context)
            if self.BuildType == WorldBuildType.UnionGoLeader then
                return
            end
            self.touchX, self.touchY = context.inputEvent.x, context.inputEvent.y + 120
            self.isUpdate = false
            GameUpdate.Inst():DelFixedUpdate(self.TouchMove)
        end
    )

    self:AddListener(self._btnConfirm.onClick,
        function()
            local oldPosNum = MathUtil.GetPosNum(Model.Player.X, Model.Player.Y)
            local item = GD.ItemAgent.GetItemModelById(Global.FlyCityItemID)
            local config = ConfigMgr.GetItem("configItems", Global.FlyCityItemID)
            if self.useMoney > 0 and not UITool.CheckGem(self.useMoney) then
                return
            end

            if self.BuildType == WorldBuildType.MainCity then
                Net.Items.UseFlyCity(
                    self.posX,
                    self.posY,
                    function(val)
                        local newPosNum = MathUtil.GetPosNum(self.posX, self.posY)
                        MapModel.DelPoint(MathUtil.GetPosNum( Model.Player.X,Model.Player.Y))
                        Model.Player.X = self.posX
                        Model.Player.Y = self.posY

                        -- Event.Broadcast(EventDefines.WorldMapBuildAnim, oldPosNum, newPosNum)
                        Event.Broadcast(EventDefines.UIOnWorldMapChange, self.posX, self.posY)
                        Event.Broadcast(EventDefines.UIOnMoveCity)
                    end
                )
            elseif self.BuildType == WorldBuildType.UnionGoLeader then
                Net.Items.UseAllianceFlyCity(
                    function()
                        Model.Player.X = self.posX
                        Model.Player.Y = self.posY
                        -- local newPosNum = MathUtil.GetPosNum(self.posX, self.posY)
                        -- Event.Broadcast(EventDefines.WorldMapBuildAnim, oldPosNum, newPosNum)
                        Event.Broadcast(EventDefines.UIOnWorldMapChange, self.posX, self.posY)
                        Event.Broadcast(EventDefines.UIOnMoveCity)
                    end
                )
            else
                if UITool.CheckGem(Global.AllianceFortressBuildCostGem) then
                    Net.AllianceBuildings.Create(self.ConfId, self.posX, self.posY)
                end
            end
            self.visible = false
            Event.Broadcast(EventDefines.EndBuildingMove)
        end
    )
    self:AddListener(self._btnNotConfirm.onClick,
        function()
            if self.useMoney > 0 then
                UITool.CheckGem(self.useMoney)
            end
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self.visible = false
            Event.Broadcast(EventDefines.EndBuildingMove)
        end
    )
    self:AddListener(self._btnConfirm2.onClick,
        function()
            if self.BuildType == WorldBuildType.UnionGoLeader then
                Net.Items.UseAllianceFlyCity(
                    function(rsp)
                        Model.Player.X = self.posX
                        Model.Player.Y = self.posY
                        Event.Broadcast(EventDefines.UIOnWorldMapChange, self.posX, self.posY)
                        Event.Broadcast(EventDefines.UIOnMoveCity)
                    end
                )
            elseif self.BuildType == WorldBuildType.UnionFortress or self.BuildType == WorldBuildType.UnionStore then
                Net.AllianceBuildings.Create(self.ConfId, self.posX, self.posY)
            end
            self.visible = false
            Event.Broadcast(EventDefines.EndBuildingMove)
        end
    )
    self:AddListener(self._touch.onClick,
        function()
            self.visible = false
            Event.Broadcast(EventDefines.EndBuildingMove)
        end
    )
    --开始建筑移动
    self:AddEvent(
        EventDefines.RefreshBuildBtnInfo,
        function(data)
            self.visible = true
            self:Refresh(data)
        end
    )
    --结束建筑移动
    self:AddEvent(
        EventDefines.EndBuildingMove,
        function()
            self.visible = false
        end
    )
    self:AddEvent(
        EventDefines.UIIsCanBuild,
        function(isCanBuild)
            if self.useMoney > 0 then
                isCanBuild = isCanBuild and Model.Player.Gem >= self.useMoney
            end
            if isCanBuild then
                self._btnController.selectedIndex = (self.useMoney > 0 or self.BuildType == WorldBuildType.UnionGoLeader) and 0 or 2
            else
                self._btnController.selectedIndex = self.useMoney > 0 and 1 or 3
            end
        end
    )
    self:AddEvent(
        EventDefines.UICloseMapDetail,
        function()
            self.visible = false
        end
    )
end
--迁移主城
function ItemPlotSelectionBtn:RefreshInfoByFlyCity()
    local item = GD.ItemAgent.GetItemModelById(Global.FlyCityItemID)
    local config = ConfigMgr.GetItem("configItems", Global.FlyCityItemID)
    if item and item.Amount > 0 then
        self._buyIcon.icon = UITool.GetIcon(config.icon)
        self._notBuyIcon.icon = UITool.GetIcon(config.icon)
        self._itemNum.text = 1
        self._notItemNum.text = 1
        self.useMoney = 1
    else
        self._buyIcon.icon = GD.ResAgent.GetDiamondSmallIcon()
        self._notBuyIcon.icon = GD.ResAgent.GetDiamondSmallIcon()
        self._itemNum.text = config.price_hot
        self._notItemNum.text = config.price_hot
        self.useMoney = config.price_hot
    end
end

function ItemPlotSelectionBtn:RefreshInfoByUnionGoLeader()
    local item = GD.ItemAgent.GetItemModelById(Global.AllianceFlyCityItemID)
    if item and item.Amount > 0 then
        local config = ConfigMgr.GetItem("configItems", Global.AllianceFlyCityItemID)
        self._buyIcon.icon = UITool.GetIcon(config.icon)
        self._notBuyIcon.icon = UITool.GetIcon(config.icon)
        self._itemNum.text = 1
        self._notItemNum.text = 1
    else
        self:RefreshInfoByFlyCity()
    end
end

return ItemPlotSelectionBtn
