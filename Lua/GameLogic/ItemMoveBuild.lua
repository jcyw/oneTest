--[[
    author:{zhanzhang}
    time:2020-04-13 15:33:16
    function:{迁城相关显示操作}
]]
local ItemMoveBuild = {}
local WorldMapModel = import("Model/WorldMapModel")

local _BuildPos
local _CheckChunkPos
local _RecyclePos
local lastPosX = 0
local lastPosY = 0
local isOpen = false

function ItemMoveBuild:Init(uiTran)
    self.buildTrans = uiTran
    uiTran.localPosition = CVector3.zero

    self.MoveDragTrans = uiTran:Find("DragObj").transform
    self.MainCityRender = self.MoveDragTrans:Find("MainCity"):GetComponent("Renderer")
    self.UnionFortresss = self.MoveDragTrans:Find("UnionFortresss"):GetComponent("SpriteRenderer")
    self.UnionStore = self.MoveDragTrans:Find("UnionStore"):GetComponent("SpriteRenderer")
    self.CheckChunkTran = uiTran:Find("CheckChunk").transform

    self.ShadowTrans = self.MoveDragTrans:Find("Shadow").transform

    self.PlotList = {}
    for i = 1, 4 do
        self.PlotList[i] = self.CheckChunkTran:Find(i .. "_0")
    end
    _RecyclePos = CVector3(-1000, 1000, -1000)
    Event.AddListener(
        EventDefines.EndBuildingMove,
        function()
            self:OnClose()
        end
    )
    Event.AddListener(
        EventDefines.UICloseMapDetail,
        function()
            if isOpen then
                self:OnClose()
            end
        end
    )
end

function ItemMoveBuild:Open(data)
    local posX, posY = MathUtil.GetCoordinate(data.posNum)
    _BuildPos = CVector3(posX, 0, posY)
    _CheckChunkPos = CVector3(posX, 0, posY)
    self.MoveDragTrans.localPosition = _BuildPos
    self.CheckChunkTran.localPosition = _CheckChunkPos
    if data.BuildType == WorldBuildType.MainCity or data.BuildType == WorldBuildType.UnionGoLeader then
        self.BuildType = WorldBuildType.MainCity
        CSCoroutine.Start(
            function()
                local path = "materials/buildings/building_town_lv" .. Model.Player.Level
                coroutine.yield(ResMgr.Instance:LoadMaterial(path))
                local mat = ResMgr.Instance:GetMaterial(path)
                if not mat or not mat.mainTexture then
                    Log.Debug("ItemMoveBuild : 获取材质球失败  ")
                    return
                end
                local mat = ResMgr.Instance:GetMaterial(path)
                local newMat = Util.GetNewMat(mat)
                newMat.renderQueue = 4400
                self.MainCityRender.material = newMat
                self.MainCityRender.enabled = true
                self.UnionFortresss.enabled = false
                self.UnionStore.enabled = false
            end
        )
    elseif data.BuildType == WorldBuildType.UnionFortress then
        self.BuildType = data.BuildType
        self.MainCityRender.enabled = false
        self.UnionFortresss.enabled = true
        self.UnionStore.enabled = false
    elseif data.BuildType == WorldBuildType.UnionStore then
        self.BuildType = data.BuildType
        self.MainCityRender.enabled = false
        self.UnionFortresss.enabled = false
        self.UnionStore.enabled = true
    end
    self:CheckPoint(posX, posY)

    local shadowScale = 0.6
    if Model.Player.Level > 25 then
        shadowScale = 1.2
    elseif Model.Player.Level > 21 then
        shadowScale = 1
    elseif Model.Player.Level > 6 then
        shadowScale = 0.8
    end
    self.ShadowTrans.localScale = CVector3.one * shadowScale
    isOpen = true
end

--检测地块合法性
function ItemMoveBuild:CheckPoint(posX, posY)
    if not self.PlotList then
        return
    end
    -- if posX < 0 then
    --     posX = 0
    -- end
    -- if posY < 0 then
    --     posY = 0
    -- end
    posX = math.floor(posX)
    posY = math.floor(posY)
    local isCanBuild = true
    local checkList = MapModel.CheckBuildPoint(MathUtil.GetPosNum(posX, posY), self.BuildType)
    if not checkList then
        return
    end

    for i = 1, #checkList do
        self.PlotList[i].transform.localPosition = checkList[i] and WorldMapModel.GetPosByIndex(i) or WorldMapModel.GetPosByIndex(5)
        if not checkList[i] then
            isCanBuild = false
        end
    end
    Event.Broadcast(EventDefines.UIIsCanBuild, isCanBuild)
end

function ItemMoveBuild:MoveTo(touchX, touchY)
    if not isOpen then
        return
    end
    local posX, posY = WorldMap.Instance():ScreenToLogicPoint(MathUtil.FairyToScreeen(touchX, touchY))
    _BuildPos.x = posX
    _BuildPos.z = posY
    self.MoveDragTrans.localPosition = _BuildPos
    if math.abs(posX - lastPosX) < 0.5 and math.abs(posY - lastPosY) < 0.5 then
        return
    end
    lastPosX = posX
    lastPosY = posY
    local checkPosX = math.floor(posX + 0.5)
    local checkPosY = math.floor(posY + 0.5)
    if checkPosX ~= _CheckChunkPos.x or checkPosY ~= _CheckChunkPos.z then
        _CheckChunkPos.x = checkPosX
        _CheckChunkPos.z = checkPosY
        self.CheckChunkTran.transform.localPosition = _CheckChunkPos
        self:CheckPoint(checkPosX, checkPosY)
    end
end

function ItemMoveBuild:OnClose()
    isOpen = false
    self.MoveDragTrans.localPosition = _RecyclePos
    self.CheckChunkTran.localPosition = _RecyclePos
end

return ItemMoveBuild
