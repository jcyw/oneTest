--[[
    Author: songzeming
    Function: 联盟管理 修改联盟徽章
]]
local GD = _G.GD
local UnionBadge = UIMgr:NewUI("UnionManager/UnionBadge")

local UnionModel = import('Model/UnionModel')
local UnionInfoModel = import('Model/Union/UnionInfoModel')
import('UI/Union/UnionManager/ItemUnionBadge')
local BLANK_HALF = 2 --占位
local CONTROLLER = {
    Normal = 'Normal',
    Special = 'Special'
}
local DefaultId = 101 --默认徽章Id
local DefaultSpecialId = 201 --默认特殊徽章

function UnionBadge:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController('Controller')

    self._num = self._btnModify:GetChild("text")
    self:AddListener(self._btnModify.onClick,
        function()
            self:OnBtnModifyClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionManager/UnionBadge')
        end
    )
    self:AddListener(self._btnModifyGray.onClick,
        function()
            UIMgr:Close('UnionManager/UnionBadge')
        end
    )

    local numConf = #ConfigMgr.GetList("configAllianceLogos")
    self._list.numItems = numConf + BLANK_HALF * 2
    local blankArr = {1, 2, self._list.numChildren - 1, self._list.numChildren}
    for _, v in pairs(blankArr) do
        self._list:GetChildAt(v - 1):Init(v - 1)
    end
    self:AddListener(self._list.scrollPane.onScroll,function()
        self:SlideControl()
    end)
end

function UnionBadge:OnOpen()
    self._list:EnsureBoundsCorrect()

    self.unionInfo = UnionInfoModel.GetInfo()
    self.showIndex = nil
    self:UpdateData()
end

function UnionBadge:OnClose()
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
end

function UnionBadge:UpdateData()
    local conf = ConfigMgr.GetList("configAllianceLogos")
    for k, v in ipairs(conf) do
        local index = k + BLANK_HALF - 1
        local item = self._list:GetChildAt(index)
        local click_func = function()
            self._list.scrollPane:SetPosX(item.x - item.width * 2, true)
        end
        item:Init(index, v, click_func)
        if self.unionInfo.Emblem == v.id then
            --初始化显示
            self._list.scrollPane:SetPosX(item.x - item.width * 2)
            self:ShowData(v)
            self.oldName = v.name and StringUtil.GetI18n(I18nType.Commmon, v.name)
            self.oldSpecial = CheckSpecial(v)
            self:SlideControl()
        end
    end

    self:ShowCD()
end

function UnionBadge:ShowData(data)
    local isCurrent = self.unionInfo.Emblem == data.id
    self.chooseData = data

    --self._icon.icon = UITool.GetIcon(data.image)
    self._medal:SetMedal(data.id, Vector3(160, 160, 160))
    if CheckSpecial(data) then
        --特殊徽章
        self._controller.selectedPage = CONTROLLER.Special
        self._name.text = StringUtil.GetI18n(I18nType.Commmon, data.name)
        self._from.text = StringUtil.GetI18n(I18nType.Commmon, data.get_info)
        local desc
        for _, v in ipairs(data.buff_info) do
            if not desc then
                desc = StringUtil.GetI18n(I18nType.Commmon, v)
            else
                desc = '\n' .. StringUtil.GetI18n(I18nType.Commmon, v)
            end
        end
        self._desc.text = desc
        self._btnModify.icon = UITool.GetIcon(data.image)
        if CheckItem(data.consume.category) then
            self._num.text = UITool.GetTextColor(GlobalColor.White, data.consume.amount)
        else
            self._num.text = UITool.GetTextColor(GlobalColor.Red, data.consume.amount)
        end
        self._time.visible = isCurrent
    else
        --普通徽章
        self._controller.selectedPage = CONTROLLER.Normal
        local conf = ConfigMgr.GetItem("configResourcess", Global.ResDiamond)
        self._btnModify.icon = UITool.GetIcon(conf.img)
        self._num.text = UITool.UBBTipGoldText(data.consume.amount)
    end
    self._btnModify.enabled = not isCurrent
