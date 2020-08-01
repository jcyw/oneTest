--[[
    Author: songzeming
    Function: 领奖动画 通用界面
]]
local GD = _G.GD
local EffectReceiveReward = UIMgr:NewUI("EffectReceiveReward")

import("UI/Effect/EffectNode")

local DELAY_TIME = 0.1 --奖励延时时间

local ROW_NUMBER = 4 --一排奖励数量Y
local INTERVALX = 180 --奖励之间的列间隔
local INTERVALY = 120 --奖励之间的行间隔
local START_POS_Y = -105 --奖励起始Y距离奖品中心点坐标
local limitNum = 16 --奖励限制个数，当分批次播放奖励时每批次最大数量
local PlayAniQueue = {} --动画播放队列，用于分批次播放动画时存储动画队列
local AniQueueIndex = 1

local function GetStartMovePos(index, number)
    START_POS_Y = -105
    if number == 1 then
        --只有1个奖励
        return Vector2(0, START_POS_Y)
    elseif number == 2 then
        --只有2个奖励
        return Vector2(index == 1 and -INTERVALX / 2 or INTERVALX / 2, START_POS_Y)
    elseif number == 3 then
        --只有3个奖励
        return Vector2(INTERVALX * (index - 2), START_POS_Y)
    elseif number == 4 then
        --只有4个奖励
        return Vector2(INTERVALX * (index - 2) - INTERVALX / 2, START_POS_Y)
    else
        --奖励大等于一排
        local col = (index - 1) % ROW_NUMBER
        local row = math.modf((index - 1) / ROW_NUMBER)
        return Vector2(INTERVALX * (col - 2) + INTERVALX / 2, INTERVALY * row + START_POS_Y)
    end
end

local function GetRewardLineScale(number)
    if number < 4 then
        return Vector3(1, 1, 1)
    else
        --奖励大等于一排
        local col = number / ROW_NUMBER
        local row = math.ceil(col)
        local scale = 1 + 0.7 * (row - 1)
        return Vector3(1, scale, 1)
    end
end

function EffectReceiveReward:OnInit()
    NodePool.Init(NodePool.KeyType.ReceiveAwardAnim, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.ReceiveAwardLight, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.ReceiveAwardRes, "Effect", "EffectPlayerRes")
    self._label = MainCity.MainTop:GetChild("labelNode")
    self.countOpen = 0
end

function EffectReceiveReward:OnOpen(info, cb, double)
    self._double = double
    self._bg.visible = false
    self.complete = cb
    self.countOpen = self.countOpen + 1
    AudioModel.Play(40006)
    if not info or next(info) == nil then
        UIMgr:Close("EffectReceiveReward")
    end
    self.resInfo = {}
    self.itemInfo = {}
    for _, v in pairs(info) do
        if v.Category == Global.RewardTypeRes then
            --资源
            table.insert(self.resInfo, v)
        elseif v.Category == Global.RewardTypeItem then
            --道具
            table.insert(self.itemInfo, v)
        end
    end

    if next(self.resInfo) == nil then
        self:BatchPlayItemAnim()
    else
        self:OnResAnim()
    end

    if self._double then
        local x2_item = UIMgr:CreateObject("Common", "itemNumberAnim")
        self.Controller.contentPane:AddChild(x2_item)
        x2_item:GetChild("_multiple").text = "x2"
        x2_item.y = self._bg.y - x2_item.height / 2
        x2_item.x = self._bg.x + 50
        local x2_anim = x2_item:GetTransition("Multiple")
        x2_anim:Play(
            function()
                x2_item:Dispose()
                self:PlayEndAnim(self.itemInfo)
            end
        )
    end
end

function EffectReceiveReward:OnClose()
    local num = self._node.numChildren
    for i = 1, num do
        num = num - 1
        local item = self._node:GetChildAt(num)
        item:StopEffect()
        GTween.Kill(item)
        NodePool.Set(NodePool.KeyType.ReceiveAwardAnim, item)
    end
    local numLight = self._light.numChildren
    for i = 1, numLight do
        numLight = numLight - 1
        local item = self._light:GetChildAt(numLight)
        item:StopEffect()
        NodePool.Set(NodePool.KeyType.ReceiveAwardLight, item)
    end
    local numRes = self._res.numChildren
    for i = 1, numRes do
        numRes = numRes - 1
        local item = self._res:GetChildAt(numRes)
        item:GetTransition("anim"):Stop()
        GTween.Kill(item)
        NodePool.Set(NodePool.KeyType.ReceiveAwardRes, item)
    end
end

--资源动画
function EffectReceiveReward:OnResAnim()
    for k, v in pairs(self.resInfo) do
        local conf = ConfigMgr.GetItem("configResourcess", v.ConfId)
        local item = NodePool.Get(NodePool.KeyType.ReceiveAwardRes)
        self._res:AddChild(item)
        item.title = "+" .. Tool.FormatNumberThousands(v.Amount)
        item.icon = UITool.GetIcon(conf.icon_reward, item)
        item.x = -50
        item.y = 100 * math.floor(k / 2) * (k % 2 == 1 and -1 or 1)
        item.visible = true
        item.alpha = 1
        item:GetTransition("anim"):Play(
            function()
                NodePool.Set(NodePool.KeyType.ReceiveAwardRes, item)
                if k == #self.resInfo and next(self.itemInfo) ~= nil then
                    self:BatchPlayItemAnim()
                end
            end
        )
    end
