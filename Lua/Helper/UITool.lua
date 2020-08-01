if UITool then
    return UITool
end

UITool = {}
UITool.Red = Color(219 / 255, 92 / 255, 95 / 255, 1)
UITool.Green = Color(48 / 255, 199 / 255, 86 / 255, 1)

local GD = _G.GD

--设置文本颜色
function UITool.GetTextColor(color, text)
    return StringUtil.Format("[color=" .. color .. "]{1}[/color]", text)
end

-- 格式化文本显示
function UITool.FormatListText(node, col)
    local average = node.width / col
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        item.visible = col >= i
        item.x = (i - 0.5) * average
        item.width = average
    end
end

-- 格式化文本显示  雷达各等级文本特调
function UITool.RadarFormatListText(node, col)
    local average = node.width / col
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        item.visible = col >= i
        if i == 1 then
            item.x = 0.5 * node.width * 0.15
        elseif i == 2 then
            item.x = node.width * 0.15 + 0.5 * node.width * 0.7
        elseif i == 3 then
            item.x = node.width * 0.85 + 0.5 * node.width * 0.15
        end
        item.width = i == 2 and node.width * 0.7 or node.width * 0.15
    end
end

-- 金币文本颜色显示 提示框
function UITool.UBBTipGoldText(gem)
    return UITool.GetTextColor(GlobalColor.White, gem)
end

-- 金币不足提示 通用  --备注：一般情况直接可使用  UITool.CheckGem
function UITool.GoldLack()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Diamond_Not_Enough"),
        sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "Ui_GetDiamonds_Now"),
        sureCallback = function()
            UIMgr:ClosePanelsByFUIType(FUIType.Panel_Top)
            TurnModel.RechargeMain()
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--检测钻石是否足够
function UITool.CheckGem(gem)
    if Model.Player.Gem < gem then
        UITool.GoldLack()
        return false
    end
    return true
end

--获取资源
function UITool.GetIcon(icon, dynamicNode)
    return DynamicModel.GetIcon(icon, dynamicNode)
end

-- rewards = {Category, Amount, ConfId}
function UITool.ShowReward(rewards,cb, double)
    UIMgr:Close("EffectReceiveReward")
    UIMgr:Open("EffectReceiveReward", rewards, cb, double)
end

--根据奖励Id播放领奖动画(推荐任务/普通任务)
function UITool.GiftReward(rewardId)
    local giftConf = ConfigMgr.GetItem("configGifts", rewardId)
    local rewards = {}
    if giftConf.res then
        for _, v in ipairs(giftConf.res) do
            local reward = {
                Category = Global.RewardTypeRes,
                ConfId = v.category,
                Amount = v.amount
            }
            table.insert(rewards, reward)
        end
    end
    if giftConf.items then
        for _, v in ipairs(giftConf.items) do
            local reward = {
                Category = Global.RewardTypeItem,
                ConfId = v.confId,
                Amount = v.amount
            }
            table.insert(rewards, reward)
        end
    end
    UITool.ShowReward(rewards)
end

-- blank 动画item父节点，挂在UI上，自己找好位置 （用 blankNode 这个空组件）
-- items 就是items
-- colSpace 列间距
-- rowSpace 行间距
-- colNum 列数，可不传，默认3
function UITool.SetRewardAnim(blank,items,colSpace,rowSpace,colNum)
    NodePool.Init(NodePool.KeyType.ItemPropBig, "Common", "itemPropBig")
    for k, v in pairs(items) do
        local conf = ConfigMgr.GetItem("configItems", v.confId)
        local item = NodePool.Get(NodePool.KeyType.ItemPropBig)
        GTween.Kill(item)
        blank:AddChild(item)
        item:SetAmount(conf.icon, conf.color, v.amount, GD.ItemAgent.GetItemNameByConfId(v.confId), GD.ItemAgent.GetItemInnerContent(v.confId))
        item.pivot = Vector2(0.5, 0.5)
        item.scale = Vector2(0, 0)

        local col = (k - 1) % (colNum or 3) + 1
        local row = math.floor((k - 1) / (colNum or 3))
        local goalPos = Vector2((col - 2) * (item.width + colSpace) - item.width / 2, row * (item.height + rowSpace) - item.height / 2)
        item.xy = Vector2(goalPos.x, goalPos.y + rowSpace)
        item:TweenScale(Vector2(1, 1), 0.05 * k)
        item:TweenMoveY(goalPos.y, 0.05 * k)
    end
end

function UITool.SetRewardResOrItem(blank,items,colSpace,rowSpace,colNum)
    NodePool.Init(NodePool.KeyType.ItemPropBig, "Common", "itemPropBig")
    for k, v in pairs(items) do
        local item = NodePool.Get(NodePool.KeyType.ItemPropBig)
        GTween.Kill(item)
        blank:AddChild(item)
        item:SetAmount(v.image, v.color, v.amount, v.title, v.midStr)
        item.pivot = Vector2(0.5, 0.5)
        item.scale = Vector2(0, 0)

        local col = (k - 1) % (colNum or 3) + 1
        local row = math.floor((k - 1) / (colNum or 3))
        local goalPos = Vector2((col - 2) * (item.width + colSpace) - item.width / 2, row * (item.height + rowSpace) - item.height / 2)
        item.xy = Vector2(goalPos.x, goalPos.y + rowSpace)
        item:TweenScale(Vector2(1, 1), 0.05 * k)
        item:TweenMoveY(goalPos.y, 0.05 * k)
    end
end

-- completeCallBack 最后一个item移动完后得回调
function UITool.PlayRewardAinm(blank,completeCallBack,colSpace,rowSpace,colNum)
    for i = 1, blank.numChildren do
        local item = blank:GetChildAt(i - 1)
        local col = (i - 1) % (colNum or 3) + 1
        local mvx = col == -1 and -20 or (col == 1 and 20 or 0)
        blank:GetContext():GtweenOnComplete(item:TweenMove(Vector2(item.x + mvx, item.y - 20), 0.1):SetEase(EaseType.QuadOut), function()
            local mvpos = Vector2(0 - item.width / 2, 200)
            item:SetAnimState(false)
            blank:GetContext():GtweenOnComplete(item:TweenMove(mvpos, 0.2):SetEase(EaseType.Linear), function()
                item:SetAnimState(true)
                NodePool.Set(NodePool.KeyType.ItemPropBig, item)
                if completeCallBack and i == blank.numChildren then
                    completeCallBack()
                end
            end)
        end)
    end
end

--道具提示
function UITool.TipsLabel(id, item, uiSelf)
    item:RemoveEventListeners()
    local title = GD.ItemAgent.GetItemNameByConfId(id)
    local decs = GD.ItemAgent.GetItemDescByConfId(id)
    uiSelf:AddListener(item.onTouchBegin,
        function()
            if (uiSelf.detailPop and uiSelf.detailPop.OnShowUI) then
                uiSelf.detailPop:OnShowUI(title, decs,item,false)
            end
        end
    )

    uiSelf:AddListener(item.onTouchEnd,
        function()
            uiSelf.detailPop:OnHidePopup()
        end
    )

    uiSelf:AddListener(item.onRollOut,
        function()
            uiSelf.detailPop:OnHidePopup()
        end
    )
end

return UITool
