--[[
    Author:zhangzhichao
    Function:VIP升级界面
]]
local VIPLevel = UIMgr:NewUI("VIPLevel")


local VIPModel = import("Model/VIPModel")
local list,point
local list1,point1

function VIPLevel:OnInit( )
    local viewContent = self.Controller.contentPane
    local view=viewContent:GetChild("content")
    --按钮
    self._btnUse=view:GetChild("btnUse")
    self._btnClose=view:GetChild("btnClose")
    self._btnUseText=self._btnUse:GetChild("title")
    self._btnUseText.text=StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    --文本
    -- self._titleName=view:GetChild("titleName")
    self._textNum=view:GetChild("textNUm")
    self._textTagLevel=view:GetChild("textTagLevel")
    self._textTagNext=view:GetChild("textTagNext")
    --列表
    self._liebiao=view:GetChild("liebiao")

    self._textSpeed = view:GetChild("textSpeed")
    self._textAP = view:GetChild("textAP")
    self._bgAP = view:GetChild("bgAP")
    self._bgSpeed = view:GetChild("bgSpeed")
    self._arrowSpeed = view:GetChild("arrowSpeed")
    self._arrowAP = view:GetChild("arrowAP")
    self._bgMask = viewContent:GetChild("bgMask")
    self._effectNode = view:GetChild("effectNode")

    --UI图片
    self._Hero = view:GetChild("Hero")
    self._textVip = view:GetChild("textVip")

    self:SetIncreaseUI(1, false)
    self:SetIncreaseUI(2, false)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("VIPLevel")
    end)
    self:AddListener(self._btnUse.onClick,function()
        UIMgr:Close("VIPLevel")
    end)
    self:AddListener(self._bgMask.onClick,function ()
        UIMgr:Close("VIPLevel")
    end)

    NodePool.Init(NodePool.KeyType.VipUpgradeEffect, "Effect", "EffectNode")

    --设置Banner
    -- self._banner.icon = UITool.GetIcon(GlobalBanner.VipLevel)

    self.ScreenAdp(view);
end

function VIPLevel.ScreenAdp(item)
    local scaleValue =(_G.Screen.height/_G.Screen.width)/(1334/750)
    if scaleValue >= 1 then
        return
    end
    item.scale = _G.Vector2(scaleValue,scaleValue)
    item.x = item.x + item.width*(1-scaleValue)*0.5
    item.y = item.y + item.height*(1-scaleValue)*0.5
end

function VIPLevel:SetIncreaseUI(index, visible)
    if index == 1 then
        self._textSpeed.visible = visible
        self._bgSpeed.visible = visible
        self._arrowSpeed.visible = visible
    else
        self._textAP.visible = visible
        self._bgAP.visible = visible
        self._arrowAP.visible = visible
    end
end

function VIPLevel:OnOpen(beforelevel,curlevel)
    self:PlayVipEffect()
    -- self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Upgrade_Title")
    self._textNum.text = curlevel
    self._textTagLevel.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = beforelevel})
    self._textTagNext.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = curlevel})
    local conf = ConfigMgr.GetList("configVips")
    list1, _ = VIPModel.GetLevelPropByConf(beforelevel,conf)
    list2, _ = VIPModel.GetLevelPropByConf(curlevel,conf)
   
    list1, list2 = VIPModel.SetLevelPropList(list1, list2)
   
    local increaseNum = 0
    self._liebiao.numItems = #list1 * 2
    SdkModel.TrackBreakPoint(10029, math.ceil(curlevel))      --打点
    for k, v in ipairs(list1) do
        local leftItem = self._liebiao:GetChildAt(2 * (k - 1))
        local rightItem = self._liebiao:GetChildAt(2 * (k - 1) + 1)
        
        leftItem:InitEvent(list1[k], beforelevel, false)
        rightItem:InitEvent(list2[k], curlevel, true)

        if increaseNum < 2 and v.sort == 2 then
            local name = ConfigMgr.GetI18n("configI18nCommons", "Vip_Desc"..list1[k].vip_right)
            local num = list2[k].num - list1[k].num 

            local conf = ConfigMgr.GetItem("configVipAttrs", list1[k].vip_right)
            if conf.format == 1 then
               num = num - Global.FreeBuildTime
            end
            local numText = VIPModel.GetValueByType(num, conf.format)
            if conf.format == 1 then
                numText = "+" .. numText
            end
            numText = "[color=#30c756]" .. numText .. "[/color]"
            local text = name .. numText
            if increaseNum == 0 then
                self:SetIncreaseUI(1, true)
                self._textSpeed.text = text
            else
                self:SetIncreaseUI(2, true)
                self._textAP.text = text     
            end
            increaseNum = increaseNum + 1
        end
    end
end

function VIPLevel:OnClose()
    if self.effect then
        NodePool.Set(NodePool.KeyType.VipUpgradeEffect, self.effect)
    end
    if self.effect2 then
        NodePool.Set(NodePool.KeyType.VipUpgradeEffect, self.effect2)
    end
end

--播放Vip升级特效
function VIPLevel:PlayVipEffect()
    self.effect = NodePool.Get(NodePool.KeyType.VipUpgradeEffect)
    self.effect.xy = Vector2(0, 50)
    self._effectNode:AddChild(self.effect)
    self.effect:InitNormal()
    self.effect:PlayEffectLoop("effects/vipupgrade/prefab/effect_level _vip")

    self.effect2 = NodePool.Get(NodePool.KeyType.VipUpgradeEffect)
    self.effect2.xy = Vector2(self._effectNode.x, self._effectNode.y)
    self.Controller.contentPane:AddChild(self.effect2)
    self.effect2:InitNormal()
    self.effect2:PlayEffectLoop("effects/vipupgrade/prefab/effect_level _vip2")
end

return VIPLevel