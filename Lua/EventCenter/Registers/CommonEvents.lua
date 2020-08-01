local CommonEvent = {}

local GD = _G.GD

function CommonEvent.init()
    -- 同一账号登录被挤下线提示通知
    Event.AddListener(
        EventDefines.UILoginAtOtherPlace,
        function()
            CommonType.RECONNECT = false
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Tips_Line_Other"),
                sureCallback = function()
                    FUIUtils.QuitGame()
                end,
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )
    -- 道具变化通知
    Event.AddListener(
        EventDefines.UIItemsAmount,
        function(rsp)
            if rsp.Items then
                local newItems = {}

                for _, v in pairs(rsp.Items) do
                    if v.Amount > 0 then
                        -- 添加物品保存新获得物品状态
                        local oldItem = GD.ItemAgent.GetItemModelById(v.ConfId)
                        if not oldItem or oldItem.Amount < v.Amount then
                            local amount = oldItem and (v.Amount - oldItem.Amount) or v.Amount
                            table.insert(newItems, {ConfId = v.ConfId, Amount = amount})
                        end

                        Model.Create(ModelType.Items, v.ConfId, v)
                    else
                        Model.Delete(ModelType.Items, v.ConfId)
                    end
                end

                GD.ItemAgent.SaveNewItemsStatus(newItems)
                Event.Broadcast(EventDefines.UIRefreshBackpack)
                Event.Broadcast(EventDefines.UIRefreshBackpackRedPoint)
            end
            Event.Broadcast(EventDefines.RefreshVipUpgradeTip)
        end
    )

    -- 单个道具变化通知
    Event.AddListener(
        EventDefines.UIItemAmount,
        function(rsp)
            if rsp.Item.Amount > 0 then
                -- 添加物品保存新获得物品状态
                local oldItem = GD.ItemAgent.GetItemModelById(rsp.Item.ConfId)
                if not oldItem or oldItem.Amount < rsp.Item.Amount then
                    local amount = oldItem and (rsp.Item.Amount - oldItem.Amount) or rsp.Item.Amount
                    GD.ItemAgent.SaveNewItemsStatus({{ConfId = rsp.Item.ConfId, Amount = amount}})
                end

                Model.Create(ModelType.Items, rsp.Item.ConfId, rsp.Item)
            else
                Model.Delete(ModelType.Items, rsp.Item.ConfId)
            end
            Event.Broadcast(EventDefines.UIRefreshBackpack)
            Event.Broadcast(EventDefines.UIRefreshBackpackRedPoint)
            Event.Broadcast(EventDefines.RefreshVipUpgradeTip)
        end
    )

    -- 单个道具变化通知
    Event.AddListener(
        EventDefines.ItemAmount,
        function(rsp)
            if rsp.Amount > 0 then
                -- 添加物品保存新获得物品状态
                local oldItem = GD.ItemAgent.GetItemModelById(rsp.ConfId)
                if not oldItem or oldItem.Amount < rsp.Amount then
                    local amount = oldItem and (rsp.Amount - oldItem.Amount) or rsp.Amount
                    GD.ItemAgent.SaveNewItemsStatus({{ConfId = rsp.ConfId, Amount = amount}})
                end

                Model.Create(ModelType.Items, rsp.ConfId, rsp)
            else
                Model.Delete(ModelType.Items, rsp.ConfId)
            end
            Event.Broadcast(EventDefines.UIRefreshBackpack)
            Event.Broadcast(EventDefines.UIRefreshBackpackRedPoint)
            Event.Broadcast(EventDefines.RefreshVipUpgradeTip)
        end
    )

    -- 保护资源发生变化
    Event.AddListener(
        EventDefines.UIResProtects,
        function(rsp)
            for _, v in pairs(rsp.ResProtects) do
                Model.Create(ModelType.ResProtects, v.Category, v)
            end
        end
    )
end

return CommonEvent
