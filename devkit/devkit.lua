term.setBackgroundColour(colours.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Loading APIs...")

local apis = fs.list("FireBox/apis")
for k, v in pairs(apis) do
	os.loadAPI("FireBox/apis/"..v)
	print("Loaded "..v)
end

print("Insert a disk to use for development")

local e, par = os.pullEvent("disk")
if not disk.hasData(par) then
	print("Invalid disk!")
	return
end
sleep(0.1)
term.clear()
term.setCursorPos(1,1)
print("FireCast IDE [SDK]")
write("Name of the game: ")
local name = read()
write("Version: ")
local version = read()
write("Author: ")
local author = read()
write("Name of the main file to run on disk\n(EXAMPLE: mygame): ")
local run = read()
local f = fs.open(disk.getMountPath(par).."/firecastlaunch","w")
f.write("run = \""..run.."\"\ngameName = \""..name.."\"\nversionGame = \""..version.."\"\nauthorGame = \""..author.."\"\n")
f.close()
disk.setLabel(par, name.." [FireCast]")
shell.run("/rom/programs/edit", disk.getMountPath(par).."/"..run)
local f = fs.open(disk.getMountPath(par).."/start","w")
f.write(sts)
f.close()
term.clear()
term.setCursorPos(1,1)
print("Run: edit "..disk.getMountPath(par).."/"..run.." to edit the game")
