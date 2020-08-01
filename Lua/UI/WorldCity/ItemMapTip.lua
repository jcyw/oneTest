--[[
    author:{zhanzhang}
    time:2019-12-12 19:11:23
    function:{缩略图浮标}
]]
local ItemMapTip = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/mapTip", ItemMapTip)

---BuildSelectTip   环状操作列表item
function ItemMapTip:ctor()
    self.tipIcon = self:GetChild("tipIcon")
    self:AddListener(self.tipIcon.onClick,
        function()
            if self.cb then
                self.cb()
            end
        end
    )
end

function ItemMapTip:Init(resName,cb)
    self.tipIcon.icon = UIPackage.GetItemURL("WorldCity", resName)

    self.cb = cb
end

return ItemMapTip
