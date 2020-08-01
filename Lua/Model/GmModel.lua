--author: 	Amu
--time:		2020-06-08 22:49:05

if GmModel then
    return GmModel
end

-- 可能重复import
import("Common/functions")
import("FairyGUI/FairyGUI")
import("UI/Loading/btnGm")

GmModel = {}

GmModel.CanShow = true

local _btnGm

function GmModel.InitGmByDevice(playerName)
    local device = Util.GetDevice()
    local deviceId = Util.GetDeviceId()
    Sdk.AiHelpSetName("Final Order")
    Sdk.AiHelpSetUserName(device)
    Sdk.AiHelpSetUserId(deviceId)
    Sdk.AiHelpSetServerId(playerName)
    local language = Language.Current()
    local configs = ConfigMgr.GetList("configLanguages")
    local fq_language = "en"
    for _,v in ipairs(configs)do
        if language == v.language then
            fq_language = v.language_faq
        end
    end
    Sdk.AiHelpSetSDKLanguage(fq_language)
    Sdk.GetUnreadMessageFetchUid(deviceId)
end

function GmModel.gmCallBcak()
    if not GmModel.CanShow then
        return
    end
    if not _btnGm then
        GmModel.InitGmByDevice("logining")
        
        local desc
        local res
        if ResMgr.IsReadDirect() then
            UIPackage.AddPackage("Assets/BundleResources/UI/Loading")
        else
            desc = ResMgr.Instance:LoadBundleSync("ui/loading_fui")
            res = ResMgr.Instance:LoadBundleSync("ui/loading_atlas")
            UIPackage.AddPackage(desc, res)
        end
        _btnGm = UIPackage.CreateObject("Loading", "btnGm")
        if _btnGm then
            GRoot.inst:AddChild(_btnGm)
            _btnGm.sortingOrder = 10000
            _btnGm.x = GRoot.inst.width - 100
            _btnGm.y = GRoot.inst.height - _btnGm.height - 80
            _btnGm.SoundName = ""
            for i = 1, _btnGm.numChildren do
                _btnGm:GetChildAt(i - 1).visible = false
            end
            _btnGm:GetChild("bg_new").visible = true
        end
    end
end

function GmModel.HideGm()
    _btnGm:Hide()
    _btnGm = nil
end

function GmModel.StartGM()
    print("===========GmModel.StartGM=============")

    GmModel.CanShow = true
    Scheduler.ScheduleOnce(GmModel.gmCallBcak, Global.GMEntranceTime)
end

function GmModel.EndGm()
    print("===========GmModel.EndGm=============")
    if Scheduler then
        Scheduler.UnSchedule(GmModel.gmCallBcak)
    end
    if _btnGm then
        GmModel.HideGm()
    end
    GmModel.CanShow = false
end

return GmModel