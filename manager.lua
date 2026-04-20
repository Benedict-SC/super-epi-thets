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
            mng.selectedPet.sell(function() 
                mng.state = "SHOP";
                mng.cleanupDrag(); 
            end);
            mng.clearSelection();
        elseif mng.draggingPet then
            game.run.gold = game.run.gold + mng.draggingPet.getSellPrice();
            game.team.removePet(mng.draggingPet);
            mng.state = "ANIMATE";
            mng.draggingPet.sell(function() 
                mng.state = "SHOP";
                mng.cleanupDrag(); 
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
            game.petShop.roll(game.run.tier);
            game.itemShop.roll(game.run.tier);
        end
    end

    mng.endButton = Button("img/end.png");
    mng.endButton.x = 680;
    mng.endButton.y = 10;
    mng.endButton.onMouseUp = function()
        game.run.endTurn();
        mng.state = "BATTLE";
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
            --fade back in
            asyn.doOverTime(0.8,function(percent) 
                game.fadeAlpha = 1-percent;
            end,function() 
                game.fadeAlpha = 0;
                --start the battle
                mng.startBattle();
            end);
        end)
    end
    
    mng.startBattle = function()
        mng.battle = Battle(game.team,game.enemyTeam);
        mng.battle.begin();
    end
    mng.startTurn = function()
        --trigger start of turn abilities
        mng.state = "SHOP";
    end
    mng.triggerRandom = function()
        --interrupt/hijack current battle action to trigger random abilities
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
        return true;
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