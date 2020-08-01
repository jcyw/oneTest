--[[
    Author: songzeming
    Function: 巨兽模型动画
]]
local FBXNode = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/FBXNode", FBXNode)

local GlobalVars = _G.GlobalVars
local Global = _G.Global
local Vector2 = _G.Vector2
local Vector3 = _G.Vector3
local Quaternion = _G.Quaternion
local GTween = _G.GTween
local GameObject = _G.GameObject
local GoWrapper = _G.GoWrapper
local Tool = _G.Tool
local DynamicRes = _G.DynamicRes
local WeatherModel = _G.WeatherModel

local isClear = false
local RATATION_OFFSET = 30 --滑动偏移量
local RATATION_DEFAULT = 40
local RATATION_HOSPITAL_DEFAULT = 32
local MonsterFrom = {
    Manual = 1,
    Hospital = 2,
}

function FBXNode:ctor()
    self._touch.icon = "" --TODO 关闭框框

    self.opaque = false
    self.width = _G.GRoot.inst.width
    self.z = 780
    self.pivotY = 1
    self.pivotAsAnchor = true

    self:AddListener(self.onClick,
        function()
            self:PlayFBXBeastClickAnim()
        end
    )
    self:AddListener(self.onTouchMove,
        function(context)
            if self.isInjured then
                return
            end
            if not self.lastTouchMoveX then
                self.lastTouchMoveX = context.inputEvent.x
                return
            end

            if self._beastSubObj then
                local mvx = context.inputEvent.x - self.lastTouchMoveX
                mvx = mvx > RATATION_OFFSET and RATATION_OFFSET or (mvx < -RATATION_OFFSET and -RATATION_OFFSET or mvx)
                -- self._graph.rotationY = self._graph.rotationY - mvx
                self._beastSubObj.localEulerAngles = Vector3(0, self._beastSubObj.localEulerAngles.y - mvx, 0)
                self.lastTouchMoveX = context.inputEvent.x
            end
        end
    )

    self._beastObj = nil
    self._beastSubObj = nil
end

function FBXNode:Init(injured)
    self.height = 440
    local offsetX = injured and -35 or 0
    local initY = self.from == MonsterFrom.Hospital and 500 or 420
    initY = initY / GlobalVars.ScreenRatio.y * GlobalVars.ScreenRatio.x
    self._graph.xy = Vector2(self.width / 2 + offsetX, initY)
end

--巨兽模型动画
local function GET_PATH(id, index)
    return (id == Global.BeastGodzilla and "godzilla" or "kingkong") .. Tool.FormateNumberZero(index)
end

function FBXNode:Clear()
    isClear = true    
end

-- local count = 0
function FBXNode:LoadFBXBeastAnim(id, injured, level, from, ctx)
    -- count = count + 1
    -- level = count
    isClear = false
    self.monsterId = id
    self.isInjured = injured
    self.level = level
    self.from = from
    local name = GET_PATH(id, level)
    self:Init(injured)
    local function play_func()
        local scale = self.from == MonsterFrom.Hospital and 155 or 130 + 3 * level
        if id == Global.BeastKingkong then
            scale = scale * 0.8
        end
        self._beastObj.transform.localScale = Vector3(scale, scale, scale)
        -- self._graph.rotationY = RATATION_DEFAULT
        local initY = self.from == MonsterFrom.Hospital and RATATION_HOSPITAL_DEFAULT or RATATION_DEFAULT
        self._beastObj.transform.localRotation = Quaternion(0, 1, 0,0)
        self._beastSubObj.localEulerAngles = Vector3(0, initY, 0)
        self:PlayFBXBeastAnim()
    end
    if self._beastObj then
        play_func()
    else
        self.visible = false
        local _loadProgress = ctx:GetChild("_loadProgress")
        _loadProgress:GetChild("title").visible = true
        _loadProgress.visible = true
        _loadProgress.value = 0
        local function cb(prefab)
            if isClear then
                return
            end
            self.visible = true
            _loadProgress.visible = false
            if self._beastObj then
                play_func()
                return
            end
            local object = GameObject.Instantiate(prefab)
            -- local subObject = object.transform:Find("sub_name") --获取子节点
            self._graph:SetNativeObject(GoWrapper(object))
            self._beastObj = object
            self._beastSubObj = object.transform:Find("object")
            if id == Global.BeastKingkong and self._beastSubObj then
                local hair = self._beastSubObj:Find("JG_T".. Tool.FormateNumberZero(level) .. "_Hair")
                hair:GetComponent("SkinnedMeshRenderer").material.renderQueue = 3100
            end
            play_func()
        end
        local function progressCb(v)
            _loadProgress.value = v * 100
        end
        --动态资源加载
        local dynamicPath = id == Global.BeastGodzilla and "godzilla" or "kingkong"
        DynamicRes.GetBundle("monster_fbx/" .. dynamicPath .. "/common", function()
            DynamicRes.GetPrefab("monster_fbx/".. dynamicPath .. "/t" .. level, name, cb, progressCb)
        end)
    end
end

--巨兽点击动画
function FBXNode:PlayFBXBeastClickAnim()
    if self._beastObj and self._beastSubObj then
        if self.isInjured then
            if self.monsterId == Global.BeastGodzilla then
                self._beastSubObj:GetComponent("Animator"):Play("die_show")
            end
        else
            self._beastSubObj:GetComponent("Animator"):Play("stand_show")
        end
        WeatherModel.CheckWeatherRain()
    end
end

--播放巨兽动画
function FBXNode:PlayFBXBeastAnim()
    if self._beastObj and self._beastSubObj then
        if self.isInjured then
            GTween.Kill(self._graph)
            self._graph.visible = false
            self:GtweenOnComplete(self._graph:TweenFade(1, 0.1),function()
                self._graph.visible = true
                self._beastSubObj:GetComponent("Animator"):Play("die_stand")
            end)
        else
            self._beastSubObj:GetComponent("Animator"):Play("stand")
        end
    end
end

return FBXNode
