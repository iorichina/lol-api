local ngx           = ngx;
local type          = type;
local pairs         = pairs;
local tostring      = tostring;
module(...);

--[[ for debuging --]]
function debug_print(tbData)
    if (type(tbData) == 'string') then
        ngx.print(tbData, "\n");
    elseif (type(tbData) == 'table') then
        for k,v in pairs(tbData) do
            ngx.print(k .. ' : ' .. tostring(v), "\n");
        end
    else
        println(tbData);
    end
end

function println(...)
    ngx.print(...);
    ngx.print("\n");
end