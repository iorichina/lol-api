local redis         = require ('lib.redis');
local type          = type;
local ipairs        = ipairs;
local setmetatable  = setmetatable;
local getmetatable  = getmetatable;
local print         = ngx.print;
local crc32_short   = ngx.crc32_short;
local _rds          = {};
local debug_print   = require('model.util').debug_print;
local println       = require('model.util').println;
--[[ error logging --]]
local g                     = require('lib.g')
local log                   = g.log

local _config       = {
    {host = "172.19.16.82", port = 6380, connect_timeout = 100, db = 1}
};

--[[ 
@desc init static module
--]]
module(...);

--[[
@params string   flag  flag for calculate the id of server
--]]
function client(self, flag)
    flag                = flag and flag or '1';
    local rdsConfigs    = _config;
    local rds           = {};
    -- setmetatable(rds, mt);
    if type(rdsConfigs) == 'table' and #rdsConfigs > 0 then
        local seed      = #rdsConfigs;
        local hashId    = crc32_short('' .. flag) % seed + 1;

        for i,c in ipairs(rdsConfigs) do
            if i == hashId then
                if _rds[i] then
                    rds = _rds[i];
                else
                    rds = redis:new(c);
                    --[[
                    继承lib.redis
                    --]]
                    setmetatable(self, {__index = rds});
                    --[[ 缓存起来防止重复创建 --]]
                    _rds[i] = self
                end
                break;
            end
        end
    end
    return self;
end
--[[
重写connect方法，增加select指定db的功能
--]]
function connect(self)
    local connected     = redis.connect(self);
    if self.cfg.db then
        local rs, err   = self.rds:select(self.cfg.db);
        if not rs then
            log('redis select db failure');
        end
    end
    return connected;
end

--[[
zrange
]]
function zrange(self, ... )
    local rev   = self:zrevrange( ... );
    local res   = {};
    if rev and type(rev) == 'table' then
        if rev.scores then
            local len   = #rev.members + 1;
            res.members = {};
            for i,v in ipairs(rev.members) do
                res.members[len -i] = v;
            end

            len   = #rev.scores + 1;
            res.scores = {};
            for i,v in ipairs(rev.scores) do
                res.scores[len -i] = v;
            end
        else
            local len   = #rev + 1;
            for i,v in ipairs(rev) do
                res[len -i] = v;
            end
        end
    end
    return (res.scores or #res > 0) and res or nil;
end

function hgetall(self, ... )
    local res   = redis.hgetall(self, ... );
    local rs    = {};
    if res and #res > 0 then
        local len   = #res + 1;
        for i,v in ipairs(res) do
            if i % 2 == 1 then
                rs[v]   = res[i+1];
            end
        end
    end
    return rs;
end