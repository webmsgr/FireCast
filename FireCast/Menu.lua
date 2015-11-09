local function crash(reason,message)
	local function center(y, text )
		w, h = term.getSize()
		term.setCursorPos((w - #text) / 2, y)
		write(text)
	end

	os.pullEvent = os.pullEventRaw
	reasons = {
		["bypass"] = "System Bypassed",
		["security"] = "System Security Issue",
		["crash"] = "System Crashed",
		["unknown"] = "Unknown Error",
		["game"] = "A Game Crashed The System",

	}
		term.setBackgroundColor(colors.blue)
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.white)
		center(1,"FireCast Crashed:")
		if not reasons or not reasons[reason] then
			center(2,reasons["crash"])
		else
			center(2,reasons[reason])
		end
		
		if not message then
			center(4,"Undefined Crash")
		else
			print("\n\n"..message)
		end
		local x, y = term.getCursorPos()
		center(y+2,"Please reboot system!")
		center(y+3,"Please report the issue here:")
		center(y+4,"https://github.com/Sertex-Team/FireCast/issues")
		while true do
			sleep(0)
		end
end
local function main(...)
  local e
  local par
	for i, v in ipairs(fs.list("/FireCast/APIs/")) do
		if not fs.isDir(v) then
			os.loadAPI("/FireCast/APIs/"..v)
		end
	end
	local function clear()
		term.setBackgroundColor(colors.white)
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.red)
	end
	
	_G.firecast = {
		version = "1",
	}
	
	function os.version()
		return "FireCast "..firecast.version	
	end
	
	function firecast.runApp(_app,...)
		if not fs.exists("/FireCast/Apps/".._app) then
			error("File not found")
		end
		shell.run("/FireCast/Apps/".._app,...)
	end
	
	local function playDisk()
		sleep(0.1)
		clear()
		graphics.header()
		sertextext.center(5, "Insert disk or press backspace")
		while true do
			e, par = os.pullEvent()
			if e == "disk" then
				break
			elseif e == "key" then
				if par == keys.backspace then
					return
				end
			end
		end
		if not fs.exists(disk.getMountPath(par).."/firecastlaunch") then
			if fs.exists(disk.getMountPath(par).."/fireboxlaunch") then
				clear()
				graphics.header()
				sertextext.center(5, "FireBox disk detected!")
				sertextext.center(6, "This game may not be compatible")
				sleep(2)
				fireboxdisk = true
			else
				clear()
				graphics.header()
				sertextext.center(5, "The inserted disk is not compatible with FireCast")
				disk.eject(par)
				sleep(2)
			end
		else
			if fireboxdisk then
				dofile(disk.getMountPath(par).."/fireboxlaunch")
			else
				dofile(disk.getMountPath(par).."/firecastlaunch")
			end
		end
		if not run or not fs.exists(disk.getMountPath(par).."/"..run) then
			clear()
			graphics.header()
			sertextext.center(5, "The inserted disk is not compatible with FireCast")
			disk.eject(par)
			sleep(2)
		else
			if not gameName then
				gameName = "Unknown"
			end
			if not versionGame then
				versionGame = 1
			end
			if not authorGame then
				authorGame = "Unknown"
			end
			logoGame = nil
			clear()
			graphics.header()
			sertextext.center(5, "Loading Disk...")
			sleep(1.25)
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1,1)
			term.setTextColor(colors.white)
			sleep(0.1)
			local ok, err = pcall(function()
				local g = fs.open(disk.getMountPath(par).."/"..run, "r")
				local runGame = g.readAll()
				g.close()
				setfenv(loadstring(runGame),getfenv())()
			end)
			if not ok then
				clear()
				graphics.header()
				sertextext.center(5, "The Program \""..gameName.."\" crashed")
				print(6, "\n"..err)
				local x, y = term.getCursorPos()
				sertextext.center(y+2, "Contact "..authorGame.." and report the error")
				sertextext.center(y+4, "Press Any Key To Continue")
				os.pullEvent("key")
			end
		end
		mainMenu()
	end
	local function localGamesList()
		while true do
			clear()
			graphics.header()
			local options = {
				"Play Disk",
				"Worm",
				"Solitaire",
				"TRON",
				"Back",
			}
			local opt, ch = ui.menu(options, "Games")
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1,1)
			term.setTextColor(colors.white)
			if ch == 1 then
				playDisk()
			elseif ch == 2 then
				shell.run("/rom/programs/fun/worm")
			elseif ch == 3 then
				shell.run("/FireCast/Games/Solitaire")
			elseif ch == 4 then
				shell.run("/FireCast/Games/HighOrLow")
			elseif ch == 5 then
				mainMenu()
			end
		end
	end
	local function localAppsList()
	while true do
		clear()
		graphics.header()
		local options = {
			"Play App on Disk",
			"Firewolf",
			"Sertex Network",
			"Sertex ID",
			"Back",	
		}
		local opt, ch = ui.menu(options, "Apps")
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.white)
		if ch == 1 then
			playDisk()
		elseif ch == 2 then
			playFirewolf() --worth a try
		end
		function mainMenu(se)
			if se then
				if se == "games" then
					localGamesList()
	 			elseif se == "apps" then
					localAppsList()
				end
			end
			clear()
			graphics.header()
	
			local options = {
				"Play", --1
				"Apps", --2
				"Settings", --3
				"Update", --4
				"Power Off", --5
			}
	
			local opt, ch = ui.menu(options, "Main Menu")
	
			if ch == 1 then
				sleep(0.1)
				localGamesList()
			elseif ch == 2 then
				sleep(0.1)
				localAppsList()
			elseif ch == 4 then
				setfenv(loadstring(http.get("https://raw.githubusercontent.com/Sertex-Team/FireCast/master/FireCast/installer.lua").readAll()),getfenv())()
			elseif ch == 5 then
				term.setBackgroundColour(colours.white)
				term.setTextColour(colours.red)
				term.clear()
				sertextext.center(8,"Shutting Down...")
				sleep(1)
				term.setBackgroundColour(colours.grey)
				term.clear()
				sleep(0.5)
				term.setBackgroundColour(colours.lightGrey)
				term.clear()
				sleep(0.2)
				os.shutdown()
			else
				mainMenu()
			end
		end
	
		clear()
		sertextext.centerDisplay("FireCast")
		local x, y = term.getCursorPos()
		sertextext.center(y+3, "Sertex-Team & Game Fusion Team")
		sleep(3)
		mainMenu()
	end
end
end

disk = peripheral.find("drive")

local lock = true

if lock then
	os.pullEvent = os.pullEventRaw
end

local args = {...}

local argData = {
  ["-u"] = false,
}

if #args > 0 then
  while #args > 0 do
    local arg = table.remove(args, 1)
    if argData[arg] ~= nil then
      argData[arg] = true
    end
  end
end

if argData["-u"] then
 term.clear()
 term.setCursorPos(1,1)
 print("Streaming installer...")
 sleep(0.1)
 setfenv(loadstring(http.get("https://raw.github.com/Sertex-Team/FireCast/master/install").readAll()),getfenv())()
end


-- Check System

if not term.isColor() or pocket or turtle then
	print("FireCast Is Only For Advanced Computers")
	return
end

-- If function main() crashes this script will lock the system

local ok, err = pcall(main)
if not ok then
	crash("crash",err)
end
