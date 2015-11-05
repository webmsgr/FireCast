local function crash(reason,message)
	local function center(y, text )
		w, h = term.getSize()
		term.setCursorPos((w - #text) / 2, y)
		write(text)
	end
	local function playFirewolf()
		local isOpen=false
for k,v in pairs({"right","left","top","bottom","front","back"}) do
	if peripheral.getType(v)=="modem" then
		rednet.open(v)
		isOpen=true
	end
end
if not isOpen then
	error("no modem attached")
end
local Mx,My=term.getSize()
local Cx,Cy=math.floor(Mx/2),math.floor(My/2)
function maingame()
	local lang={"Waiting for player",{[0]="^",">","v","<"},{{"|","/","|","\\"},{"/","-","\\","-"},{"|","\\","|","/"},{"\\","-","/","-"}},"You died.","You won."}
	local board=setmetatable({},{__index=function(s,n) s[n]={} return s[n] end})
	for l1=99,-99,-1 do
		board[l1][-99]={"-",3}
	end
	for l1=99,-99,-1 do
		board[l1][99]={"|",3}
	end
	for l1=99,-99,-1 do
		board[-99][l1]={"-",3}
	end
	for l1=99,-99,-1 do
		board[99][l1]={"|",3}
	end
	board[100][100]={"/",3}
	board[100][-100]={"\\",3}
	board[-100][100]={"/",3}
	board[-100][-100]={"\\",3}
	local modem
	local initheader="TRON:"
	local pnid
	local function send(...)
		rednet.send(pnid,string.sub(textutils.serialize({...}),2,-2))
	end
	local function decode(dat)
		return textutils.unserialize("{"..dat.."}")
	end
	local col
	term.setCursorPos(math.floor(Cx-(#lang[1])/2),Cy)
	term.setTextColor(colors.orange)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.write(lang[1])
	rednet.broadcast(initheader.."pingcon")
	local p1,p2
	while true do
		local p={os.pullEvent()}
		if p[1]=="rednet_message" and p[2]~=os.getComputerID() then
			if p[3]==initheader.."pingcon" then
				rednet.send(p[2],initheader.."pongcon")
				pnid=p[2]
				col={colors.blue,colors.red}
				p1={pos={x=2,y=1},dir=0}
				p2={pos={x=1,y=1},dir=0}
				break
			elseif p[3]==initheader.."pongcon" then
				pnid=p[2]
				col={colors.red,colors.blue}
				p1={pos={x=1,y=1},dir=0}
				p2={pos={x=2,y=1},dir=0}
				break
			end
		end
	end
	term.setBackgroundColor(colors.black)
	term.clear()
	local frs=0
	local fps=0 -- frame counter (debugging)
	local function render()
		frs=frs+1
		term.setTextColor(colors.gray)
		for l1=1,My do
			term.setCursorPos(1,l1)
			local pre=p1.pos.x%3
			if (l1+p1.pos.y)%3==0 then
				if pre==1 then
					pre="--"
				elseif pre==2 then
					pre="-"
				else
					pre=""
				end
				term.write(pre..string.rep("+--",math.ceil(Mx/2)))
			else
				if pre==1 then
					pre="  "
				elseif pre==2 then
					pre=" "
				else
					pre=""
				end
				term.write(pre..string.rep("|  ",math.ceil(Mx/2)))
			end
		end
		term.setTextColor(colors.blue)
		local num=0
		for k,v in pairs(board) do
			for l,y in pairs(v) do
				if (k-p1.pos.x)+Cx<=Mx and (k-p1.pos.x)+Cx>=1 and (l-p1.pos.y)+Cy<=My and (l-p1.pos.y)+Cy>=1 then
					term.setTextColor(col[y[2]] or y[2])
					term.setCursorPos((k-p1.pos.x)+Cx,(l-p1.pos.y)+Cy)
					term.write(y[1])
					num=num+1
				end
			end		
		end
		term.setCursorPos(1,1)
		if col[1]==colors.blue then
			term.setTextColor(colors.blue)
			term.write("BLUE")
		else
			term.setTextColor(colors.red)
			term.write("RED")
		end
	end
	local odr={[p1]=p1.dir,[p2]=p2.dir}
	local function processmove(u)
		local ccol
		if u==p1 then
			ccol=col[1]
		else
			ccol=col[2]
		end
		term.setTextColor(ccol)
		if u==p1 and board[u.pos.x][u.pos.y] then
			send("DIE")
			term.setCursorPos(Cx,Cy)
			term.write("x")
			sleep(2)
			term.setCursorPos(Cx-math.floor(#lang[4]/2),Cy)
			term.setTextColor(colors.orange)
			term.clear()
			term.write(lang[4])
			sleep(5)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
			term.setCursorPos(1,1)
			term.clear()
			error("",0)
		end
		if odr[u]~=u.dir then
			board[u.pos.x][u.pos.y]={lang[3][odr[u]+1][u.dir+1],ccol}
		end
		if not board[u.pos.x][u.pos.y] then
			if u.dir%2==0 then
				board[u.pos.x][u.pos.y]={"|",ccol}
			else
				board[u.pos.x][u.pos.y]={"-",ccol}
			end
		end
		local chr=board[u.pos.x][u.pos.y][1]
		local shr={x=u.pos.x,y=u.pos.y}
		if u.dir==0 then
			u.pos.y=u.pos.y-1
		elseif u.dir==1 then
			u.pos.x=u.pos.x+1
		elseif u.dir==2 then
			u.pos.y=u.pos.y+1
		else
			u.pos.x=u.pos.x-1
		end
		odr[u]=u.dir
		return chr,shr
	end
	local function renderchar(u)
		local ccol
		if u==p1 then
			ccol=col[1]
			term.setCursorPos(Cx,Cy)
		else
			ccol=col[2]
			term.setCursorPos((p2.pos.x-p1.pos.x)+Cx,(p2.pos.y-p1.pos.y)+Cy)
		end
		term.setTextColor(ccol)
		term.write(lang[2][u.dir])
	end
	function processturn(p,u)
		local dirs={[keys.up]=0,[keys.right]=1,[keys.down]=2,[keys.left]=3}
		if (odr[u]+2)%4~=dirs[p] then
			u.dir=dirs[p]
			renderchar(u)
			if u==p1 then
				send("ROT",u.dir)
			end
		end
	end
	render()
	local move=os.startTimer(0.1)
	local fct=os.startTimer(1)
	while true do
		local p={os.pullEvent()}
		if p[1]=="key" then
			if p[2]==keys.up or p[2]==keys.right or p[2]==keys.down or p[2]==keys.left then
				processturn(p[2],p1)
			end
		elseif p[1]=="timer" then
			if p[2]==move then
				local ret,ret2=processmove(p1)
				move=os.startTimer(0.1)
				send("MOVE",ret2,ret)
			elseif p[2]==fct then
				fps=frs
				frs=0
				fct=os.startTimer(1)
			end
		elseif p[1]=="rednet_message" and p[2]==pnid then
			local dat=decode(p[3])
			if dat[1]=="ROT" then
				p2.dir=dat[2]
				renderchar(p2)
			elseif dat[1]=="DIE" then
				p1.pos=p2.pos
				render()
				term.setTextColor(col[2])
				term.setCursorPos(Cx,Cy)
				term.write("x")
				sleep(2)
				term.setCursorPos(Cx-math.floor(#lang[5]/2),Cy)
				term.setTextColor(colors.orange)
				term.clear()
				term.write(lang[5])
				sleep(5)
				term.setTextColor(colors.white)
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1,1)
				term.clear()
				return
			elseif dat[1]=="MOVE" then
				p2.pos=dat[2]
				board[p2.pos.x][p2.pos.y]={dat[3],col[2]}
				render()
				renderchar(p1)
				renderchar(p2)
			end
		end
	end
end
local selected=1
function rmain()
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.blue)
	local txt="  _  _______________     ________    __       _\n/ \\/  _____________\\   /  ____  \\  |  \\     / |\n\\_/| /    / \\       | /  /    \\  \\ |   \\ __/  |\n   | |    | |\\  ___/ |  |      |  ||    \\     |\n   | |    | | \\ \\    |  |      |  ||   __\\    |\n   | |    | |  \\ \\    \\  \\____/  / |  /   \\   |\n   \\_/    \\_/   \\_/    \\________/  |_/     \\__|"
	local cnt=1
	local cnt2=Cx-23
	for char in string.gmatch(txt,".") do
		if char~=" " and char~="\n" then
			term.setCursorPos(cnt2,cnt)
			term.write(char)
		elseif char=="\n" then
			cnt=cnt+1
			cnt2=Cx-23
		end
		cnt2=cnt2+1
	end
	local selections={"Multiplayer","Exit"}
	selected=((selected-1)%(#selections))+1
	for k,v in pairs(selections) do
		if k==selected then
			term.setTextColor(colors.blue)
			term.setCursorPos(Cx-(math.floor(#v/2)+1),k+10)
			term.write(">"..v.."<")
			term.setTextColor(colors.lightBlue)
			term.setCursorPos(Cx-math.floor(#v/2),k+10)
			term.write(v)
		else
			term.setTextColor(colors.lightBlue)
			term.setCursorPos(Cx-math.floor(#v/2),k+10)
			term.write(v)
		end
	end
end
rmain()
while true do
	p={os.pullEvent()}
	if p[1]=="key" then
		if p[2]==keys.up then
			selected=selected-1
			rmain()
		elseif p[2]==keys.down then
			selected=selected+1
			rmain()
		elseif p[2]==keys.enter then
			if selected==1 then
				a,b=pcall(maingame)
				if not a and b~="" then
					error(b,0)
				end
				rmain()
			else
			break
			end
		end
	end
end
term.setCursorPos(1,1)
term.clear()
end

	os.pullEvent = os.pullEventRaw
	reasons = {
		["bypass"] = "System Bypassed",
		["security"] = "System Security Issue",
		["crash"] = "System Crashed",
		["unknown"] = "Unknown Error",
		["game"] = "A Game Crashed The System"

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
