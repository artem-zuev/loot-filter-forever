-- Runs the LootFilter Forever simulation tests against stubbed WoW APIs.
-- Usage (from the repository root, Lua 5.1 or LuaJIT):
--   luajit tests/run.lua
--   lua5.1 tests/run.lua
local root = ((arg and arg[0]) or ""):match("^(.-)tests[/\\]run%.lua$") or ""
ADDON_FILE = root .. "LootFilterForever/LootFilterForever.lua"
dofile(root .. "tests/wow_stubs.lua")
dofile(ADDON_FILE)
dofile(root .. "tests/cases.lua")
