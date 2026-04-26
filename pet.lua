Pet = function(id) 
    local pet = Clickable();
    pet.id = id;
    pet.battlesFought = 0;
    pet.level = 1;
    pet.xp = 0;
    local sourcePet = PetMap[id];
    pet.name = sourcePet.name;
    pet.atk = sourcePet.atk;
    pet.hp = sourcePet.hp;
    pet.defense = function() return 0; end
    pet.tier = sourcePet.tier;
    pet.gender = sourcePet.gender;
    pet.frozen = false;
    pet.perk = Perk();

    pet.tempAtk = 0;
    pet.tempHp = 0;

    pet.imgUrl = sourcePet.img;
    pet.img = love.graphics.newImage(pet.imgUrl);
    pet.projectileUrl = "img/rock.png";
    pet.x = 0;
    pet.y = 0;
    pet.inputState = "IDLE";

    pet.priceModifier = 0;

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
            pet.addExp(1);
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
    end
    pet.losePerk = function()
        if pet.perk.lostPerk then
            game.abilityStack.registerAbilityTrigger(pet,"lostPerk",pet.perk.lostPerk)
        end
        pet.perk = Perk();
    end
    pet.gainPerk = function(perk)
        pet.losePerk();
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
                        game.abilityStack.registerAbilityTrigger(tm,"friendGainedAilment",el.func,perk);
                    end
                end);
            end);
            game.abilityStack.startProcessing();
        else
            --here's where we'd trigger gained-perk effects... TIMMY TURNER'S DAD MEME!!!
        end
    end
    pet.fling = function(pos,failedFilename)

    end
    pet.getCopy = function()
        local newPet = Pet(pet.id);
        newPet.atk = pet.atk + pet.tempAtk;
        newPet.hp = pet.hp + pet.tempHp;
        newPet.xp = pet.xp;
        newPet.level = pet.level;
        newPet.enemy = pet.enemy;
        newPet.battlesFought = pet.battlesFought;
        newPet.priceModifier = pet.priceModifier;
        newPet.perk = pet.perk.copy();
        newPet.perk.owner = newPet;
        return newPet;
    end
    pet.allAbilities = function()
        return pet.abilities.concat(pet.perk.abilities);
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
        if pet.discount and pet.discount > 0 then
            love.graphics.draw(discount,xoff+pet.x+22,yoff+pet.y-15);
            love.graphics.print(3-pet.discount,xoff+pet.x+52,yoff+pet.y-21)
        end
        if pet.inputState == "DRAGGING" then
            love.graphics.setColor(0,0,0);
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
        local atkOffset = (pet.atk > 9) and -6 or 0;
        local hpOffset = (pet.hp > 9) and -6 or 0;
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
            love.graphics.draw(pet.perk.img,xoff+10+pet.x,yoff+60+pet.y);
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
        --info box
        if pet.hovered then
            local nudge = 0;
            if xoff - 100 < 5 then
                nudge = 5 - (xoff-100);
            end
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

        popColor();
    end
    pet.onMouseDown = function()
        if game.manager.state == "SHOP" then
            if pet.inputState == "IDLE" then
                pet.inputState = "HELD";
            end
        end
    end
    pet.onMouseUp = function()
        if game.manager.state == "SHOP" then
            if pet.inputState == "HELD" then
                game.manager.selectPet(pet);
            elseif pet.inputState == "SELECTED" then
                game.manager.clearSelection();
            elseif game.manager.draggingPet and game.manager.draggingPet ~= pet then
                local dragged = game.manager.draggingPet;
                pet.combineAction(dragged);
                game.manager.cleanupDrag();
                game.manager.flushStack();
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
            elseif game.manager.draggingFood then
                if not pet.fromShop then
                    local didBuy = game.manager.buyFood(game.manager.draggingFood);
                    if didBuy then
                        local foodAte = game.manager.draggingFood;
                        foodAte.eat(pet,foodAte);
                        game.manager.flushStack();
                    end
                end
                game.manager.cleanupDrag();
            end
        end
    end
    pet.onRightMouseUp = function()
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
                --switch positions
                game.team.swapPets(pet,otherPet)
                pet.inputState = "IDLE";
            end
        else
            if (pet.name == otherPet.name) then
                if pet.level < 3 then
                    --combine and level up
                    local success = game.manager.buyPet(pet);
                    if success then
                        pet.combine(otherPet);
                        game.petShop.buy(otherPet);
                    end
                end
            else
                --do nothing- you can't buy onto a full slot
            end
        end
    end
    pet.onHoverExit = function()
        if game.manager.state == "SHOP" then
            if pet.inputState == "HELD" then
                game.manager.dragPet(pet);
            end
        end
    end
    pet.onHoverEnter = function()
        if game.manager.state == "SHOP" then
            if pet.inputState == "DRAGGING" then
                pet.inputState = "HELD";
            end
        end
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
    pet.transform = function(newId)
        local template = PetMap[newId];
        pet.id = newId;
        pet.name = template.name;
        pet.img = love.graphics.newImage(template.img);
        pet.tier = template.tier;
        giveAbilitiesToPet(pet);
    end

    return pet;
end

