--[[
    author:{zhanzhang}
    time:2019-11-15 20:08:10
    function:{登录界面特效层---因为login和loading是两层页面}
]]
local LoginEffect = UIMgr:NewUI("LoginEffect")
local GoWrapper = CS.FairyGUI.GoWrapper
local GGraph = CS.FairyGUI.GGraph
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object

function LoginEffect:OnInit()
end

function LoginEffect:OnOpen()
    -- CSCoroutine.Start(
    --     function()
    --         local resPath = "prefabs/effect/loading_fire/loadingfire"
    --         coroutine.yield(ResMgr.Instance:LoadPrefab(resPath))
    --         local prefab = ResMgr.Instance:GetPrefab(resPath)

    --         local go = GameObject.Instantiate(prefab)
    --         -- go.transform.localScale = CS.UnityEngine.Vector3(0.001, 0.001)
    --         local wrapper = GoWrapper(go)
    --         self._fireArea.asGraph:SetNativeObject(wrapper)
    --     end
    -- )
end

function LoginEffect:OnClose()

end

return LoginEffect
