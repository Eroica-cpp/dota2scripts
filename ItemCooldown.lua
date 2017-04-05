-- ===========================================
-- Item Cooldown Display (Version 1.0)
-- Author : Eroica (eroicacmcs@gmail.com)
-- Date : 2017.2.20
-- ===========================================
-- 
-- Usage:
-- 1. Place this script to ./scripts/ folder
-- 2. Navigate in menu : "Awareness" -> "Item Cooldown Display" (On/Off)

-- Features:
-- 1. Display certain important items in enemy's inventory (smoke, dust, blink dagger, BKB, linken's shpere, sheepstick, etc)
-- 2. Show cooldown of these items.

-- Please feel free to report bugs or provide suggestions.
-- ===========================================

local ItemCooldown = {}

ItemCooldown.optionEnable = Menu.AddOption({ "Awareness" }, "Item Cooldown Display", "Show items cooldown")
ItemCooldown.font = Renderer.LoadFont("Tahoma", 15, Enum.FontWeight.EXTRABOLD)

-- important item database
ItemCooldown.importantItems = {}
ItemCooldown.importantItems["item_dagon"] = "dagon" -- "Dagon 1"
ItemCooldown.importantItems["item_dagon_2"] = "dagon" -- "Dagon 2"
ItemCooldown.importantItems["item_dagon_3"] = "dagon" -- "Dagon 3"
ItemCooldown.importantItems["item_dagon_4"] = "dagon" -- "Dagon 4"
ItemCooldown.importantItems["item_dagon_5"] = "dagon" -- "Dagon 5"
ItemCooldown.importantItems["item_aegis"] = "aegis" --"Aegis of the Immortal"
ItemCooldown.importantItems["item_blink"] = "blink" -- "Blink Dagger"
ItemCooldown.importantItems["item_cheese"] = "cheese" -- "Cheese"
ItemCooldown.importantItems["item_dust"] = "dust" -- "Dust of Appearance"
ItemCooldown.importantItems["item_faerie_fire"] = "faerie_fire" -- "Faerie Fire"
ItemCooldown.importantItems["item_gem"] = "gem" -- "Gem of True Sight"
ItemCooldown.importantItems["item_ghost"] = "ghost_scepter" -- "Ghost Scepter"
ItemCooldown.importantItems["item_flask"] = "salve" -- "Healing Salve"
ItemCooldown.importantItems["item_infused_raindrop"] = "raindrop" -- "Infused Raindrop"
ItemCooldown.importantItems["item_shadow_amulet"] = "shadow_amulet" -- "Shadow Amulet"
ItemCooldown.importantItems["item_smoke_of_deceit"] = "smoke" -- "Smoke of Deceit"
ItemCooldown.importantItems["item_abyssal_blade"] = "abyssal_blade" -- "Abyssal Blade"
ItemCooldown.importantItems["item_black_king_bar"] = "BKB" -- "Black King Bar"
ItemCooldown.importantItems["item_blade_mail"] = "blade_mail" -- "Blade Mail"
ItemCooldown.importantItems["item_tpscroll"] = "tp" -- "Town Portal Scroll"
ItemCooldown.importantItems["item_travel_boots"] = "tp_boot" -- "Boots of Trave 1"
ItemCooldown.importantItems["item_travel_boots_2"] = "tp_boot" -- "Boots of Trave 2"
ItemCooldown.importantItems["item_ethereal_blade"] = "ethereal_blade" -- "Ethereal Blade"
ItemCooldown.importantItems["item_cyclone"] = "eul" -- "Eul's Scepter of Divinity"
ItemCooldown.importantItems["item_force_staff"] = "force_staff" -- "Force Staff"
ItemCooldown.importantItems["item_glimmer_cape"] = "glimmer_cape" -- "Glimmer Cape"
ItemCooldown.importantItems["item_guardian_greaves"] = "guardian_greaves" -- "Guardian Greaves"
ItemCooldown.importantItems["item_heavens_halberd"] = "heavens_halberd" -- "Heaven's Halberd"
ItemCooldown.importantItems["item_hurricane_pike"] = "hurricane_pike" -- "Hurricane Pike"
ItemCooldown.importantItems["item_sphere"] = "linken" -- "Linken's Sphere"
ItemCooldown.importantItems["item_manta"] = "manta" -- "Manta Style"
ItemCooldown.importantItems["item_mekansm"] = "mekansm" -- "Mekansm"
ItemCooldown.importantItems["item_orchid"] = "orchid" -- "Orchid Malevolence"
ItemCooldown.importantItems["item_rapier"] = "rapier" -- "Divine Rapier"
ItemCooldown.importantItems["item_refresher"] = "refresher" -- "Refresher Orb"
ItemCooldown.importantItems["item_rod_of_atos"] = "atos" -- "Rod of Atos"
ItemCooldown.importantItems["item_satanic"] = "satanic" -- "Satanic"
ItemCooldown.importantItems["item_sheepstick"] = "sheepstick" -- "Scythe of Vyse"
ItemCooldown.importantItems["item_invis_sword"] = "shadow_blade" -- "Shadow Blade"
ItemCooldown.importantItems["item_silver_edge"] = "silver_edge" -- "Silver Edge"

function ItemCooldown.OnDraw()
	if not Menu.IsEnabled(ItemCooldown.optionEnable) then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	for i = 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		if not Entity.IsSameTeam(myHero, hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) then
			ItemCooldown.DrawDisplay(hero)
		end
	end

end

function ItemCooldown.DrawDisplay(hero)

	local slotNum = 9
	-- draw para
	local pos = Entity.GetAbsOrigin(hero)
	local x, y, visible = Renderer.WorldToScreen(pos)
	local gapX = 50
	local gapY = 20
	y = y - 4 * gapY

	for i = 0, slotNum-1 do
		local item = NPC.GetItemByIndex(hero, i)
		
		if item then
			local itemName = Ability.GetName(item)
	
			if ItemCooldown.importantItems[itemName] then
				local itemCd = math.ceil(Ability.GetCooldown(item))

				-- draw
				local shortItemName = ItemCooldown.importantItems[itemName]
				if itemCd > 0 then
					Renderer.SetDrawColor(255, 0, 0, 255)
					local text = shortItemName.."("..itemCd..")"
					Renderer.DrawTextCenteredY(ItemCooldown.font, x+gapX, y, text, 1)
				else
					Renderer.SetDrawColor(0, 255, 0, 255)
					Renderer.DrawTextCenteredY(ItemCooldown.font, x+gapX, y, shortItemName, 1)
				end
				y = y + gapY

			end
	
		end
	
	end -- end of big for loop

end

return ItemCooldown