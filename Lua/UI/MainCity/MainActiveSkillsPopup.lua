--[[
    author:{maxiaolong}
    time:2019-11-01 10:30:56
    function:{主动技能弹窗}
]]
local MainActiveSkillsPopup = UIMgr:NewUI("MainActiveSkillsPopup")

function MainActiveSkillsPopup:OnInit()
    local view = self.Controller.contentPane
    self._btnUse = view:GetChild("btnUSE")
    self._btnTitle = self._btnUse:GetChild("title")
    self._title = view:GetChild("titleName")
    self._textDes = view:GetChild("textContent")
    self._icon = view:GetChild("icon")
    self._groupWarn = view:GetChild("groupWarn")
    self._bgMask = view:GetChild("bgMask")
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("MainActiveSkillsPopup")
        end
    )
    self:AddListener(self._btnUse.onClick,
        function()
             UIMgr:Close("MainActiveSkillsPopup")
        end
    )
    self._title.text = "技能"
    self._btnTitle.text = "使用"
    self._groupWarn.visible = false
end

function MainActiveSkillsPopup:OnOpen(param)
    
end

function MainActiveSkillsPopup:OnClose()
    -- UIMgr:Close("MainActiveSkillsPopup")
end

return MainActiveSkillsPopup
