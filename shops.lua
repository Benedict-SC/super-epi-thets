PetShop = function()
    local shop = {};
    shop.contents = Array();
    shop.x = 78;
    shop.y = 420;
    shop.roll = function(tier)
        local frozen = shop.getFrozenPets();
        local slotsLeftOver = game.run.shopSlots - #frozen;
        if slotsLeftOver >= 1 then
            shop.contents = Array();
            shop.contents = shop.contents.concat(frozen);
            shop.contents.forEach(function(x) 
                if x.linkedPet then
                    if not shop.contents.contains(x.linkedPet) then
                        x.linkedPet = nil;
                        x.linkDraw = false;
                    end
                end
            end);
            for i=1,slotsLeftOver,1 do
                local pickedTier = math.random(tier);
                local idsAvailable = PetTiers[pickedTier];
                local petId = idsAvailable[math.random(#idsAvailable)];
                local pet = Pet(petId);
                pet.fromShop = true;
                --pet.x = ((i-1) * 100);
                shop.contents.push(pet);
            end
        end
    end
    shop.lastStars = love.timer.getTime();
    shop.update = function()
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            pet.inputUpdate(shop.x + ((i-1) * 100),shop.y);
        end
        local time = love.timer.getTime();
        if ((time - shop.lastStars) > 0.6) and game.manager.state == "SHOP" then
            shop.lastStars = time;
            for i=1,#shop.contents,1 do
                local pet = shop.contents[i];
                local party = game.team.getAllPets();
                local matches = party.filter(function(el) 
                    return el.id == pet.id;
                end);
                if #matches > 0 then
                    game.manager.spawnStars({x=shop.x + (i*100) - 50,y=shop.y+90});
                end
            end
        end
    end
    shop.draw = function()
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            pet.draw(shop.x + ((i-1) * 100),shop.y,1);
        end
    end
    shop.buy = function(pet)
        shop.contents.removeElement(pet);
        if pet.linkedPet then
            shop.contents.removeElement(pet.linkedPet);
            pet.linkedPet = nil;
        end
    end
    shop.stock = function(id)
        shop.contents.push(Pet(id));
    end
    shop.levelUpBonusStock = function()
        local tier = game.run.tier + 1;
        if tier > 6 then tier = 6; end
        
        local idsAvailable = PetTiers[tier];
        local petId = idsAvailable[math.random(#idsAvailable)];
        local round2 = idsAvailable.filter(function(x) return x ~= petId; end);
        local petId2 = round2[math.random(#round2)];
        local pet = Pet(petId);
        local pet2 = Pet(petId2);
        pet.linkedPet = pet2;
        pet2.linkedPet = pet;
        pet.fromShop = true;
        pet2.fromShop = true;
        pet.linkDraw = true;
        shop.contents.insert(pet2,1);  
        shop.contents.insert(pet,1);         
    end
    shop.getFrozenPets = function()
        local frozen = Array();
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            if pet.frozen then
                frozen.push(pet);
            end
        end
        return frozen;
    end
    shop.applyGrahamDiscount = function(discount)
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            if pet.id == "graham" then
                if not pet.discount then
                    pet.discount = 0;
                end
                pet.discount = pet.discount + discount;
                if pet.discount > 3 then pet.discount = 3; end
            end
        end
    end

    return shop;
end

ItemShop = function()
    local shop = {};
    shop.contents = Array();
    shop.x = 780;
    shop.y = 430;
    shop.roll = function(tier)
        local frozen = shop.getFrozenFood();
        local slotsLeftOver = game.run.itemSlots - #frozen;
        if slotsLeftOver >= 1 then
            shop.contents = Array();
            shop.contents = shop.contents.concat(frozen);
            for i=1,slotsLeftOver,1 do
                local pickedTier = math.random(tier);
                if pickedTier ~= 6 then
                    local idsAvailable = FoodTiers[pickedTier];
                    local foodId = idsAvailable[math.random(#idsAvailable)];
                    local food = Food(foodId);
                    shop.contents.push(food);
                else
                    local isGraham = math.random(4) == 1;
                    if isGraham then
                        local graham = Pet("graham");
                        graham.fromShop = true;
                        graham.isFromFoodShop = true;
                        graham.discount = 0;
                        shop.contents.push(graham);
                    else
                        local idsAvailable = FoodTiers[pickedTier];
                        local foodId = idsAvailable[math.random(#idsAvailable)];
                        local food = Food(foodId);
                        shop.contents.push(food);
                    end
                end
            end
        end
    end
    shop.update = function()
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            food.inputUpdate(shop.x + ((i-1) * 100),shop.y);
        end
    end
    shop.draw = function()
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            food.draw(shop.x + ((i-1) * 100),shop.y,1);
        end
    end
    shop.buy = function(food)
        shop.contents.removeElement(food);
        local triggers = game.team.getAllPets();
        triggers.forEach(function(pet) 
            pet.allAbilities().forEach(function(el) 
                if el.id == "boughtFood" then
                    game.abilityStack.registerAbilityTrigger(pet,"boughtFood",el.func,food);
                end
            end);
        end);
    end
    shop.stock = function(id,highlight)
        shop.contents.push(Food(id));
        if highlight then
            local x = shop.x + (100 * #(shop.contents)) - 50;
            local y = shop.y + 50;
            game.manager.spawnStars({x=x,y=y});
        end
    end
    shop.getFrozenFood = function()
        local frozen = Array();
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            if food.frozen then
                frozen.push(food);
            end
        end
        return frozen;
    end
    shop.stockAdditionalRandomFood = function(discount)
        local pickedTier = math.random(game.run.tier);
        if pickedTier ~= 6 then
            local idsAvailable = FoodTiers[pickedTier];
            local foodId = idsAvailable[math.random(#idsAvailable)];
            local food = Food(foodId);
            food.discount = discount;
            shop.contents.push(food);
        else
            local isGraham = math.random(4) == 1;
            if isGraham then
                local graham = Pet("graham");
                graham.discount = discount;
                graham.fromShop = true;
                graham.isFromFoodShop = true;
                shop.contents.push(graham);
            else
                local idsAvailable = FoodTiers[pickedTier];
                local foodId = idsAvailable[math.random(#idsAvailable)];
                local food = Food(foodId);
                food.discount = discount;
                shop.contents.push(food);
            end
        end
    end
    shop.applyGlobalDiscount = function(discount)
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            food.discount = food.discount + discount;
            if food.discount > 3 then food.discount = 3; end
        end
    end
    return shop;
end