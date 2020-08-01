--[[
    Author: songzeming
    Function: 地块解锁区域Item
]]
local GD = _G.GD
local ItemAreaLock = fgui.extension_class(GButton)
fgui.register_extension("ui://City/btnMapAreaLock", ItemAreaLock)

local CTR = {
    Lock = "Lock",
    Unlock = "Unlock"
}

local GlobalVars = GlobalVars

function ItemAreaLock:ctor()
    self._ctr = self:GetController("Ctr")
    self._anim = self:GetTransition("Loop")

    self:AddListener(self.onClick,
        function()
            self:OnBtnLockClick()
        end
    )
end

--初始化城外建筑解锁区域块
function ItemAreaLock:InitOuter(index, isLock)
    self:SetVisible(isLock)
    if not isLock then
        --地块已解锁
        return
    end
    self.index = index
    local conf = ConfigMgr.GetItem("configAreaUnlocks", index)
    for _, v in pairs(conf.position) do
        local piece = CityMapModel.GetMapPiece(v)
        piece:SetPieceActive(false)
    end
    if Model.Player.Level >= conf.unlock_level then
        --待解锁
        self._ctr.selectedPage = CTR.Unlock
        self._anim:Play()
    else
        --解锁条件不满足
        self._ctr.selectedPage = CTR.Lock
    end
end

function ItemAreaLock:SetVisible(flag)
    self.parent.visible = flag
end

--区域已经解锁完毕
function ItemAreaLock:GetVisible()
    return not self.parent.visible
end

--设置已解锁
function ItemAreaLock:SetStateUnlock()
    self._ctr.selectedPage = CTR.Unlock
end
--判断是否已解锁
function ItemAreaLock:CheckStateUnlock()
    return self._ctr.selectedPage == CTR.Unlock
end

--点击解锁按钮
function ItemAreaLock:OnBtnLockClick()
    -- 测试特效
    -- self:UnlockAreaAnim()
    -- if not x then return end
    if CityType.BUILD_MOVE_TIP then
        Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
    end

    if self.isBanTouchable then
        return
    end
    GlobalVars.ClickBuildFunction = true

    local conf = ConfigMgr.GetItem("configAreaUnlocks", self.index)
    if self._ctr.selectedPage == CTR.Lock then
        --解锁条件不满足
        local values = {
            base_name = StringUtil.GetI18n(I18nType.Building, Global.BuildingCenter .. "_NAME"),
            base_level = conf.unlock_level
        }
        TipUtil.TipById(30601, values)
    else
        --可解锁
        --检查资源条件是否满足
        local notEnoughRes = false
        local conditions = {}
        if conf.res_req then
            for _, v in pairs(conf.res_req) do
                local condition = {
                    Icon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", v.category).img),
                    Title = Tool.FormatNumberThousands(v.amount),
                    IsSatisfy = Model.Resources[v.category].Amount >= v.amount,
                    Type = BuildType.CONDITION.ResObtain,
                    Category = v.category,
                    Callback = function()
                        UIMgr:Close("BackpackUseDetails")
                        UIMgr:Open("ResourceDisplay", v.category, v.category, v.amount - Model.Resources[v.category].Amount)
                    end
                }
                if not condition.IsSatisfy then
                    notEnoughRes = true
                end
                table.insert(conditions, condition)
            end
        end
        local unlock_func=function ()
            Net.Buildings.UnlockArea(
                    self.index,
                    function()
                        table.insert(Model.UnlockedAreas, self.index)
                        self:UnlockAreaAnim()
                    end
                )
        end
        local cb_func = function()
            if notEnoughRes then
                TipUtil.TipById(50076)
            else
                unlock_func()
            end
        end
        local cb_Not=function ()
            local lackRes = {}
            local needResList = {}
            local canUseItemToFill = true
            if conf.res_req then
                for _, v in pairs(conf.res_req) do
                    local diffAmount = v.amount - Model.Resources[v.category].Amount
                    if diffAmount > 0 then
                        if not GD.ItemAgent.CanBackPackItemFillResNeed(v.category,diffAmount) then
                            canUseItemToFill = false
                        end
                        table.insert(lackRes, {Category = v.category, Amount = diffAmount})
                        table.insert(needResList, {resType = v.category, needCount = diffAmount})
                    end
                end
            end
            if not canUseItemToFill then
                local data = {
                    textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text7"),
                    lackRes = lackRes,
                    textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "FUND_UNLOCK_BUTTON"),
                    cbBtnSure = function ()
                        unlock_func()
                        UIMgr:Close("BackpackUseDetails")
                    end,
                    cbBtnGetMore = function ()
                        UIMgr:Close("BackpackUseDetails")
                    end
                }
                UIMgr:Open("ConfirmPopupDissatisfaction", data)
            else
                UIMgr:Open("ComfirmPopupUseRes", needResList,function ()
                    unlock_func()
                    UIMgr:Close("BackpackUseDetails")
                end)
            end
        end
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "UI_AREA_UNLOCEED"),
            cbOk = cb_func,
            cbNot = cb_Not,
            from = "MAP_AREA_LOCK",
            items = conditions
        }
        UIMgr:Open("BackpackUseDetails", data)
    end
end

function ItemAreaLock:UnlockAreaAnim()
    --播放特效
    self.isBanTouchable = true
    NodePool.Init(NodePool.KeyType.MapAreaUnlockEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.MapAreaUnlockEffect)
    item.xy = Vector2(self.parent.x + self.x + self.width / 2, self.parent.y + self.y + 120)
    self.parent.parent:AddChild(item)
    item:InitNormal()
    item:PlayEffectSingle(
        "effects/citymap/locktree/prefab/locktrees",
        function()
            self.isBanTouchable = false
            NodePool.Set(NodePool.KeyType.MapAreaUnlockEffect, item)
        end,
        Vector3(1, 1, 1)
    )
    self:SetVisible(false)
    local conf = ConfigMgr.GetItem("configAreaUnlocks", self.index)
    for _, v in pairs(conf.position) do
        local piece = CityMapModel.GetMapPiece(v)
        piece:SetPieceFade(true, 1)
        piece:SetPieceUnlock(true)
    end
end

return ItemAreaLock
