--[[
    Author: songzeming
    Function: 特效节点 承接特效用
]]
local EffectNode = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/EffectNode", EffectNode)

import("UI/Effect/ItemPropEffect")

function EffectNode:ctor()
    self.effectObject = {}
    self._graph.visible = false
    self._prop.visible = false
end

function EffectNode:EffectDispose()
    if self.effectObject.object then
        GameObject.Destroy(self.effectObject.object)
        self.effectObject = {}
    end
    self._graph.visible = false
    self._prop.visible = false
end

--播放特效 单次
function EffectNode:PlayEffectSingle(path, cb, scale, rate, isBeShowEffectControl, isImmediatelyPlay)
    if not GlobalVars.IsShowEffect() and isBeShowEffectControl and isBeShowEffectControl == 1 then
        if cb then
            cb()
        end
        return
    end
    self.cb = cb
    self.visible = true
    self._prop.visible = true
    self._graph.visible = true
    AudioModel.Play(40018)
    if path == self.effectObject.path then
        self.visible = true
        self._prop.visible = true
        self._graph.visible = true
        if scale then
            local oldScale = self.effectObject.scale
            self.effectObject.object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
        end
        local particle = self.effectObject.object:GetComponent("ParticleSystem")
        if rate then
            particle.emission.rate = ParticleSystem.MinMaxCurve(rate)
        end
        if particle.main.isPlaying == false then
            particle:Play()
        end
        if isImmediatelyPlay then
            particle:Play()
        end
        self.single_effect_func = function()
            if self.cb then
                self.cb()
            end
        end
        self:ScheduleOnce(self.single_effect_func, particle.main.duration)
        return
    end
    CSCoroutine.Start(
        function()
            coroutine.yield(ResMgr.Instance:LoadPrefab(path))
            if next(self.effectObject) ~= nil and self.effectObject.path == path then
                return
            end
            local prefab = ResMgr.Instance:GetPrefab(path)
            if prefab == nil then
                -- Log.Error("EffectNode not found path: {0}", path)
                return
            end
            local object = GameObject.Instantiate(prefab)
            local effectObject = object.transform:Find("Particle System")
            if effectObject then
                object = effectObject.gameObject
            else
                effectObject = object.transform:Find("Effect")
                if effectObject then
                    object = effectObject.gameObject
                end
            end

            self._graph.asGraph:SetNativeObject(GoWrapper(object))
            local oldScale = object.transform.localScale
            if scale then
                object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
            end
            --获取粒子特效参数
            local particle = object:GetComponent("ParticleSystem")
            if rate then
                particle.emission.rate = ParticleSystem.MinMaxCurve(rate)
            end
            if not particle then
                -- Log.Error("EffectNode particle not found: {0}", path)
                return
            end
            if 0 < particle.main.duration then
                self.effectObject = {path = path, object = object, loop = false, scale = oldScale}
                self.single_effect_func = function()
                    if self.cb then
                        self.cb()
                    end
                end
                self:ScheduleOnce(self.single_effect_func, particle.main.duration)
            else
                self.effectObject = {path = path, object = object, loop = false}
            end
        end
    )
end

