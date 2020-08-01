--[[
    Author: songzeming
    Function: 巨兽模型动画
]]
local AnimationMonster = {}
import("UI/Effect/FBXNode")
local MonsterModel = import("Model/MonsterModel")

AnimationMonster.From = {
    Manual = 1,
    Hospital = 2
}

local Godzilla = nil
local GodzillaPos = Vector2.zero
local GodzillaInjured = nil
local GodzillaInjuredPos = Vector2.zero
local KingKong = nil
local KingKongPos = Vector2.zero
local KingKongInjured = nil
local KingKongInjuredPos = Vector2.zero

local function GetNode()
    return UIMgr:CreateObject("Effect", "FBXNode")
end
local function SetVisible()
    if Godzilla then
        Godzilla.x = -10000
    end
    if GodzillaInjured then
        GodzillaInjured.x = -10000
    end
    if KingKong then
        KingKong.x = -10000
    end
    if KingKongInjured then
        KingKongInjured.x = -10000
    end
end
local function GetHave(id, injure, offset)
    if id == Global.BeastGodzilla then
        if injure then
            if GodzillaInjured then
                GodzillaInjured.xy = Vector2(GodzillaInjuredPos.x, GodzillaInjuredPos.y + offset)
                return true
            end
        else
            if Godzilla then
                Godzilla.xy = Vector2(GodzillaPos.x, GodzillaPos.y + offset)
                return true
            end
        end
    elseif id == Global.BeastKingkong then
        if injure then
            if KingKongInjured then
                KingKongInjured.xy = Vector2(KingKongInjuredPos.x, KingKongInjuredPos.y + offset)
                return true
            end
        else
            if KingKong then
                KingKong.xy = Vector2(KingKongPos.x, KingKongPos.y + offset)
                return true
            end
        end
    end
    return
end

--播放巨兽动画
function AnimationMonster.PlayMonsterAnim(ctx, from, id, injure, index)
    local level = MonsterModel.GetMonsterLevel(id)
    id = math.floor(id / 100) * 100
    local offset = from == AnimationMonster.From.Manual and 140 or 160
    if id == Global.BeastGodzilla then
        SetVisible()
        --哥斯拉
        if GetHave(id, injure, offset) then
            return
        end
        local item = GetNode()
        local pos = Vector2(GRoot.inst.width / 2 - item.width / 2, GRoot.inst.height / 2 - item.height / 2)
        item:LoadFBXBeastAnim(id, injure, level, from, ctx)
        if index then
            ctx:AddChildAt(item, index)
        else
            ctx:AddChild(item)
        end
        if injure then
            GodzillaInjured = item
            GodzillaInjuredPos = pos
        else
            Godzilla = item
            GodzillaPos = pos
        end
        item.xy = Vector2(pos.x, pos.y + offset)
    elseif id == Global.BeastKingkong then
        --金刚
        SetVisible()
        if GetHave(id, injure, offset) then
            return
        end
        local item = GetNode()
        local pos = Vector2(GRoot.inst.width / 2 - item.width / 2, GRoot.inst.height / 2 - item.height / 2)
        item:LoadFBXBeastAnim(id, injure, level, from, ctx)
        if index then
            ctx:AddChildAt(item, index)
        else
            ctx:AddChild(item)
        end
        if injure then
            KingKongInjured = item
            KingKongInjuredPos = pos
        else
            KingKong = item
            KingKongPos = pos
        end
        item.xy = Vector2(pos.x, pos.y + offset)
    end
end

--刷新巨兽显示
function AnimationMonster.Refresh()
    if Godzilla then
        Godzilla:PlayFBXBeastAnim()
    end
    if GodzillaInjured then
        GodzillaInjured:PlayFBXBeastAnim()
    end
    if KingKong then
        KingKong:PlayFBXBeastAnim()
    end
    if KingKongInjured  then
        KingKongInjured:PlayFBXBeastAnim()
    end
end

--清空巨兽医院动画
function AnimationMonster.Clear()
    if Godzilla  then
        if ResMgr.Instance.UnLoadCacheBundles then
            UIMgr.AddDelayDisposeBundle("monster_fbx/godzilla/t"..Godzilla.level)
            UIMgr.AddDelayDisposeBundle("monster_fbx/godzilla/common")
        end
        Godzilla:Clear()
        Godzilla:Dispose()
        Godzilla = nil
    end
    if GodzillaInjured then
        if ResMgr.Instance.UnLoadCacheBundles then
            UIMgr.AddDelayDisposeBundle("monster_fbx/godzilla/t"..GodzillaInjured.level)
            UIMgr.AddDelayDisposeBundle("monster_fbx/godzilla/common")
        end
        GodzillaInjured:Clear()
        GodzillaInjured:Dispose()
        GodzillaInjured = nil
    end
    if KingKong then
        if ResMgr.Instance.UnLoadCacheBundles then
            UIMgr.AddDelayDisposeBundle("monster_fbx/kingkong/t"..KingKong.level)
            UIMgr.AddDelayDisposeBundle("monster_fbx/kingkong/common")
        end
        KingKong:Clear()
        KingKong:Dispose()
        KingKong = nil
    end
    if KingKongInjured  then
        if ResMgr.Instance.UnLoadCacheBundles then
            UIMgr.AddDelayDisposeBundle("monster_fbx/kingkong/t"..KingKongInjured.level)
            UIMgr.AddDelayDisposeBundle("monster_fbx/kingkong/common")
        end
        KingKongInjured:Clear()
        KingKongInjured:Dispose()
        KingKongInjured = nil
    end
end

return AnimationMonster
