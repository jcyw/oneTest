--[[
    author:{zhanzhang}
    time:2019-11-08 15:44:01
    function:{跳转页面Item}
]]
local ItemAccessWay = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemAccessWay", ItemAccessWay)

local JumpMap = import("Model/JumpMap")

function ItemAccessWay:ctor()
    self._icon = self:GetChild("icon"):GetChild("_icon")
    self._title = self:GetChild("title")
    self._btn = self:GetChild("btn")

    self._iconCom = self:GetChild("icon")
    if self._iconCom:GetChild("_amountMid").text == "" then
        self._iconCom:GetChild("_numBg").visible = false
    else
        self._iconCom:GetChild("_numBg").visible = true
    end
    
    self:AddListener(self._btn.onClick,
        function()
            self:OnBtnJumpClick()
        end
    )
end

function ItemAccessWay:Init(config, index, cb)
    self.config = config
    self.index = index
    self.cb = cb
    local info = ConfigMgr.GetItem("configGetmoreIDs", config.getid[index])

    if(self.config.jump[self.index].jump == 0) then
        self._btn.visible = false
    end
    self._iconCom:SetShowData(info.icon)
    --self._icon.icon =  UITool.GetIcon(info.icon)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, info.key)
end

function ItemAccessWay:OnBtnJumpClick()
    local configInfo = self.config.jump[self.index]
    JumpMap:JumpTo({jump = configInfo.jump, para = configInfo.para})
    if self.cb then
        self.cb()
    end
    UIMgr:Close("AccessWay")
end

return ItemAccessWay
