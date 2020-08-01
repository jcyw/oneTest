--author: 	Amu
--time:		2020-02-27 20:51:12
-- 联盟引导

if GuidedModel then
    return GuidedModel
end

--ui 类型
local GUIDED_UI_STEP = {}
GUIDED_UI_STEP.UnionMain = 100        --联盟主界面
GUIDED_UI_STEP.UnionAct = 200        --联盟动态
GUIDED_UI_STEP.UnionManage = 300        --联盟管理
GUIDED_UI_STEP.UnionMenber = 400        --联盟成员
GUIDED_UI_STEP.UnionSci = 500        --联盟科技
GUIDED_UI_STEP.UnionSet = 600        --联盟信息设定
GUIDED_UI_STEP.UnionIns = 700        --全体联盟指令
GUIDED_UI_STEP.UnionHorn = 800        --联盟公告喇叭
GUIDED_UI_STEP.UnionDec = 1000        --修改联盟宣言
GUIDED_UI_STEP.UnionRec = 1100        --修改公开招募
GUIDED_UI_STEP.UnionShop = 1200        --联盟商店
GUIDED_UI_STEP.UnionSoc = 1300        --修改联盟社交信息
GUIDED_UI_STEP.UnionTran = 1400        --邀请迁移

--按钮类型
local GUIDED_BTN_TYPE = {}
GUIDED_BTN_TYPE.BtnAct = 102        --联盟动态按钮
GUIDED_BTN_TYPE.BtnManage = 103     --管理按钮
GUIDED_BTN_TYPE.BtnMember = 104     --成员按钮
GUIDED_BTN_TYPE.BtnSci = 105     --联盟科技按钮
GUIDED_BTN_TYPE.BtnShop = 106     --联盟商店按钮
GUIDED_BTN_TYPE.BtnHorn = 201     --联盟公告喇叭按钮
GUIDED_BTN_TYPE.BtnSet = 301     --联盟信息设定按钮
GUIDED_BTN_TYPE.BtnIns = 302     --全体联盟指令按钮
GUIDED_BTN_TYPE.BtnDec = 601     --修改联盟宣言按钮
GUIDED_BTN_TYPE.BtnRec = 602     --修改公开招募按钮
GUIDED_BTN_TYPE.BtnSoc = 603     --修改联盟社交信息按钮
GUIDED_BTN_TYPE.BtnTran = 701     --邀请迁移按钮


GuidedModel = {}

GuidedModel._changeNameFlag = false
GuidedModel._changeNameStep = 0
GuidedModel._changeNamePlayerId = nil



local startGuided = false
local isClick = false
local guidedList = {}
local guidedStep = 1
local guideItem = nil
local targetObj = nil
local _cb = nil
local _t_cb = nil

_t_cb = function()
    if not startGuided then
        return
    end
    if not isClick then
        GuidedModel.EndGuided()
    end
    isClick = false
end

function GuidedModel.InitEvent()
    GRoot.inst.onTouchEnd:Add(_t_cb)
end

--开始引导
function GuidedModel.StartGuided(guidedId)
    startGuided = true
    guidedList = {}
    guidedStep = 1
    targetObj = nil
    isClick = false
    GuidedModel.InitEvent()

    local taskInfo = ConfigMgr.GetItem("configAllianceBossTasks", guidedId)
    guidedList = taskInfo.jump
    guidedList.guidedId = guidedId
    GuidedModel.StartGuiedStep(guidedList[guidedStep])

    Event.AddListener(
        EventDefines.GameReStart,
        function()
            GuidedModel.EndGuided()
        end
    )
end

--下一步引导
function GuidedModel.NextGuidedStep()
    GuidedModel.CheckIsEnd()
    guidedStep = guidedStep + 1
    targetObj = nil
    GuidedModel.StartGuiedStep(guidedList[guidedStep])

end

