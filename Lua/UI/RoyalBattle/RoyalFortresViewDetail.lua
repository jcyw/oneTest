--[[
    王战查看详情
    author:{tiantian}
    time:2020-06-21
]]
local RoyalFortresViewDetail = UIMgr:NewUI("RoyalFortresViewDetail")
local ItemUnionAggregation = import("UI/Union/ItemUnionAggregation")
local MonsterModel = import("Model/MonsterModel")

function RoyalFortresViewDetail:OnInit()
    local view = self.Controller.contentPane
    self._control = view:GetController("showControl")
    self._list.itemRenderer = function(index, item)
        self:itemRenderer(index,item)
    end
    self._list:SetVirtual()
    self:InitEvent()
        --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionGift)
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Warzone_State")
    self._txtIconName.text = StringUtil.GetI18n(I18nType.Commmon, "QUEUE_IN_OCCUPY")
    self._txtMemberTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceArmy_Number")
end
function RoyalFortresViewDetail:InitEvent()

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("RoyalFortresViewDetail")
        end
    )

    self:AddListener(self._btnRecovery.onClick,
        function()
            
        end
    )
end

function RoyalFortresViewDetail:itemRenderer(index,item)
    if index < #self.datas then
        local data = self.datas[index + 1]
        local itemClickFunc = function()
            if item:GetSelected() then
                for k,v in pairs(self.curSelectedList) do
                    if v == data.UserId then
                        table.remove(self.curSelectedList, k)
                        break
                    end
                end
            else
                table.insert(self.curSelectedList, data.UserId)
            end
            self._list:RefreshVirtualList()
        end

        item:Init(ItemUnionAggregation.TypeEnum.Common, itemClickFunc)

        --选中项展开士兵列表
        for _,v in pairs(self.curSelectedList) do
            if v == data.UserId then
                if self.chunkInfo.OwnerId == Model.Account.accountId and v ~= Model.Account.accountId then
                    item:OpenList(data.Team.Armies, data.Team.Beasts, function()
                        local x, y = MathUtil.GetCoordinate(self.chunkInfo.Id)
                        Net.AllianceBuildings.RemovalGarrison(x, y, data.UserId, function(rsp)
                            local id = data.UserId
                            for k,v in pairs(self.datas) do
                                if v.UserId == id then
                                    table.remove(self.datas, k)
                                    break
                                end
                            end
                            table.remove(self.curSelectedList, index + 1)
                            self:RefreshListView()
                        end)
                    end)
                else
                    item:OpenList(data.Team.Armies, data.Team.Beasts)
                end
                break
            end
        end

        local total = 0
        local power = 0
        for _,v in pairs(data.Team.Armies) do
            total = total + v.Amount
            power = power + math.floor(ConfigMgr.GetItem("configArmys", v.ConfId).power * v.Amount)
        end
        for _,v in pairs(data.Team.Beasts) do
            power = power + MonsterModel.GetMonsterRealPower(v.Id, v.Level, v.Health, v.MaxHealth)
        end
        item:SetContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Power"), Tool.FormatNumberThousands(math.floor(power)))
        item:SetSubContent(StringUtil.GetI18n(I18nType.Commmon, "UI_Warzone_Army"), total)
        item:SetPlayerInfo(data, data.Name, data.UserId)
        item:SetStatusContent("")
    else
        -- 显示加入按钮
        item:Init(ItemUnionAggregation.TypeEnum.Add, function()
            local data = {
                openType = ExpeditionType.UnionBuildingStation,
                posNum = self.chunkInfo.Id
            }
            UIMgr:Open("Expedition", data)
        end)
        item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tipsb"))
    end
end
function RoyalFortresViewDetail:OnOpen(val,chunkInfo)
    self.datas = val.Garrisons
    self.maxAssist= val.MaxAssist
    self.chunkInfo = chunkInfo
    self.curSelectedList = {}
    local namekey = chunkInfo.Category == Global.MapTypeThrone and "MARCH_TARGET_SUPERCITY" or "Ui_WarZone_Notice_Name3"
    local iconData =  chunkInfo.Category == Global.MapTypeThrone and {"IconArm","warzone"} or {"IconArm","missilebase"}
    self._txtName.text = StringUtil.GetI18n(I18nType.Commmon, namekey)
    self._icon.icon = UITool.GetIcon(iconData)
    self:RefreshListView()
end
function RoyalFortresViewDetail:RefreshListView()
    if self.maxAssist == 0 then
        self._txtMember.visible = false
        self._txtMemberTitle.visible = false
    else
        self._txtMember.visible = true
        self._txtMemberTitle.visible = true
        local amount = 0
        for _, v in ipairs(self.datas) do
            for _, v1 in ipairs(v.Team.Armies) do
                amount = amount + v1.Amount
            end
        end

        self._list.numItems = #self.datas
        self._txtMember.text = amount .. "/" ..self.maxAssist
    end
end
return RoyalFortresViewDetail