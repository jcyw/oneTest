--[[
    author:Temmie
    time:2019-09-07 16:39:40
    function:编队改名
]]
local FormationRename = UIMgr:NewUI("FormationRename")
FormationRename.limit = 16

function FormationRename:OnInit()
    self:AddListener(self._textRename.onFocusIn,function()
        self._textTip.visible = false
    end)

    self:AddListener(self._textRename.onFocusOut,function()
        if self._textRename.text == "" then
            self._textTip.visible = true
        else
            self._textRename.text = Util.GetStringByLimit(self._textRename.text, FormationRename.limit)
        end
    end)

    self:AddListener(self._textRename.onChanged,function()
        self._textTip.visible = false
        self._textRename.text = Util.GetStringByLimit(self._textRename.text, FormationRename.limit)

        --if string.sub(self._textRename.text, 1, 1) == " " then
        --    self._textRename.text = ""
        --end
        --
        --if string.len(self._textRename.text) > FormationRename.limit then
        --    --self._textRename.text = StringUtil:Utf8LimitOfByte(self._textRename.text, FormationRename.limit)
        --    self._textRename.text = Util.GetStringByLimit(self._textRename.text, FormationRename.limit)
        --end
    end)

    self:AddListener(self._btnConfirm.onClick,function()

        if Model.Formations and Model.Formations[self.teamIndex] then
            Net.Armies.ModifyFormationName(self.teamIndex, self._textRename.text, function(rsp)
                if rsp.Fail then
                    return
                end
    
                local name = self._textRename.text
                Model.Formations[self.teamIndex].FormName = name
    
                if self.cb and name ~= "" then
                    self.cb(name)
                end
        
                UIMgr:Close("FormationRename")
            end)
        else
            local data = {
                FormId = self.teamIndex,
                FormName = self._textRename.text,
                Armies = {}
            }
            Net.Armies.Formation({data}, function(rsp)
                if rsp.Fail then
                    return
                end
    
                Model.Create(ModelType.Formations, data.FormId, data)
                
                if self.cb and self._textRename.text ~= "" then
                    self.cb(self._textRename.text)
                end

                UIMgr:Close("FormationRename")
            end)
        end
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("FormationRename")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("FormationRename")
    end)
end

function FormationRename:OnOpen(name, teamIndex, cb)
    self.cb = cb
    self.teamIndex = teamIndex
    if name then
        self._textRename.text = name
        self._textTip.visible = false
    else
        self._textRename.text = ""
        self._textTip.visible = true
    end
end

return FormationRename