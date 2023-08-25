local Main = {}
local WayToStealSoul = include("scripts/items/collectibles/c002_way_to_steal_soul/c002_way_to_steal_soul_api")
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

function Main:PostPlayerUpdate(player)
	WayToStealSoul:PlayerCollectibleDataInit(player)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.PostPlayerUpdate, 0)

function Main:PostNPCDeath(npc)
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
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Main.PostNPCDeath, nil)

function Main:PostEntityKill(entity)
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
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Main.PostEntityKill, nil)

function Main:OnUse(item, rng, player, use_flags, active_slot, custom_var_data)
	player:AddSoulHearts(2)
	return {ShowAnim = true, Remove = false}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, Main.OnUse, modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL)

--[[
function Main:OnCollision(pickup, other, collides_other_first)
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
ModRef:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Main.OnCollision, PickupVariant.PICKUP_LIL_BATTERY)
]]

return Main