function GuidedModel.StartGuiedStep(step)
    Log.Info("========StartGuiedStep=======".."ui:  "..step.ui_id.." btn:  "..step.btn_id)
    if step.ui_id == GUIDED_UI_STEP.UnionMain then--联盟主界面
        if not UIMgr:GetUI("UnionMain/UnionMain") then
            UIMgr:Open("UnionMain/UnionMain")
        end
        local panel = UIMgr:GetUI("UnionMain/UnionMain")
        if panel then
            if step.btn_id == GUIDED_BTN_TYPE.BtnAct then--联盟动态按钮
                GuidedModel.SetGuideItem(panel, panel._msgBox, 0.1)
                targetObj = panel._msgBox
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnManage then--管理按钮
                GuidedModel.SetGuideItem(panel, panel._btnManager, 0.1)
                targetObj = panel._btnManager
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnMember then --成员按钮
                GuidedModel.SetGuideItem(panel, panel._btnMember, 0.1)
                targetObj = panel._btnMember
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnSci then--联盟科技按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Button_Technology"], 0.2)
                targetObj = panel.itemList["Button_Technology"]
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnShop then--联盟商店按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Button_Shop"], 0.2)
                targetObj = panel.itemList["Button_Shop"]
            end
        end
    elseif step.ui_id == GUIDED_UI_STEP.UnionAct then--联盟动态
        -- UIMgr:OpenHideLastFalse("UnionScienceDonate")
        -- local panel = UIMgr:GetUI("UnionScienceDonate")

        local panel = UIMgr:GetUI("UnionMain/UnionMain")
        if step.btn_id == GUIDED_BTN_TYPE.BtnHorn then--联盟公告喇叭按钮
            local btn = panel._syncNews:GetNoticeItem()
            GuidedModel.SetGuideItem(panel, btn, 0.1)
            targetObj = btn
        end

    elseif step.ui_id == GUIDED_UI_STEP.UnionHorn then--联盟公告喇叭
        -- UIMgr:OpenHideLastFalse("UnionScienceDonate")
        -- local panel = UIMgr:GetUI("UnionScienceDonate")

    elseif step.ui_id == GUIDED_UI_STEP.UnionManage then--联盟管理
        -- UIMgr:Open("UnionManager")
        if not UIMgr:GetUI("UnionManager") then
            UIMgr:Open("UnionManager")
        end
        local panel = UIMgr:GetUI("UnionManager")
        if panel then
            if step.btn_id == GUIDED_BTN_TYPE.BtnSet then--联盟信息设定按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Button_Set"], 0.2)
                targetObj = panel.itemList["Button_Set"]
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnIns then--全体联盟指令按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Button_Whole_Command"], 0.2)
                targetObj = panel.itemList["Button_Whole_Command"]
            end
        end
    elseif step.ui_id == GUIDED_UI_STEP.UnionMenber then--联盟成员
        -- UIMgr:Open("UnionMember/UnionMember")
        local panel = UIMgr:GetUI("UnionMember/UnionMember")

    elseif step.ui_id == GUIDED_UI_STEP.UnionSci then--联盟科技
        -- UIMgr:OpenHideLastFalse("UnionScienceDonate")
        local panel = UIMgr:GetUI("UnionScienceDonate")

    elseif step.ui_id == GUIDED_UI_STEP.UnionShop then --联盟商店
        -- Net.AllianceShop.Info(Model.Player.AllianceId,function(msg)
        --     UIMgr:Open("UnionShop", msg)
        -- end)
        local panel = UIMgr:GetUI("UnionShop")

    elseif step.ui_id == GUIDED_UI_STEP.UnionSet then--联盟信息设定
        -- UIMgr:Open("UnionSetup/UnionSetup")
        if not UIMgr:GetUI("UnionSetup/UnionSetup") then
            UIMgr:Open("UnionSetup/UnionSetup")
        end
        local panel = UIMgr:GetUI("UnionSetup/UnionSetup")
        if panel then
            if step.btn_id == GUIDED_BTN_TYPE.BtnDec then--修改联盟宣言按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Ui_Modify_Declaration"], 0.2)
                targetObj = panel.itemList["Ui_Modify_Declaration"]
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnRec then--修改公开招募按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Ui_Modify_Recruit"], 0.2)
                targetObj = panel.itemList["Ui_Modify_Recruit"]
            elseif step.btn_id == GUIDED_BTN_TYPE.BtnSoc then --修改联盟社交信息按钮
                GuidedModel.SetGuideItem(panel, panel.itemList["Ui_Modifying_SocialRelations"], 0.2)
                targetObj = panel.itemList["Ui_Modifying_SocialRelations"]
            end
        end
    elseif step.ui_id == GUIDED_UI_STEP.UnionDec then--修改联盟宣言
        -- UIMgr:Open("UnionSetup/UnionSetup")
        local panel = UIMgr:GetUI("UnionSetup/UnionSetup")

    elseif step.ui_id == GUIDED_UI_STEP.UnionRec then--修改公开招募
        -- UIMgr:Open("UnionSetup/UnionSetup")
        local panel = UIMgr:GetUI("UnionSetup/UnionSetup")

    elseif step.ui_id == GUIDED_UI_STEP.UnionSoc then--修改联盟社交信息
        -- UIMgr:Open("UnionSetup/UnionSetup")
        local panel = UIMgr:GetUI("UnionSetup/UnionSetup")

    elseif step.ui_id == GUIDED_UI_STEP.UnionIns then--全体联盟指令
        -- UIMgr:Open("UnionInstructionsPopup", 2)
        if not UIMgr:GetUI("UnionInstructionsPopup") then
            UIMgr:Open("UnionInstructionsPopup", 2)
        end
        local panel = UIMgr:GetUI("UnionInstructionsPopup")
        if panel then
            if step.btn_id == GUIDED_BTN_TYPE.BtnTran then--邀请迁移按钮
                GuidedModel.SetGuideItem(panel, panel._listView:GetChildAt(2), 0.2)
                targetObj = panel._listView:GetChildAt(2)
            end
        end
    elseif step.ui_id == GUIDED_UI_STEP.UnionTran then--邀请迁移
        local panel = UIMgr:GetUI("UnionScienceDonate")

    end
    GuidedModel.CheckClick()
