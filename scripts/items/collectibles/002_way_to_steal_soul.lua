local WayToStealSoul = {}
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local DefaultCycle = 7

function WayToStealSoul:PlayerCollectibleDataInit(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)
	if data.CongruentEnemyCount == nil then
		data.CongruentEnemyCount = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WayToStealSoul.PlayerCollectibleDataInit, 0)

function WayToStealSoul:GetCongruentEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)
	return data.CongruentEnemyCount or 0
end

function WayToStealSoul:ResetCongruentEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)
	data.CongruentEnemyCount = 0
end

function WayToStealSoul:ModifyCongruentEnemyCount(player, amount)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)
	if data.CongruentEnemyCount then
		data.CongruentEnemyCount = math.max(0, data.CongruentEnemyCount + amount) % DefaultCycle
	end
end

function WayToStealSoul:ModifyActiveCharge(player, amount)
	if amount == nil then
		amount = 1
	end
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

function WayToStealSoul:PostNPCDeath(npc)
	local NumPlayers = Game():GetNumPlayers()
	if (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) and (not EntityRef(npc).IsFriendly) then
		for p = 0, NumPlayers - 1 do
			local player = Isaac.GetPlayer(p)
			WayToStealSoul:TryModifyActiveCharge(player, 1)
			WayToStealSoul:ModifyCongruentEnemyCount(player, 1)
		end
		return
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, WayToStealSoul.PostNPCDeath, nil)

function WayToStealSoul:PostEntityKill(entity)
	local NumPlayers = Game():GetNumPlayers()
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		if not EntityRef(npc).IsFriendly then
			for p = 0, NumPlayers - 1 do
				local player = Isaac.GetPlayer(p)
				WayToStealSoul:TryModifyActiveCharge(player, 1)
				WayToStealSoul:ModifyCongruentEnemyCount(player, 1)
			end
			return
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WayToStealSoul.PostEntityKill, nil)

function WayToStealSoul:OnUse(item, rng, player, use_flags, active_slot, custom_var_data)
	player:AddSoulHearts(2)
	return {ShowAnim = true, Remove = false}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, WayToStealSoul.OnUse, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)

--[[
function WayToStealSoul:OnCollision(pickup, other, collides_other_first)
	if other.Type == EntityType.ENTITY_PLAYER and other.Variant == 0 then
		local player = other:ToPlayer()
		for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
			if player:GetActiveItem(slot) == modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL then
				for prior_slot = ActiveSlot.SLOT_PRIMARY, slot - 1 do
					if player:NeedsCharge(prior_slot) then
						return nil
					end
				end
			end
			local ChargeAmountList = {
				[BatterySubType.BATTERY_NORMAL] = 6,
				[BatterySubType.BATTERY_MICRO] = 2,
				[BatterySubType.BATTERY_MEGA] = 12,
				[BatterySubType.BATTERY_GOLDEN] = 6,
			}
			local amount = ChargeAmountList[pickup.SubType] or 6
			WayToStealSoul:ModifyActiveCharge(player, amount)
			Tools:PlayUniqueAnimation(pickup, "Collect")
			pickup:Remove()
		end
	end
	return nil
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, WayToStealSoul.OnCollision, PickupVariant.PICKUP_LIL_BATTERY)
]]

function WayToStealSoul:PreAddCollectible(collectible_type, rng, player)
	Translation:ShowDefaultCollectibleText(collectible_type)
end
ModRef:AddCallback(SoulCallbacks.SOULC_PRE_ADD_COLLECTIBLE, WayToStealSoul.PreAddCollectible, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)

return WayToStealSoul