local CompatibleMods = {}

if EID then
	CompatibleMods.CM_EID = include("compatible mods/external item descriptions/main")
end

--if ModConfigMenu then
--	CompatibleMods.CM_ModConfigMenu = include("compatible mods/mod config menu/main")
--end

--if CuerLib then
--	if Martha then
--		CompatibleMods.CM_Martha = include("compatible mods/martha/main")
--	end
--	if Reverie then
--		CompatibleMods.CM_Reverie = include("compatible mods/reverie/main")
--	end
--end

--if Isaac_BenightedSoul then
--	CompatibleMods.CM_IBS = include("compatible mods/benighted soul/main")
--end

--¼Ð´øË½»õ.jpg
--if TBOM then
--	CompatibleMods.CM_TBOM = include("compatible mods/tbom/main")
--end

return CompatibleMods
