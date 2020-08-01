--[[
    author:Temmie
    time:
    function:仓库界面
]]
local GD = _G.GD
local ResourceDisplay = _G.UIMgr:NewUI("ResourceDisplay")

import("UI/Common/ItemResourceDisplay")
local BuildModel = import("Model/BuildModel")
local UnionModel = import("Model/UnionModel")

local EventDefines = _G.EventDefines
local GlobalItem = _G.GlobalItem
local ConfigMgr = _G.ConfigMgr
local Tool = _G.Tool
local I18nType = _G.I18nType
local Net = _G.Net
local TipUtil = _G.TipUtil
local UIMgr = _G.UIMgr
local Model = _G.Model
local Global = _G.Global
local TipBtnOffset = 0.5

function ResourceDisplay:OnInit()
    local view = self.Controller.contentPane

    local btnReturn = view:GetChild("btnReturn")
    local btnExplain = view:GetChild("btnExplain")
    local btnRes1 = view:GetChild("btnTagSingle1")
    local btnRes2 = view:GetChild("btnTagSingle2")
    local btnRes3 = view:GetChild("btnTagSingle3")
    local btnRes4 = view:GetChild("btnTagSingle4")

    self._btnHelp = view:GetChild("btnHelp")
    self._btnHelp2 = view:GetChild("btnHelp2")
    self._txtResNum1 = btnRes1:GetChild("title")
    self._txtResNum2 = btnRes2:GetChild("title")
    self._txtResNum3 = btnRes3:GetChild("title")
    self._txtResNum4 = btnRes4:GetChild("title")
    self._btnResList = {btnRes1, btnRes4, btnRes3, btnRes2}
    self._controlTipShow = view:GetController("tipShowControl")
    self._iconCurRes = view:GetChild("icon")
    self._txtCurResNum = view:GetChild("textIconNumber")
    self._list = view:GetChild("liebiao")
    self._btnDirectUse = view:GetChild("btnUse")
    self._btnDirectUse2 = view:GetChild("btnUse2")
    self._controlBtnShow = view:GetController("btnShowControl")
    self.curAllModel = {}

    view:GetChild("textName").text = ConfigMgr.GetI18n("configI18nBuildings", "404000_NAME")

    self:AddEvent(
        EventDefines.UIResourcesAmount,
        function(_)
            self:RefreshResource()
        end
    )

    self:AddListener(btnRes1.onClick,
        function()
            self.curResType = GlobalItem.ItemEffectWood
            self:RefreshUnsafeResNum()
            self:RefreshList()
        end
    )

    self:AddListener(btnRes2.onClick,
        function()
            self.curResType = GlobalItem.ItemEffectFood
            self:RefreshUnsafeResNum()
            self:RefreshList()
        end
    )

    self:AddListener(btnRes3.onClick,
        function()
            self.curResType = GlobalItem.ItemEffectIron
            self:RefreshUnsafeResNum()
            self:RefreshList()
        end
    )

    self:AddListener(btnRes4.onClick,
        function()
            self.curResType = GlobalItem.ItemEffectStone
            self:RefreshUnsafeResNum()
            self:RefreshList()
        end
    )

    local directUseFunc = function()
        local itemAmounts = {}
        local curAmount = 0
        for _, v in pairs(self.curAllModel) do
            local config = ConfigMgr.GetItem("configItems", v.ConfId)
            curAmount = curAmount + (v.Amount * config.value)
            table.insert(itemAmounts, {ConfId = v.ConfId, Amount = v.Amount})
        end

        local data = {
            items = {
                [1] = {
                    icon = GD.ResAgent.GetIconUrl(self.curResType, true),
                    amount = "X" .. Tool.FormatAmountUnit(curAmount)
                }
            },
            content = ConfigMgr.GetI18n(I18nType.Commmon, "Use_All_Res"),
            cbOk = function()
                Net.Items.BatchUse(
                    itemAmounts,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        TipUtil.TipById(50040, Tool.FormatAmountUnit(curAmount) .. ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. self.curResType))
                        self:RefreshList()
                        self:RefreshResource()
                    end
                )
            end
        }
        -- local data = {
        --     icon = GD.ResAgent.GetIconUrl(self.curResType, true),
        --     content = ConfigMgr.GetI18n(I18nType.Commmon, "Use_All_Res"),
        --     amount = Tool.FormatAmountUnit(curAmount),
        --     sureCallback = function()
        --         Net.Items.BatchUse(
        --             itemAmounts,
        --             function(rsp)
        --                 if rsp.Fail then
        --                     return
        --                 end

        --                 TipUtil.TipById(50040, Tool.FormatAmountUnit(curAmount) .. ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. self.curResType))
        --                 self:RefreshList()
        --                 self:RefreshResource()
        --             end
        --         )
        --     end
        -- }
        UIMgr:Open("BackpackUseDetails", data)
    end
    self:AddListener(self._btnDirectUse.onClick,directUseFunc)
    self:AddListener(self._btnDirectUse2.onClick,directUseFunc)

    local helpFunc = function()
        local data = {
            content = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Ask_Help_Res"),
            sureCallback = function()
                Net.AllianceAssist.AskForAssist(
                    Model.Player.AllianceId,
                    self.curResType,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        self._btnHelp.enabled = false
                        self._btnHelp2.enabled = false
                        TipUtil.TipById(50041)
                    end
                )
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
    self:AddListener(self._btnHelp.onClick,helpFunc)
    self:AddListener(self._btnHelp2.onClick,helpFunc)

    self:AddListener(btnExplain.onClick,
        function()
            UIMgr:Open("ResourceDescribe", self.curResType)
        end
    )

    self:AddListener(btnReturn.onClick,
        function()
            UIMgr:Close("ResourceDisplay")
            self:DoCallback("close")
        end
    )
end

--[[
    resType 跳转资源标签（可以为nil）
    needType 需要资源类型（可以为nil）
    needAmount 需要资源量（可以为nil）
    callback 关闭界面回调（可以为nil）
]]
function ResourceDisplay:OnOpen(resType, needType, needAmount, callback)
    -- if not BuildModel.CheckExist(Global.BuildingVault) then
    --     UIMgr:Close("ResourceDisplay")
    --     return
    -- end

    self.callback = callback
    self.curResType = resType and resType or GlobalItem.ItemEffectWood
    self.needType = needType
    self.needAmount = needAmount
    self._txtCurResNum.text = Tool.FormatAmountUnit(GD.ResAgent.Amount(self.curResType, false) - GD.ResAgent.SafeAmount(self.curResType, false))

    local btn = self._btnResList[self.curResType]
    if btn ~= nil then
        btn:FireClick(true)
        btn.onClick:Call()
    end

    -- 设置资源标签
    local unlock = 0
    local centerLv = BuildModel.GetCenterLevel()
    for _, v in pairs(Global.ResUnlockLevel) do
        if centerLv >= v.level then
            unlock = v.category
        end
    end
    self._controlTipShow.selectedPage = unlock

    if unlock == 1 then
        self._btnResList[1].x = TipBtnOffset
        self._btnResList[1].width = self._list.width - TipBtnOffset * 2
    elseif unlock == 4 then
        local width = self._list.width / 2 - TipBtnOffset
        self._btnResList[1].x = TipBtnOffset
        self._btnResList[1].width = width
        self._btnResList[4].x = TipBtnOffset * 2 + self._btnResList[1].width
        self._btnResList[4].width = width
    elseif unlock == 3 then
        local width = self._list.width / 3 - TipBtnOffset * 2
        self._btnResList[1].x = TipBtnOffset
        self._btnResList[1].width = width
        self._btnResList[4].x = TipBtnOffset * 2 + self._btnResList[1].width
        self._btnResList[4].width = width
        self._btnResList[3].x = TipBtnOffset * 3 + self._btnResList[1].width * 2
        self._btnResList[3].width = width
    elseif unlock == 2 then
        local width = self._list.width / 4 - TipBtnOffset * 3
        self._btnResList[1].x = TipBtnOffset
        self._btnResList[1].width = width
        self._btnResList[4].x = TipBtnOffset * 2 + self._btnResList[1].width
        self._btnResList[4].width = width
        self._btnResList[3].x = TipBtnOffset * 3 + self._btnResList[1].width * 2
        self._btnResList[3].width = width
        self._btnResList[2].x = TipBtnOffset * 4 + self._btnResList[1].width * 3
        self._btnResList[2].width = width
    end

    self:RefreshList()
    self:RefreshResource()
end

function ResourceDisplay:RefreshResource()
    self._txtResNum1.text = GD.ResAgent.Amount(ConfigMgr.GetVar("ResWood"), true)
    self._txtResNum2.text = GD.ResAgent.Amount(ConfigMgr.GetVar("ResFood"), true)
    self._txtResNum3.text = GD.ResAgent.Amount(ConfigMgr.GetVar("ResIron"), true)
    self._txtResNum4.text = GD.ResAgent.Amount(ConfigMgr.GetVar("ResStone"), true)
end

function ResourceDisplay:RefreshList()
    self.isEmpty = true
    self.curAllModel = {} -- 玩家拥有的当前类型的所有资源model

    self._list:RemoveChildrenToPool()
    local datas = ConfigMgr.GetList("configItems")
    local notOwn = {}
    for _, v in pairs(datas) do
        if v.type == 3 and v.type2 == self.curResType then
            local model = GD.ItemAgent.GetItemModelById(v.id)

            -- 显示拥有的和能购买的资源
            if (model ~= nil and model.Amount > 0) then
                self.isEmpty = false
                table.insert(self.curAllModel, model)

                local item = self._list:AddItemFromPool()
                item:Init(
                    v,
                    model,
                    self,
                    function()
                        self:RefreshList()
                        self:RefreshResource()
                    end
                )
            elseif v.price ~= nil then
                table.insert(notOwn, v)
            end
        end
    end

    -- 没有的项放在拥有道具项的后面
    for _, v in pairs(notOwn) do
        local item = self._list:AddItemFromPool()
        item:Init(
            v,
            nil,
            self,
            function()
                self:RefreshList()
                self:RefreshResource()
            end
        )
    end

    self._list.scrollPane:ScrollTop()

    -- 设置底部按钮
    local hadUnion = UnionModel.CheckHadUnion()
    if not self.isEmpty and hadUnion then
        self._controlBtnShow.selectedPage = "all"
        self:SetHelpButton()
    elseif self.isEmpty and hadUnion then
        self._controlBtnShow.selectedPage = "help"
        self:SetHelpButton()
    elseif not self.isEmpty and not hadUnion then
        self._controlBtnShow.selectedPage = "use"
    else
        self._controlBtnShow.selectedPage = "empty"
    end
end

function ResourceDisplay:DoCallback(type, value)
    local cbData = {
        state = type,
        value = value
    }
    if self.callback then
        self.callback(cbData)
    end
end

function ResourceDisplay:SetHelpButton()
    self._btnHelp.enabled = false
    self._btnHelp2.enabled = false
    Net.AllianceAssist.GetAskForResAssistCoolDown(
        function(rsp)
            if rsp.Fail then
                return
            end

            if rsp.Cooldown then
                self._btnHelp.enabled = true
                self._btnHelp2.enabled = true
            end
        end
    )
end

function ResourceDisplay:RefreshUnsafeResNum()
    self._iconCurRes.url = GD.ResAgent.GetIconUrl(self.curResType)
    self._btnHelp.icon = GD.ResAgent.GetIconUrl(self.curResType)
    self._btnHelp2.icon = GD.ResAgent.GetIconUrl(self.curResType)
    local normalRes = Model.Resources[self.curResType].Amount - Model.Resources[self.curResType].SafeAmount
    local protectMax = (Model.ResProtects[self.curResType] and Model.ResProtects[self.curResType].Amount) or 0
    self._txtCurResNum.text = Tool.FormatAmountUnit(normalRes > protectMax and normalRes - protectMax or 0)
end

return ResourceDisplay
