--[[
    author:{laofu}
    time:2020-06-11 24:03:06
    function:{新城竞赛task项}
]]
local ItemNewWarZoneTask = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemNewWarZoneTask", ItemNewWarZoneTask)
local GD = _G.GD
local WelfareModel = import("Model/WelfareModel")

function ItemNewWarZoneTask:ctor()
    self._c1 = self:GetController("c1")

    self._title = self:GetChild("_title")
    self._sentTitle = self:GetChild("_sentTitle")
    self._progress = self:GetChild("_progress")

    self._btnGoto = self:GetChild("_use")

    self._list = self:GetChild("liebiao")

    self._btnGoto.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    self:InitEvent()

    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function ItemNewWarZoneTask:InitEvent()
    self._list.itemRenderer = function(index, item)
        local itemData = self.rewardDatas[index + 1]
        local itemInfo = {
            Category = itemData.isRes and REWARD_TYPE.Res or REWARD_TYPE.Item,
            Amount = itemData.amount,
            ConfId = itemData.confId
        }
        local mid = GD.ItemAgent.GetItemInnerContent(itemData.confId)
        local amount = "x" .. itemData.amount
        local icon, color = GD.ItemAgent.GetShowRewardInfo(itemInfo)
        item:SetShowData(icon, itemData.color, amount, nil, mid)
        UITool.TipsLabel(itemData.confId, item, self)
    end

    self:AddListener(
        self._btnGoto.onClick,
        function()
            if self.taskInfo.configType == 0 then
                --打开AccessWay窗口
                UIMgr:Open(
                    "AccessWay",
                    self.taskInfo.jumpId,
                    function()
                        UIMgr:Close("NewWarZoneActivity")
                        UIMgr:Close("ActivityCenter")
                    end,
                    self.accessWayStr,
                    StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
                )
            else
                JumpMap:JumpTo({jump = self.taskInfo.jumpId, para = self.taskInfo.jumpPara})
                UIMgr:Close("NewWarZoneActivity")
                UIMgr:Close("ActivityCenter")
            end
        end
    )
end

local function TaskTitle(taskType, para1, para2)
    local params = {num = Tool.FormatAmount(para2)}
    if para1 ~= 0 then
        params["key_1"] = BuildModel.GetName(para1)
        params["value_1"] = Tool.FormatAmount(para2)
    end
    local str = StringUtil.GetI18n(I18nType.Tasks, taskType.name, params)
    return str
end

function ItemNewWarZoneTask:SetData(taskInfo)
    if taskInfo.finished then
        self._c1.selectedIndex = 1
        self._sentTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_SEND_BY_MAIL")
    else
        self._c1.selectedIndex = 0
    end

    self.taskInfo = taskInfo
    local taskType = GD.NewWarZoneActivityAgent.GetTaskType(taskInfo.taskType)
    self._title.text = TaskTitle(taskType, taskInfo.taskPara1, taskInfo.maxProcess)
    self._progress.text = taskInfo.process .. "/" .. taskInfo.maxProcess

    --AccessWay弹窗描述
    if self.jumpId == 5 then
        self.accessWayStr = StringUtil.GetI18n(I18nType.Commmon, "UI_LEVEL_JUMP_NEWA_WARZONE")
    end

    self.rewardDatas = WelfareModel.GetResOrItemByGiftId(taskInfo.rewardGift)
    self._list.numItems = #self.rewardDatas
end

return ItemNewWarZoneTask
