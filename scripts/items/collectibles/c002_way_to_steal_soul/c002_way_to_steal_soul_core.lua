local WayToStealSoul_META = {
	__index = setmetatable({}, include("scripts/items/collectibles/c002_way_to_steal_soul/c002_way_to_steal_soul_constants")),
}
local WayToStealSoul = WayToStealSoul_META.__index
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local DefaultCycle = WayToStealSoul.DefaultCycle

local function GetWayToStealSoulData(player)
	return Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)
end

function WayToStealSoul:PlayerCollectibleDataInit(player)
	local data = GetWayToStealSoulData(player)
	if data.CongruentEnemyCount == nil then
		data.CongruentEnemyCount = 0
	end
end

function WayToStealSoul:GetCongruentEnemyCount(player)
	local data = GetWayToStealSoulData(player)
	return data.CongruentEnemyCount or 0
end

function WayToStealSoul:ResetCongruentEnemyCount(player)
	local data = GetWayToStealSoulData(player)
	data.CongruentEnemyCount = 0
end

function WayToStealSoul:ModifyCongruentEnemyCount(player, amount)
	local data = GetWayToStealSoulData(player)
	if data.CongruentEnemyCount then
		data.CongruentEnemyCount = math.max(0, data.CongruentEnemyCount + amount) % DefaultCycle
	end
end

function WayToStealSoul:ModifyActiveCharge(player, amount)
	amount = amount or 1
    for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
		if player:GetActiveItem(slot) == modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL then
			local prev_charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
			local max_charge = Isaac.GetItemConfig():GetCollectible(modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL).MaxCharges
			local max_charge_base = max_charge
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
				max_charge = max_charge * 2
				if prev_charge > max_charge_base then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position, Vector(0, 0), nil)
				end
			end
			local new_charge = math.max(0, prev_charge + amount)
			if prev_charge < max_charge then
				player:SetActiveCharge(math.min(new_charge, max_charge), slot)
				Game():GetHUD():FlashChargeBar(player, slot)
				local sfx = SFXManager()
				sfx:Play(SoundEffect.SOUND_BEEP)
				if new_charge >= max_charge_base then
					sfx:Play(SoundEffect.SOUND_ITEMRECHARGE)
				end
			end
		end
    end
end

function WayToStealSoul:TryModifyActiveCharge(player, amount)
	if WayToStealSoul:GetCongruentEnemyCount(player) == DefaultCycle - 1 then
		WayToStealSoul:ModifyActiveCharge(player, amount)
	end
end

return WayToStealSoul_META