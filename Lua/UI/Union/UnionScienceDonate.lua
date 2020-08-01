-- 联盟科技主界面
local UnionScienceDonate = UIMgr:NewUI("UnionScienceDonate")

local UnionModel = import("Model/UnionModel")

function UnionScienceDonate:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("liebiao")
    self._list = self._list:GetChild("liebiao")
    -- self._txtTotalLv = view:GetChild("textLevelNum")
    self._txtUnionCoin = view:GetChild("textHaveNum")
    self.totalLv = 0
    self.upgradeDatas = {} -- 所有可以升级技能
    self.recommendDatas = {} -- 所有推荐技能
    self.configDatas = {} -- 按组分类好的所有技能
    self.techModels = {}
    self.openStatus = {} -- 列表项开关状态

    self._list.scrollItemToViewOnClick = false
    
    local btnHelp = view:GetChild("btnHelp")
    self:AddListener(btnHelp.onClick,function()
        Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1002).article_id)
    end)
    
    local btnReturn = view:GetChild("btnReturn")
    self:AddListener(btnReturn.onClick,function()
        self:Close()
    end)

    self:AddEvent(EventDefines.UIUnionDonateHonorRefresh, function(honor)
        self.honor = self.honor + honor
        self._txtUnionCoin.text = self.honor
    end)
end

function UnionScienceDonate:OnOpen(notScrollTop)
    -- self.upgradeDatas = {}
    -- self.recommendDatas = {}
    -- self.configDatas = {}
    -- self.techModels = {}
    self.maxLevel = 0
    self.honor = Model.Find(ModelType.Resources, RES_TYPE.UnionHonor).Amount
    self._txtUnionCoin.text = self.honor
    self.notScrollTop = notScrollTop

    -- 获取联盟技能列表
    UnionModel.GetTechs(function(rsp)
        if rsp.Fail then
            return
        end

        self.upgradeDatas = {}
        self.recommendDatas = {}
        self.configDatas = {}
        self.techModels = rsp.Techs
        self.totalLv = rsp.TotalLevel
        UnionModel.techModels = rsp.Techs
        -- self._txtTotalLv.text = self.totalLv

        self:SetConfigData()
        self:RefreshList()
    end)
end

function UnionScienceDonate:Close()
    self.openStatus = {}
    UIMgr:Close("UnionScienceDonate")
    Event.Broadcast(SHOPEVENT.Refresh)
end

function UnionScienceDonate:RefreshList()
    self._list:RemoveChildrenToPool()
    
    -- 显示可以升级科技，组别为-2
    if UnionModel.CheckPermission(GlobalAlliance.APUpgradeTech) and #self.upgradeDatas > 0 then
        local item = self._list:AddItemFromPool()
        item:Init(-2, self.upgradeDatas, false, true, function()
            self:OnOpen(true)
        end)
    end
    
    -- 显示推荐科技，组别为-1
    if #self.recommendDatas > 0 then
        local item = self._list:AddItemFromPool()
        item:Init(-1, self.recommendDatas, false, true, function()
            self:OnOpen(true)
        end)
    end

    -- 按分组显示科技，未解锁的技能组只显示组号最小的一组
    local curShowFloor = 1
    for k,v in pairs(self.configDatas) do
        if v[1].config.points <= self.totalLv then
            local isOpen = self.openStatus[k]
            if isOpen == nil then
                isOpen = #self.upgradeDatas <= 0 and #self.recommendDatas <= 0 and v[1].config.floor == self.maxLevel
                self.openStatus[k] = isOpen
            end

            curShowFloor = curShowFloor + 1
            local item = self._list:AddItemFromPool()
            item:Init(k, v, false, isOpen, function()
                self:OnOpen(true)
            end, 
            function(status)
                self.openStatus[k] = status
            end)
        elseif k == curShowFloor then
            local isOpen = self.openStatus[k]
            if isOpen == nil then
                isOpen = false
                self.openStatus[k] = isOpen
            end

            local item = self._list:AddItemFromPool()
            item:Init(k, v, true, isOpen, function()
                self:OnOpen(true)
            end,
            function(status)
                self.openStatus[k] = status
            end)
        end
    end

    if not self.notScrollTop then
        self._list.scrollPane:ScrollTop()
    end
end

-- 将科技分类
function UnionScienceDonate:SetConfigData()
    
    local configs = ConfigMgr.GetList("configAllanceTechDisplays")
    for _,v in pairs(configs) do
        local curModel = self:GetModel(v.id)

        -- 可升级科技
        if curModel.Level < v.max_lv and curModel.ContriProgress == curModel.ContriMax then
            if curModel.IsUp then
                table.insert(self.upgradeDatas, 1, {config = v, model = curModel})
            else
                table.insert(self.upgradeDatas, {config = v, model = curModel})
            end
        end

        -- 推荐科技
        if curModel.IsRecommended then
            table.insert(self.recommendDatas, {config = v, model = curModel})
        end
        
        -- 按分组分类
        if self.configDatas[v.floor] ~= nil then
            table.insert(self.configDatas[v.floor], {config = v, model = curModel})
        else
            self.configDatas[v.floor] = {{config = v, model = curModel}}
        end

        -- 找到最高等级组
        if v.points <= self.totalLv and v.floor > self.maxLevel then
            self.maxLevel = v.floor
        end
    end
end

-- model 结构为AllianceTech服务器协议
function UnionScienceDonate:GetModel(configId)
    for _,v in pairs(self.techModels) do
        if (v.ConfId - v.Level) == configId then
            return v
        end
    end
end

return UnionScienceDonate