--[[
    author:{xiaosao}
    time:2020年3月27日
    function:{弹窗文字自适应}
        适用于所有带有textList组件的弹窗
]]
if ConfirmPopupTextUtil then
    return
end

local OneLINE_HIGHT = 35
local TwoLINE_HIGHT = 67 --两行文本高度
ConfirmPopupTextUtil = {}
function ConfirmPopupTextUtil.SetContent(minHight,maxHight,label,textString)
    local up = label:GetChild("up")
    local center = label:GetChild("center")
    --设置文本高度最低值
    label.height = minHight
    label.touchable = false

    center.text = textString
    if center.height <= minHight then
        --文本上下居中显示
        up.visible = false
        center.visible = true
        if center.height <= OneLINE_HIGHT or (center.height <= TwoLINE_HIGHT and string.find(textString,"\n")) then
            center.align = AlignType.Center
        else
            center.align = AlignType.Left
        end
        --center:SetPosition(0,label.height * 0.5 ,0)
    else
        --文本上对齐显示
        center.visible = false
        up.visible = true
        up.text = textString

        --设置文本高度
        if up.height > label.height then
            if up.height > maxHight then
                --设置文本高度最大值
                label.height = maxHight
                label.touchable = true
            else
                --文本自适应高度
                label.height = up.height
            end
        end
    end
end

function ConfirmPopupTextUtil.SetUpContent(maxHight,label,textString)
    local up = label:GetChild("up")
    local center = label:GetChild("center")
    label.touchable = false
    center.visible = false
    up.visible = true
    up.text = textString
    label.height = maxHight
    --设置文本高度
    if up.height > label.height then
        if up.height > maxHight then
            label.touchable = true
        else
            --文本自适应高度
            label.height = up.height
        end
    end
end

return ConfirmPopupTextUtil
