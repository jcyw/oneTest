--author: 	Amu
--time:		2019-07-02 14:00:22
local GD = _G.GD
local ItemUnionTaskActivePresident = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTaskActivePresident", ItemUnionTaskActivePresident)

local UnionModel = import("Model/UnionModel")

ItemUnionTaskActivePresident.tempList = {}

function ItemUnionTaskActivePresident:ctor()
    self._bgTag = self:GetChild("bgTag")

    self._listView = self:GetChild("liebiao")

    self._title = self:GetChild("textName")
    self._dec = self:GetChild("text")

    self._btnGo = self:GetChild("btnGo")
    self._btnReceive = self:GetChild("btnReceive")
    self._btnGo.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_JUMP") --前往

    self._ctrView = self:GetController("c1")

    self:InitEvent()
end


function ItemUnionTaskActivePresident:SetData(info)
    self._info = info

    self._title.text = StringUtil.GetI18n(I18nType.Commmon, info.name)
    self._dec.text = StringUtil.GetI18n(I18nType.Commmon, info.describe)

    self.itemInfos = {}
    local conf = ConfigMgr.GetItem("configGifts", info.gift_id)
    for _,item in ipairs(conf.items)do
        table.insert(self.itemInfos, item)
    end

    if self._info.Status == UNION_BOSS_TASK.APTStatusIdle then
        self._ctrView.selectedIndex = 0
    elseif self._info.Status == UNION_BOSS_TASK.APTStatusFinished then
        self._ctrView.selectedIndex = 1
        self._btnReceive.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")    --领取
        self._btnReceive.enabled = true
    elseif self._info.Status == UNION_BOSS_TASK.APTStatusClaimed then
        self._ctrView.selectedIndex = 1
        self._btnReceive.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39") --已领取
        self._btnReceive.enabled = false
    end

    self:RefreshListView()
end

function ItemUnionTaskActivePresident:InitEvent()
    self:AddListener(self._btnGo.onClick,function()
        if self._info.Status == UNION_BOSS_TASK.APTStatusIdle then
            local panel = UIMgr:GetUI("UnionTaskActive")
            panel:Close()
            GuidedModel.StartGuided(self._info.id)
        elseif self._info.Status == UNION_BOSS_TASK.APTStatusFinished then
            Net.AllianceDaily.AlliancePresientTaskClaim(self._info.id, function(msg)
                --播放领奖动画
                UITool.ShowReward(msg.Rewards)
                TipUtil.TipById(50273)
                for _,v in ipairs(UnionModel.bossTasks)do
                    if v.ConfId == self._info.id then
                        v.Status = UNION_BOSS_TASK.APTStatusClaimed
                        break
                    end
                end
                UnionModel:RefreshUnionBossTaskNotRead()
            end)
        end
    end)

    self:AddListener(self._btnReceive.onClick,function()
        if self._info.Status == UNION_BOSS_TASK.APTStatusFinished then
            Net.AllianceDaily.AlliancePresientTaskClaim(self._info.id, function(msg)
                --播放领奖动画
                UITool.ShowReward(msg.Rewards)
                TipUtil.TipById(50273)
                for _,v in ipairs(UnionModel.bossTasks)do
                    if v.ConfId == self._info.id then
                        v.Status = UNION_BOSS_TASK.APTStatusClaimed
                        break
                    end
                end
                UnionModel:RefreshUnionBossTaskNotRead()
            end)
        end
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local config = ConfigMgr.GetItem("configItems", math.ceil(self.itemInfos[index + 1].confId))
        --item:GetChild("_icon").icon = UITool.GetIcon(config.icon)
        --item:GetChild("_amount").text = self.itemInfos[index + 1].amount
        --item:GetChild("_title").text = config.name
        --item:GetController("c1").selectedIndex = 2
        --item:SetQuality(config.color)
        --item:SetAmountMid(config.id)
        -- item:SetData(self.itemInfos[index+1])
        local mid = GD.ItemAgent.GetItemInnerContent(config.id)
        item:SetShowData(config.icon,config.color,self.itemInfos[index + 1].amount,config.name,mid)
    end

    self._listView:SetVirtual()
end

function ItemUnionTaskActivePresident:RefreshListView()
    self._listView.numItems = #self.itemInfos
end

function ItemUnionTaskActivePresident:RefreshItem(  )

end

return ItemUnionTaskActivePresident