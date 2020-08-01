--[[
    Author:muyu
    Function:章节奖励结算界面
]]
local GD = _G.GD
local TaskPlotConfirm = UIMgr:NewUI("TaskPlotConfirm")
local GlobalVars = GlobalVars

function TaskPlotConfirm:OnInit()
    local view = self.Controller.contentPane
    --文字显示
    self._textRewardDescribe = view:GetChild("textRewardDescribe")
    self._tiptext = view:GetChild("tiptext")

    --view:GetChild("titleName").icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "1002"))

    --按钮
    self._btnGo = view:GetChild("btnGo")
    self._btnGotitle = self._btnGo:GetChild("title")
    self._bgMask = view:GetChild("bgMask")

    --列表
    self._list = view:GetChild("liebiao")
    self._list.itemRenderer = function(index, item)
        -- local itemmsg = GD.ItemAgent.GetItemModelByConfId(self.gifts[index + 1].confId)
        -- local itemConfigInfo = ConfigMgr.GetItem("configItems", math.ceil(self.gifts[index + 1].ConfId))
        -- local midStr = GD.ItemAgent.GetItemInnerContent(self.gifts[index + 1].confId)
        item:SetAmount(self.gifts[index + 1].image, self.gifts[index + 1].color, self.gifts[index + 1].amount, nil, self.gifts[index + 1].midStr)

        self:AddListener(item.onTouchBegin,
            function()
                local prop_name = self.gifts[index + 1].title
                local prop_desc = self.gifts[index + 1].desc
                self._longPressLabel:InitLabel(prop_name, prop_desc)
                self._longPressLabel:SetArrowController(true)
                local distance = 10 + (item.size.x + 28) * index
                self._longPressLabel:SetPos(distance)
                self._longPressLabel:SetArrowDownPosX(item.size.x + (item.size.x + 28) * index - distance)
                self._longPressLabel.visible = true
            end
        )
    end
    self:AddListener(view.onTouchEnd,
        function()
            self._longPressLabel.visible = false
        end
    )

    --点击X或者空白Mask时候 关闭页面
    self:AddListener(self._btnGo.onClick,
        function()
            self:Doclose()
        end
    )
    self:AddListener(self._bgMask.onClick,
        function()
            self:Doclose()
        end
    )
    NodePool.Init(NodePool.KeyType.TaskPlotConfirmEffect, "Effect", "EffectNode")
end

function TaskPlotConfirm:OnOpen(gifts, num)
    self.gifts = gifts
    --设置奖励列表
    self._list.numItems = #gifts
    --文字国际化的显示
    self._textRewardDescribe.text = StringUtil.GetI18n(I18nType.Tasks, "PLOT_TASK_" .. num .. "_FINISH")
    self._tiptext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_FINISH_PLOT_TASK")
    self._btnGotitle.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_AWARD_ALL")
    self._rewordText.icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "4007"))
    --初始化道具动画
    self._list.visible = true
    self._blank.visible = false
    UITool.SetRewardResOrItem(self._blank, self.gifts, 25, 0, 4)

    --提示框的显示
    self._longPressLabel.visible = false
    --特效
    if not self.effect then
        self.effect = NodePool.Get(NodePool.KeyType.TaskPlotConfirmEffect)
        self.effect.xy = Vector2(-252, -562)
        self._effectNode:AddChild(self.effect)
        self.effect:InitNormal()
        self.effect:PlayEffectLoop("effects/task/taskplotfinish/prefab/effect_zj_upgrade")
        -- self.setTitle_func = function()
        --     self.effectEN = self._effectNode.displayObject.gameObject.transform:Find("EffectNode/GoWrapper/effect_zj_upgrade(Clone)/Xunhaun_anim/en")
        --     if self.effectEN ~= nil then
        --         self.effectCN = self._effectNode.displayObject.gameObject.transform:Find("EffectNode/GoWrapper/effect_zj_upgrade(Clone)/Xunhaun_anim/cn")
        --         self.effectTW = self._effectNode.displayObject.gameObject.transform:Find("EffectNode/GoWrapper/effect_zj_upgrade(Clone)/Xunhaun_anim/tw")
        --         if Language.Current() == Language.ChineseSimplified then
        --             self.effectEN.gameObject:SetActive(false)
        --             self.effectCN.gameObject:SetActive(true)
        --             self.effectTW.gameObject:SetActive(false)
        --         elseif Language.Current() == Language.ChineseTraditional then
        --             self.effectEN.gameObject:SetActive(false)
        --             self.effectCN.gameObject:SetActive(false)
        --             self.effectTW.gameObject:SetActive(true)
        --         else
        --             self.effectEN.gameObject:SetActive(true)
        --             self.effectCN.gameObject:SetActive(false)
        --             self.effectTW.gameObject:SetActive(false)
        --         end
        --     else
        --         self:ScheduleOnceFast(self.setTitle_func,0.1)
        --     end
        -- end
        -- self:ScheduleOnceFast(self.setTitle_func,0.1)
    end
end

--关闭界面
function TaskPlotConfirm:Doclose()
    --播放领奖动画
    self._list.visible = false
    self._blank.visible = true
    UITool.PlayRewardAinm(
        self._blank,
        function()
            if GlobalVars.IsTriggerStatus then
                return
            end
            Event.Broadcast(EventDefines.TaskPlotDialog, false, true)
            UIMgr:Close("TaskPlotConfirm")
        end,
        25,
        0,
        4
    )
    if self.effect then
        NodePool.Set(NodePool.KeyType.TaskPlotConfirmEffect, self.effect)
        self.effect = nil
    end
end

return TaskPlotConfirm
