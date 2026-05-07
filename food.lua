Food = function(id) 
    local food = Clickable();
    food.id = id;
    local sourceFood = FoodMap[id];
    food.name = sourceFood.name;
    food.tier = sourceFood.tier;
    food.eat = sourceFood.eat;
    food.frozen = false;
    food.discount = 0;

    food.imgUrl = sourceFood.img;
    food.img = love.graphics.newImage(food.imgUrl);
    food.x = 0;
    food.y = 0;
    food.inputState = "IDLE";

    food.priceModifier = 0;

    food.eatTriggers = function(pet)
        pet.ateFood(function() end,food.tier);
        local mates = pet.getTeammates();
        mates.forEach(function(el) 
            el.friendAteFood(function() end,food);
        end);
    end

    food.draw = function(xoff,yoff,xscale)
        pushColor();
        if food.discount > 0 then
            love.graphics.draw(discount,xoff+food.x+22,yoff+food.y-15);
            love.graphics.print(3-food.discount,xoff+food.x+52,yoff+food.y-21)
        end
        if food.inputState == "DRAGGING" then
            love.graphics.setColor(0,0,0);
        end
        love.graphics.draw(food.img,xoff+ ((xscale == -1) and 100 or 0) + food.x,yoff,0,xscale,1);
        if game.manager.state == "SHOP" then
            if food.hovered or food.inputState == "SELECTED" then
                if not (food.inputState == "SELECTED") then
                    love.graphics.setColor(1,1,1,0.5);
                end
                love.graphics.draw(arrow,xoff + 80 + food.x,yoff-20);
            end
        end
        love.graphics.setColor(1,1,1);
        if food.frozen then
            love.graphics.draw(ice,xoff+food.x,yoff+food.y);
        end
        love.graphics.draw(dice[food.tier],xoff+food.x,yoff+food.y-5);
        popColor();
    end
    food.onMouseDown = function()
        if game.manager.state == "SHOP" then
            if food.inputState == "IDLE" then
                food.inputState = "HELD";
            end
        end
    end
    food.onMouseUp = function()
        if game.manager.state == "SHOP" then
            if food.inputState == "HELD" then
                game.manager.selectFood(food);
            elseif food.inputState == "SELECTED" then
                game.manager.clearSelection();
            end
        end
    end
    food.onRightMouseUp = function()
        if game.manager.state == "SHOP" then
            food.frozen = not food.frozen;
        end
    end
    food.onHoverExit = function()
        if game.manager.state == "SHOP" then
            if food.inputState == "HELD" then
                game.manager.dragFood(food);
            end
        end
    end
    food.onHoverEnter = function()
        if game.manager.state == "SHOP" then
            if food.inputState == "DRAGGING" then
                food.inputState = "HELD";
            end
        end
    end
    return food;
end

