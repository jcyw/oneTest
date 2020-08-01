--[[
    Author: songzeming
    Function: 排行榜主界面
]]

local RankMain = UIMgr:NewUI("RankMain")

local UnionModel = import("Model/UnionModel")

function RankMain:OnInit()
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
                info = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Rank_TipsTab')
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("RankMain")
            if self.isReturnLastLayer then
                TurnModel.PlayerDetails()
            end
        end
    )

    self._list:RemoveChildrenToPool()
    for _, v in pairs(ConfigMgr.GetList("configRankLists")) do
        local item = self._list:AddItemFromPool()
        item:Init(v)
    end
    
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.PlayerRankMain)
    self._effectNode = self
end

function RankMain:OnOpen(rsp, isReturn)
    SdkModel.TrackBreakPoint(10074)      --打点
    self.isReturnLastLayer = isReturn --是否反回上一界面
    if #rsp.RankInfo > 0 then
        local info = rsp.RankInfo[1]
        self._iconRank.visible = true
        self._icon.visible = true
        --self._icon.url = UnionModel.GetUnionBadgeIcon(info.AllianceAvatar)
        self._medal:SetMedal(info.AllianceAvatar, Vector3(100, 100, 100))
        -- self._textRank.text = "1"
        self._textIcon.text = "("..info.AllianceShortName..")"..info.AllianceName
    else
        self._iconRank.visible = false
        self._icon.visible = false
        -- self._textRank.text = ""
        self._textIcon.text = ""
    end

    self:PlayAnim()
    self:PlayEffect()
end

function RankMain:PlayAnim()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        GTween.Kill(item)
        item.x = -item.width
        self:GtweenOnComplete(item:TweenMoveX(item.x, 0.1 * i),function()
            item:TweenMoveX(0, 0.2)
        end)
    end
end

function RankMain:PlayEffect()
    if self.effect then
        NodePool.Set(NodePool.KeyType.RankMainEffect, self.effect)
    end
    NodePool.Init(NodePool.KeyType.RankMainEffect, "Effect", "EffectNode")
    self.effect = NodePool.Get(NodePool.KeyType.RankMainEffect)
    self.Controller.contentPane:AddChild(self.effect)
    -- local posx, posy = MathUtil.ScreenRatio(Screen.width, Screen.height)
    -- self.effect.xy = Vector2(posx / 2, posy / 2)
    self.effect.xy = Vector2(250, 850)
    self.effect:PlayEffectLoop("effects/signineffect/prefab/effect_qirijiangli_huoxing", Vector3(100, 100, 1))
end

return RankMain
