require('modules/util')
-- automatical generation file
local MODULES =
{
	'request',
	'tester',
	'donate',
}
local util = __util__
for k,v in pairs(MODULES) do
	util.ModuleRequire(...,v .. "/" .. v)
end 