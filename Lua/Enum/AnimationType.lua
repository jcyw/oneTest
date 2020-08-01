if AnimationType then
    return AnimationType
end

AnimationType = {
    --------------------------------------------- 面板打开、关闭动画
    PanelScaleOpen = "PanelScaleOpen", --面板打开缩放动画
    PanelScaleClose = "PanelScaleClose", --面板关闭缩放动画
    PanelMoveUp = "PanelMoveUp", --面板向上移动动画 [打开邮件]
    PanelMovePreUp = "PanelMovePreUp", --面板向上移动动画 (移动到(0,0))[VIP]
    PanelMoveDown = "PanelMoveDown", --面板向下移动动画
    PanelMovePreDown = "PanelMovePreDown", --面板向下移动动画(移动到(0,0))[VIP]
    PanelMoveLeft = "PanelMoveLeft", --面板向左移动动画
    PanelMovePreLeft = "PanelMovePreLeft", --面板向左移动动画(移动到(-distance,0)) [邮件、联盟]
    PanelMoveRight = "PanelMoveRight", --面板向右移动动画
    PanelMovePreRight = "PanelMovePreRight", --面板向右移动动画(移动到(0,0)) [邮件、联盟]
    ActiveSkills = "ActiveSkills", --面板向上、下移动 [技能]

    UILeftToRight = "UILeftToRight", --UI左向右动
    UIRightToLeft = "UIRightToLeft", --UI右向左动
    UITopToDown = "UITopToDown", --UI上向下动
    UIDownToTop = "UITopToDown", --UI下向上动
    UIDownToTopBox = "UITopToDown", --UI下向上动(一排多个)
}

return AnimationType
