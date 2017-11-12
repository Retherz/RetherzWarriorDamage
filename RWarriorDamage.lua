function RWarriorDamage() 
	className, class = UnitClass("player")
	if class=="WARRIOR" then
		DEFAULT_CHAT_FRAME:AddMessage("RWarriorDamage loaded.", 0.26, 0.97, 0.26);
		SLASH_RWARRIORDAMAGE1 = "/rwarriordamage";
		SLASH_RWARRIORDAMAGE2 = "/rwd";
		SlashCmdList["RWARRIORDAMAGE"] = CalculateDamage;
	else
		DEFAULT_CHAT_FRAME:AddMessage("RWarriorDamage disabled, you're a " .. className .. " .", 0.86, 0.07, 0.23);
	end
end

function CalculateDamage()

	--Talent information
	_, _, _, _, overpowerRank , _ = GetTalentInfo(1, 7);
	_, _, _, _, impaleRank , _ = GetTalentInfo(1, 11);
	_, _, _, _, flurryRank , _ = GetTalentInfo(2, 16);
	_, _, _, _, unbridledWrath , _ = GetTalentInfo(2, 4);
	_, _, _, _, heroicStrikeCost , _ = GetTalentInfo(1, 1);
	if(heroicStrikeCost == nil) then
		heroicStrikeCost = 0;
	end
	heroicStrikeCost = 15 - heroicStrikeCost;
	if(unbridledWrath == nil) then
		unbridledWrath = 0;
	end
	
	if(flurryRank ~= nil) then
		flurryRank = flurryRank + 1;
	else
		flurryRank = 0;
	end
	if(overpowerRank == nil) then
		overpowerRank = 0;
	end
	if(impaleRank == nil) then
		impaleRank = 0;
	end

	--Get necessary character variables
	hasOffhand = OffhandHasWeapon();
	critChance = GetCritChance() / 100;
	
		mainHandAttackBase, mainHandAttackMod, offHandHandAttackBase, offHandAttackMod = UnitAttackBothHands("player");
	weaponSkillMH = mainHandAttackBase + mainHandAttackMod;
	weaponSkillOH = offHandHandAttackBase + offHandAttackMod;
		minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, _, _, _ = UnitDamage("player");
	weaponDamageMH = (minDamage + maxDamage) / 2;
	weaponDamageOH = (minOffHandDamage + maxOffHandDamage) / 2;
	speedMH, speedOH = UnitAttackSpeed("player");
	
	baseAP, posBuffAP, negBuffAP = UnitAttackPower("player");
	attackPower = baseAP + posBuffAP + negBuffAP;
	
	--Off hand crit
	offHandCrit = critChance + (weaponSkillOH - weaponSkillMH) * 0.0004;
	
	--Calculate hit table values
	hitTable = 1.00;
	hitFromWeaponSkillMH = 0;
	hitFromWeaponSkillOH = 0;
		if(weaponSkillMH >= 305) then
			hitFromWeaponSkillMH = hitFromWeaponSkillMH + 2;
			hitFromWeaponSkillMH = hitFromWeaponSkillMH +(weaponSkillMH - 305) * 0.04;
		else
			hitFromWeaponSkillMH = hitFromWeaponSkillMH +(weaponSkillMH - 300) * 0.04;		
		end
		if(hasOffhand) then
			if(weaponSkillOH >= 305) then
				hitFromWeaponSkillOH = hitFromWeaponSkillOH + 2;
				hitFromWeaponSkillOH = hitFromWeaponSkillOH +(weaponSkillOH - 305) * 0.04;
			else
				hitFromWeaponSkillOH = hitFromWeaponSkillOH +(weaponSkillOH - 300) * 0.04;		
			end
		end
		
	dodgeChanceMH = 0.056;
	dodgeChanceOH = 0.056;
		if(weaponSkillMH >= 301) then
			dodgeChanceMH = dodgeChanceMH -(weaponSkillMH - 300) * 0.0004;		
		end
		if(hasOffhand) then
			if(weaponSkillOH >= 301) then
				dodgeChanceOH = dodgeChanceOH -(weaponSkillOH - 300) * 0.0004;
			end
		end
		
		
		
	missChance = 0.08;
		if(hasOffhand) then
			missChance = missChance + 0.19;
		end
	hitFromGear = BonusScanner:GetBonus("TOHIT");
	hitBonus = (hitFromGear + hitFromWeaponSkillMH) / 100;
	hitBonusOH = (hitFromGear + hitFromWeaponSkillOH) / 100;
	SendMessage("-------------------");
	
	baseoverpowerDamage, baseflurryUptime, basewhirlwindDamage, basebloodthirstDamage, basedps, baseragePerSecond, basehsDamage = CalculateDPS(critChance, impaleRank, overpowerRank, dodgeChanceMH, hitBonus, missChance, hitBonusOH, dodgeChanceOH, offHandCrit, speedMH, speedOH,
weaponDamageMH, weaponSkillMH, flurryRank, weaponDamageOH, weaponSkillOH, attackPower, unbridledWrath);
	normalDPS = dps;
	SendMessage("OP: " .. baseoverpowerDamage .. " WW: " .. basewhirlwindDamage .. " BT: " .. basebloodthirstDamage);
	SendMessage("Flurry uptime: " .. Round(baseflurryUptime * 100) .. "% Rage per Second: " .. Round(baseragePerSecond));
	basehsPS = Round((baseragePerSecond - 7.5) / heroicStrikeCost);
	basedpsFromHS = 0;
	if(baseragePerSecond > 7.5) then
		hspPerS = Round((1 / basehsPS) * 1.5);
		SendMessage("Heroic Strikes 1 per " .. hspPerS .. " seconds.");
		basedpsFromHS = (basehsDamage - weaponDamageMH) / hspPerS;
	end
	SendMessage("DPS: " .. Round(basedps + basedpsFromHS));
	SendMessage("-------------------");
	
	-- recalcualte with +1 crit
	SendMessage("Adding 1% Crit would result in: ");
	
	overpowerDamage, flurryUptime, whirlwindDamage, bloodthirstDamage, dps, ragePerSecond, hsDamage = CalculateDPS(critChance + 0.01, impaleRank, overpowerRank, dodgeChanceMH, hitBonus, missChance, hitBonusOH, dodgeChanceOH, offHandCrit + 0.01, speedMH, speedOH,
weaponDamageMH, weaponSkillMH, flurryRank, weaponDamageOH, weaponSkillOH, attackPower, unbridledWrath);
	SendMessage("OP: +" .. Round(overpowerDamage - baseoverpowerDamage) .. " WW: +" .. Round(whirlwindDamage - basewhirlwindDamage) .. " BT: +" .. Round(bloodthirstDamage - basebloodthirstDamage));
	SendMessage("Flurry uptime: +" .. Round((flurryUptime - baseflurryUptime)* 100) .. "% Rage per Second: +" .. Round((ragePerSecond - baseragePerSecond)));
	hsPS = Round((ragePerSecond - 7.5) / heroicStrikeCost);
	dpsFromHS = 0;
	if(baseragePerSecond > 7.5) then
		hspPerS = Round((1 / hsPS) * 1.5);
		SendMessage("Heroic Strikes 1 per " .. hspPerS .. " seconds.");
		dpsFromHS = (hsDamage - weaponDamageMH) / hspPerS;
	end
	SendMessage("DPS: " .. Round((dps + dpsFromHS) - (basedps + basedpsFromHS))  .. " added dps.");
	SendMessage("-------------------");
	
	-- recalcualte with +1 hit
	SendMessage("Adding 1% hit would result in: ");
	
	overpowerDamage, flurryUptime, whirlwindDamage, bloodthirstDamage, dps, ragePerSecond, hsDamage = CalculateDPS(critChance, impaleRank, overpowerRank, dodgeChanceMH, hitBonus + 0.01, missChance, hitBonusOH + 0.01, dodgeChanceOH, offHandCrit, speedMH, speedOH,
weaponDamageMH, weaponSkillMH, flurryRank, weaponDamageOH, weaponSkillOH, attackPower, unbridledWrath);
	SendMessage("OP: +" .. Round(overpowerDamage - baseoverpowerDamage) .. " WW: +" .. Round(whirlwindDamage - basewhirlwindDamage) .. " BT: +" .. Round(bloodthirstDamage - basebloodthirstDamage));
	SendMessage("Flurry uptime: +" .. Round((flurryUptime - baseflurryUptime)* 100) .. "% Rage per Second: +" .. Round((ragePerSecond - baseragePerSecond)));
	hsPS = Round((ragePerSecond - 7.5) / heroicStrikeCost);
	dpsFromHS = 0;
	if(baseragePerSecond > 7.5) then
		hspPerS = Round((1 / hsPS) * 1.5);
		SendMessage("Heroic Strikes 1 per " .. hspPerS .. " seconds.");
		dpsFromHS = (hsDamage - weaponDamageMH) / hspPerS;
	end
	SendMessage("DPS: " .. Round((dps + dpsFromHS) - (basedps + basedpsFromHS))  .. " added dps.");
	SendMessage("-------------------");
	
	
	
	
