local SoulContract_META = {
	__index = setmetatable({}, include("scripts/items/collectibles/c004_soul_contract/c004_soul_contract_constants")),
}
local SoulContract = SoulContract_META.__index
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local function GetSoulContractGlobalData()
	return Tools:Global_GetCollectibleData(modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
end

function SoulContract:SoulContractDataInit()
	local data = GetSoulContractGlobalData()
	if data.EnemyCount == nil then
		data.EnemyCount = 0
	end
end

function SoulContract:GetEnemyCount()
	local data = GetSoulContractGlobalData()
	return data.EnemyCount or 0
end

function SoulContract:ResetEnemyCount()
	local data = GetSoulContractGlobalData()
	data.EnemyCount = 0
end

function SoulContract:ModifyEnemyCount(amount)
	local data = GetSoulContractGlobalData()
	if data.EnemyCount then
		data.EnemyCount = math.max(0, data.EnemyCount + amount)
	end
end

return SoulContract_META