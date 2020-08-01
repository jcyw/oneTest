-- author:{Amu}
-- time:2019-05-31 16:28:02

local exception

local function SqlCatch(query, e)
    -- print(string.format( "Exec end :  %d: %s", e, exception[e]))
    --暂时不抛出错误
    -- if e>1 then
    --     error(string.format( "Exec end :  %d: %s query error:%s", e, exception[e], query))
    -- end
end

if SqliteHelper then 
    return SqliteHelper 
end

local Sql = require("sqlite")

SqliteHelper = {}

SqliteHelper.connetPool = {}
local curSql = nil
local sqlExecutList = {}

function SqliteHelper:IsDbExist(dbName)
    local url = string.format( "%s/%s", KSUtil.GetPlatformUrl(), dbName)
    return (SqliteHelper.connetPool[url]~=nil) and true or false
end

--切换或者打开数据库前调用
function SqliteHelper:Open(dbName)
    local url = string.format( "%s/%s", KSUtil.GetPlatformUrl(), dbName)
    if not self.connetPool[url] then
        self.connetPool[url], errorCode, errorMsg  = Sql.open(url)
        if not self.connetPool[url] then
            Log.Error("Sqlite open failed, code: {0}, msg: {1}", errorCode, errorMsg)
        end
    end
    curSql = self.connetPool[url]
    return curSql
end

-- 执行
function SqliteHelper:Exec(query, callback)
    local e = curSql:exec(query, callback)
    SqlCatch(query, e)
    return e
end

local function _ExecNext()
    local _nextExec = table.remove(sqlExecutList, 1)
    if _nextExec then
        while _nextExec.flag > 0 do
            _nextExec.flag = _nextExec.flag - 1
            local e = SqliteHelper:Exec(_nextExec.query, _nextExec.callback)
            if e == 0 then
                _ExecNext()
                return
            end
        end
        _ExecNext()
    end
end

local function _nextExec()
    for i = #sqlExecutList, 1, -1 do
        local v = sqlExecutList[i]
        v.flag = v.flag - 1
        local e = SqliteHelper:Exec(v.query, v.callback)
        if e == 0 or v.flag <= 0 then
            table.remove(sqlExecutList, i)
        end
    end
end

-- 查询  返回一个table
function SqliteHelper:Query(query)
    local val = {}
    for v in curSql:nrows(query) do 
        table.insert(val, v)
    end
    return val
end

function SqliteHelper:IsTableExist(tableName)
    local temp = false
    local query = "SELECT COUNT(*) FROM SQLITE_MASTER WHERE TYPE= 'table' and name = "..tableName
    local log = self:Exec(query,
        function(udate, cols, values, names)
            temp = not(values[1] == "0")
            return 0
        end)

    return temp
end

function SqliteHelper:IsColumnExist(tableName, columnName)
    local query = string.format("SELECT COUNT(*) AS CNTREC FROM pragma_table_info(%s) WHERE name='%s'", tableName, columnName)
    query = string.format( "PRAGMA table_info(%s)", tableName)
    local info = self:Query(query)
    for _,v in ipairs(info)do
        if v.name == columnName then
            return true
        end
    end

    return false
end

function SqliteHelper:AddExecutQuery(query, flag, cb)
    -- 默认3次
    local flag = flag or 3
    local cb = cb or nil
    table.insert(sqlExecutList, {query = query, flag = flag, callback = cb})

    _nextExec()
end

function SqliteHelper:Close(dbName)
    local url = string.format( "%s/%s", KSUtil.GetPlatformUrl(), dbName)
    if  self.connetPool[url] ~= nil then
        self.connetPool[url]:close()
        self.connetPool[url] = nil
    else
        Log.Warning("==SqliteHelper:Close== DB can't  found ====")
    end
end

-- 返回值
-- OK: 0          ERROR: 1       INTERNAL: 2    PERM: 3        ABORT: 4
-- BUSY: 5        LOCKED: 6      NOMEM: 7       READONLY: 8    INTERRUPT: 9
-- IOERR: 10      CORRUPT: 11    NOTFOUND: 12   FULL: 13       CANTOPEN: 14
-- PROTOCOL: 15   EMPTY: 16      SCHEMA: 17     TOOBIG: 18     CONSTRAINT: 19
-- MISMATCH: 20   MISUSE: 21     NOLFS: 22      FORMAT: 24     RANGE: 25
-- NOTADB: 26     ROW: 100       DONE: 101
exception = {
    [0]     = "OK",
    [1]     = "ERROR",
    [2]     = "INTERNAL",
    [3]     = "PERM",
    [4]     = "ABORT",
    [5]     = "BUSY",
    [6]     = "LOCKED",
    [7]     = "NOMEM",
    [8]     = "READONLY",
    [9]     = "INTERRUPT",
    [10]    = "IOERR",
    [11]    = "CORRUPT",
    [12]    = "NOTFOUND",
    [13]    = "FULL",
    [14]    = "CANTOPEN",
    [15]    = "PROTOCOL",
    [16]    = "EMPTY",
    [17]    = "SCHEMA",
    [18]    = "TOOBIG",
    [19]    = "CONSTRAINT",
    [20]    = "MISMATCH",
    [21]    = "MISUSE",
    [22]    = "NOLFS",
    -- [23]    = "OK",
    [24]    = "FORMAT",
    [25]    = "RANGE",
    [26]    = "NOTADB",
    [100]   = "ROW",
    [101]   = "DONE"
}

return SqliteHelper