end

function CalculateDPS(critChance, impaleRank, overpowerRank, dodgeChanceMH, hitBonus, missChance, hitBonusOH, dodgeChanceOH, offHandCrit, speedMH, speedOH,
weaponDamageMH, weaponSkillMH, flurryRank, weaponDamageOH, weaponSkillOH, attackPower, unbridledWrath)

	critCapMH = 0.6 - dodgeChanceMH - missChance + hitBonus;
	critCapOH = 0.6 - dodgeChanceOH - missChance + hitBonusOH;
	if(critChance ~= offHandCrit and hasOffhand) then
		SendMessage("Crit MH/Crit cap: " .. (critChance) * 100 .. "/" .. critCapMH * 100 .. "% Crit from Cap: " .. (critCapMH - critChance) * 100 .. "%");
		SendMessage("Crit OH/Crit cap: " .. (offHandCrit) * 100 .. "/" .. critCapOH * 100 .. "% Crit from Cap: " .. (critCapMH - critChance) * 100 .. "%");
	else
		SendMessage("Crit/Crit cap: " .. (critChance) * 100 .. "/" .. critCapMH * 100 .. "% Crit from Cap: " .. (critCapMH - critChance) * 100 .. "%");		
	end
	AbilityHitChance = 0.92;
	AbilityHitChance = AbilityHitChance + hitBonus;
	if(AbilityHitChance > 1.00) then
		AbilityHitChance = 1.00;
	end
	--Normalized MH Weapon Damage
	normalizedMHDamage = 0; --base_weapon_damage + (X * attackPower / 14) 2.4 DW, 3.3 2h
	if(hasOffhand) then
		normalizedMHDamage = (weaponDamageMH - (speedMH * attackPower / 14)) + (2.4 * attackPower / 14);
	else
		normalizedMHDamage = (weaponDamageMH - (speedMH * attackPower / 14)) + (3.3 * attackPower / 14);		--assuming main hand is 2h
	end
	
	overPowerCritChance, overpowerDamage = CalcOverpower(critChance, AbilityHitChance, impaleRank, overpowerRank, normalizedMHDamage);	--calculate overpower before adding dodge to save those precious IPSs.
	AbilityHitChance = AbilityHitChance - dodgeChanceMH;
	
	mainHandHits, mainHandCrits, mainHandMiss = CalcAAHitTable(hitBonus, dodgeChanceMH, critChance, missChance);
	offHandHits, offHandCrits, offHandMiss = CalcAAHitTable(hitBonusOH, dodgeChanceOH, offHandCrit, missChance);
	flurryUptime = CalcFlurryUptime(speedMH, speedOH, critChance + dodgeChanceMH * overPowerCritChance, offHandCrit + dodgeChanceOH * overPowerCritChance)
	
	ragePerSecond = 0.66;
	
	mainHandDPS, mainHandRage = CalcAutoAttackDamage(weaponDamageMH, speedMH, mainHandHits, dodgeChanceMH, mainHandCrits, mainHandMiss, weaponSkillMH, overpowerDamage, flurryUptime, flurryRank * 0.05, unbridledWrath);
	offHandDPS, offHandRage = 0;
	ragePerSecond = ragePerSecond + mainHandRage;
		if(hasOffhand) then
			offHandDPS, offHandRage = CalcAutoAttackDamage(weaponDamageOH, speedOH, offHandHits, dodgeChanceOH, offHandCrits, offHandMiss, weaponSkillOH, overpowerDamage, flurryUptime, flurryRank * 0.05, unbridledWrath);
			ragePerSecond = ragePerSecond + offHandRage;
		end
	whirlwindDamage = CalcWhirlwind(critChance, AbilityHitChance, impaleRank, normalizedMHDamage);
	bloodthirstDamage = CalcBloodthirst(critChance, AbilityHitChance, impaleRank, attackPower);
	dps = Round(mainHandDPS + offHandDPS + bloodthirstDamage / 6 + whirlwindDamage / 10);
	hsDamage = CalcHeroicstrike(critChance, AbilityHitChance, impaleRank, weaponDamageMH);
	return overpowerDamage, flurryUptime, whirlwindDamage, bloodthirstDamage, dps, ragePerSecond, hsDamage;
