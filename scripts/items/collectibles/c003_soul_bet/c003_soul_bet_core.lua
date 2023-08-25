local SoulBet_META = {
	__index = setmetatable({}, include("scripts/items/collectibles/c003_soul_bet/c003_soul_bet_constants")),
}
local SoulBet = SoulBet_META.__index
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local function GetSoulBetGlobalData()
	return Tools:Global_GetCollectibleData(modCollectibleType.COLLECTIBLE_SOUL_BET)
end

function SoulBet:SoulBetDataInit()
	local data = GetSoulBetGlobalData()
	if data.EnemyCount == nil then
		data.EnemyCount = 0
	end
end

function SoulBet:GetEnemyCount()
	local data = GetSoulBetGlobalData()
	return data.EnemyCount or 0
end

function SoulBet:ResetEnemyCount()
	local data = GetSoulBetGlobalData()
	data.EnemyCount = 0
end

function SoulBet:ModifyEnemyCount(amount)
	local data = GetSoulBetGlobalData()
	if data.EnemyCount then
		data.EnemyCount = math.max(0, data.EnemyCount + amount)
	end
end

return SoulBet_META