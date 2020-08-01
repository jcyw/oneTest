--[[
    Author: songzeming
    Function: 修改玩家名称
]]
local GD = _G.GD
local Rename = UIMgr:NewUI("Rename")

local CheckValidModel = import("Model/Common/CheckValidModel")

local CTR = {
    Name = "Name",
    Desc = "Desc"
}
local CTR_COST = {
    Free = "Free",
    Charge = "Charge"
}
local NAME_MIN_LIMIT = 3 --名字长度最小值限定
local NAME_MAX_LIMIT = 16 --名字长度最大值限定
local DESC_MIN_LIMIT = 3 --宣言长度最小值限定
local DESC_MAX_LIMIT = 98 --宣言长度最大值限定
local BEAUTY_NAME_MIN_LIMIT = 3 --美女名称最小值限定
local BEAUTY_NAME_MAX_LIMIT = 16 --美女名称最小值限定
local CDKEY_MIN_LIMIT = 3 --兑换码最小值限定
local CDKEY_MAX_LIMIT = 30 --兑换码最小值限定
local function NameWordsNumber(from, len, white)
    local min = 3
    local max = 16
    if from == CheckValidModel.From.PlayerRename then
        --玩家改名
        min = NAME_MIN_LIMIT
        max = NAME_MAX_LIMIT
    elseif from == CheckValidModel.From.BeautyRename then
        --美女改名
        min = BEAUTY_NAME_MIN_LIMIT
        max = BEAUTY_NAME_MAX_LIMIT
    end
    local t = "(" .. len .. "/" .. max .. ")"
    local f = white or (len >= min and len <= max)
    local c = f and GlobalColor.White or GlobalColor.Red
    return UITool.GetTextColor(c, t)
end
local function GetTipI18n(i18n, color)
    local str = _G.StringUtil.GetI18n(_G.I18nType.Commmon, i18n)
    return not color and str or string.format("[color=%s]%s[/color]", color, str)
end

function Rename:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    self._ctrCost = view:GetController("CtrCost")

    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._inputName.onChanged,
        function()
            self:ShowValid()
        end
    )
    self:AddListener(self._inputName.onFocusOut,
        function()
            self:ShowValid()
        end
    )
    self:AddListener(self._inputDesc.onChanged,
        function()
            self:ShowValid()
        end
    )
    self:AddListener(self._inputDesc.onFocusOut,
        function()
            self:ShowValid()
        end
    )
    self._number = self._btnCharge:GetChild("text")
    self._bgBtnCharge = self._btnCharge:GetChild("bg")
    self:AddListener(self._btnCharge.onClick,
        function()
            self:OnBtnModifyClick()
        end
    )
    self:AddListener(self._btnFree.onClick,
        function()
            self:OnBtnModifyClick()
        end
    )
    self:AddListener(self._imageNo.onClick,
        function()
            self:SetResetSDKey()
        end
    )
end

function Rename:OnOpen(from, prompt, info)
    self.from = from
    self.info = info

    self:ShowIsValid(false)
    self._imageNo.visible = false
    self._imageNo.touchable = self.from == CheckValidModel.From.CDKey
    self._limit.visible = self.from ~= CheckValidModel.From.CDKey
    self._limit.text = NameWordsNumber(from, 0, true)
    self.free = false
    self.last = ""
    self.tipsColor = "#B6B0A4"

    if from == CheckValidModel.From.PlayerRename then
        --玩家改名
        self._ctr.selectedPage = CTR.Name
        self._inputName.text = ""
        self._inputName.promptText = GetTipI18n("Ui_CommanderName_Enter")
        self._title.text = GetTipI18n("Ui_CommanderName_change")
        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips", self.tipsColor)
        self._btnCharge.title = GetTipI18n("Button_CommanderName_change")
        self._ctrCost.selectedPage = CTR_COST.Charge
        if Model.Items[GlobalItem.ItemModifyUserName] then
            local conf = ConfigMgr.GetItem("configItems", GlobalItem.ItemModifyUserName)
            self._btnCharge.icon = UITool.GetIcon(conf.icon)
            self._number.text = 1
            self.free = true
        else
            self._btnCharge.icon = GD.ResAgent.GetDiamondSmallIcon()
            self._number.text = Global.ModifyUserNameCost
        end
    end
    if from == CheckValidModel.From.PlayerRedesc then
        --玩家修改宣言
        self._ctr.selectedPage = CTR.Desc
        self._inputDesc.text = ""
        self._inputDesc.promptText = GetTipI18n("Ui_Declaration_Txt")
        self._title.text = GetTipI18n("Button_CommanderTips_Change")
        self._textTip.text = GetTipI18n("Button_CommanderTips_ChangeTips", self.tipsColor)
        self._btnCharge.icon = GD.ResAgent.GetDiamondSmallIcon()
        if Model.Player.DeclareModified then
            --修改过宣言
            self._ctrCost.selectedPage = CTR_COST.Charge
            self._btnCharge.title = GetTipI18n("Button_Presidentchange")
            self._number.text = Global.ModifyUserDeclarationCost
        else
            self.free = true
            self._ctrCost.selectedPage = CTR_COST.Free
            self._btnCharge.title = GetTipI18n("BUTTON_Free")
        end
    end
    if from == CheckValidModel.From.BeautyRename then
        --美女改名
        self._ctr.selectedPage = CTR.Name
        self._inputName.text = ""
        self._inputName.promptText = prompt
        self._title.text = GetTipI18n("girl_rename")
        self._textTip.text = GetTipI18n("girl_rename_desc", self.tipsColor)
        self._btnCharge.icon = GD.ResAgent.GetDiamondSmallIcon()
        if info.msg.NameChangeTimes > 0 then
            self._ctrCost.selectedPage = CTR_COST.Charge
            self._number.text = Global.GirlNameChangeCost
            self._btnCharge.title = GetTipI18n("girl_rename")
        else
            self.free = true
            self._ctrCost.selectedPage = CTR_COST.Free
            self._btnFree.title = GetTipI18n("girl_rename_free")
        end
    end
    if from == CheckValidModel.From.CDKey then
        self._ctr.selectedPage = CTR.Name
        self._title.text = GetTipI18n("System_Cdkey_Name")
        self.free = true
        self._ctrCost.selectedPage = CTR_COST.Free
        self._btnFree.title = GetTipI18n("Ui_Exchange")
        self:SetResetSDKey()
    end