end

function UnionBadge:SlideControl()
    local center = self._list.scrollPane.posX + self._list.viewWidth / 2
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local iCenter = item.x + item.width / 2
        local distance = math.abs(center - iCenter)
        if distance < item.width / 2 + self._list.columnGap / 2 then
            self.itemIndex = i
            local scale = 1 + (item.width / (item.width + distance) - 0.5) * 0.5
            item:SetScale(scale, scale)
            local index = item:GetIndex()
            if index ~= self.showIndex then
                self.showIndex = index
                self:ShowData(item:GetConf())
            end
        else
            item:SetScale(1, 1)
        end
    end
end

--检测是否拥有道具
function CheckItem(id)
    return Model.Items[id] and Model.Items[id].Amount > 0
end
--检测是否为特殊徽章
function CheckSpecial(data)
    return data.name
end

function UnionBadge:ShowCD()
    self:OnClose()
    --特殊徽章剩余时间
    local ctime = self.unionInfo.EmblemExpireAt - Tool.Time()
    if ctime > 0 then
        local show_func = function(t)
            self._time.text = Tool.FormatTime(t)
        end
        show_func(ctime)
        self.cd_func = function()
            ctime = ctime - 1
            if ctime >= 0 then
                show_func(ctime)
                return
            end
            --联盟徽章到期 重置徽章
            self.unionInfo.Emblem = DefaultId
            self.unionInfo.EmblemExpireAt = 0
            self:UpdateData()
        end
        self:Schedule(self.cd_func, 1)
    end
end

--点击修改
function UnionBadge:OnBtnModifyClick()
    if not UnionModel.CheckUnionPermissions(GlobalAlliance.APChangeEmblem) then
        --权限不足
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Presidentchange_NoJurisdiction'),
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    local net_func = function()
        --修改联盟徽章
        Net.Alliances.ChangeEmblem(
            self.chooseData.id,
            function()
                TipUtil.TipById(50147)
                self.unionInfo.Emblem = self.chooseData.id
                if self.chooseData.time then
                    self.unionInfo.EmblemExpireAt = Tool.Time() + self.chooseData.time
                end
                self:UpdateData()
                Event.Broadcast(EventDefines.UIAllianceIconExchanged)
            end
        )
    end

    if CheckSpecial(self.chooseData) then
        --特殊徽章
        if CheckItem(self.chooseData.consume.category) then
            --有道具
            if self.oldSpecial then
                --特殊联盟徽章在激活状态再次点击其他徽章修改时的提示
                local values = {
                    oldlogo_name = self.oldName
                }
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Presidentchange_SpecialTips', values),
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, 'Buttion_Presidentchange_yes'),
                    sureCallback = net_func
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                --非徽章点击修改特殊徽章时的提示
                local values = {
                    number = self.chooseData.consume.amount,
                    item_name = GD.ItemAgent.GetItemNameByConfId(self.chooseData.consume.category),
                    logo_name = StringUtil.GetI18n(I18nType.Commmon, self.chooseData.name)
                }
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Presidentchange_Specialcost', values),
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, 'Buttion_Presidentchange_yes'),
                    sureCallback = net_func
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
        else
            --没有徽章道具
            local values = {
                number = self.chooseData.consume.amount,
                item_name = GD.ItemAgent.GetItemNameByConfId(self.chooseData.consume.category)
            }
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Presidentchange_SpecialTips2', values)
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    else
        --普通徽章
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Presidentchange_cost'),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, 'Buttion_Presidentchange_yes'),
            sureCallback = function()
                if self.chooseData.consume.amount > Model.Player.Gem then
                    UITool.GoldLack()
                else
                    net_func()
                end
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

return UnionBadge
