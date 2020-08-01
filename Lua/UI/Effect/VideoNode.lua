--[[
    Author: songzeming
    Function: 视频播放
]]
local VideoNode = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/VideoNode", VideoNode)

function VideoNode:ctor()
    self._icon = self:GetChild("icon")
    self.width = GRoot.inst.width
    self.height = GRoot.inst.height
end

function VideoNode:PlayVideo(nTexture2D)
    self._icon.image.texture = nTexture2D
end

return VideoNode
