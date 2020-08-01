function class(super, ...)
    assert(super ~= nil)
    local cls = setmetatable({}, {__index = super})
    cls._super = super
    function cls.new(...)
        return new(cls, ...)
    end
    return cls
end

-- simple new table to a object
function new(cls, ...)
    assert(cls ~= nil)
    local ins = setmetatable({}, {__index = cls})
    if cls.ctor then
        ins:ctor(...)
    end
    return ins
end

function setpeer(csobj, state)
    local csobj_mt = getmetatable(csobj)
    for k, v in pairs(csobj_mt) do
        rawset(state, k, v)
    end
    local csobj_index, csobj_newindex = state.__index, state.__newindex
    state.__index = function(obj, k)
        if state[k] ~= nil then
            return state[k]
        end
        return csobj_index(obj, k)
    end
    state.__newindex = function(obj, k, v)
        if csobj_index(obj, k) ~= nil then
            csobj_newindex(obj, k, v)
        else
            rawset(state, k, v)
        end
    end
    debug.setmetatable(csobj, state)
    state._userdate = csobj
    return state
end

function extension_class(csclass)
    local Register = import("Common/Register")
    local o = setmetatable({}, {__index = Register})
    o.__index = o
    o._super = Register
    o.base = csclass
    o.Extend = function(ins, url)
        local t = {}
        setmetatable(t, o)
        setpeer(ins, t)
        ins:InitRegister(url)
        return t
    end
    return o
end

--输出日志--
function log(str)
    Util.Log(str);
end

--错误日志--
function logError(str)
	Util.LogError(str);
end

--警告日志--
function logWarn(str)
	Util.LogWarning(str);
end

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
	GameObject.Destroy(obj);
end

function newObject(prefab)
	return GameObject.Instantiate(prefab);
end

--创建面板--
function createPanel(name)
	PanelManager:CreatePanel(name);
end

function child(str)
	return transform:FindChild(str);
end

function subGet(childNode, typeName)
	return child(childNode):GetComponent(typeName);
end

function findPanel(str)
	local obj = find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua");
end
--[[
function dump(a, ...)
    if type(a) == "table" then
        print(table.inspect(a))
    else
        print(a, ...)
    end
end
--]]