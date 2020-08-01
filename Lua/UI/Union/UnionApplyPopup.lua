--[[
    Author: songzeming
    Function: 申请联盟弹窗
]]
local UnionApplyPopup = UIMgr:NewUI("UnionApplyPopup")

function UnionApplyPopup:OnInit()
    self:AddListener(self._btnSend.onClick,
        function()
            self:Apply()
        end
    )
    self:AddListener(self._btnSendNo.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
end

function UnionApplyPopup:OnOpen(allianceId, cb)
    self.allianceId = allianceId
    self.cb = cb

    self._textInput.text = ""
end

--发送申请联盟请求
function UnionApplyPopup:Apply()
    Net.Alliances.ApplyJoin(
        self.allianceId,
        self._textInput.text,
        function(rsp)
            self.cb(rsp)
            self:Close()
        end
    )
end

function UnionApplyPopup:Close()
    UIMgr:Close("UnionApplyPopup")
end

return UnionApplyPopup