end

function CalcAutoAttackDamage(weaponDamage, weaponSpeed, hits, dodgeChance, crits, miss, weaponSkill, overpowerDamage, flurryUptime, flurryModifier, unbridledWrath)
	damage = (0.4 * weaponDamage * CalcGlance(weaponSkill) + overpowerDamage * dodgeChance + weaponDamage * hits + (weaponDamage * 2 * crits));
	rage = (damage - overpowerDamage * dodgeChance) / 30 + (unbridledWrath * 0.08 * (hits + crits));
	return damage / (weaponSpeed * (1 + flurryModifier * flurryUptime)), rage / weaponSpeed;
end

function CalcAAHitTable(hitBonus, dodgeChance, critChance, missChance)
	miss =  missChance - hitBonus;
	crits = critChance;
	if(missChance < 0) then
		miss = 0;
	end
	hits = 0.6 - dodgeChance - miss;			--glances are always 40%;
	if((hits - crits) < 0) then
		crits = hits;
		hits = 0;
	end
	return hits, crits, miss;
end

function CalcFlurryUptime(speedMH, speedOH, critChance, offHandCrit)
	attacksPerFlurry = 3.0;			-- 3 base attacks until the buff wears off + whirlwind cd / uptime + blood thirst cd / uptime
	flurryBuffUptime = speedMH * 2 * 0.7;
	if((speedOH ~= nil) and (speedOH > speedMH)) then
		flurryBuffUptime = speedOH * 2 * 0.7;
	end
	attacksPerFlurry = attacksPerFlurry + flurryBuffUptime / 10; 	--+whirlwind attacks
	attacksPerFlurry = attacksPerFlurry + flurryBuffUptime / 6; 	--+bloodthirst attacks
	flurry = 1 - math.pow(1-critChance, attacksPerFlurry);
	if(speedOH ~= nil) then
		flurryOH = 1 - math.pow(1-offHandCrit, attacksPerFlurry);
		flurryOH = flurryOH * (Round(speedMH / speedOH));
		flurry = flurry * (Round(speedOH / speedMH));
		flurry = (flurryOH + flurry) / (speedOH / speedMH + speedMH / speedOH);
	else
		return (flurry);
	end
	return (flurry);
