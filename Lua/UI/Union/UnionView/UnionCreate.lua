--[[
    Author: songzeming
    Function: 创建联盟弹窗
]]
local UnionCreate = UIMgr:NewUI("UnionView/UnionCreate")

local UnionInfoModel = import("Model/Union/UnionInfoModel")
local CTR = {
    Free = "Free",
    Gold = "Gold"
}
local CTR_VALID = {
    True = "True",
    False = "False"
}

function UnionCreate:OnInit()
    self:AddListener(self._btnCreateFree.onClick,
        function()
            self:Create()
        end
    )
    self._textGold = self._btnCreateGold:GetChild("text")
    self._textGold.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Create2")
    self:AddListener(self._btnCreateGold.onClick,
        function()
            self:Create()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._inputCreate.onFocusOut,
        function()
            self:Check()
        end
    )
    self:AddListener(self._inputCreate.onChanged,
        function()
            self._inputCreate.text = self:GetNameText()
        end
    )
    self:AddListener(self._inputDesc.onChanged,
        function()
            self._inputDesc.text = string.gsub(self._inputDesc.text, "[[%]]+", "")
        end
    )
end

function UnionCreate:OnOpen(isGodLike)
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    self._ctrValid = view:GetController("CtrValid")

    self._inputCreate.text = ""
    self._inputDesc.text = ""

    --是否是天选之人
    self.isGodLike = isGodLike and true or false

    if isGodLike then
        self._ctr.selectedPage = CTR.Free
    else
        self._ctr.selectedPage = Model.Player.Level >= Global.AllianceCreateByFreeLv and CTR.Free or CTR.Gold
    end
    self._ctrValid.selectedPage = CTR_VALID.False
end

function UnionCreate:Close()
    UIMgr:Close("UnionView/UnionCreate")
end

function UnionCreate:GetNameText()
    return string.gsub(StringUtil.RemoveStringSpace(self._inputCreate.text), "[\t\n[%]]+", "")
end

-- 简称联盟名称是否合法
function UnionCreate:Check()
    local name = self:GetNameText()
    if #name < 3 then
        self._ctrValid.selectedPage = CTR_VALID.False
    else
        Net.Alliances.NameValid(
            name,
            function(rsp)
                local isValid = rsp.Result == 0
                self._ctrValid.selectedPage = isValid and CTR_VALID.True or CTR_VALID.False
                if not isValid then
                    TipUtil.TipById(50168)
                end
            end
        )
    end
end

-- 点击创建联盟
function UnionCreate:Create()
    if self._ctrValid.selectedPage == CTR_VALID.False then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_CreateTips_Txt")
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end

    local function create_func()
        local name = self:GetNameText()
        local desc = self._inputDesc.text
        SdkModel.TrackBreakPoint(10044)      --打点
        Net.Alliances.Create(
            name,
            desc,
            self.isGodLike,
            function(rsp)
                Model.Player.AllianceId = rsp.Uuid
                Model.Player.AllianceName = rsp.ShortName
                Model.Player.AlliancePos = Global.AlliancePosR5
                UnionInfoModel.SetInfo(rsp)
                UIMgr:ClosePopAndTopPanel()
                local values = {alliance_name = name}
                TipUtil.TipById(50181, values)
                TurnModel.UnionView()
                Event.Broadcast(EventDefines.UIAllianceCreate)
            end
        )
    end
    if self._ctr.selectedPage == CTR.Free then
        create_func()
        return
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_GreatTips"),
        gold = Global.AllianceCreateFee,
        sureCallback = create_func
    }
    UIMgr:Open("ConfirmPopupText", data)
end

return UnionCreate
