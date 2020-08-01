if HULoading then
    return HULoading
end

HULoading = {}

import("ConfigFiles/LoadingTip")

local LoadingEffect = import("UI/Loading/LoadingEffect")
local GoWrapper = CS.FairyGUI.GoWrapper

function HULoading:LoadUI(isRestart)
    local desc
    local res
    if ResMgr.IsReadDirect() then
        UIPackage.AddPackage("Assets/BundleResources/UI/Loading")
    else
        desc = ResMgr.Instance:LoadBundleSync("ui/loading_fui")
        res = ResMgr.Instance:LoadBundleSync("ui/loading_atlas")
        UIPackage.AddPackage(desc, res)
        self.isLoad = true
    end
    local a = UIPackage.CreateObject("Loading", "Loading")
    self.loadingUI = a.asCom
    self.loadingUI:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.bg = self.loadingUI:GetChild("_bg")
    self.progressBar = self.loadingUI:GetChild("_bar")
    self.progressTip = self.loadingUI:GetChild("_text")
    self.updateTip = self.loadingUI:GetChild("_tip")
    self._effectNode = self.progressBar:GetChild("_effectNode")
    self._effectNode2 = self.progressBar:GetChild("_effectNode2")
    self.SetLoadingTip("open_loading")
    self:setProgress(0)
    CS.FairyGUI.GRoot.inst:AddChild(self.loadingUI)

    --播放Loading特效
    local loadingEffect = self.loadingUI:GetChild("_loadingEffect")
    LoadingEffect.LoadEffect(loadingEffect)
end

local isShowBG = false
function HULoading:ShowBG()
    self.loadingUI:SetSize(GRoot.inst.width, GRoot.inst.height)
    if isShowBG then
        Log.Info("ShowBG skip")
        return
    end
    isShowBG = true
    self.bg.icon = ABTest.Loading()
    self.progressBar.visible = true
    self.progressTip.visible = true
end

function HULoading:setProgress(value)
    self.progressBar.asProgress.value = value * 100
end

function HULoading.SetLoadingTip(tip)
    if HULoading.progressTip then
        HULoading.progressTip.text = LoadingTip.Get(tip)
    end
end

return HULoading