--播放动态资源特效 单次
function EffectNode:PlayDynamicEffectSingle(bundleName, resName, cb, scale, rate, isBeShowEffectControl)
    if not GlobalVars.IsShowEffect() and isBeShowEffectControl and isBeShowEffectControl == 1 then
        self._prop.visible = true
        if cb then
            cb()
        end
        return
    end
    self.cb = cb
    self.visible = true
    self._prop.visible = true
    self._graph.visible = true
    local path = ("%s/%s"):format(bundleName, resName)
    AudioModel.Play(40018)
    if path == self.effectObject.path then
        self.visible = true
        self._prop.visible = true
        self._graph.visible = true
        if scale then
            local oldScale = self.effectObject.scale
            self.effectObject.object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
        end
        local particle = self.effectObject.object:GetComponent("ParticleSystem")
        if rate then
            particle.emission.rate = ParticleSystem.MinMaxCurve(rate)
        end
        if particle.main.isPlaying == false then
            particle:Play()
        end
        self.single_effect_func = function()
            if self.cb then
                self.cb()
            end
        end
        self:ScheduleOnce(self.single_effect_func, particle.main.duration)
        return
    end
    DynamicRes.GetBundle(
        bundleName,
        function()
            DynamicRes.GetPrefab(
                bundleName,
                resName,
                function(prefab)
                    if next(self.effectObject) ~= nil and self.effectObject.path == path then
                        if self.cb then
                            self.cb()
                        end
                        return
                    end

                    if prefab == nil then
                        -- Log.Error("EffectNode not found path: {0}", path)
                        if self.cb then
                            self.cb()
                        end
                        return
                    end
                    local object = GameObject.Instantiate(prefab)
                    local effectObject = object.transform:Find("ParticleSystem")
                    if effectObject then
                        object = effectObject.gameObject
                    end
                    if not object then
                        -- Log.Error("EffectNode object not found: {0}", path)
                        if self.cb then
                            self.cb()
                        end
                        return
                    end

                    self._graph.asGraph:SetNativeObject(GoWrapper(object))
                    local oldScale = object.transform.localScale
                    if scale then
                        object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
                    end
                    --获取粒子特效参数
                    local particle = object:GetComponent("ParticleSystem")
                    if rate then
                        particle.emission.rate = ParticleSystem.MinMaxCurve(rate)
                    end
                    if not particle then
                        -- Log.Error("EffectNode particle not found: {0}", path)
                        if self.cb then
                            self.cb()
                        end
                        return
                    end
                    if 0 < particle.main.duration then
                        self.effectObject = {path = path, object = object, loop = false, scale = oldScale}
                        self.single_effect_func = function()
                            if self.cb then
                                self.cb()
                            end
                        end
                        self:ScheduleOnce(self.single_effect_func, particle.main.duration)
                    else
                        self.effectObject = {path = path, object = object, loop = false}
                    end
                end
            )
        end
    )
end

--停止播放特效
function EffectNode:StopEffect()
    self.cb = nil
    if next(self.effectObject) ~= nil and not self.effectObject.loop then
        local particle = self.effectObject.object:GetComponent("ParticleSystem")
        if particle.main.isPlaying then
            particle.main:Stop()
        end
    end
    if self.single_effect_func then
        self:UnSchedule(self.single_effect_func)
    end
    self.visible = false
    self._prop.visible = false
    self._graph.visible = false
end

--播放特效 循环
function EffectNode:PlayEffectLoop(path, scale, isBeShowEffectControl)
    if not GlobalVars.IsShowEffect() and isBeShowEffectControl and isBeShowEffectControl == 1 then
        return
    end
    self.visible = true
    self._prop.visible = true
    self._graph.visible = true
    if path == self.effectObject.path then
        self.visible = true
        self._prop.visible = true
        self._graph.visible = true
        if scale then
            local oldScale = self.effectObject.scale
            self.effectObject.object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
        end
        return
    end
    if next(self.effectObject) ~= nil then
        local obj = self.effectObject.object
        if obj then
            destroy(obj)
        end
    end
    CSCoroutine.Start(
        function()
            coroutine.yield(ResMgr.Instance:LoadPrefab(path))
            if next(self.effectObject) ~= nil and self.effectObject.path == path then
                return
            end
            local prefab = ResMgr.Instance:GetPrefab(path)
            if prefab == nil then
                Log.Error("EffectNode not found path: {0}", path)
                return
            end
            local object = GameObject.Instantiate(prefab)
            local goWarp = GoWrapper(object)
            goWarp.supportStencil = true
            self._graph.asGraph:SetNativeObject(goWarp)
            local oldScale = object.transform.localScale
            if scale then
                object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
            end
            --获取粒子特效参数
            self.effectObject = {path = path, object = object, loop = true, scale = oldScale}
        end
    )
end

