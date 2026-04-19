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
    pet.fling = function(pos)

    end
    pet.getCopy = function()
        local newPet = Pet(pet.id);
        newPet.atk = pet.atk;
        newPet.hp = pet.hp;
        newPet.xp = pet.xp;
        newPet.level = pet.level;
        newPet.battlesFought = pet.battlesFought;
        newPet.priceModifier = pet.priceModifier;
        return newPet;
    end

    pet.draw = function(xoff,yoff,xscale)
        pushColor();
        if pet.inputState == "DRAGGING" then
            love.graphics.setColor(0,0,0);
        end
        love.graphics.draw(pet.img,xoff+ ((xscale == -1) and 100 or 0) + pet.x,yoff,0,xscale,1);
        if game.manager.state == "SHOP" then
            if pet.hovered or pet.inputState == "SELECTED" then
                if not (pet.inputState == "SELECTED") then
                    love.graphics.setColor(1,1,1,0.5);
                end
                love.graphics.draw(arrow,xoff + 80 + pet.x,yoff-20);
            end
        end
        love.graphics.setColor(1,1,1);
        love.graphics.draw(game.team.statsIndicator,xoff + 5 + pet.x, yoff + 90)
        love.graphics.setColor(0,0,0);
        love.graphics.print("" .. pet.atk,xoff + 24 + pet.x, yoff + 91);
        love.graphics.print("" .. pet.hp,xoff + 72 + pet.x, yoff + 89);
        love.graphics.setColor(1,1,1);
        love.graphics.print("" .. pet.atk,xoff + 22 + pet.x, yoff + 89);
        love.graphics.print("" .. pet.hp,xoff + 70 + pet.x, yoff + 87);
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
            elseif game.manager.selectedPet and game.manager.selectedPet ~= pet then
                local selected = game.manager.selectedPet;
                pet.combineAction(selected);
                game.manager.clearSelection();
            end
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
    pet.getIndex = function(team)
        for i=1,5,1 do
            local tpet = team.listBackToFront[i];
            if tpet == pet then
                return i;
            end
        end
        return 0;
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
}
PetMap["gansley"] = {
    name = "Dan Gansley";
    atk = 1;
    hp = 1;
    img = "img/char/gansley.png";
    tier = 1;
}
PetMap["ben"] = {
    name = "Ben";
    atk = 3;
    hp = 2;
    img = "img/char/ben.png";
    tier = 1;
}
PetMap["flamethrower"] = {
    name = "Flamethrower";
    atk = 2;
    hp = 2;
    img = "img/char/flamethrower.png";
    tier = 1;
}
PetMap["wellwatcher"] = {
    name = "Well Watcher";
    atk = 3;
    hp = 3;
    img = "img/char/wellwatcher.png";
    tier = 1;
}
PetMap["skywatcher"] = {
    name = "Sky Watcher";
    atk = 2;
    hp = 2;
    img = "img/char/skywatcher.png";
    tier = 1;
    notBuyable = true;
}
PetMap["martin"] = {
    name = "Martin";
    atk = 1;
    hp = 2;
    img = "img/char/martin.png";
    tier = 1;
}
PetMap["gorou"] = {
    name = "Gorou";
    atk = 2;
    hp = 3;
    img = "img/char/gorou.png";
    tier = 1;
}
PetMap["giovanni"] = {
    name = "Giovanni";
    atk = 3;
    hp = 2;
    img = "img/char/giovanni.png";
    tier = 1;
}
PetMap["molly"] = {
    name = "Molly";
    atk = 2;
    hp = 4;
    img = "img/char/molly.png";
    tier = 2;
}
PetMap["simphony"] = {
    name = "Simphony";
    atk = 3;
    hp = 1;
    img = "img/char/simphony.png";
    tier = 2;
}
PetMap["bugsy"] = {
    name = "Bugsy";
    atk = 1;
    hp = 5;
    img = "img/char/bugsy.png";
    tier = 2;
}
PetTiers = {Array(),Array(),Array(),Array(),Array(),Array()};
for k,v in pairs(PetMap) do
    if not v.notBuyable then
        PetTiers[v.tier].push(k);
    end
end