FoodMap = {};
FoodMap["apple"] = {
    name = "Apple";
    img = "img/food/apple.png";
    tier = 1;
    eat = function(pet,food)
        pet.atk = pet.atk + 1;
        pet.hp = pet.hp + 1;
        food.eatTriggers(pet);
    end
}
FoodMap["corn"] = {
    name = "Corn";
    img = "img/food/corn.png";
    tier = 1;
    eat = function(pet,food)
        local amount = 1;
        if food.multiplier and (food.enemy == pet.enemy) then
            amount = amount * food.multiplier;
        end
        if pet.atk < pet.hp then
            pet.atk = pet.atk + amount;
        else
            pet.hp = pet.hp + amount;
        end
        food.eatTriggers(pet);
    end;
    notBuyable = true;
}
FoodMap["honeyedsnack"] = {
    name = "Honeyed Snack";
    img = "img/food/honeyedsnack.png";
    tier = 1;
    eat = function(pet,food)
        local honey = HoneyedSnackPerk(1);
        pet.gainPerk(honey);
        food.eatTriggers(pet);
    end
}
FoodMap["waterysoup"] = {
    name = "Watery Soup";
    img = "img/food/waterysoup.png";
    tier = 1;
    eat = function(pet,food)
        pet.tempAtk = pet.tempAtk + 2;
        pet.tempHp = pet.tempHp + 2;
        food.eatTriggers(pet);
    end
}
FoodMap["donutgun1"] = {
    name = "Donut Gun";
    img = "img/food/donutgun.png";
    tier = 2;
    eat = function(pet,food)
        local gunperk = DonutGunPerk(1);
        pet.gainPerk(gunperk);
        food.eatTriggers(pet);
    end;
}
FoodMap["donutgun2"] = {
    name = "Donut Gun";
    img = "img/food/donutgun.png";
    tier = 2;
    eat = function(pet,food)
        local gunperk = DonutGunPerk(2);
        pet.gainPerk(gunperk);
        food.eatTriggers(pet);
    end;
    notBuyable = true;
}
FoodMap["donutgun3"] = {
    name = "Donut Gun";
    img = "img/food/donutgun.png";
    tier = 2;
    eat = function(pet,food)
        local gunperk = DonutGunPerk(3);
        pet.gainPerk(gunperk);
        food.eatTriggers(pet);
    end;
    notBuyable = true;
}
FoodMap["toohot"] = {
    name = "Soup that is Too Hot";
    img = "img/food/toohot.png";
    tier = 2;
    eat = function(pet,food)
        pet.hp = pet.hp - 2;
        if pet.hp < 1 then pet.hp = 1; end
        local hotperk = HotHotHotPerk();
        pet.gainPerk(hotperk);
        food.eatTriggers(pet);
    end;
}
FoodMap["betterapple"] = {
    name = "Better Apple";
    img = "img/food/betterapple.png";
    tier = 3;
    eat = function(pet,food)
        pet.atk = pet.atk + 2;
        pet.hp = pet.hp + 2;
        food.eatTriggers(pet);
    end
}
FoodMap["salad"] = {
    name = "Salad Bowl";
    img = "img/food/salad.png";
    tier = 3;
    eat = function(pet,food)
        game.manager.state = "ANIMATE";
        local targets = Array();
        local options = pet.getTeam().getAllPets();
        local picked = options[math.random(#options)];
        targets.push(picked);
        local o2 = options.filter(function(el) return el ~= picked; end);
        if #o2 > 0 then
            targets.push(o2[math.random(#o2)]);
        end
        --targets should now be the conga line of relevant pets
        local funcs = Array();
        for i=1,#targets,1 do
            local targ = targets[i];
            local func = function(next)
                game.manager.animateThrow(targ,targ,"img/heartfulpunch.png",function()
                    targ.atk = targ.atk + 1;
                    targ.hp = targ.hp + 1;
                    food.eatTriggers(pet);
                    next();
                end,0.4)
            end
            funcs.push(func);
        end
        asyn.runSerial(funcs,function() 
            game.manager.state = "SHOP";
        end)
    end
}
FoodMap["spellemup"] = {
    name = "Spell 'em Up Soup";
    img = "img/food/spellemup.png";
    tier = 3;
    eat = function(pet,food)
        game.manager.state = "ANIMATE";
        local targets = Array();
        targets.push(pet);
        local fits = true;
        while fits do
            fits = false;
            local checking = targets[#targets];
            if not checking then error("checking is... " .. #targets); end
            local lastLetter = checking.name:sub(#(checking.name)):lower();
            if lastLetter == "!" then lastLetter = "h"; end --cover for Weh!
            local nextPetAhead = checking.getTeam().get(checking.getIndex() + 1);
            if nextPetAhead then
                local firstLetter = nextPetAhead.name:sub(1,1):lower();
                if firstLetter == lastLetter then
                    fits = true;
                    targets.push(nextPetAhead);
                end
            end
        end
        --targets should now be the conga line of relevant pets
        local funcs = Array();
        for i=1,#targets,1 do
            local targ = targets[i];
            local func = function(next)
                game.manager.animateThrow(targ,targ,"img/heartfulpunch.png",function()
                    targ.atk = targ.atk + 1;
                    targ.hp = targ.hp + 1;
                    food.eatTriggers(pet);
                    next();
                end,0.4)
            end
            funcs.push(func);
        end
        asyn.runSerial(funcs,function() 
            game.manager.state = "SHOP";
        end)
    end
}
FoodMap["oftheday"] = {
    name = "Soup of the Day";
    img = "img/food/oftheday.png";
    tier = 4;
    eat = function(pet,food)
        local sotd = SoupOfTheDayPerk();
        pet.gainPerk(sotd);
        food.eatTriggers(pet);
    end
}
FoodMap["grapes"] = {
    name = "Grapes";
    img = "img/food/grapes.png";
    tier = 4;
    eat = function(pet,food)
        local grap = GrapesPerk();
        pet.gainPerk(grap);
        food.eatTriggers(pet);
    end
}
FoodMap["bestapple"] = {
    name = "Best Apple";
    img = "img/food/bestapple.png";
    tier = 5;
    eat = function(pet,food)
        pet.atk = pet.atk + 3;
        pet.hp = pet.hp + 3;
        food.eatTriggers(pet);
    end
}
FoodMap["chocolate"] = {
    name = "Chocolate";
    img = "img/food/chocolate.png";
    tier = 5;
    eat = function(pet,food)
        pet.addExp(1);
        food.eatTriggers(pet);
    end
}
FoodMap["cocoasoup"] = {
    name = "Cocoa Soup";
    img = "img/food/cocoasoup.png";
    tier = 5;
    eat = function(pet,food)
        local options = pet.getTeam().getAllPets();
        local picked = options[math.random(#options)];
        picked.addExp(1);
        food.eatTriggers(picked);
    end
}
FoodMap["hotdog"] = {
    name = "Hot Dog";
    img = "img/food/hotdog.png";
    tier = 6;
    eat = function(pet,food)
        local targets = game.team.getAllPets();
        if #targets == 0 then 
            return;
        elseif #targets == 1 then
            local target = targets[1];
            target.atk = target.atk + 4;
            target.ateFood(function() end,6);
        else
            local randomPet1 = targets[math.random(#targets)];
            targets.removeElement(randomPet1);
            local randomPet2 = targets[math.random(#targets)];
            randomPet1.atk = randomPet1.atk + 4;
            food.eatTriggers(randomPet1);
            randomPet2.atk = randomPet2.atk + 4;
            food.eatTriggers(randomPet2);
        end
    end
}
FoodTiers = {Array(),Array(),Array(),Array(),Array(),Array()};
for k,v in pairs(FoodMap) do
    if not v.notBuyable then
        FoodTiers[v.tier].push(k);
    end
end