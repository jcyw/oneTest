--[[
    author:{laofu}
    time:2020-4-20 16:03:59
    function:{哥斯拉在线活跃页}
]]
local MainGodzillaAward = UIMgr:NewUI("MainGodzillaAward")
local WelfareModel = import("Model/WelfareModel")
local JumpMap = import("Model/JumpMap")
--是否有无领取状态
local Status = -1
--可领取奖励列表
local HasGet = {}

function MainGodzillaAward:OnInit()
    local view = self.Controller.contentPane

    self._btnAllReceuve = view:GetChild("btnAllReceive")
    self._btnExit = view:GetChild("bgMask")
    self._textName = view:GetChild("_textIntegral")
    self._listView = view:GetChild("liebiao")
    self._listView.scrollItemToViewOnClick = false
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MONSTER_UNLOCK")
    self._banner.icon = UITool.GetIcon(GlobalBanner.GodzillaAward)
    view:GetChild("text").icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "1001"))

    --初始化事件
    self:InitEvent()
end

function MainGodzillaAward:InitEvent()
    self._listView.itemRenderer = function(index, item)
        local itemInfo = self.itemInfos[index + 1]
        item:SetData(itemInfo)
    end

    self:AddListener(self._btnAllReceuve.onClick,
        function()
            local rewards = {}
            if Status == 1 then
                --领取
                for _, hasget in pairs(HasGet) do
                    Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusAward(
                        hasget.id,
                        function(rsp)
                            --关闭主页小红点
                            Event.Broadcast(EventDefines.UIGodzillaOnlineBonusFinish, false)
                            --全部领取完了关闭主页按钮
                            if hasget.id >= 4 then
                                Event.Broadcast(EventDefines.GozillzUnlockEvent, false)
                            end
                        end
                    )
                    --设置奖励播放动画
                    local _, items = WelfareModel:GetGiftInfoById(hasget.giftID, 2)
                    for _, v in pairs(items) do
                        local reward = {
                            Category = Global.RewardTypeItem,
                            ConfId = v[1].id,
                            Amount = v[2]
                        }
                        table.insert(rewards, reward)
                    end
                end
                UITool.ShowReward(rewards)
                UIMgr:Close("MainGodzillaAward")
            else
                --跳转指挥中心升级
                JumpMap:JumpTo({jump = 810100, para = 400000})
                UIMgr:Close("MainGodzillaAward")
            end
        end
    )

    self:AddListener(self._btnExit.onClick,
        function()
            UIMgr:Close("MainGodzillaAward")
        end
    )

    self:AddEvent(
        EventDefines.UIGodzillaOnlineBonusFinish,
        function(category)
            self:RefreshShow()
        end
    )
end

function MainGodzillaAward:OnOpen()
    self.itemList = self:GetItemList()
    self:RefreshShow()
end

--[[
    itemInfo结构：
        id：自己本身的id
        titleName:标题名称
        gift:奖励id，用于索引gift表对应的奖励列表
        status:状态，0是未完成，1是可领取
 ]]
function MainGodzillaAward:RefreshShow()
    self.itemInfos = {}
    HasGet = {}
    Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusInfo(
        function(rsp)
            local arr = rsp.Info
            local btnHasGet = false
            for i = 1, #arr, 1 do
                for _, v in pairs(self.itemList) do
                    if arr[i].Id == v.id then
                        local itemInfo = {}
                        itemInfo.id = v.id
                        itemInfo.gift = v.gift
                        itemInfo.titleName = StringUtil.GetI18n(I18nType.Commmon, "UI_GOTH_REWARD_LEVEL", {num = v.level})
                        itemInfo.status = arr[i].Status
                        table.insert(self.itemInfos, itemInfo)
                        if arr[i].Status == 1 then
                            btnHasGet = true
                            local hasget = {}
                            hasget.id = arr[i].Id
                            hasget.giftID = v.gift
                            table.insert(HasGet, hasget)
                        end
                        goto continue
                    end
                end
                ::continue::
            end
            --排序
            table.sort(
                self.itemInfos,
                function(a, b)
                    local flag
                    flag = a.id < b.id
                    return flag
                end
            )
            if btnHasGet then
                --领取
                self._btnAllReceuve.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_AWARD_ALL")
                Status = 1
            else
                --前往
                self._btnAllReceuve.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
                Status = 0
                HasGet = {}
            end
            btnHasGet = false
            self._listView.numItems = #self.itemList
        end
    )
end

--获得配置表的数据
function MainGodzillaAward:GetItemList()
    return ConfigMgr.GetList("configGothgifts")
end

function MainGodzillaAward:GetItemById(id)
    return ConfigMgr.GetItem("configGothgifts", id)
end

return MainGodzillaAward
