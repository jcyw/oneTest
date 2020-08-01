--[[
    Author: zixiao
    Function: 存放黑名单数据
]]--

local BlockListModel = {}
local BlockList = {}

function BlockListModel.Init()
	BlockListModel.GetBlockList()
end

function BlockListModel.AddToBlocklist(playerID, callback)
	Net.Chat.AddToBlockList(playerID, function (rsp)
		table.insert(BlockList, rsp.Info)
		if callback then
			callback(rsp)
		end
	end)
end

function BlockListModel.RemoveFromBlockList(playerID, callback)
	Net.Chat.RemoveFromBlockList(playerID, function (rsp)
		for i, v in ipairs(BlockList) do
			if playerID == v.UserId then
				table.remove(BlockList, i)
				break
			end
		end
		if callback then
			callback(rsp)
		end

	end)
end

function BlockListModel.GetBlockList(callback)
	Net.Chat.GetBlockList(function (rsp)
		BlockList = rsp.List or {}
		if callback then
			callback(rsp)
		end
	end)
end

function BlockListModel.IsInBlockList(playerID)
	for _, v in ipairs(BlockList) do
		if playerID == v.UserId then
			return true
		end
	end
	return false
end

function BlockListModel.GetList()
	return BlockList
end

return BlockListModel