--播放动态特效 循环
function EffectNode:PlayDynamicEffectLoop(bundleName, resName, scale, isBeShowEffectControl)
    if not GlobalVars.IsShowEffect() and isBeShowEffectControl and isBeShowEffectControl == 1 then
        return
    end
    self._prop.visible = true
    self._graph.visible = true
    self.visible = true
    local path = ("%s/%s"):format(bundleName, resName)
    if path == self.effectObject.path then
        self.visible = true
        self._prop.visible = true
        self._graph.visible = true
        if scale then
            local oldScale = self.effectObject.scale
            self.effectObject.object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
        end
        return
    end
    if next(self.effectObject) ~= nil then
        local obj = self.effectObject.object
        if obj then
            destroy(obj)
        end
    end
    DynamicRes.GetBundle(
        bundleName,
        function()
            DynamicRes.GetPrefab(
                bundleName,
                resName,
                function(prefab)
                    if next(self.effectObject) ~= nil and self.effectObject.path == path then
                        return
                    end

                    if prefab == nil then
                        Log.Error("EffectNode not found path: {0}", path)
                        return
                    end
                    local object = GameObject.Instantiate(prefab)
                    self._graph.asGraph:SetNativeObject(GoWrapper(object))
                    local oldScale = object.transform.localScale
                    if scale then
                        object.transform.localScale = Vector3(oldScale.x * scale.x, oldScale.y * scale.y, oldScale.z * scale.z)
                    end
                    --获取粒子特效参数
                    self.effectObject = {path = path, object = object, loop = true, scale = oldScale}
                end
            )
        end
    )
end

function EffectNode:getEagleSweepFadeOut()
    local obj = self.effectObject.object.transform:Find("Animation")
    if obj then
        local Guang = obj.transform:Find("Guang_1")
        if Guang then
            local particle = Guang.transform:GetComponent("ParticleSystem")
            local main = particle.main
        --local color = CS.UnityEngine.Color(1, 1, 1, 0);
        --main.startColor = ParticleSystem.MinMaxGradient(color);
        --self.tween = GTween.To(1, 0, 5):OnUpdate(
        --        function()
        --            local color = CS.UnityEngine.Color(1, 1, 1, self.tween.value.x);
        --            main.startColor = ParticleSystem.MinMaxGradient(color);
        --        end
        --):OnComplete(
        --        function()
        --            local color = CS.UnityEngine.Color(1, 1, 1, 1);
        --            main.startColor = ParticleSystem.MinMaxGradient(color);
        --            self.visible = false
        --        end
        --)
        end
    end
end

function EffectNode:InitNormal()
    self._prop:InitNormal()
end

function EffectNode:InitIcon(...)
    self._prop:InitIcon(...)
end

function EffectNode:IconMiddle(...)
    self._prop:IconMiddle(...)
end

function EffectNode:GetIconLoader()
    return self._prop:GetIconLoader()
end

--播放在线奖励动画
function EffectNode:PlayOnlineRewardAnim(cb)
    local scale = 1.5
    local scale2 = 1.2
    local delay = 1.5
    local delay2 = 0.1
    local time = 0.2
    local time2 = 0.2
    local originPos = self._prop.xy
    self._prop.scale = Vector2(0.1, 0.1)
    --延时
    self._prop:TweenScale({x = 0.1, y = 0.1}, delay2):OnComplete(
        function()
            self._prop:TweenScale({x = scale, y = scale}, time):OnComplete(
                function()
                    self._prop:TweenScale({x = 1, y = 1}, time):OnComplete(
                        function()
                            --延时
                            self._prop:TweenScale({x = 1, y = 1}, delay):OnComplete(
                                function()
                                    self._prop:TweenScale({x = scale2, y = scale2}, time)
                                    self._prop:TweenMoveY(-100, time2):OnComplete(
                                        function()
                                            self._prop:TweenScale({x = 0, y = 0}, time2)
                                            self._prop:TweenMoveY(500, time):OnComplete(
                                                function()
                                                    NodePool.Set(NodePool.KeyType.OnlineRewardEffect, self)
                                                    self._prop.xy = originPos
                                                    if cb then
                                                        cb()
                                                    end
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

function EffectNode:GetContext()
    return self
end

return EffectNode
