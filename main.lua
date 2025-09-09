local state = ya.sync(function()
	local selected = {}
	for _, url in pairs(cx.active.selected) do
		selected[#selected + 1] = url
	end
	return cx.active.current.cwd, selected
end)

local function split_urls(cwd, output)
	if not output or output == "" then return {} end

	local t = {}
	for line in output:gmatch("[^\r\n]+") do
		if line ~= "" then
			-- Get everything before first colon, or entire line if no colon
		local file = line:find("\xC2\xA0") and line:sub(1, line:find("\xC2\xA0") - 1) or line
	
			if file and file ~= "" then
				local u = Url(file)
				if u.is_absolute then
					t[#t + 1] = u
				else
					t[#t + 1] = cwd:join(u)
				end
			end
		end
	end
	return t
end

local function run_with(cwd, selected, script_name)
	local script_path = os.getenv("HOME") .. "/.config/yazi/plugins/fazif.yazi/" .. script_name

	local sepaths = {}
	if #selected > 0 then
		for _, u in ipairs(selected) do
			table.insert(sepaths, tostring(u))
		end
	end

	local child
	if #selected == 0 then
		child = Command(script_path):cwd(tostring(cwd)):stdin(Command.INHERIT):stdout(Command.PIPED):spawn()
	else
		child = Command(script_path):arg(sepaths):stdout(Command.PIPED):spawn()
	end

	if not child then
		return nil, "Failed to start script"
	end

	local output, err = child:wait_with_output()
	if not output then
		return nil, "Cannot read output: " .. tostring(err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, "Script exited with code " .. tostring(output.status.code)
	end
	return output.stdout, nil
end

local function entry(_, job)
	local script_name = job.args[1]
	
	local permit = ya.hide()
	local cwd, selected = state()

	local output, err = run_with(cwd, selected, script_name)

	if permit then
		permit:drop()
	end

	if not output then
		return ya.notify { title = "Fazif", content = tostring(err), timeout = 5, level = "error" }
	end

	local urls = split_urls(cwd, output)
	if #urls == 0 then
		return
	elseif #urls == 1 then
		ya.emit("tab_create", {})
		ya.emit(fs.cha(urls[1]).is_dir and "cd" or "reveal", { urls[1], raw = true })
    else
        ya.emit("tab_create", {})
        local id = ya.id("ft")
        local virtual_cwd = cwd:into_search("FZF Results")
        ya.emit("cd", { Url(virtual_cwd) })
        ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(virtual_cwd), files = {} }) })

        local files = {}
        for i = 1, #urls do
            local url = urls[i]
            local cha = fs.cha(url, true)
            if cha then
                files[#files + 1] = File { url = url, cha = cha }
            else
                files[#files + 1] = File { url = url }
            end
        end

        ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(virtual_cwd), files = files }) })
        ya.emit("update_files", { op = fs.op("done", { id = id, url = virtual_cwd, cha = Cha { kind = 16 } }) })
    end
end

return { entry = entry }