end

--分批次播放道具动画
function EffectReceiveReward:BatchPlayItemAnim()
    local batchItemInfo = {}
    local batch = {}
    local index = 0
    PlayAniQueue = {}
    AniQueueIndex = 1
    for i = 1, #self.itemInfo, 1 do
        table.insert(batch, self.itemInfo[i])
        index = index + 1
        if index >= limitNum or i == #self.itemInfo then
            table.insert(batchItemInfo, batch)
            batch = {}
            index = 0
        end
    end
    for _, batchInfo in pairs(batchItemInfo) do
        table.insert(
            PlayAniQueue,
            function()
                self:OnItemAnim(batchInfo)
            end
        )
    end
    PlayAniQueue[AniQueueIndex]()
end

--道具动画
function EffectReceiveReward:OnItemAnim(itemInfo)
    local countOpen = self.countOpen
    local count = 0
    local number = #itemInfo
    --背景特效
    local itemLight = NodePool.Get(NodePool.KeyType.ReceiveAwardLight)
    local firstNode = GetStartMovePos(1, number)
    local lastNode = GetStartMovePos(#itemInfo, number)
    local centerY = (firstNode.y + lastNode.y) / 2 - 15
    itemLight.xy = Vector2(0, centerY)
    self._light:AddChild(itemLight)
    --背景版
    local pos = self._light:LocalToGlobal(itemLight.xy)
    local posX, posY = MathUtil.ScreenRatio(pos.x, pos.y + 9)
    self._bg.xy = Vector2(posX, posY)
    self._bg.visible = true
    self._bg.scaleY = 0
    --背景特效播放
    local bgScale = GetRewardLineScale(#itemInfo)
    self:GtweenOnComplete(
        self._bg:TweenScaleY(bgScale.y, 0.1):SetEase(EaseType.Linear),
        function()
            itemLight:PlayEffectSingle("effects/reward/guangquan/prefab/guangquan_line", nil, bgScale)
        end
    )
    --道具动画
    for k, v in pairs(itemInfo) do
        local item = NodePool.Get(NodePool.KeyType.ReceiveAwardAnim)
        item.scale = Vector2(2, 2)
        item.visible = false
        if v.Category == Global.RewardTypeRes then
            --资源
            local conf = ConfigMgr.GetItem("configResourcess", v.ConfId)
            local icon = UITool.GetIcon(conf.icon_reward, item:GetIconLoader())
            local amount = v.Amount
            item:InitIcon(icon, amount)
        elseif v.Category == Global.RewardTypeItem then
            --道具
            local conf = ConfigMgr.GetItem("configItems", v.ConfId)
            local icon = UITool.GetIcon(conf.icon, item:GetIconLoader())
            local amount = v.Amount
            local amountMid = GD.ItemAgent.GetItemInnerContent(v.ConfId)
            if not amountMid then
                item:InitIcon(icon, amount)
            else
                item:IconMiddle(icon, amount, amountMid, conf.color)
            end
        end
        --道具图标位置
        local goalPos = GetStartMovePos(k, number)
        item.xy = goalPos
        self._node:AddChild(item)
        --逐个显示
        self:GtweenOnComplete(
            item:TweenFade(1, k * DELAY_TIME),
            function()
                item.visible = true
                --播放光圈特效
                item:PlayEffectSingle(
                    "effects/reward/guangquan/prefab/guangquan",
                    function()
                        count = count + 1
                        if count == number and countOpen == self.countOpen then
                            if not self._double then
                                self:PlayEndAnim(itemInfo)
                            end
                        end
                    end,
                    nil,
                    nil,
                    0
                )
                --播放缩放动画
                self:GtweenOnComplete(item:TweenScale(Vector2(1, 1), 0.1):SetEase(EaseType.Linear))
            end
        )
    end
end
function EffectReceiveReward:PlayEndAnim(itemInfo)
    local count = 0
    for k, v in pairs(itemInfo) do
        local item = self._node:GetChildAt(k - 1)
        self:GtweenOnComplete(
            item:TweenFade(0, k * DELAY_TIME):SetEase(EaseType.CubicIn),
            function()
                item:StopEffect()
                count = count + 1
                if count == #itemInfo then
                    if next(PlayAniQueue, AniQueueIndex) then
                        AniQueueIndex = AniQueueIndex + 1
                        PlayAniQueue[AniQueueIndex]()
                    else
                        self._bg.visible = false
                        UIMgr:Close("EffectReceiveReward")
                        if self.complete then
                            self.complete()
                        end
                    end
                end
            end
        )
    end
end

return EffectReceiveReward
