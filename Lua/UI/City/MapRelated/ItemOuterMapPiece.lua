--[[
    Author: songzeming
    Function: 地图空白按钮 点击创建建筑 城外
]]
local ItemOuterMapPiece = fgui.extension_class(GComponent)
fgui.register_extension("ui://City/pieceOuter", ItemOuterMapPiece)

local BuildModel = import("Model/BuildModel")

function ItemOuterMapPiece:ctor()
    self:AddListener(self.onClick,function()
        self:OnBtnPieceClick()
    end)

    self:SetPieceBuild(false)
    self:SetMoveState(false)
end

--初始化地图块
function ItemOuterMapPiece:InitPiece(pos, cb)
    self.goalpos = pos
    self.cb = cb
end

--设置地图块移动起始位置
function ItemOuterMapPiece:SetStartPiecePos(pos)
    self.oldpos = pos
end

--是否显示移动效果
function ItemOuterMapPiece:SetMoveState(flag)
    self._move.visible = flag
end
--设置地图块颜色显示
function ItemOuterMapPiece:SetMoveStateColor(flag)
    self._move.color = flag and Color.green or Color.red
end

--是否可触摸
function ItemOuterMapPiece:SetPieceTouch(flag)
    self.touchable = flag
end

--是否显示地图按钮
function ItemOuterMapPiece:SetPieceActive(flag)
    self.visible = flag
end
function ItemOuterMapPiece:GetPieceActive()
    return self.visible
end

--地图渐显/渐隐
function ItemOuterMapPiece:SetPieceFade(isShow, time)
    if not time then
        time = 1
    end
    if isShow then
        self:SetPieceActive(true)
        self.alpha = 0
        self:TweenFade(1, time)
    else
        self:SetPieceActive(true)
        self.alpha = 1
        self:TweenFade(0, time)
    end
end

--地图块是否有建筑
function ItemOuterMapPiece:SetPieceBuild(flag)
    self.isBuild = flag
    self:SetPieceActive(not flag)
end
function ItemOuterMapPiece:GetPieceBuild()
    return self.isBuild
end

--设置位置是否解锁
function ItemOuterMapPiece:SetPieceUnlock(flag)
    self.isUnlock = flag
end
function ItemOuterMapPiece:GetPieceUnlock()
    return self.isUnlock
end

--获取地图块的位置
function ItemOuterMapPiece:GetPiecePos()
    return self.goalpos
end

--点击地图块
function ItemOuterMapPiece:OnBtnPieceClick()
    if not CityType.BUILD_MOVE_TIP then
        self.cb()
        return
    end
    if not self.oldpos then
        return
    end
    local move_func = function()
        Net.Buildings.Move(self.oldpos, self.goalpos, function()
            CityType.BUILD_MOVE_POS = nil
            local building = BuildModel.FindByPos(self.oldpos)
            building.Pos = self.goalpos
            local node = BuildModel.GetObject(building.Id)
            node:SetXY(self.x, self.y)
            node:ResetPos()
            node:UpdateBuilding(building)
            self:SetPieceBuild(true)
            self.parent:GetMapPiece(self.oldpos):SetPieceBuild(false)
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
        end)
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_MOVE_BUILDING"),
        sureCallback = move_func
    }
    UIMgr:Open("ConfirmPopupText", data)
end

return ItemOuterMapPiece
