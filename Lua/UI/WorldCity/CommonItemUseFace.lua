--[[
    author:{zhanzhang}
    time:2019-09-24 16:44:25
    function:{通用道具buff页面}
]]
local GD = _G.GD
local CommonItemUseFace = UIMgr:NewUI("CommonItemUseFace")

function CommonItemUseFace:OnInit()
    self:OnRegister()
end

function CommonItemUseFace:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("CommonItemUseFace")
        end
    )
end
function CommonItemUseFace:OnOpen(propType)
    self.pageType = propType
    if propType == Global.PageBaseBuff then
        --基地增益界面
    elseif propType == Global.PageVipPoint then
        --VIP积分界面
    elseif propType == Global.PageVipActive then
    elseif propType == Global.PageMarchSpeed then
        --行军加速界面
        
    elseif propType == Global.PageMarchLimit then
        --出征上限提升界面
    elseif propType == Global.PageAddAp then
        --体力增加界面
    elseif propType == Global.PageAddExp then
        --经验提升界面
    elseif propType == Global.PageMarchReturn then
        --行军返回界面
    else
        Log.Info("该界面未定义")
    end

    local list = GD.ItemAgent.GetItemListByPage(Global.PageMarchLimit)
    self._contentList:RemoveChildrenToPool()
    for i = 1, #list do
        local item = self._contentList:AddItemFromPool()
        item:Init(list[i], ItemType.ExpeditionLimitProp)
    end
end

return CommonItemUseFace
