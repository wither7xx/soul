local ModData = {}
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools

local function GetEffectivePlayerData()
	local data = {}
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local idx = Tools:GetPlayerIndex(player, false)
		if Soul.TempData.PlayerData[idx] then
			data[idx] = Soul.TempData.PlayerData[idx]
		end
	end
	return data
end

local function GetEffectiveUserRegister()
	local data = {}
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local idx_user = Tools:GetPlayerIndex(player, true)
		if Soul.TempData.PlayerData_UserRegister[idx_user] then
			data[idx_user] = Soul.TempData.PlayerData_UserRegister[idx_user]
		end
	end
	return data
end

local function GetPlayerData_Static()
	return Soul.TempData.PlayerData_Static
end
local function GetGameData()
	return Soul.TempData.GameData
end

local function GetKeyConfig()
	return Soul.KeyConfig
end

local json = require("json")

function ModData:SaveModData()
	local SavingData = {
		PlayerData = GetEffectivePlayerData(),
		PlayerData_UserRegister = GetEffectiveUserRegister(),
		PlayerData_Static = GetPlayerData_Static(),
		GameData = GetGameData(),
		KeyConfig = GetKeyConfig(),
	}
	Soul:SaveData(json.encode(SavingData))
end
ModRef:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, ModData.SaveModData)
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ModData.SaveModData)

function ModData:LoadModData(is_continued)
	if Soul:HasData() then
		local LoadingData = json.decode(Soul:LoadData())
		if is_continued then
			if LoadingData then
				Soul.TempData.PlayerData = LoadingData.PlayerData or {}
				Soul.TempData.PlayerData_UserRegister = LoadingData.PlayerData_UserRegister or {}
				Soul.TempData.PlayerData_Static = LoadingData.PlayerData_Static or {}
				Soul.TempData.GameData = LoadingData.GameData or {}
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ModData.LoadModData)

return ModData