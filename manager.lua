Manager = function()
    local mng = {};
    mng.state = "SHOP";
    mng.hideUI = false;

    mng.sellButton = Button("img/sell.png");
    mng.sellButton.x = 560;
    mng.sellButton.y = 10;
    mng.sellButton.onMouseUp = function()
        if mng.selectedPet then
            game.run.gold = game.run.gold + mng.selectedPet.getSellPrice();
            game.team.removePet(mng.selectedPet);
            mng.state = "ANIMATE";
            game.abilityStack.registerAbilityTrigger(mng.selectedPet,"sell",mng.selectedPet.sell);
            mng.triggerForTeam("friendSold",mng.selectedPet,function()
                mng.state = "SHOP";
            end);
            mng.clearSelection();
        elseif mng.draggingPet then
            game.run.gold = game.run.gold + mng.draggingPet.getSellPrice();
            game.team.removePet(mng.draggingPet);
            mng.state = "ANIMATE";
            game.abilityStack.registerAbilityTrigger(mng.draggingPet,"sell",mng.draggingPet.sell);
            mng.triggerForTeam("friendSold",mng.draggingPet,function()
                mng.state = "SHOP";
            end);
            mng.cleanupDrag();
        end
    end

    mng.rollButton = Button("img/roll.png");
    mng.rollButton.x = 10;
    mng.rollButton.y = 420;
    mng.rollButton.onMouseUp = function()
        if game.run.gold > 0 then
            game.run.gold = game.run.gold - 1;
            mng.triggerGoldSpent(1);
            game.petShop.roll(game.run.tier);
            game.itemShop.roll(game.run.tier);
        end
    end

    mng.endButton = Button("img/end.png");
    mng.endButton.x = 680;
    mng.endButton.y = 10;
    mng.endButton.onMouseUp = function()
        if mng.state == "SHOP" then
            game.run.endTurn();
            mng.state = "ANIMATE";
            mng.triggerForTeam("endOfTurn",nil,function()
                asyn.doOverTime(0.8,function(percent) 
                    game.fadeAlpha = percent;
                end,function() 
                    --replace teams with instanced teams;
                    game.savedTeam = game.team;
                    game.savedEnemyTeam = game.enemyTeam;
                    game.team = game.team.getCopy();
                    game.enemyTeam = game.enemyTeam.getCopy();
                    --hide UI
                    mng.hideUI = true;
                    mng.state = "BATTLE";
                    --fade back in
                    asyn.doOverTime(0.8,function(percent) 
                        game.fadeAlpha = 1-percent;
                    end,function() 
                        game.fadeAlpha = 0;
                        --start the battle
                        mng.startBattle();
                    end);
                end)
            end);
        end
    end
    
    mng.startBattle = function()
        mng.battle = Battle(game.team,game.enemyTeam);
        mng.battle.begin();
    end
    mng.startTurn = function()
        game.run.goldSpentThisTurn = 0;
        --trigger start of turn abilities
        local all = game.team.getAllPets();
        local actions = Array();
        for i=#all,1,-1 do
            local pet = all[i];
            pet.allAbilities().forEach(function(el) 
                if el.id == "startOfTurn" then
                    game.abilityStack.registerAbilityTrigger(pet,"startOfTurn",el.func,args);
                end
            end);
        end
        game.abilityStack.startProcessing(function()
            mng.state = "SHOP";
        end);
    end
    mng.triggerRandom = function()
        --interrupt/hijack current battle action to trigger random abilities
    end
    mng.triggerGoldSpent = function(amount)
        game.run.goldSpentThisTurn = game.run.goldSpentThisTurn + amount;
        if game.run.goldSpentThisTurn > 10 then
            local diff = game.run.goldSpentThisTurn - amount;
            if diff < 10 then
                --correct amount
                amount = amount - (10-diff);
            end
            mng.triggerForTeam("spentGoldPastTen",amount,function()
                    mng.state = "SHOP";
            end);
        end
    end
    mng.flushStack = function()
        if (#game.abilityStack.stack > 0) and not game.abilityStack.callbackSet then
            mng.state = "ANIMATE";
            game.abilityStack.startProcessing(function() 
                mng.state = "SHOP";
            end);
        else 
            return;
        end
    end

    mng.selectPet = function(pet,fromShop)
        mng.setAllIdle();
        pet.inputState = "SELECTED";
        mng.selectedPet = pet;
        mng.selectedFood = nil;
        mng.configureEmptySlots();
    end
    mng.selectFood = function(food)
        mng.setAllIdle();
        food.inputState = "SELECTED";
        mng.selectedFood = food;
        mng.selectedPet = nil;
        --mng.configureEmptySlots() --maybe we do this when we get graham
    end
    mng.dragPet = function(pet,fromShop)
        mng.setAllIdle();
        pet.inputState = "DRAGGING";
        mng.draggingPet = pet;
        mng.draggingFood = nil;
        mng.configureEmptySlots();
    end
    mng.dragFood = function(food,fromShop)
        mng.setAllIdle();
        food.inputState = "DRAGGING";
        mng.draggingFood = food;
        mng.draggingPet = nil;
        --mng.configureEmptySlots();
    end
    mng.setAllIdle = function()
        for i=1,5,1 do
            local tpet = game.team.get(i);
            if tpet then
                tpet.inputState = "IDLE";
            end
        end
        for i=1,#game.petShop.contents,1 do
            local tpet = game.petShop.contents[i];
            if tpet then
                tpet.inputState = "IDLE";
            end
        end
        for i=1,#game.itemShop.contents,1 do
            local food = game.itemShop.contents[i];
            food.inputState = "IDLE";
        end
    end
    mng.buyPet = function(pet)
        local price = 3;
        --if it's like, graham cost-reduced by arnold or something, reduce it
        if game.run.gold < price then
            return false;
        end
        game.run.gold = game.run.gold - price;
        pet.fromShop = false;
        mng.triggerGoldSpent(price);
        return true;
    end
    mng.buyFood = function(food)
        local price = 3;
        --todo: handle cost reduction
        if game.run.gold < price then
            return false;
        end
        game.run.gold = game.run.gold - price;
        game.itemShop.buy(food);
        mng.triggerGoldSpent(price);
        return true;
    end
    mng.triggerForTeam = function(triggerType,args,done)
        local allFriendlyPets = game.team.getAllPets();
        local anyTriggered = false;
        allFriendlyPets.forEach(function(pet) 
            pet.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    anyTriggered = true;
                    game.abilityStack.registerAbilityTrigger(pet,triggerType,el.func,args);
                end
            end);
        end);
        if anyTriggered then
            mng.state = "ANIMATE";
        end
        game.abilityStack.startProcessing(done)
    end
    mng.clearSelection = function()
        if mng.selectedPet then
            mng.selectedPet.inputState = "IDLE";
        end
        if mng.selectedFood then
            mng.selectedFood.inputState = "IDLE";
        end
        mng.selectedPet = nil;
        mng.selectedFood = nil;
        mng.removeEmptySlots();
    end
    mng.cleanupDrag = function()
        if mng.draggingPet then
            mng.draggingPet.inputState = "IDLE";
        end
        if mng.draggingFood then
            mng.draggingFood.inputState = "IDLE";
        end
        mng.draggingPet = nil;
        mng.draggingFood = nil;
        mng.removeEmptySlots();
    end

    mng.emptySlots = Array();
    mng.configureEmptySlots = function()
        for i=1,5,1 do
            if not game.team.get(i) then
                local slot = EmptySlot(i);
                slot.x = game.team.x + ((i-1)*100);
                slot.y = game.team.y;
                mng.emptySlots.push(slot);
            end
        end
    end
    mng.removeEmptySlots = function()
        mng.emptySlots = Array();
    end

    mng.update = function()
        mng.sellButton.inputUpdate(0,0);
        mng.rollButton.inputUpdate(0,0);
        mng.endButton.inputUpdate(0,0);
        for i=1,#mng.emptySlots,1 do
            local slot = mng.emptySlots[i];
            if not slot then break; end
            slot.inputUpdate(0,0);
        end
        if mng.lastFrameMouseDown and not love.mouse.isDown(1) then
            if mng.draggingPet then
                --do the thing where you drop it.
                mng.draggingPet.inputState = "IDLE";
                mng.draggingPet = nil;
            end
        end

        mng.lastFrameMouseDown = love.mouse.isDown(1);
    end
    mng.draw = function()
        mng.sellButton.draw();
        mng.rollButton.draw();
        mng.endButton.draw();
        for i=1,#mng.emptySlots,1 do
            mng.emptySlots[i].draw();
        end
        if mng.draggingPet then
            local mx, my = love.mouse.getPosition();
            pushColor();
            love.graphics.setColor(1,1,1,0.8);
            love.graphics.draw(mng.draggingPet.img,mx-50,my-50);
            love.graphics.setColor(0.95,0.33,0,1);
            love.graphics.print("" .. mng.draggingPet.getSellPrice(),mng.sellButton.x + 42,mng.sellButton.y + 45);
            popColor();
        end
        if mng.draggingFood then
            local mx, my = love.mouse.getPosition();
            pushColor();
            love.graphics.setColor(1,1,1,0.8);
            love.graphics.draw(mng.draggingFood.img,mx-50,my-50);
            popColor();
        end
        if mng.selectedPet then
            pushColor();
            love.graphics.setColor(0.95,0.33,0,1);
            love.graphics.print("" .. mng.selectedPet.getSellPrice(),mng.sellButton.x + 42,mng.sellButton.y + 45);
            popColor();
        end
    end
    return mng;
end