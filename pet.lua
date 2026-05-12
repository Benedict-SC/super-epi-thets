Pet = function(id,wailing) 
    local pet = Clickable();
    pet.id = id;
    pet.battlesFought = 0;
    pet.level = 1;
    pet.xp = 0;
    local sourcePet = PetMap[id];
    pet.name = sourcePet.name;
    pet.atk = sourcePet.atk;
    pet.hp = sourcePet.hp;
    pet.tier = sourcePet.tier;
    pet.gender = sourcePet.gender;
    pet.frozen = false;
    pet.perk = Perk();

    pet.tempAtk = 0;
    pet.tempHp = 0;

    pet.imgUrl = sourcePet.img;
    if wailing then
        pet.imgUrl = string.gsub(pet.imgUrl,"char/","char/wailmer/");
    end
    pet.img = love.graphics.newImage(pet.imgUrl);
    pet.projectileUrl = "img/rock.png";
    pet.x = 0;
    pet.y = 0;
    pet.inputState = "IDLE";

    pet.priceModifier = 0;
    pet.defense = function() 
        local amt = 0;
        if pet.perk.id == "melon" then 
            amt = amt + 20
        elseif pet.perk.id == "coconut" then
            amt = amt + 999;
        end
        if pet.perk.defDown then
            amt = amt - pet.perk.defDown;
        end
        return amt;
    end

    pet.allAbilities = function()
        if pet.isMollywhopped() then
            return pet.abilities.concat(Array());
        end
        return pet.abilities.concat(pet.perk.abilities);
    end
    giveAbilitiesToPet(pet);

    pet.getSellPrice = function()
        return pet.level + pet.priceModifier;
    end
    pet.combine = function(otherPet)
        if pet.name ~= otherPet.name then
            return; --later handle Graham in here
        else
            local highestAtk = math.max(pet.atk,otherPet.atk);
            local highestHp = math.max(pet.hp,otherPet.hp);
            pet.atk = highestAtk;
            pet.hp = highestHp;
            if pet.perk.id == "default" and otherPet.perk.id ~= "default" then
                pet.perk = otherPet.perk;
                pet.perk.owner = pet;
            end
            local xpamount = (otherPet.xp > 0) and 2 or 1;
            pet.addExp(xpamount);
        end
    end
    pet.addExp = function(amt)
        pet.xp = pet.xp + amt;
        pet.atk = pet.atk + amt;
        pet.hp = pet.hp + amt;
        if pet.xp > 5 then
            pet.xp = 5;
            return;
        end
        if pet.level == 1 and pet.xp > 1 then
            pet.levelUp()
        elseif pet.level == 2 and pet.xp > 4 then
            pet.levelUp()
        end
    end
    pet.levelUp = function()
        pet.level = pet.level + 1;
        if pet.level > 3 then 
            pet.level = 3;
            return;
        end
        if game and (not game.manager.battle) and (not pet.enemy) then
            game.petShop.levelUpBonusStock();
        end
    end
    pet.loseExp = function(amt)
        if pet.xp == 0 then return; end
        pet.xp = pet.xp - amt;
        pet.atk = pet.atk - amt;
        pet.initialhp = pet.hp;
        pet.hp = pet.hp - amt;
        if pet.atk < 1 then pet.atk = 1; end
        if pet.hp < 1 and pet.initialhp > 0 then pet.hp = 1; end
        if pet.xp < 0 then pet.xp = 0; end
        if pet.xp < 5 then pet.level = 2; end
        if pet.xp < 2 then pet.level = 1; end
    end
    pet.losePerk = function()
        if pet.perk.lostPerk then
            game.abilityStack.registerAbilityTrigger(pet,"lostPerk",pet.perk.lostPerk)
        end
        pet.perk = Perk();
    end
    pet.gainPerk = function(perk,done,defer)
        if perk.isAilment and (pet.oldDefense) and (pet.getIndex() ~= 5) then
            --this is for lorelai's ability- checks oldDefense instead of her ID in case rick copied it
            if done then done(); end
            return;
        end
        if pet.isMollywhopped() then
            if done then done(); end
            return;
        end
        
        if perk.isAilment and (pet.perk.id == "ambrosia") then
            pet.losePerk();
            done();
            return;
        else
            pet.losePerk();
        end
        pet.perk = perk;
        pet.perk.owner = pet;
        if perk.isAilment then
            pet.allAbilities().forEach(function(el) 
                if el.id == "gainedAilment" then
                    game.abilityStack.registerAbilityTrigger(pet,"gainedAilment",el.func,perk);
                end
            end);
            local teammates = pet.getTeam().getAllPets();
            teammates.forEach(function(tm) 
                tm.allAbilities().forEach(function(el) 
                    if el.id == "friendGainedAilment" and not (tm == pet) then
                        game.abilityStack.registerAbilityTrigger(tm,"friendGainedAilment",el.func,pet);
                    end
                end);
            end);
            local enemies = pet.getEnemyTeam().getAllPets();
            if game.manager.battle then
                enemies.forEach(function(en) 
                    en.allAbilities().forEach(function(el) 
                        if el.id == "opponentGainedAilment" then
                            game.abilityStack.registerAbilityTrigger(en,"opponentGainedAilment",el.func,pet);
                        end
                    end);
                end);
            end
            if not defer then
                game.abilityStack.startProcessing(done);
            elseif done then
                done();
            end
        else
            --here's where we'd trigger gained-perk effects... TIMMY TURNER'S DAD MEME!!!
            if done then done(); end
        end
    end
    pet.fling = function(pos,failedFilename)

    end
    pet.getCopy = function()
        local newPet = Pet(pet.id,pet.wailmer);
        newPet.atk = pet.atk + pet.tempAtk;
        newPet.hp = pet.hp + pet.tempHp;
        newPet.xp = pet.xp;
        newPet.level = pet.level;
        newPet.enemy = pet.enemy;
        newPet.battlesFought = pet.battlesFought;
        newPet.priceModifier = pet.priceModifier;
        newPet.perk = pet.perk.copy();
        newPet.perk.owner = newPet;
        newPet.original = pet;
        newPet.wailmer = pet.wailmer;
        return newPet;
    end
    pet.triggerOne = function(triggerType,args,done,defer)
        pet.allAbilities().forEach(function(el) 
            if el.id == triggerType then
                game.abilityStack.registerAbilityTrigger(pet,triggerType,el.func,args);
            end
        end);
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end

    pet.draw = function(xoff,yoff,xscale)
        pushColor();

        local fade = 0;
        if pet.fade then fade = pet.fade; end

        if pet.discount and pet.discount > 0 then
            love.graphics.draw(discount,xoff+pet.x+22,yoff+pet.y-15);
            love.graphics.print(3-pet.discount,xoff+pet.x+52,yoff+pet.y-21)
        end
        if pet.inputState == "DRAGGING" then
            love.graphics.setColor(0,0,0);
        else
            love.graphics.setColor(1,1,1,1-fade);
        end
        love.graphics.draw(pet.img,xoff+ ((xscale == -1) and 100 or 0) + pet.x,yoff+pet.y,0,xscale,1);
        if game.manager.state == "SHOP" then
            if pet.hovered or pet.inputState == "SELECTED" then
                if not (pet.inputState == "SELECTED") then
                    love.graphics.setColor(1,1,1,0.5);
                end
                love.graphics.draw(arrow,xoff + 80 + pet.x,yoff-20);
            end
        end
        --draw stats
        love.graphics.setColor(1,1,1);
        love.graphics.draw(game.team.statsIndicator,xoff + 5 + pet.x, yoff + 90)
        love.graphics.setColor(0,0,0);
        local atkOffset = ((pet.atk + pet.tempAtk) > 9) and -6 or 0;
        local hpOffset = ((pet.hp + pet.tempHp) > 9) and -6 or 0;
        love.graphics.print("" .. (pet.atk + pet.tempAtk),xoff + 24 + pet.x + atkOffset, yoff + 91);
        love.graphics.print("" .. (pet.hp + pet.tempHp),xoff + 72 + pet.x + hpOffset, yoff + 89);
        love.graphics.setColor(1,1,1);
        love.graphics.print("" .. (pet.atk + pet.tempAtk),xoff + 22 + pet.x + atkOffset, yoff + 89);
        love.graphics.print("" .. (pet.hp + pet.tempHp),xoff + 70 + pet.x + hpOffset, yoff + 87);
        if pet.tempAtk > 0 then
            love.graphics.rectangle("fill",xoff+22+pet.x+atkOffset,yoff+89+36,15,3);
        end
        if pet.tempHp > 0 then
            love.graphics.rectangle("fill",xoff+70+pet.x+atkOffset,yoff+87+36,15,3);
        end
        --draw level
        if not pet.fromShop then
            love.graphics.draw(levelbg,(xoff - 9) + pet.x, yoff - 16);
            love.graphics.setColor(1,0.725,0);
            if (pet.xp == 1) or (pet.xp > 2) then
                love.graphics.circle("fill",xoff+1+pet.x,yoff+11,4);
            end
            if (pet.xp == 4) then
                love.graphics.circle("fill",xoff+11+pet.x,yoff+11,4);
            end
            if pet.xp == 5 then
                love.graphics.circle("fill",xoff+22+pet.x,yoff+11,4);
                love.graphics.rectangle("fill",xoff+pet.x,yoff+7,22,8);
            end
            if (pet.xp < 2) then
                love.graphics.setColor(0,0,0);
                love.graphics.circle("fill",xoff+22+pet.x,yoff+11,6);
            end
            love.graphics.setColor(1,0.725,0);
            love.graphics.print("" .. pet.level,xoff+14+pet.x,yoff-26);

        end
        love.graphics.setColor(1,1,1);
        --draw perk
            if not pet.isMollywhopped() then
                love.graphics.draw(pet.perk.img,xoff+10+pet.x,yoff+60+pet.y);
            end
        --draw other stuff
        if pet.fainted then
            love.graphics.draw(bandage,xoff+20,yoff+20);
        end
        if pet.frozen then
            love.graphics.draw(ice,xoff+pet.x,yoff+pet.y);
        end
        if pet.fromShop then
            love.graphics.draw(dice[pet.tier],xoff+pet.x,yoff+pet.y-5);
        end
        if pet.linkedPet and pet.linkDraw then
            love.graphics.draw(petlink,xoff+pet.x+68,yoff+pet.y+118);
        end
        if ((pet.id == "molly") or pet.copyingMolly) and not pet.fromShop then
            local flipmod = 0;
            if pet.enemy then flipmod = -100; end
            love.graphics.setColor(0.17,0.8,0.49,0.29);
            love.graphics.ellipse(  "fill",
                                    xoff+ ((xscale == -1) and 100 or 0) + pet.x + 50 + flipmod,
                                    yoff+pet.y+50,
                                    (50 + (100* (pet.level - 1)))*1.11,
                                    (50 + (100* (pet.level - 1)))*0.96
            );
            love.graphics.setColor(0.33,0.81,0.44,0.8);
            love.graphics.ellipse(  "line",
                                    xoff+ ((xscale == -1) and 100 or 0) + pet.x + 50 + flipmod,
                                    yoff+pet.y+50,
                                    (50 + (100* (pet.level - 1)))*1.11,
                                    (50 + (100* (pet.level - 1)))*0.96
            );
            love.graphics.setColor(1,1,1);
        end
        --info box
        local nudge = 0;
        if xoff - 100 < 5 then
            nudge = 5 - (xoff-100);
        end
        if pet.hovered then
            love.graphics.setColor(0,0,0);
            love.graphics.rectangle("fill",xoff+nudge - 100,yoff-130,300,110);
            love.graphics.setColor(1,1,1);
            love.graphics.rectangle("fill",xoff+nudge - 95,yoff-125,290,100);
            love.graphics.draw(dice[pet.tier],xoff+nudge-96,yoff-126);
            love.graphics.setColor(1,0.29,0);
            love.graphics.print(pet.name,xoff+nudge - 52,yoff-129);
            love.graphics.setColor(0.96,0.71,0.08);
            love.graphics.print(pet.getSellPrice(),xoff+nudge+170,yoff-129);
            love.graphics.setColor(0,0,0);
            if pet.abilityText then
                love.graphics.setFont(smallfont_bold);
                local abText = pet.abilityText[pet.level];
                love.graphics.printf(abText,xoff+nudge-90,yoff-90,280);
                love.graphics.setFont(mainfont);
            end
        end
        --perk infobox
        if pet.hovered and (pet.perk.id ~= "default") then
            love.graphics.setColor(0,0,0);
            love.graphics.rectangle("fill",xoff+100+nudge - 100,yoff-30,250,60);
            love.graphics.setColor(1,1,1);
            love.graphics.rectangle("fill",xoff+100+nudge - 95,yoff-25,240,50);
            love.graphics.setColor(0,0,0);
            if pet.perk.effectText then
                love.graphics.setFont(smallfont_bold);
                love.graphics.printf("Perk - " .. pet.perk.name .. " - " .. pet.perk.effectText,xoff+nudge+10,yoff-28,230);
                love.graphics.setFont(mainfont);
            end
        end

        popColor();
    end
    pet.dragKind = "pet";
    pet.canDrag = function()
        return game.manager.state == "SHOP";
    end
    pet.onDragStart = function()
        if game.manager.state == "SHOP" then
            game.manager.dragPet(pet);
        end
    end
    pet.onClick = function()
        if game.manager.state == "SHOP" then
            if game.manager.selectedPet == pet then
                game.manager.clearSelection();
            elseif game.manager.selectedPet and game.manager.selectedPet ~= pet then
                local selected = game.manager.selectedPet;
                pet.combineAction(selected);
                game.manager.clearSelection();
                game.manager.flushStack();
            elseif game.manager.selectedFood then
                if not pet.fromShop then
                    local didBuy = game.manager.buyFood(game.manager.selectedFood);
                    if didBuy then
                        local foodAte = game.manager.selectedFood;
                        foodAte.eat(pet,foodAte);
                        game.manager.flushStack();
                    end
                end
                game.manager.clearSelection();
            else
                game.manager.selectPet(pet);
            end
        end
    end
    pet.onDrop = function(source)
        if game.manager.state ~= "SHOP" or source == pet then
            return false;
        end

        if source.dragKind == "pet" then
            pet.combineAction(source);
            game.manager.flushStack();
            return true;
        end

        if source.dragKind == "food" and not pet.fromShop then
            local didBuy = game.manager.buyFood(source);
            if didBuy then
                source.eat(pet,source);
                game.manager.flushStack();
                return true;
            end
        end

        return false;
    end
    pet.onRightClick = function()
        if game.manager.state == "SHOP" and pet.fromShop then
            pet.frozen = not pet.frozen;
        end
    end
    pet.combineAction = function(otherPet)
        if pet.fromShop then
            return;
        end
        if not otherPet.fromShop then
            if (pet.name == otherPet.name) then
                --combine and level up
                if pet.level < 3 then
                    pet.combine(otherPet);
                    game.team.removePet(otherPet);
                end
            else
                if otherPet.id == "graham" then
                    pet.eatGraham(otherPet);
                else
                    --switch positions
                    game.team.swapPets(pet,otherPet)
                    pet.inputState = "IDLE";
                    otherPet.inputState = "IDLE";
                end
            end
        else
            if (pet.name == otherPet.name) then
                if pet.level < 3 then
                    --combine and level up
                    local success = false;
                    if otherPet.isFromFoodShop then
                        success = game.manager.buyFood(otherPet);
                    else
                        success = game.manager.buyPet(otherPet);
                    end
                    if success then
                        pet.combine(otherPet);
                        game.petShop.buy(otherPet);
                    end
                end
            else
                if otherPet.id == "graham" then
                    if otherPet.isFromFoodShop then
                        local success = game.manager.buyFood(otherPet);
                        if success then
                            pet.eatGraham(otherPet);
                        end
                    else
                        local success = game.manager.buyPet(otherPet);
                        if success then
                            pet.eatGraham(otherPet);
                            game.petShop.buy(otherPet);
                        end
                    end
                else
                    --do nothing if not graham- you can't buy onto a full slot
                    pet.inputState = "IDLE";
                    otherPet.inputState = "IDLE";
                end
            end
        end
    end
    pet.eatGraham = function(graham)
        if graham.level == 1 then
            pet.atk = pet.atk + 3;
            pet.hp = pet.hp + 3;
        elseif graham.level == 2 then
            pet.atk = pet.atk + 10;
            pet.hp = pet.hp + 10;
        else
            pet.atk = pet.atk + graham.atk;
            pet.hp = pet.atk + graham.hp;
        end
        pet.ateFood(function() end,6);
        local mates = pet.getTeammates();
        mates.forEach(function(el) 
            el.friendAteFood(function() end,graham);
        end);
        game.team.removePet(graham);
        if graham.isFromFoodShop then
        end
        game.abilityStack.startProcessing(function() end);
    end
    pet.getTeam = function()
        return pet.enemy and game.enemyTeam or game.team;
    end
    pet.getEnemyTeam = function()
        return pet.enemy and game.team or game.enemyTeam;
    end
    pet.getIndexOnTeam = function(team)
        for i=1,5,1 do
            local tpet = team.listBackToFront[i];
            if tpet == pet then
                return i;
            end
        end
        return 0;
    end
    pet.getIndex = function()
        local team = pet.getTeam();
        return pet.getIndexOnTeam(team);
    end
    pet.getXthOpponentAhead = function(x)
        local eteam = pet.getEnemyTeam();
        local count = 0;
        for i=5,1,-1 do
            local ene = eteam.get(i);
            if ene then
                count = count + 1;
                if count == x then
                    return ene;
                end
            end
        end
        return nil;
    end
    pet.getTeammates = function()
        if pet.fromShop then return Array(); end
        local team = pet.getTeam();
        team = team.getAllPets();
        return team.filter(function(el)
            return el ~= pet;
        end);
    end
    pet.screenCenter = function()
        local team = pet.enemy and game.enemyTeam or game.team;
        local index = pet.getIndex(team);
        local xoff = team.x + ( (pet.enemy and -1 or 1) * 100 * (index-1)) + pet.x;
        local yoff = team.y + pet.y;
        return {x=xoff,y=yoff};
    end
    pet.isMollywhopped = function()
        local pos = pet.getIndex();
        if (pet.id == "molly") or pet.copyingMolly then return true; end
        --check friendlies
        local teammates = pet.getTeammates();
        local mollies = teammates.filter(function(el) 
            return (el.id == "molly") or el.copyingMolly;
        end);
        for i=1,#mollies,1 do
            local mol = mollies[i]
            local molpos = mol.getIndex();
            if math.abs(molpos-pos) < mol.level then
                return true;
            end
        end
        if game.manager.battle then
            local enemies = pet.getEnemyTeam().getAllPets();
            local relativePos = 5+(6-pos);
            local badmollies = enemies.filter(function(el) 
                return (el.id == "molly") or el.copyingMolly;
            end);
            for i=1,#badmollies,1 do
                local mol = badmollies[i]
                local molpos = mol.getIndex();
                if math.abs(molpos-relativePos) < mol.level then
                    return true;
                end
            end
        end
        return false;

    end
    pet.transform = function(newId)
        local template = PetMap[newId];
        pet.id = newId;
        pet.name = template.name;
        local imgurl = template.img;
        if pet.wailmer then
            imgurl = string.gsub(imgurl,"char/","char/wailmer/");
        end
        pet.img = love.graphics.newImage(imgurl);
        pet.tier = template.tier;
        giveAbilitiesToPet(pet);
    end

    return pet;