end

function Rename:Close()
    UIMgr:Close("Rename")
end
function Rename:OnClose()
    --关闭处理
end

--勾叉图标显示
function Rename:ShowIsValid(flag)
    self._imageYes.visible = flag
    self._imageNo.visible = not flag
    self:SetTouchable(flag)
    self._bgBtnCharge.grayed = not flag
end

function Rename:SetTouchable(flag)
    self._btnCharge.touchable = flag
    self._btnFree.enabled = flag
end
--兑换码输入重置
function Rename:SetResetSDKey()
    self._imageNo.visible = false
    self._inputName.text = ""
    self._inputName.promptText = GetTipI18n("System_Cdkey_Explain")
    self._textTip.text = GetTipI18n("System_Cdkey_Hint1", "#00CC00")
    self:SetTouchable(false)
end

function Rename:ShowValid()
    if self.from == CheckValidModel.From.PlayerRename then
        self:SetTouchable(false)
        self.last = self._inputName.text
        self:CheckValid(self.from, self._inputName, NAME_MIN_LIMIT, NAME_MAX_LIMIT, true)
    end
    if self.from == CheckValidModel.From.PlayerRedesc then
        self:SetTouchable(false)
        self.last = self._inputDesc.text
        self:CheckValid(self.from, self._inputDesc, DESC_MIN_LIMIT, DESC_MAX_LIMIT, true)
    end
    if self.from == CheckValidModel.From.BeautyRename then
        self:SetTouchable(false)
        self.last = self._inputName.text
        self:CheckValid(self.from, self._inputName, BEAUTY_NAME_MIN_LIMIT, BEAUTY_NAME_MAX_LIMIT, true)
    end
    --兑换码
    if self.from == CheckValidModel.From.CDKey then
        self.last = self._inputName.text
        local gbLen = Util.GetGBLength(self.last)
        self:SetTouchable(gbLen > 0)
        self._imageNo.visible = gbLen > 0
        if gbLen <= 0 then
            self:SetResetSDKey()
        end
    end
end

