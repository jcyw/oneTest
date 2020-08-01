--[[
    author:{tiantian}
    time:2020/6/10
    function:{王城市政厅官员奴隶item}
]]
local ItemAppoint = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/ItemAppoint", ItemAppoint)

function ItemAppoint:ctor()
    self.controller = self:GetController("c1")
    self.controller.selectedIndex = 0
    self:InitEvent()
end
function ItemAppoint:InitEvent()
    self:AddListener(
        self._btnBox.onClick,
        function()
            -- 分配官员
            if _G.RoyalModel.GetAccountTitlePower(2) then
                RoyalModel.SetOfficialPositionId(self.data.id)
            end
            UIMgr:Open("OfficerPopUpBox",self.data)
        end
    )
end
function ItemAppoint:SetData(data)
    self.data = data
    local cfg = data
    local info = _G.RoyalModel.GetTitleInfoByTitleId(cfg.id)
    local power = _G.RoyalModel.GetAccountTitlePower(2) -- 自己是否有设置官职权限 有 true 否 false
    local officer = cfg.officer_event == 1 --官员 true 奴隶 false

    self._appoint.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, cfg.office_name)
    self.controller.selectedIndex = info and 2 or (officer and 0 or 1)
    if info then
        CommonModel.SetUserAvatar(self._icon, info.Avatar, info.PlayerId)
        self._name.text = (info.AllianceShortName == "" and "" or "(" .. info.AllianceShortName .. ")" ).. info.Name
    else
        self._name.text =
            power and "[color=#FFFF33]" .. _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Appoint") .. "[/Color]" or ""
    end
end
