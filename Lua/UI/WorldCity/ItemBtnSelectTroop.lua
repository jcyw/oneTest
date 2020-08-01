--[[
    author:{zhanzhang}
    time:2019-06-14 16:46:29
    function:{选择编队按钮}
]]
local ItemBtnSelectTroop = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnTroopsGroup", ItemBtnSelectTroop)

local VIPModel = import("Model/VIPModel")  

function ItemBtnSelectTroop:ctor()
    self._controller = self:GetController("c1")
    self.btnTeams = {
        {obj = self._btnTeam1, vip = nil}, 
        {obj = self._btnTeam2, vip = nil},
        {obj = self._btnTeam3, vip = nil},
        {obj = self._btnTeam4, vip = nil}
    }

    self:InitTeamButton()
end

-- cb返回选择队伍的编号，队伍内容，队伍名字
function ItemBtnSelectTroop:Init(index, isHide, cb)
    self.cb = cb
    self.curTeam = 0
    self.isHide = isHide
    self:RefreshTeamButton()

    if index then
        self.curTeam = index
        self.curFormation = (Model.Formations and Model.Formations[self.curTeam]) and Model.Formations[self.curTeam] or nil
        self.btnTeams[index].obj.selected = true
    end
end

function ItemBtnSelectTroop:SelectedBtn(index)
    if index > 0 and index <= #self.btnTeams then
        self.curTeam = index
        self.btnTeams[index].obj.selected = true
    else
        self.curTeam = 0
        self._controller.selectedPage = "none"
    end
end

function ItemBtnSelectTroop:InitTeamButton( )
    local index = 0
    for _,v in pairs(self.btnTeams) do
        index = index + 1
        func = function (cur)
            self:AddListener(v.obj.onClick,function()
                if v.vip ~= nil and v.vip <= VIPModel.GetVipLevel() and VIPModel.GetVipActivated() then
                    self.curTeam = cur
                    self.curFormation = (Model.Formations and Model.Formations[cur]) and Model.Formations[cur] or nil
                    local name = self.curFormation and self.curFormation.FormName or StringUtil.GetI18n(I18nType.Commmon, "FOMATION_DEFAULT_"..cur)
                    if self.cb then
                        self.cb(cur, self.curFormation, name)
                    end
                elseif v.vip == nil then
                    TipUtil.TipById(50193)
                    if self.curTeam > 0 then
                        self.btnTeams[self.curTeam].obj.selected = true
                    else
                        self._controller.selectedPage = "none"
                    end
                else
                    local data = {
                        content = StringUtil.GetI18n(I18nType.Commmon, "FOMATION_UNLOCK_VIP", {number = v.vip}),
                        sureCallback = function()
                            Net.Vip.GetVipInfo(function(msg)
                                UIMgr:Open("VIPMain", msg)
                            end)
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                    if self.btnTeams[self.curTeam] then
                        self.btnTeams[self.curTeam].obj.selected = true
                    else
                        self._controller.selectedPage = "none"
                    end
                end
            end)
        end
        func(index)
    end
end

function ItemBtnSelectTroop:RefreshTeamButton()
    for _,v in pairs(self.btnTeams) do
        if self.isHide then
            v.obj.visible = false
        end
        v.obj:GetChild("Lock").visible = true
        v.obj:GetChild("icon").visible = false
        v.obj:GetChild("title").color = Color(0.71, 0.72, 0.73)
        v.obj.selected = false
        v.vip = nil
    end

    local proList = VIPModel.GetProListByAttr(Global.MovementPresetTroops)
    local curValue = 0
    for _,v in pairs(proList) do
        if v.value > curValue then
            curValue = v.value
            local index = curValue > #self.btnTeams and #self.btnTeams or curValue
            for i=1, index do
                self.btnTeams[i].vip = v.vip
            end
        end
    end

    if VIPModel.GetVipActivated() then
        local num = VIPModel.GetCurLevelProByAttr(Global.MovementPresetTroops)
        if num then
            for i=1, num do
                if i <= #self.btnTeams then
                    self.btnTeams[i].obj.visible = true
                    self.btnTeams[i].obj:GetChild("Lock").visible = false
                    self.btnTeams[i].obj:GetChild("icon").visible = true
                    self.btnTeams[i].obj:GetChild("title").color = Color.white
                end
            end
            -- self.btnTeams[1].obj.selected = true
        end
    end
end

return ItemBtnSelectTroop
