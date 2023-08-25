local Main = {}
local RedCrystalNecklace = include("scripts/items/trinkets/t001_red_crystal_necklace/t001_red_crystal_necklace_api")
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modTrinketType = Soul.modTrinketType

function Main:PostPlayerUpdate(player)
	RedCrystalNecklace:RedCrystalNecklaceDataInit(player)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.PostPlayerUpdate, 0)

function Main:PostNewRoom()
	local game = Game()
	local NumPlayers = game:GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = game:GetPlayer(p)
		if RedCrystalNecklace:CanTriggerEffect(player) then
			RedCrystalNecklace:TriggerEffect(player)
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, Main.PostNewRoom)

function Main:PostNewGreedModeWave(current_wave)
	local game = Game()
	if game:IsGreedMode() then
		local NumPlayers = game:GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = game:GetPlayer(p)
			if RedCrystalNecklace:CanTriggerEffect_Greed(player, current_wave) then
				RedCrystalNecklace:TriggerEffect(player)
			end
		end
	end
end
ModRef:AddCallback(SoulCallbacks.SOULC_POST_NEW_GREED_MODE_WAVE, Main.PostNewGreedModeWave)

function Main:EvaluateCache(player, caflag)
	if player:HasTrinket(modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE) then
		if caflag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 1
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Main.EvaluateCache)

function Main:PostPlayerEffectUpdate(player)
	RedCrystalNecklace:ModifyBookOfShadowFrame(player, 1)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Main.PostPlayerEffectUpdate)

function Main:PostPlayerRender(player, offset)
	local damage_CD = Tools:Immunity_GetDamageCooldown(player)
	local frame = RedCrystalNecklace:GetBookOfShadowFrame(player)
	local sprite = RedCrystalNecklace:GetBookOfShadowSprite(player)
	if  damage_CD > 0 and sprite then
		if damage_CD > 90 then
			sprite:SetFrame("WalkDown", frame % 40)
		else
			sprite:SetFrame("Blink", frame % 16)
		end
		sprite.Scale = player.SpriteScale
		sprite:Render(Tools:GetEntityRenderScreenPos(player, true))
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Main.PostPlayerRender)

return Main