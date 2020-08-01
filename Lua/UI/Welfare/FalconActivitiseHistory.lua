--[[
    author:{maxiaolong}
    time:2019-10-24 16:28:48
    function:{活动奖励弹窗列表元素}
]]
local FalconActivitiseHistory = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/FalconActivitiseHistory", FalconActivitiseHistory)

function FalconActivitiseHistory:ctor()

end

function FalconActivitiseHistory:SetData(udid,MailId,index,content,timer)
    self.udid = udid
    self.MailId = MailId
    self._indexText.text = index
    self._contentText.text = content
    self._timeText.text = timer
    self.params = JSON.encode(self.MailId)
end

return FalconActivitiseHistory
