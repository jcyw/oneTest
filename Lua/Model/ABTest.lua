if ABTest then
    return ABTest
end

ABTest = {
    ABGroupIds = {}
}

local abConst = {
    --LoadingA = 1,
    --LoadingB = 2,
    Beauty_TriggerA = 1,            ---是否开启美女引导
    
    TwelveHour_SendSoldier = 5,     ---12小时送兵逻辑
    NoviceGuide_DiffVersion = 1012, ---新手引导B方案
    Kingkong_ABLogic = 1021,        ---金刚AB方案
    
    ChapterTask_ABLogic = 2001,     ---章节任务AB方案
    MainTask_ABLogic = 2002,        ---主线任务AB方案

    OriginLevelUp_Logic = 4001,     ---原有升级逻辑
    FreeLevelUp_Logic = 4002,       ---秒升逻辑
    
    GuideNoSkip_Logic = 5001,       ---不跳过
    GuideSkip_Logic = 5002,         ---跳过
    
    GodzilaGuide_Normal = 6001,     ---正常解锁
    GodzilaGuide_Delay = 6002,      ---延迟解锁
    
    GuideNoSkipButton_Logic = 7001, --无法跳过
    GuideSkipButton_Logic = 7002,   --可以跳过
}

-- 是否进行LoadingAB测试
function ABTest.Loading()
    --if ABTest.haveId(abConst.LoadingA) then
    --    return UIPackage.GetItemURL("Loading", "bg_loadingB")
    --end
    --if ABTest.haveId(abConst.LoadingB) then
    --    return UIPackage.GetItemURL("Loading", "bg_loading")
    --end
    return UIPackage.GetItemURL("Loading", "bg_loading")
end

function ABTest.BeautySystemTrigger()
    if ABTest.haveId(abConst.Beauty_TriggerA) then
        Log.Warning("进入ABTest流程，恭喜你，看不到美女触发引导~~~~~~~~~")
        return true
    end
    return false
end

function ABTest.TwelveHourSendSoldier()
    if ABTest.haveId(abConst.TwelveHour_SendSoldier) then
        Log.Warning("进入ABTest流程，恭喜你，会收到赠送的兵~~~~~~~~~~~~~")
        return true
    end
    return false
end

function ABTest.NoviceGuideDiffVersion()
    if ABTest.haveId(abConst.NoviceGuide_DiffVersion) then
        Log.Warning("进入新手引导ABTest流程，恭喜你，新手引导会很长~~~~~~~~~~~~~~")
        return true
    end
    return false
end

function ABTest.Kingkong_ABLogic()
    if ABTest.haveId(abConst.Kingkong_ABLogic) then
        Log.Warning("进入金刚ABTest流程，恭喜你，开始各种骚操作~~~~~~~~~~~~~~")
        return true
    end
    return false
end

function ABTest.Task_ABLogic()
    if ABTest.haveId(abConst.ChapterTask_ABLogic) then
        Log.Warning("进入章节任务ABTest流程，走新的章节任务表~~~~~~~~~~~~~~~~~")
        return 2001
    elseif ABTest.haveId(abConst.MainTask_ABLogic) then
        Log.Warning("进入主线任务ABTest流程，没有章节任务了~~~~~~~~~~~~~~~~~~")
        return 2002
    end
    return 9999
end

function ABTest.BuildingLevelUp_Logic()
    if ABTest.haveId(abConst.OriginLevelUp_Logic) then
        Log.Warning("进入建筑升级ABTest流程，走的原有升级逻辑~~~~~~~~~~~~~~~~~~~")
        return 4001
    elseif ABTest.haveId(abConst.FreeLevelUp_Logic) then
        Log.Warning("进入建筑升级ABTest流程，走的免费升级逻辑~~~~~~~~~~~~~~~~~~~")
        return 4002
    end
    return 9999
end

function ABTest.GuideSkipAB_Logic()
    if ABTest.haveId(abConst.GuideSkip_Logic) then
        Log.Warning("进入跳过引导ABTest流程，可以10秒跳过~~~~~~~~~~~~~~~~~~~")
        return 5002
    elseif ABTest.haveId(abConst.GuideNoSkip_Logic) then
        Log.Warning("进入跳过引导ABTest流程，不能10秒跳过~~~~~~~~~~~~~~~~~~~")
        return 5001
    end
    return 9999
end

function ABTest.GodzilaGuideAB_Logic()
    if ABTest.haveId(abConst.GodzilaGuide_Normal) then
        Log.Warning("进入哥斯拉引导AB逻辑，哥斯拉3级正常解锁~~~~~~~~~~~~~~~~~~")
        return 6001
    elseif ABTest.haveId(abConst.GodzilaGuide_Delay) then
        Log.Warning("进入哥斯拉引导AB逻辑，哥斯拉8级才解锁~~~~~~~~~~~~~~~~~~")
        return 6002
    end
    return 9999
end

function ABTest.GuideSkipButtonAB_Logic()
    if ABTest.haveId(abConst.GuideSkipButton_Logic) then
        Log.Warning("进入跳过引导ABTest流程，有跳过按钮~~~~~~~~~~~~~~~~~~~")
        return 7002
    elseif ABTest.haveId(abConst.GuideNoSkipButton_Logic) then
        Log.Warning("进入跳过引导ABTest流程，没有跳过按钮~~~~~~~~~~~~~~~~~~~")
        return 7001
    end
    return 9999
end

-- 保存ABTest信息
function ABTest.SaveIds(ids)
    if ids == nil then
        return
    end
    ABTest.ABGroupIds = {}
    for _, groupId in ipairs(ids) do
        Log.Info("ABTestId: {0}", groupId)
        ABTest.ABGroupIds[groupId] = true
    end
end

-- 是否包含ID
function ABTest.haveId(id)
    return ABTest.ABGroupIds[id]
end

return ABTest