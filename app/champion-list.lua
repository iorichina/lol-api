local ngx       = ngx;
local type      = type;
local pairs     = pairs;
local tostring  = tostring;
local ipairs    = ipairs;
local print     = ngx.print;
-- local getmetatable  = getmetatable;
-- local model = require ('model.AppLuaIo');
-- local table = table;
-- local setmetatable = setmetatable;
local cjson         = require('cjson');
local redis         = require('model.redis');
local debug_print   = require('model.util').debug_print;
local println       = require('model.util').println;

--[[ init module --]]
module(...);
--[[ indexed by current module env. --]]
-- local mt = {__index = _M};

--[[ instantiation ]]
-- function new(self)
--     local set = {};
--     setmetatable(set, mt);
--     return set;
-- end

-- local mydb = {
--     ['database'] = 'app_lua_io',
--     ['host'] = '127.0.0.1',
--     ['port'] = 3306,
--     ['charset'] = "utf8",
--     ['user'] = 'root',
--     ['password'] = ''
-- };

-- local tb_test = model:new({
--     ['config'] = mydb
--     });
function run ()
    local rds   = redis:client(1);
    local key   = "lol:champions:en:z:champion:list";
    -- println('get "lol:champions:en:z:champion:list":');
    local res   = rds:zrange(key, 0, -1, 'WITHSCORES');
    print_api_list( res );
    -- local rev   = rds:zrevrange(key, 0, 5, 'WITHSCORES');
    -- print_list( rev );
end

function print_api_list(res)
    if not res or not res.scores then
        return;
    end
    local json  = {};
    for i,v in ipairs(res.scores) do
        json[v] = res.members[i];
    end

    local max_age   = 60 * 60 * 24;
    ngx.header['Content-Type']  = 'application/json; charset=utf-8';
    ngx.header['Expires']       = ngx.http_time( ngx.time() + max_age );
    ngx.header["Cache-Control"] = "max-age=" .. max_age;
    print(cjson.encode(json));
end

function print_list(res) 
    if not res or not res.scores then
        return;
    end
    for i,v in ipairs(res.scores) do
        println(v, '=', res.members[i]);
    end
end


--[[ to prevent use of casual module global variables --]]
-- setmetatable(_M, {
--     __newindex = function (table, key, val)
--         log('attempt to write to undeclared variable "' .. key .. '" in ' .. table._NAME);
--     end
-- });
