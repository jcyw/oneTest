--author: 	Amu
--time:		2019-12-14 17:11:14

local NetLoading = UIMgr:NewUI("NetLoading")

function NetLoading:OnInit()
    local view = self.Controller.contentPane


    self:AddEvent(EventDefines.ReLoginSuccess, function()
        UIMgr:Close( 'NetLoading')            
    end)

    self:AddEvent(EventDefines.CloseNetLoading, function()
        UIMgr:Close( 'NetLoading')            
    end)
end

return NetLoading