PetMap = {};
PetMap["crapgorps"] = {
    name = "Crap Gorps";
    atk = 1;
    hp = 3;
    img = "img/char/crapgorps.png";
    tier = 1;
    gender = "m";
}
PetMap["gansley"] = {
    name = "Dan Gansley";
    atk = 1;
    hp = 1;
    img = "img/char/gansley.png";
    tier = 1;
    gender = "m";
}
PetMap["ben"] = {
    name = "Ben";
    atk = 3;
    hp = 2;
    img = "img/char/ben.png";
    tier = 1;
    gender = "m";
}
PetMap["flamethrower"] = {
    name = "Flamethrower";
    atk = 2;
    hp = 2;
    img = "img/char/flamethrower.png";
    tier = 1;
    gender = "m";
}
PetMap["wellwatcher"] = {
    name = "Well Watcher";
    atk = 3;
    hp = 3;
    img = "img/char/wellwatcher.png";
    tier = 1;
    gender = "m";
}
PetMap["skywatcher"] = {
    name = "Sky Watcher";
    atk = 2;
    hp = 2;
    img = "img/char/skywatcher.png";
    tier = 1;
    notBuyable = true;
    gender = "m";
}
PetMap["martin"] = {
    name = "Martin";
    atk = 1;
    hp = 2;
    img = "img/char/martin.png";
    tier = 1;
    gender = "m";
}
PetMap["gorou"] = {
    name = "Gorou";
    atk = 2;
    hp = 3;
    img = "img/char/gorou.png";
    tier = 1;
    gender = "m";
}
PetMap["giovanni"] = {
    name = "Giovanni";
    atk = 3;
    hp = 2;
    img = "img/char/giovanni.png";
    tier = 1;
    gender = "m";
}
PetMap["molly"] = {
    name = "Molly";
    atk = 2;
    hp = 4;
    img = "img/char/molly.png";
    tier = 2;
    gender = "f";
}
PetMap["simphony"] = {
    name = "Simphony";
    atk = 3;
    hp = 1;
    img = "img/char/simphony.png";
    tier = 2;
    gender = "f";
}
PetMap["bugsy"] = {
    name = "Bugsy";
    atk = 1;
    hp = 5;
    img = "img/char/bugsy.png";
    tier = 2;
    gender = "m";
}
PetMap["spike"] = {
    name = "Spike";
    atk = 4;
    hp = 2;
    img = "img/char/spike.png";
    tier = 2;
    gender = "f";
}
PetMap["feenie"] = {
    name = "Phoenica";
    atk = 1;
    hp = 3;
    img = "img/char/feenie.png";
    tier = 2;
    gender = "f";
}
PetMap["gacha"] = {
    name = "Gacha";
    atk = 3;
    hp = 3;
    img = "img/char/gacha.png";
    tier = 2;
    gender = "f";
}
PetMap["darkstar"] = {
    name = "Darkstar";
    atk = 4;
    hp = 1;
    img = "img/char/darkstar.png";
    tier = 2;
    gender = "m";
}
PetMap["crusher"] = {
    name = "Crusher";
    atk = 2;
    hp = 2;
    img = "img/char/crusher.png";
    tier = 2;
    gender = "m";
}
PetMap["mera"] = {
    name = "Mera";
    atk = 3;
    hp = 4;
    img = "img/char/mera.png";
    tier = 3;
    gender = "f";
}
PetMap["stink"] = {
    name = "Stink";
    atk = 2;
    hp = 2;
    img = "img/char/stink.png";
    tier = 3;
    gender = "m";
}
PetMap["poochy"] = {
    name = "Poochy";
    atk = 1;
    hp = 5;
    img = "img/char/poochy.png";
    tier = 3;
    gender = "f";
}
PetMap["craig"] = {
    name = "CRAIG";
    atk = 1;
    hp = 1;
    img = "img/char/craig.png";
    tier = 3;
    notBuyable = true;
    gender = "m";
}
PetMap["naven"] = {
    name = "Naven";
    atk = 2;
    hp = 2;
    img = "img/char/naven.png";
    tier = 3;
    gender = "m";
}
PetMap["umby"] = {
    name = "Umbreon";
    atk = 4;
    hp = 5;
    img = "img/char/umby.png";
    tier = 3;
    gender = "m";
}
PetMap["espy"] = {
    name = "Espeon";
    atk = 3;
    hp = 4;
    img = "img/char/espy.png";
    tier = 3;
    gender = "m";
}
PetMap["sylvie"] = {
    name = "Sylvie";
    atk = 3;
    hp = 1;
    img = "img/char/sylvie.png";
    tier = 3;
    gender = "m";
}
PetMap["beefton"] = {
    name = "DR. BEEFTON";
    atk = 1;
    hp = 1;
    img = "img/char/beefton.png";
    tier = 3;
    notBuyable = true;
    gender = "m";
}
PetMap["scaregrow"] = {
    name = "Scaregrow";
    atk = 1;
    hp = 7;
    img = "img/char/scaregrow.png";
    tier = 3;
    gender = "m";
}
PetMap["howdy"] = {
    name = "Howdy";
    atk = 5;
    hp = 3;
    img = "img/char/howdy.png";
    tier = 4;
    gender = "m";
}
PetMap["indus"] = {
    name = "Indus";
    atk = 8;
    hp = 5;
    img = "img/char/indus.png";
    tier = 5;
    gender = "m";
}
PetMap["jolteon"] = {
    name = "Jolteon";
    atk = 10;
    hp = 6;
    img = "img/char/jolteon.png";
    tier = 6;
    gender = "m";
}
PetTiers = {Array(),Array(),Array(),Array(),Array(),Array()};
for k,v in pairs(PetMap) do
    if not v.notBuyable then
        PetTiers[v.tier].push(k);
    end
end