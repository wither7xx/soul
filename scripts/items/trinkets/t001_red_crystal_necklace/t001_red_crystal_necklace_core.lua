local RedCrystalNecklace_META = {
	__index = setmetatable({}, include("scripts/items/trinkets/t001_red_crystal_necklace/t001_red_crystal_necklace_constants")),
}
local RedCrystalNecklace = RedCrystalNecklace_META.__index
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modTrinketType = Soul.modTrinketType

local function GetSoulContractData(player)
	return Tools:GetPlayerTrinketData(player, modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE)
end

function RedCrystalNecklace:RedCrystalNecklaceDataInit(player)
	local data = GetSoulContractData(player)
	if data.BookOfShadowFrame == nil then
		data.BookOfShadowFrame = 0
	end
	if data.BookOfShadowSprite == nil then
		data.BookOfShadowSprite = Sprite()
		data.BookOfShadowSprite:Load("gfx/characters/058_book of shadows.anm2", true)
		data.BookOfShadowSprite:SetAnimation("WalkDown")
	end
end

function RedCrystalNecklace:GetBookOfShadowFrame(player)
	local data = GetSoulContractData(player)
	return data.BookOfShadowFrame or 0
end

function RedCrystalNecklace:ResetBookOfShadowFrame(player)
	local data = GetSoulContractData(player)
	data.BookOfShadowFrame = 0
end

function RedCrystalNecklace:ModifyBookOfShadowFrame(player, amount)
	local data = GetSoulContractData(player)
	if data.BookOfShadowFrame then
		data.BookOfShadowFrame = (data.BookOfShadowFrame + amount) % 80
	end
end

function RedCrystalNecklace:GetBookOfShadowSprite(player)
	local data = GetSoulContractData(player)
	return data.BookOfShadowSprite
end

function RedCrystalNecklace:CanTriggerEffect(player)
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local room_desc = level:GetCurrentRoomDesc()
	local starting_room_idx = level:GetStartingRoomIndex()
	local chance = RedCrystalNecklace.BaseImmuneChance
	return (not game:IsGreedMode()) 
		and player:HasTrinket(modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE) 
		and Random() % 100 < chance 
		and room:IsFirstVisit() 
		and room_desc.GridIndex ~= starting_room_idx
end

function RedCrystalNecklace:CanTriggerEffect_Greed(player, current_wave)
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local room_desc = level:GetCurrentRoomDesc()
	local starting_room_idx = level:GetStartingRoomIndex()
	local chance = RedCrystalNecklace.BaseImmuneChance
	return game:IsGreedMode() 
		and player:HasTrinket(modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE)
		and Random() % 100 < chance 
		and current_wave < game:GetGreedBossWaveNum()
end

function RedCrystalNecklace:TriggerEffect(player)
	Tools:Immunity_AddImmuneEffect(player, RedCrystalNecklace.DefaultImmunityTimeout, false)
	RedCrystalNecklace:ResetBookOfShadowFrame(player)
end

return RedCrystalNecklace_META