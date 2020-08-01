--[[
    Author: songzeming
    Function: Spine动画
]]
local SpineNode = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/SpineNode", SpineNode)

function SpineNode:ctor()
    self._touch.icon = "" --TODO 关闭框框

    self.trainObject = nil
    self.nestObject = nil
    self.isLoading = false
    -- self.ArmyObject = {}
    self.armyObject = nil
    self.enemyPlaneObject = nil
    self.myPlaneObject = nil
    self.characterObject = nil
    self.noviceRoleObject = nil
    self.videoPlayer = nil
    self.noviceHelicopterObject = nil
end

--播放训练出场动画
function SpineNode:PlayTrainShowAnim(path)
    local function play_func()
        self.trainObject.transform.localScale = Vector3(68, 68, 68)
        local anim = self.trainObject:GetComponent("SkeletonAnimation")
        if anim.state and anim.state.Data.SkeletonData:FindAnimation(name) then
            anim.state:SetAnimation(0, "chuchang", false)
        end
        -- anim.state:AddAnimation(0, "daiji", true, 0)
    end
    if self.trainObject then
        play_func()
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if self.trainObject then
                    play_func()
                    return
                end
                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                self._graph:SetNativeObject(GoWrapper(object))
                self.trainObject = object
                play_func()
            end
        )
    end
end
--播放训练点击动画
function SpineNode:PlayTrainClickAnim()
    if self.trainObject then
        local anim = self.trainObject:GetComponent("SkeletonAnimation")
        anim.state:SetAnimation(0, "attack", false)
        anim.state:AddAnimation(0, "daiji", true, 0)
    end
end

--移除Spine动画
function SpineNode:RemoveMovieNode()
    if self.videoPlayer then
        GameObject.Destroy(self.videoPlayer)
        self.videoPlayer = nil
    end
end

function SpineNode:RemoveNoviceCharacterAnim()
    if self.noviceRoleObject then
        GameObject.Destroy(self.noviceRoleObject)
        self.noviceRoleObject = nil
    end
end

function SpineNode:RemoveNoviceHelicopterAnim()
    if self.noviceHelicopterObject then
        GameObject.Destroy(self.noviceHelicopterObject)
        self.noviceHelicopterObject = nil
    end
end

--内城人物动画 大兵巡逻 工程师 科学家
function SpineNode:PlayCharacterAnim(path, name, loop)
    local function play_func()
        local anim = self.characterObject:GetComponent("SkeletonAnimation")
        anim.timeScale = 0.5
        if anim.state and anim.state.Data.SkeletonData:FindAnimation(name) then
            anim.state:SetAnimation(0, name, loop)
        end
    end
    if self.characterObject then
        play_func()
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if self.characterObject then
                    play_func()
                    return
                end
                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                self._graph:SetNativeObject(GoWrapper(object))
                local scale = 100 * Global.CityCharacterScale
                object.transform.localScale = Vector3(scale, scale, scale)
                self.characterObject = object
                play_func()
            end
        )
    end
end

--新手引导角色
function SpineNode:PlayNoviceCharacterAnim(path, name)
    local function play_func()
        local anim = self.noviceRoleObject:GetComponent("SkeletonAnimation")
        if anim.state and anim.state.Data.SkeletonData:FindAnimation(name) then              
            anim.state:SetAnimation(0, name, true)
        end
    end
    if self.noviceRoleObject then
        play_func()
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if self.noviceRoleObject then
                    play_func()
                    return
                end
                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                self._graph:SetNativeObject(GoWrapper(object))
                object.transform.localScale = Vector3(85, 85, 85)
                self.noviceRoleObject = object
                play_func()
            end
        )
    end
end

function SpineNode:PlayNoviceHelicopterAnim(path, name)
    local function play_func()
        local anim = self.noviceHelicopterObject:GetComponent("SkeletonAnimation")
        if anim.state and anim.state.Data.SkeletonData:FindAnimation(name) then
            anim.state:SetAnimation(0, name, true)
        end
    end
    if self.noviceHelicopterObject then
        play_func()
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if self.noviceHelicopterObject then
                    play_func()
                    return
                end
                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                self._graph:SetNativeObject(GoWrapper(object))
                object.transform.localScale = Vector3(85, 85, 85)
                self.noviceHelicopterObject = object
                play_func()
            end
        )
    end
end

function SpineNode:PlayVideoPlayerAnim(path, name)
    local function play_func()
        
    end
    if self.videoPlayer then
        play_func()
    else
        -- CSCoroutine.Start(
            -- function()
                -- coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                if self.videoPlayer then
                    play_func()
                    return
                end
                -- local prefab = ResMgr.Instance:GetPrefab(path)
                local prefab = CS.UnityEngine.Resources.Load("MovieCanvas")
                local object = GameObject.Instantiate(prefab)
                self._graph:SetNativeObject(GoWrapper(object))
                -- object.transform.localScale = Vector3(85, 85, 85)
                self.videoPlayer = object
                -- print("++++++++++++++++++++++++++++++++++++++")
                play_func()
            -- end
        -- )
    end
end

return SpineNode
