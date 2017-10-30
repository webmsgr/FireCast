local function center(y,string)
  local w,h = term.getSize()
  local x = (w/2)-(#string/2)
  term.setCursorPos(x,y)
  print(string)
end

local function centerSlow(y,string,spd)
  local w,h = term.getSize()
  local x = (w/2)-(#string/2)
  term.setCursorPos(x,y)
  textutils.slowPrint(string,spd)
end

term.setBackgroundColour(colours.white)
term.setTextColour(colours.red)
term.clear()
center(6,"Welcome to FireCast.")
sleep(1.25)
centerSlow(7,"It's thinking.",10)
sleep(2)
dofile("FireCast/Menu")
mainmenu()