end

PetMap = {};
PetMap["crapgorps"] = {
    id="crapgorps";
    name = "Crap Gorps";
    atk = 1;
    hp = 3;
    img = "img/char/crapgorps.png";
    tier = 1;
    gender = "m";
}
PetMap["gansley"] = {
    id="gansley";
    name = "Dan Gansley";
    atk = 1;
    hp = 1;
    img = "img/char/gansley.png";
    tier = 1;
    gender = "m";
}
PetMap["ben"] = {
    id="ben";
    name = "Ben";
    atk = 3;
    hp = 2;
    img = "img/char/ben.png";
    tier = 1;
    gender = "m";
}
PetMap["flamethrower"] = {
    id="flamethrower";
    name = "Flamethrower";
    atk = 2;
    hp = 2;
    img = "img/char/flamethrower.png";
    tier = 1;
    gender = "m";
}
PetMap["wellwatcher"] = {
    id="wellwatcher";
    name = "Well Watcher";
    atk = 3;
    hp = 3;
    img = "img/char/wellwatcher.png";
    tier = 1;
    gender = "m";
}
PetMap["skywatcher"] = {
    id="skywatcher";
    name = "Sky Watcher";
    atk = 2;
    hp = 2;
    img = "img/char/skywatcher.png";
    tier = 1;
    notBuyable = true;
    gender = "m";
}
PetMap["workerbee"] = {
    id="workerbee";
    name = "Worker Bee";
    atk = 1;
    hp = 1;
    img = "img/char/workerbee.png";
    tier = 1;
    notBuyable = true;
    gender = "m";
}
PetMap["martin"] = {
    id="martin";
    name = "Martin";
    atk = 1;
    hp = 2;
    img = "img/char/martin.png";
    tier = 1;
    gender = "m";
}
PetMap["gorou"] = {
    id="gorou";
    name = "Gorou";
    atk = 2;
    hp = 3;
    img = "img/char/gorou.png";
    tier = 1;
    gender = "m";
}
PetMap["giovanni"] = {
    id="giovanni";
    name = "Giovanni";
    atk = 3;
    hp = 2;
    img = "img/char/giovanni.png";
    tier = 1;
    gender = "m";
}
PetMap["molly"] = {
    id="molly";
    name = "Molly";
    atk = 2;
    hp = 4;
    img = "img/char/molly.png";
    tier = 2;
    gender = "f";
}
PetMap["simphony"] = {
    id="simphony";
    name = "Simphony";
    atk = 3;
    hp = 1;
    img = "img/char/simphony.png";
    tier = 2;
    gender = "f";
}
PetMap["bugsy"] = {
    id="bugsy";
    name = "Bugsy";
    atk = 1;
    hp = 5;
    img = "img/char/bugsy.png";
    tier = 2;
    gender = "m";
}
PetMap["spike"] = {
    id="spike";
    name = "Spike";
    atk = 4;
    hp = 2;
    img = "img/char/spike.png";
    tier = 2;
    gender = "f";
}
PetMap["feenie"] = {
    id="feenie";
    name = "Phoenica";
    atk = 1;
    hp = 3;
    img = "img/char/feenie.png";
    tier = 2;
    gender = "f";
}
PetMap["gacha"] = {
    id="gacha";
    name = "Gacha";
    atk = 3;
    hp = 3;
    img = "img/char/gacha.png";
    tier = 2;
    gender = "f";
}
PetMap["darkstar"] = {
    id="darkstar";
    name = "Darkstar";
    atk = 4;
    hp = 1;
    img = "img/char/darkstar.png";
    tier = 2;
    gender = "m";
}
PetMap["crusher"] = {
    id="crusher";
    name = "Crusher";
    atk = 2;
    hp = 2;
    img = "img/char/crusher.png";
    tier = 2;
    gender = "m";
}
PetMap["mera"] = {
    id="mera";
    name = "Mera";
    atk = 3;
    hp = 4;
    img = "img/char/mera.png";
    tier = 3;
    gender = "f";
}
PetMap["stink"] = {
    id="stink";
    name = "Stink";
    atk = 2;
    hp = 2;
    img = "img/char/stink.png";
    tier = 3;
    gender = "m";
}
PetMap["poochy"] = {
    id="poochy";
    name = "Poochy";
    atk = 1;
    hp = 5;
    img = "img/char/poochy.png";
    tier = 3;
    gender = "f";
}
PetMap["craig"] = {
    id="craig";
    name = "CRAIG";
    atk = 1;
    hp = 1;
    img = "img/char/craig.png";
    tier = 3;
    notBuyable = true;
    gender = "m";
}
PetMap["naven"] = {
    id="naven";
    name = "Naven";
    atk = 2;
    hp = 2;
    img = "img/char/naven.png";
    tier = 3;
    gender = "m";
}
PetMap["umby"] = {
    id="umby";
    name = "Umbreon";
    atk = 4;
    hp = 5;
    img = "img/char/umby.png";
    tier = 3;
    gender = "m";
}
PetMap["espy"] = {
    id="espy";
    name = "Espeon";
    atk = 3;
    hp = 4;
    img = "img/char/espy.png";
    tier = 3;
    gender = "m";
}
PetMap["sylvie"] = {
    id="sylvie";
    name = "Sylvie";
    atk = 3;
    hp = 1;
    img = "img/char/sylvie.png";
    tier = 3;
    gender = "m";
}
PetMap["beefton"] = {
    id="beefton";
    name = "DR. BEEFTON";
    atk = 1;
    hp = 1;
    img = "img/char/beefton.png";
    tier = 3;
    notBuyable = true;
    gender = "m";
}
PetMap["scaregrow"] = {
    id="scaregrow";
    name = "Scaregrow";
    atk = 1;
    hp = 7;
    img = "img/char/scaregrow.png";
    tier = 3;
    gender = "m";
}
PetMap["howdy"] = {
    id="howdy";
    name = "Howdy";
    atk = 5;
    hp = 3;
    img = "img/char/howdy.png";
    tier = 4;
    gender = "m";
}
PetMap["percy"] = {
    id="percy";
    name = "Percy";
    atk = 4;
    hp = 4;
    img = "img/char/percy.png";
    tier = 4;
    gender = "f";
}
PetMap["wizardtower"] = {
    id="wizardtower";
    name = "Wizard Tower";
    atk = 1;
    hp = 1;
    img = "img/char/wizardtower.png";
    tier = 4;
    notBuyable = true;
    gender = "f"; --for stink targeting purposes. protects percy.
}
PetMap["arnold"] = {
    id="arnold";
    name = "Arnold";
    atk = 2;
    hp = 5;
    img = "img/char/arnold.png";
    tier = 4;
    gender = "m";
}
PetMap["ramsey"] = {
    id="ramsey";
    name = "Ramsey";
    atk = 4;
    hp = 6;
    img = "img/char/ramsey.png";
    tier = 4;
    gender = "m";
}
PetMap["trefor"] = {
    id="trefor";
    name = "Trefor";
    atk = 3;
    hp = 4;
    img = "img/char/trefor.png";
    tier = 4;
    gender = "f";
}
PetMap["carcrash"] = {
    id="carcrash";
    name = "Car Crash";
    atk = 1;
    hp = 1;
    img = "img/char/carcrash.png";
    tier = 4;
    gender = "m";
}
PetMap["bus"] = {
    id="bus";
    name = "Beat-up Bus";
    atk = 1;
    hp = 1;
    img = "img/char/bus.png";
    tier = 1;
    notBuyable = true;
    gender = "nb";
}
PetMap["spellingbee"] = {
    id="spellingbee";
    name = "Spelling Bee";
    atk = 3;
    hp = 5;
    img = "img/char/spellingbee.png";
    tier = 4;
    gender = "m";
}
PetMap["wailmer"] = {
    id="wailmer";
    name = "Wailmer";
    atk = 9;
    hp = 1;
    img = "img/char/wailmer.png";
    tier = 4;
    gender = "m";
}
PetMap["indus"] = {
    id="indus";
    name = "Indus";
    atk = 8;
    hp = 5;
    img = "img/char/indus.png";
    tier = 5;
    gender = "m";
}
PetMap["yoomtah"] = {
    id="yoomtah";
    name = "Yoomtah";
    atk = 7;
    hp = 4;
    img = "img/char/yoomtah.png";
    tier = 5;
    gender = "f";
}
PetMap["weh"] = {
    id="weh";
    name = "Weh!";
    atk = 5;
    hp = 7;
    img = "img/char/weh.png";
    tier = 5;
    gender = "f";
}
PetMap["howie"] = {
    id="howie";
    name = "Howie";
    atk = 6;
    hp = 7;
    img = "img/char/howie.png";
    tier = 5;
    gender = "m";
}
PetMap["tannenbaum"] = {
    id="tannenbaum";
    name = "Tannenbaum";
    atk = 10;
    hp = 6;
    img = "img/char/tannenbaum.png";
    tier = 5;
    gender = "m";
}
PetMap["exit"] = {
    id="exit";
    name = "Exit";
    atk = 11;
    hp = 1;
    img = "img/char/exit.png";
    tier = 5;
    gender = "m";
}
PetMap["justy"] = {
    id="justy";
    name = "Justy";
    atk = 5;
    hp = 5;
    img = "img/char/justy.png";
    tier = 5;
    gender = "m";
}
PetMap["jorge"] = {
    id="jorge";
    name = "Jorge";
    atk = 3;
    hp = 3;
    img = "img/char/jorge.png";
    tier = 5;
    gender = "m";
}
PetMap["vampirebat"] = {
    id="vampirebat";
    name = "Jorge (Batty)";
    atk = 3;
    hp = 3;
    img = "img/char/vampirebat.png";
    tier = 5;
    notBuyable = true;
    gender = "m";
}
PetMap["vampireparrot"] = {
    id="vampireparrot";
    name = "Jorge (Squawking)";
    atk = 3;
    hp = 3;
    img = "img/char/vampireparrot.png";
    tier = 5;
    notBuyable = true;
    gender = "m";
}
PetMap["vampiresquid"] = {
    id="vampiresquid";
    name = "Jorge (Wiggly)";
    atk = 3;
    hp = 3;
    img = "img/char/vampiresquid.png";
    tier = 5;
    notBuyable = true;
    gender = "m";
}
PetMap["jolteon"] = {
    id="jolteon";
    name = "Jolteon";
    atk = 10;
    hp = 6;
    img = "img/char/jolteon.png";
    tier = 6;
    gender = "m";
}
PetMap["zora"] = {
    id="zora";
    name = "Zora";
    atk = 3;
    hp = 13;
    img = "img/char/zora.png";
    tier = 6;
    gender = "f";
}
PetMap["trixie"] = {
    id="trixie";
    name = "Trixie";
    atk = 8;
    hp = 7;
    img = "img/char/trixie.png";
    tier = 6;
    gender = "f"; --for Stink targeting purposes. they auto-parry the sword with nonbiney aegis.
}
PetMap["graham"] = {
    id="graham";
    name = "Graham";
    atk = 12;
    hp = 10;
    img = "img/char/graham.png";
    tier = 6;
    gender = "m";
}
PetMap["greenpikachu"] = {
    id="greenpikachu";
    name = "Green Pikachu";
    atk = 3;
    hp = 11;
    img = "img/char/greenpikachu.png";
    tier = 6;
    gender = "m";
}
PetMap["wound"] = {
    id="wound";
    name = "Wound";
    atk = 4;
    hp = 4;
    img = "img/char/wound.png";
    tier = 6;
    gender = "f"; --for Stink targeting. hits wownd, technically, even though woond is m
}
PetMap["lorelai"] = {
    id="lorelai";
    name = "Lorelai";
    atk = 9;
    hp = 6;
    img = "img/char/lorelai.png";
    tier = 6;
    gender = "f"; 
}
PetMap["rick"] = {
    id="rick";
    name = "Rick";
    atk = 1;
    hp = 1;
    img = "img/char/rick.png";
    tier = 6;
    gender = "m"; 
}
PetTiers = {Array(),Array(),Array(),Array(),Array(),Array()};
RibbonTiers = {Array(),Array(),Array(),Array(),Array(),Array()};
for k,v in pairs(PetMap) do
    if not v.notBuyable then
        PetTiers[v.tier].push(k);
        local ribbCopy = shallowcopy(v);
        ribbCopy.ribbon = false;
        ribbCopy.sticker = false;
        ribbCopy.loadedImg = love.graphics.newImage(ribbCopy.img);
        RibbonTiers[v.tier].push(ribbCopy);
    end
end