--检查名称是否合法
function Rename:CheckValid(from, textNode, min, max, sensitive)
    CheckValidModel.CheckName(
        from,
        textNode,
        min,
        max,
        sensitive,
        function(text, valid, invalidType)
            textNode.text = text
            self:ShowIsValid(valid)
            self._limit.text = NameWordsNumber(from, Util.GetGBLength(text), false)
            if valid then
                self:SetTouchable(true)
                --名称检查合法
                if from == CheckValidModel.From.PlayerRename then
                    --玩家改名
                    self._textTip.text = GetTipI18n("Ui_CommanderName_Tips", self.tipsColor)
                elseif from == CheckValidModel.From.PlayerRedesc then
                    --玩家修改宣言
                    self._textTip.text = GetTipI18n("Button_CommanderTips_ChangeTips", self.tipsColor)
                elseif from == CheckValidModel.From.BeautyRename then
                    --美女改名
                    self._textTip.text = GetTipI18n("girl_rename_desc", self.tipsColor)
                end
            else
                --检测不合法
                if from == CheckValidModel.From.PlayerRename then
                    --玩家改名
                    if invalidType == CheckValidModel.Invalid.Short then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips1", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Long then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips3", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Sensitive then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Sensitive_Tips", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Exist then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips2", self.tipsColor)
                    else
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips", self.tipsColor)
                    end
                elseif from == CheckValidModel.From.PlayerRedesc then
                    --玩家修改宣言
                    if invalidType == CheckValidModel.Invalid.Short then
                        self._textTip.text = GetTipI18n("Button_CommanderTips_ChangeFailed", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Long then
                        self._textTip.text = GetTipI18n("Button_CommanderTips_ChangeFailed2", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Sensitive then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Sensitive_Tips", self.tipsColor)
                    else
                        self._textTip.text = GetTipI18n("Button_CommanderTips_ChangeTips", self.tipsColor)
                    end
                elseif from == CheckValidModel.From.BeautyRename then
                    --美女改名
                    if invalidType == CheckValidModel.Invalid.Short then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips1", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Long then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Tips3", self.tipsColor)
                    elseif invalidType == CheckValidModel.Invalid.Sensitive then
                        self._textTip.text = GetTipI18n("Ui_CommanderName_Sensitive_Tips", self.tipsColor)
                    else
                        self._textTip.text = GetTipI18n("girl_rename_desc", self.tipsColor)
                    end
                end
            end
        end
    )
end

--点击修改
function Rename:OnBtnModifyClick()
    if self.from == CheckValidModel.From.PlayerRename then
        self:OnBtnModifyNameClick()
    end
    if self.from == CheckValidModel.From.PlayerRedesc then
        self:OnBtnModifyDescClick()
    end
    if self.from == CheckValidModel.From.BeautyRename then
        self:OnBtnModifyBeatyNameClick()
    end
    if self.from == CheckValidModel.From.CDKey then
        self:OnBtnModifyCDKeyClick()
    end
end

--点击 修改玩家名称
function Rename:OnBtnModifyNameClick()
    local modify_func = function()
        local name = self._inputName.text
        local net_func = function()
            Model.Player.Name = name
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
            TipUtil.TipById(50130)
            Event.Broadcast(EventDefines.UIRefreshBackpack)
            CuePointModel.CheckPlayerName(true)
            self:Close()
        end
        Net.UserInfo.ModifyUserName(name, net_func)
    end
    if self.free then
        --免费修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_CommanderName_Free"),
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        --钻石修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Button_CommanderName_changeTips"),
            gold = Global.ModifyUserNameCost,
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

--点击 修改玩家宣言
function Rename:OnBtnModifyDescClick()
    local modify_func = function()
        local desc = self._inputDesc.text
        local net_func = function()
            Model.Player.DeclareModified = true
            Model.Player.Declaration = desc
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
            TipUtil.TipById(50131)
            self:Close()
        end
        Net.UserInfo.ModifyUserDeclaration(desc, net_func)
    end
    if self.free then
        --免费修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_CommanderAka_Free"),
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        --修改过宣言 钻石修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "UI_CommanderTips_change"),
            gold = Global.ModifyUserDeclarationCost,
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

--点击 美女改名
function Rename:OnBtnModifyBeatyNameClick()
    local modify_func = function()
        local name = self._inputName.text
        local net_func = function()
            Event.Broadcast(EventDefines.RefreshGirlName, name)
            self.info.msg.NameChangeTimes = self.info.msg.NameChangeTimes + 1
            TipUtil.TipById(50130)
            self:Close()
        end
        Net.Beauties.ChangeName(self.info.id, name, net_func)
    end
    if self.free then
        --免费修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_CommanderName_Free"),
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        --钻石修改
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Button_hottieName_changeTips"),
            gold = Global.GirlNameChangeCost,
            sureCallback = modify_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end
--点击兑换礼包
function Rename:OnBtnModifyCDKeyClick()
    --本地检测兑换码的长度和字符是否符合格式
    if not CheckValidModel.CheckValidCDKey(self._inputName.text, CDKEY_MIN_LIMIT, CDKEY_MAX_LIMIT) then
        self._textTip.text = GetTipI18n("System_Cdkey_Hint2", "#FF3300")
        self:ShowIsValid(false)
        return
    end
    local desc = self._inputName.text
    ---发送消息
    GD.ItemAgent.UseCDKEY(desc,function(rsp)
        if rsp.Result == 0 and rsp.Rewards and #rsp.Rewards > 0 then
            self:Close()
            UIMgr:Open("BackpackPopup", rsp.Rewards, true)
        end
        if rsp.Result ~= 0 then
            local str =
                rsp.Result == 1 and "System_Cdkey_Hint2" or
                ((rsp.Result == 2 or rsp.Result == 3) and "System_Cdkey_Hint3" or "System_Cdkey_Hint4")
            self._textTip.text = GetTipI18n(str, "#FF3300")
            self:ShowIsValid(false)
        end
    end)
end

return Rename
