local ngx           = ngx;
local type          = type;
local pairs         = pairs;
local tostring      = tostring;
local string        = string;
local ipairs        = ipairs;
local print         = ngx.print;
local cjson         = require('cjson');
local redis         = require('model.redis');
local debug_print   = require('model.util').debug_print;
local println       = require('model.util').println;

--[[ init module --]]
module(...);
--[[ indexed by current module env. --]]
function run ()
    local name  = ngx.var.arg_name;
    if not name then
        ngx.header['App-Info'] = 'params[name:'..ngx.var.arg_name..'] error';
        local max_age   = 60 * 60 * 24;
        ngx.header['Content-Type']  = 'application/json; charset=utf-8';
        ngx.header['Expires']       = ngx.http_time( ngx.time() + max_age );
        ngx.header["Cache-Control"] = "max-age=" .. max_age;
        print(cjson.encode({}));
        ngx.exit(ngx.OK);
    end
    local rds   = redis:client(1);
    local key   = "lol:champions:en:h:champion:data:";
    local res   = rds:hgetall(key .. name);
    print_api_data( res );
end

function print_api_data(res)
    if not res then
        return;
    end
    for p,v in pairs(res) do
        if p=="image" or p=="stats" then
            res[p]  = cjson.decode(v);
        end
        if p=="tags" then
            local i = 1;
            res[p]  = {};
            for tag in string.gmatch(v, "%w+") do
                res[p][i] = tag;
                i   = i + 1;
            end
        end
    end

    local max_age   = 60 * 60 * 24;
    ngx.header['Content-Type']  = 'application/json; charset=utf-8';
    ngx.header['Expires']       = ngx.http_time( ngx.time() + max_age );
    ngx.header["Cache-Control"] = "max-age=" .. max_age;
        ngx.header['Content-Type']  = 'application/json; charset=utf-8';
        ngx.header['Expires']       = ngx.http_time( ngx.time() - 100000 );
        ngx.header["Cache-Control"] = "no-cache";
    print(cjson.encode(res));
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
