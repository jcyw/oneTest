--[[
    author:{author}
    time:2020-04-21 15:57:25
    function:{desc}
]]
local GD = _G.GD
local MilitarySuppliesIconEffect = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/MilitarySuppliesIconEffect", MilitarySuppliesIconEffect)

local amount = 7

function MilitarySuppliesIconEffect:ctor()
    self.anim = self:GetTransition("anim")
    self.icons = {}
    for i=1,amount do
        table.insert(self.icons, self:GetChild("_icon"..i))
    end
end

function MilitarySuppliesIconEffect:Init(pos, category, cb)
    local curPos
    if pos then
        curPos = self:GlobalToLocal(pos)
    end
    local img = GD.ResAgent.GetIcon(category)

    for _,v in pairs(self.icons) do
        v.url = UITool.GetIcon(img)
    end

    self.anim:Play(function()
        for k,v in pairs(self.icons) do
            if curPos then
                self:GtweenOnComplete(v:TweenMove(curPos, 0.2):SetDelay(k*0.1),function()
                    v.alpha = 0
                    if k == amount and cb then
                        cb()
                    end
                end)
            else
                v.alpha = 0
                if k == amount and cb then
                    cb()
                end
            end
        end
    end)
end

return MilitarySuppliesIconEffect
