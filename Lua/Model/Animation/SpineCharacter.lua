--[[
    Author: songzeming
    Function: 副官动画
]]
local SpineCharacter = {}

import("UI/Effect/EmptyNode")

local Characters = {}
--屏幕基准高
local height = 1334
--缩放偏移值
local scaleOffset = 0.15

local function Get(bust)
    local c = Characters[bust]
    if c then
        return c
    else
        local n = UIMgr:CreateObject("Effect", "EmptyNode")
        c = {node = n, spine = nil}
        Characters[bust] = c
        return c
    end
end

local function Play(bust, character)
    local n = bust:GetChild("c_node")
    if n then
        n:RemoveFromParent()
    end
    local anim = character.spine:GetComponent("SkeletonAnimation")
    anim.state:SetAnimation(0, "idle", true)
    character.node.visible = true
    character.node.name = "c_node"
    bust:AddChild(character.node)
end

function SpineCharacter.Hide()
    for _, v in pairs(Characters) do
        v.node.visible = false
    end
end

function SpineCharacter.Show(_bust, path, size)
    local character = Get(path)
    if character.spine then
        Play(_bust, character)
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if character.spine then
                    Play(_bust, character)
                    return
                end
                local _node = character.node
                _node:ResetData()

                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                _node:GetGGraph():SetNativeObject(GoWrapper(object))
                object.transform.localScale = size * (GRoot.inst.height / height)

                character.spine = object
                Play(_bust, character)
            end
        )
    end
end

--玩家详情
function SpineCharacter.ShowBust(_bust, bust)
    if bust > #ConfigMgr.GetList("configAvatars") then
        bust = 1
    end
    local conf = ConfigMgr.GetItem("configAvatars", bust)

    local character = Get(conf.path)
    if character.spine then
        Play(_bust, character)
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(conf.path))
                if character.spine then
                    Play(_bust, character)
                    return
                end
                local _node = character.node
                _node:ResetData()

                local prefab = ResMgr.Instance:GetPrefab(conf.path)
                local object = GameObject.Instantiate(prefab)
                _node:GetGGraph():SetNativeObject(GoWrapper(object))
                if Tool.Equal(bust, 2) then
                    object.transform.localScale = Vector3(90, 90, 90)
                else
                    object.transform.localScale = Vector3(100, 100, 100)
                end
                local scale = GRoot.inst.height / height
                if scale < (1 + scaleOffset) then --矮屏
                    scale = 1---scale - scaleOffset
                elseif scale >= (1 + scaleOffset) then --高屏
                    scale = scale + scaleOffset
                end
                object.transform.localScale = object.transform.localScale * scale
                character.spine = object
                Play(_bust, character)
            end
        )
    end
end

function SpineCharacter.Clear()
    for _, v in pairs(Characters) do
        if v.node then
            v.node:Dispose()
        end
    end
    Characters = {}
end

return SpineCharacter
