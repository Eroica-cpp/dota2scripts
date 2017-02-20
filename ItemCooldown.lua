-- test file

local ItemCooldown = {}

ItemCooldown.optionEnable = Menu.AddOption({ "Awareness" }, "Item Cooldown Display", "Show items cooldown")

-- important item database
ItemCooldown.importantItems = {}
ItemCooldown.importantItems["item_dagon"] = true -- "Dagon 1"
ItemCooldown.importantItems["item_dagon_2"] = true -- "Dagon 2"
ItemCooldown.importantItems["item_dagon_3"] = true -- "Dagon 3"
ItemCooldown.importantItems["item_dagon_4"] = true -- "Dagon 4"
ItemCooldown.importantItems["item_dagon_5"] = true -- "Dagon 5"
ItemCooldown.importantItems["item_aegis"] = true --"Aegis of the Immortal"
ItemCooldown.importantItems["item_blink"] = true -- "Blink Dagger"
ItemCooldown.importantItems["item_cheese"] = true -- "Cheese"
ItemCooldown.importantItems["item_dust"] = true -- "Dust of Appearance"
ItemCooldown.importantItems["item_faerie_fire"] = true -- "Faerie Fire"
ItemCooldown.importantItems["item_gem"] = true -- "Gem of True Sight"
ItemCooldown.importantItems["item_ghost"] = true -- "Ghost Scepter"
ItemCooldown.importantItems["item_flask"] = true -- "Healing Salve"
ItemCooldown.importantItems["item_infused_raindrop"] = true -- "Infused Raindrop"
ItemCooldown.importantItems["item_shadow_amulet"] = true -- "Shadow Amulet"
ItemCooldown.importantItems["item_smoke_of_deceit"] = true -- "Smoke of Deceit"
ItemCooldown.importantItems["item_abyssal_blade"] = true -- "Abyssal Blade"
ItemCooldown.importantItems["item_black_king_bar"] = true -- "Black King Bar"
ItemCooldown.importantItems["item_blade_mail"] = true -- "Blade Mail"
ItemCooldown.importantItems["item_tpscroll"] = true -- "Town Portal Scroll"
ItemCooldown.importantItems["item_travel_boots"] = true -- "Boots of Trave 1"
ItemCooldown.importantItems["item_travel_boots_2"] = true -- "Boots of Trave 2"
ItemCooldown.importantItems["item_ethereal_blade"] = true -- "Ethereal Blade"
ItemCooldown.importantItems["item_cyclone"] = true -- "Eul's Scepter of Divinity"
ItemCooldown.importantItems["item_skadi"] = true -- "Eye of Skadi"
ItemCooldown.importantItems["item_force_staff"] = true -- "Force Staff"
ItemCooldown.importantItems["item_glimmer_cape"] = true -- "Glimmer Cape"
ItemCooldown.importantItems["item_guardian_greaves"] = true -- "Guardian Greaves"
ItemCooldown.importantItems["item_heavens_halberd"] = true -- "Heaven's Halberd"
ItemCooldown.importantItems["item_hurricane_pike"] = true -- "Hurricane Pike"
ItemCooldown.importantItems["item_sphere"] = true -- "Linken's Sphere"
ItemCooldown.importantItems["item_manta"] = true -- "Manta Style"
ItemCooldown.importantItems["item_mekansm"] = true -- "Mekansm"
ItemCooldown.importantItems["item_orchid"] = true -- "Orchid Malevolence"
ItemCooldown.importantItems["item_rapier"] = true -- "Divine Rapier"
ItemCooldown.importantItems["item_refresher"] = true -- "Refresher Orb"
ItemCooldown.importantItems["item_rod_of_atos"] = true -- "Rod of Atos"
ItemCooldown.importantItems["item_satanic"] = true -- "Satanic"
ItemCooldown.importantItems["item_sheepstick"] = true -- "Scythe of Vyse"
ItemCooldown.importantItems["item_invis_sword"] = true -- "Shadow Blade"
ItemCooldown.importantItems["item_silver_edge"] = true -- "Silver Edge"

function ItemCooldown.OnDraw()
	if not Menu.IsEnabled(ItemCooldown.optionEnable) then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local slotNum = 9
	for i = 0, slotNum-1 do
		myItem = NPC.GetItemByIndex(myHero, i)
		if myItem then
		    myItemCD = Ability.GetCooldown(myItem)
			Log.Write(i+1 .. ": " .. myItemCD)
		end
	end


end

return ItemCooldown