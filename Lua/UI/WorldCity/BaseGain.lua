-- 指挥中心增益
local BaseGain = UIMgr:NewUI("BaseGain")


function BaseGain:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("liebiao")

    local btnHelp = view:GetChild("btnHelp")
    self:AddListener(btnHelp.onClick,function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
            info = StringUtil.GetI18n(I18nType.Commmon, 'Base_Buff_Explain')
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end)
    
    local btnReturn = view:GetChild("btnReturn")
    self:AddListener(btnReturn.onClick,function()
        UIMgr:Close("BaseGain")
    end)
end

function BaseGain:OnOpen(page)
    self.curPage = page
    self.configDatas = {}
    self.dataSort = {}
    self:BuildConfigDatas()
    self:InitList()
end

function BaseGain:InitList()
    self._list:RemoveChildrenToPool()
    for _,v in pairs(self.dataSort) do
        local item = self._list:AddItemFromPool()
        item:Init(v, self.configDatas[v])
    end
end

-- 获取buff分类
function BaseGain:BuildConfigDatas()
    local mainBuffConfigs = ConfigMgr.GetList("configMainbuffs")
    for k,v in pairs(mainBuffConfigs) do
        if self:CheckBuff(v) then
            local itemConfig = ConfigMgr.GetItem("configItems", v.id)
            if self.configDatas[itemConfig.type2] == nil then
                self.configDatas[itemConfig.type2] = {}
            end
            table.insert(self.configDatas[itemConfig.type2], {mainBuff = v, item = itemConfig})

            local addSort = true
            for _,v in pairs(self.dataSort) do
                if v == itemConfig.type2  then
                    addSort = false
                    break;
                end
            end
            if addSort then
                table.insert(self.dataSort, itemConfig.type2)
            end
        end
    end
end

function BaseGain:CheckBuff(buff)
    for _,v in pairs(buff.page) do
        if v == self.curPage then
            return true
        end
    end

    return false
end

return BaseGain