end

function CalcBloodthirst(critChance, AbilityHitChance, impaleRank, attackPower)
	bloodthirstBaseDamage = 0.45 * attackPower;
	return Round((AbilityHitChance - critChance) * bloodthirstBaseDamage + (bloodthirstBaseDamage * (critChance * (2 + impaleRank * 0.05))))
end

function CalcWhirlwind(critChance, AbilityHitChance, impaleRank, normalizedMHDamage)
	return Round((AbilityHitChance - critChance) * normalizedMHDamage + (normalizedMHDamage * (critChance * (2 + impaleRank * 0.05))))
end

function CalcOverpower(critChance, AbilityHitChance, impaleRank, overpowerRank, normalizedMHDamage)
	overPowerCritChance = critChance + (overpowerRank * 0.25) - 0.03;	--subtract 3% assuming player is in  berserker stance
	overpowerDamage = normalizedMHDamage + 35;
	if(overPowerCritChance > 1.00) then
		overPowerCritChance = 1.00;
	end
	return overPowerCritChance, Round((AbilityHitChance - overPowerCritChance) * overpowerDamage + (overpowerDamage * (overPowerCritChance * (2 + impaleRank * 0.05))))
end

function CalcHeroicstrike(critChance, AbilityHitChance, impaleRank, weaponDamageMH)
	hsDamage = weaponDamageMH + 187;
	return Round((AbilityHitChance - critChance) * hsDamage + (hsDamage * (critChance * (2 + impaleRank * 0.05))))
end

function CalcGlance(weaponSkill)
	multiplier = 1.25 - 0.04 * (315 - weaponSkill)
	if multiplier > 1 then
		multiplier = 1
	end
	return multiplier;
end

function printData(data)
	SendMessage("------------------------");
	for i, name in ipairs(data) do
		SendMessage(data)
	end
	SendMessage("------------------------");
end

function SendMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

function Round(value)
	return math.floor(value * 100 + 0.5) / 100
end

--From http://wowwiki.wikia.com/wiki/API_GetCritChance?oldid=218798
 function GetCritChance()
   local critNum;
   local id = 1;
   -- This may vary depending on WoW localizations.
   local atkName = "Attack";
   if (GetSpellName(id, BOOKTYPE_SPELL) ~= atkName) then
     name, texture, offset, numSpells = GetSpellTabInfo(1);
     for i=1, numSpells do
       if (GetSpellName(i,BOOKTYPE_SPELL) == atkName) then
         id = i;
       end
     end
   end
   GameTooltip:SetOwner(WorldFrame,"ANCHOR_NONE");
   GameTooltip:SetSpell(id, BOOKTYPE_SPELL);
   local spellName = GameTooltipTextLeft2:GetText();
   GameTooltip:Hide();
   critNum = string.sub(spellName,0,(string.find(spellName, "%s") -2));
   return critNum;
 end