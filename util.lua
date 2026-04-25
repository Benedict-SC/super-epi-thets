runlua = function(fpath)
	local func, errmsg = love.filesystem.load(fpath);
	if errmsg then
		error("path " .. fpath .. " loads nil??\nos: " .. love.system.getOS() .. "\nerrmsg: " .. errmsg);
	end
	func();
end
nilf = function()

end
signof = function(number)
	if number > 0 then return 1 elseif number < 0 then return -1 else return 0 end
end
round = function(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0);
	--debug_console_string_2 = "" .. mult;
	return math.floor(num * mult + 0.5) / mult;
end
logistic = function(percent,steepness)
	return 1 - (1/(1+math.exp(steepness*(percent-0.5))));
end
distance = function(p1,p2)
	local dx,dy = p2.x - p1.x, p2.y - p1.y;
	return math.sqrt((dx*dx)+(dy*dy));
end
shallowcopy = function(orig)
    local orig_type = type(orig);
    local copy;
    if orig_type == 'table' then
        copy = {};
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value;
        end
    else -- number, string, boolean, etc
        copy = orig;
    end
    return copy;
end
splitSpaces = function(str,preserveEnds)
	local tokens = Array();
	for token in string.gmatch(str, "%S+") do
		tokens.push(token);
	end
	if preserveEnds and tokens[1] then 
		if str:sub(1,1) == " " then
			tokens[1] = " " .. tokens[1];
		end
		if str:sub(#str,#str) == " " and #tokens > 0 then
			tokens[#tokens] = tokens[#tokens].." ";
		end
	end
	return tokens;
end
countWords = function(str)
	local num = 0;
	for token in string.gmatch(str, "%S+") do
		num = num + 1;
	end
	return num;
end
capitalize = function(str)
	if #str == 1 then 
		return str:upper();
	elseif #str == 0 then
		return str;
	else
		return str:sub(1,1):upper() .. str:sub(2); 
	end
end
trimSpaces = function(str)
	str = trimLeadingSpaces(str);
	while str:sub(#str,#str) == " " do
		str = str:sub(1,#str-1);
	end
	return str;
end
trim = function(str)
	-- from PiL2 20.4
	return str:gsub("^%s*(.-)%s*$", "%1");
end
trimLeadingSpaces = function(str)
	while str:sub(1,1) == " " do
		str = str:sub(2);
	end
	return str;
end
subArray = function(array,startIndex,length)
	startIndex = startIndex or 1;
	maxIndex = startIndex - 1 + length;
	local subarray = Array();
	if maxIndex > #array then maxIndex = #array; end
	for i=startIndex,maxIndex,1 do
		subarray.push(array[i]);
	end
	return subarray;
end
contains = function(array,value)
	for i=1,#array,1 do
		if array[i] == value then return true; end
	end
	return false;
end
indexNames = function(tabl)
	for i=1,#tabl,1 do
		local obj = tabl[i];
		if obj.name then
			tabl[obj.name] = obj;
		end
	end
end
indexByVarName = function(tabl,name)
	for i=1,#tabl,1 do
		local obj = tabl[i];
		if obj[name] then
			tabl[obj[name]] = obj;
		end
	end
end
Array = function(...)
	local arr = {};
	local argnum = select("#",...);
	if argnum > 0 then
		for i = 1, argnum do
			arr[i] = select(i,...);
		end
	end
	arr.size = function()
		return #arr;
	end
	arr.push = function(el)
		arr[(#arr + 1)] = el;
	end
	arr.setAdd = function(el)
		if not (arr.contains(el)) then
			arr.push(el);
		end
	end
	arr.pop = function()
		local initsize = #arr;
		local val = table.remove(arr,#arr);
		if #arr >= initsize then error("failed to reduce size") end
		--local val = arr[arr.size];
		--arr[arr.size] = nil;
		return val;
	end
	arr.peek = function()
		if #arr < 1 then return nil; end
		return arr[#arr];
	end
	arr.insert = function(element,index)
		local i = #arr + 1;
		while i > index do
			arr[i] = arr[i-1];
			i = i - 1;
		end
		arr[index] = element;
	end
	arr.contains = function (element)
		for i=1,#arr,1 do 
			if arr[i] == element then return true; end
		end
		return false;
	end
	arr.indexOf = function(element)
		for i=1,#arr,1 do 
			if arr[i] == element then return i end
		end
		return -1;
	end
	arr.remove = function(index)
		local element = table.remove(arr,index);
		return element;
	end
	arr.removeElement = function(element)
		local idx = arr.indexOf(element);
		if idx == -1 then
			return nil;
		end
		return arr.remove(idx);
	end
	arr.forEach = function(func) --function takes one argument- the array element
		for i=1,#arr,1 do
			func(arr[i]);
		end
	end
	arr.filter = function(func)
		local nArr = Array();
		arr.forEach(function(el) 
			if func(el) then
				nArr.push(el);
			end
		end);
		return nArr;
	end
    arr.concat = function(arr2)
        local nArr = Array();
        for i=1,#arr,1 do
            nArr.push(arr[i]);
        end
        for i=1,#arr2,1 do
            nArr.push(arr2[i]);
        end
        return nArr;
    end
	arr.spacedList = function()
		local stri = "";
		for i=1,#arr,1 do
			stri = stri .. arr[i] .. ",\n";
		end
		return stri;
	end
	return arr;
end
ArrayFromRawArray = function(array)
	local arr = Array();
	if not array then
		return arr;
	end
	for i=1,#(array),1 do
		arr.push(array[i]);
	end
	return arr;
end
colorStack = Array();
pushColor = function()
	local r,g,b,a = love.graphics.getColor();
	local col = {r=r,g=g,b=b,a=a};
	colorStack.push(col);
end
popColor = function()
    if (#colorStack >= 1) then
	    local col = colorStack.pop();
	    love.graphics.setColor(col.r,col.g,col.b,col.a);
    else
        love.graphics.setColor(1,1,1);
    end
end
printInColor = function(str,x,y,r,g,b,a)
	pushColor();
	love.graphics.setColor(r or 1,g or 1,b or 1,a or 1);
	love.graphics.setShader(textColorShader);
	love.graphics.print(str,x,y);
	love.graphics.setShader();
	popColor();
end