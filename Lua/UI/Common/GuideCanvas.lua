--
--版权所有:{company}
-- Author:{maxiaolong}
-- Date: 2020-03-30 19:34:33
--
local GuideCanvas = UIMgr:NewUI("GuideCanvas")
local GlobalVars = GlobalVars
local defineRadius = 250
local path = "prefabs/clipguide"
--适配缩放比率
local scaleOffset = 0.5
local diff = 3.5

--初始化
function GuideCanvas:OnInit()
    self.sortingOrder = 1
    CSCoroutine.Start(
        function()
            coroutine.yield(ResMgr.Instance:LoadPrefab(path))
            local prefab = ResMgr.Instance:GetPrefab(path)
            local object = GameObject.Instantiate(prefab)
            self._graph:SetNativeObject(GoWrapper(object))
            object.transform.localScale = CVector3(5000, 5000, 1)
            object.transform.localPosition = CVector3(0, 0, 0)
            self.trainObject = object
            self.objRender = object:GetComponent("Renderer")
        end
    )
    self:SetHidden()
    self:AddEvent(
        EventDefines.CloseClipGuideRender,
        function()
            self:SetHidden()
        end
    )
end

function GuideCanvas:SetHidden()
    UIMgr:Close("GuideCanvas")
end
function GuideCanvas:SetOpen()
    UIMgr:Open("GuideCanvas")
end
function GuideCanvas:SetProp(pos, raius, diff)
    if pos.x < 0 then
        pos.x = 0
    end
    if pos.y < 0 then
        pos.y = 0
    end
    local posX = pos.x
    local posY = Screen.height - pos.y
    local rdiusX, rdiusY = raius.x, raius.y
    local newWidth = Screen.width / 750
    local newHeight = Screen.height / 1334
    local newRadiusX = rdiusX * newWidth
    local newRadiusY = rdiusY * newHeight
    local prop = MaterialPropertyBlock()
    self.objRender:GetPropertyBlock(prop)
    prop:SetFloat("CenterX", posX)
    prop:SetFloat("CenterY", posY)
    prop:SetFloat("RadiusX", newRadiusX)
    prop:SetFloat("RadiusY", newRadiusY)
    self.objRender:SetPropertyBlock(prop)
end

function GuideCanvas:SetPosOrScale(pos, scale)
    if GlobalVars.IsTriggerStatus then
        if not UIMgr:GetUIOpen("GuideCanvas") then
            self:SetOpen()
        end
        ScrollModel.SetWhetherMoveScale()
        UIMgr:Close("GuideLayer")
        UIMgr:Open("GuideLayer")
        local newRadius = Vector2(scale.x * defineRadius * scaleOffset, scale.y * defineRadius * scaleOffset)
        self:SetProp(pos, newRadius)
    end
end

function GuideCanvas:SetClose()
    --只在创建了遮罩蒙版才能设置
    self:SetHidden()
end

function GuideCanvas:SetShow()
    self:SetOpen()
end

return GuideCanvas