end

-- obj 指引的目标
-- delay 延时(防止目标未加载,加一个延时)
-- x, y  对应有可能出现的偏移
function GuidedModel.SetGuideItem(panel, obj, delay, x, y)
    x = x and x or 0
    y = y and y or 0
    if not guideItem then
        guideItem = UIMgr:CreateObject("Common", "Guide")
    end
    local _fun = function()
        if not startGuided then
            return
        end
        GRoot.inst:AddChild(guideItem)
        guideItem.sortingOrder = 4
        local pos = obj:LocalToRoot(Vector2.zero)
        guideItem:SetPivot(0.5, 0.5)
        local _x = pos.x + (obj.width - guideItem.width)/2 - panel.Controller.x + x
        local _y = pos.y + (obj.height - guideItem.height)/2 - panel.Controller.y + y
        guideItem:SetXY(_x, _y)
    end
    if delay then
        Scheduler.ScheduleOnce(_fun, delay)
    else
        _fun()
    end
end

function GuidedModel.RemoveGuideItem()
    guideItem:RemoveFromParent()
end

_cb = function()
    isClick = true
    targetObj.onTouchEnd:Remove(_cb)
    GuidedModel.RemoveGuideItem()
    GuidedModel.NextGuidedStep()
end

function GuidedModel.CheckClick()
    if targetObj then
        targetObj.onTouchEnd:Add(_cb)
    else
        GuidedModel.CheckIsEnd()
    end
end

function GuidedModel.CheckIsEnd()
    if (guidedStep + 1) >= #guidedList then
        GuidedModel.GuideSuccess( )
        GuidedModel.EndGuided( )
        return
    end
end

function GuidedModel.EndGuided( )
    startGuided = false
    GuidedModel.RemoveGuideItem()
    GRoot.inst.onTouchEnd:Remove(_t_cb)
    if targetObj then
        targetObj.onTouchEnd:Remove(_cb)
    end
end

function GuidedModel.GuideSuccess( )
    if guidedList.guidedId == 109 then  --  改名任务特殊处理
        GuidedModel._changeNameFlag = true
        GuidedModel._changeNameStep = 0
        GuidedModel._changeNamePlayerId = nil
    end
end

--是否正在指引中
function GuidedModel.CheckGuide()
    return startGuided
end

--先留着  
-- function GuidedModel.ClickEvent(traget)
--     if not startGuided or not traget then
--         return
--     end

--     if not targetObj then
--         GuidedModel.NextGuidedStep()
--     end

--     print("=================== targetObj : " .. targetObj.name .." traget : " .. traget.gOwner.parent.name)
--     -- local parent = traget.gOwner.parent
--     -- 这样有点问题   list  中的节点不好检测
--     if targetObj == traget.gOwner.parent then
--         GuidedModel.NextGuidedStep()
--     else
--         GuidedModel.RemoveGuideItem()
--     end
-- end


return GuidedModel