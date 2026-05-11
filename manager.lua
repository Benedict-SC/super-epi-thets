Manager = function()
    local mng = {};
    mng.state = "SHOP";
    mng.hideUI = false;
    mng.inputTargets = Array();
    mng.pointer = {
        hovered = nil,
        pressed = nil,
        rightPressed = nil,
        dragSource = nil,
        pressX = 0,
        pressY = 0,
        lastLeftDown = false,
        lastRightDown = false
    };
    mng.dragThreshold = 8;

    mng.sellButton = Button("img/sell.png");
    mng.sellButton.x = 560;
    mng.sellButton.y = 10;
    mng.sellPet = function(pet)
        if pet.fromShop then
            return;
        end
        game.run.gold = game.run.gold + pet.getSellPrice();
        game.team.removePet(pet);
        mng.state = "ANIMATE";
        game.abilityStack.registerAbilityTrigger(pet,"sell",pet.sell);
        mng.triggerForTeam("friendSold",pet,function()
            mng.state = "SHOP";
        end);
    end
    mng.sellButton.onClick = function()
        if mng.state == "SHOP" and mng.selectedPet then
            mng.sellPet(mng.selectedPet);
            mng.clearSelection();
        end
    end
    mng.sellButton.onDrop = function(source)
        if mng.state ~= "SHOP" or source.dragKind ~= "pet" then
            return false;
        end
        mng.sellPet(source);
        return true;
    end

    mng.rollButton = Button("img/roll.png");
    mng.rollButton.x = 10;
    mng.rollButton.y = 420;
    mng.rollButton.onClick = function()
        if mng.state == "SHOP" and game.run.gold > 0 then
            game.run.gold = game.run.gold - 1;
            mng.triggerGoldSpent(1);
            game.petShop.roll(game.run.tier);
            game.itemShop.roll(game.run.tier);
        end
    end

    mng.endButton = Button("img/end.png");
    mng.endButton.x = 680;
    mng.endButton.y = 10;
    mng.endButton.onClick = function()
        if mng.state == "SHOP" then
            local tb = TeamBuilder();
            game.enemyTeam = tb.generateEnemyTeam(game.run.turn,game.run.wins,5-game.run.lives);
            game.run.endTurn();
            mng.state = "ANIMATE";
            mng.triggerForTeam("endOfTurn",nil,function()
                asyn.doOverTime(0.8,function(percent) 
                    game.fadeAlpha = percent;
                end,function() 
                    --replace team with instanced team
                    game.savedTeam = game.team;
                    game.team = game.team.getCopy();
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
        if mng.battle then
            mng.battle.triggerForAll("randomThingHappens",true,nil,true);
        else
            mng.triggerForAll("randomThingHappens",false,nil,true);
        end
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
    mng.triggerForAll = function(triggerType,args,done,defer)
        local all = game.team.getAllPets();
        local actions = Array();
        for i=#all,1,-1 do
            local pet = all[i];
            pet.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(pet,triggerType,el.func,args);
                end
            end);
        end
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end
    mng.animateThrow = function(source, target, projectileImgUrl, onHit,timeOverride)
        if not projectileImgUrl then
            projectileImgUrl = source.projectileUrl;
        end
        local projectileImage = love.graphics.newImage(projectileImgUrl);
        local origin = source.screenCenter();
        origin.x = origin.x + 20;
        local projectile = {img=projectileImage,x=origin.x,y=origin.y};
        mng.extras.push(projectile);
        local destination = target.screenCenter();
        destination.x = destination.x + 20;
        game.manager.state = "ANIMATE"
        asyn.doOverTime(timeOverride or 0.6,function(percent) 
            local dx = destination.x - origin.x;
            local dy = destination.y - origin.y;
            local arcHeight = 120;
            projectile.x = origin.x + (dx * percent);
            projectile.y = origin.y + (dy * percent) - (4 * arcHeight * percent * (1 - percent));
        end,function() 
            mng.extras.removeElement(projectile);
            local between = mng.getPetsBetween(source,target);
            for i=1,#between,1 do
                local pet = between[i];
                pet.allAbilities().forEach(function(el) 
                    if el.id == "somethingFlewOverhead" then
                        game.abilityStack.registerAbilityTrigger(pet,"somethingFlewOverhead",el.func,args);
                    end
                end);
            end
            onHit();
            if game.manager.battle then
                game.manager.state = "BATTLE";
            else
                game.manager.state = "SHOP";
            end
        end);
    end
    mng.getPetsBetween = function(source,target)
        local tween = Array();
        if source == target then return tween; end
        local pos = source.getIndex();
        local tpos = target.getIndex();
        local isFriend = (source.enemy == target.enemy);
        if isFriend then
            if tpos > pos then
                for i=pos+1,tpos,1 do
                    local there = source.getTeam().get(i);
                    if there and (there ~= target) then
                        tween.push(there)
                    end
                    if there == target then 
                        break; 
                    end
                end
            else 
                for i=pos-1,tpos,-1 do
                    local there = source.getTeam().get(i);
                    if there and (there ~= target) then
                        tween.push(there)
                    end
                    if there == target then 
                        break; 
                    end
                end
            end
        else
            for i=pos+1,5,1 do
                local there = source.getTeam().get(i);
                if there then
                    tween.push(there)
                end
            end
            for i=5,tpos,-1 do
                local there = target.getTeam().get(i);
                if there and (there ~= target) then
                    tween.push(there)
                end
                if there == target then 
                    break; 
                end
            end
        end
        return tween;
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
    mng.beginInputFrame = function()
        mng.inputTargets = Array();
    end
    mng.registerClickable = function(clickable)
        mng.inputTargets.push(clickable);
    end
    mng.hitTest = function(mx,my)
        for i=#mng.inputTargets,1,-1 do
            local clickable = mng.inputTargets[i];
            if clickable and clickable.containsPoint(mx,my) then
                return clickable;
            end
        end
        return nil;
    end
    mng.setHovered = function(nextHovered)
        local current = mng.pointer.hovered;
        if current == nextHovered then
            return;
        end
        if current then
            current.hovered = false;
            current.onHoverExit();
        end
        mng.pointer.hovered = nextHovered;
        if nextHovered then
            nextHovered.hovered = true;
            nextHovered.onHoverEnter();
        end
    end
    mng.finishLeftClick = function(target)
        if target and target == mng.pointer.pressed then
            target.onClick();
        end
    end
    mng.finishDrop = function(target)
        local source = mng.pointer.dragSource;
        if target and target ~= source then
            target.onDrop(source);
        end
        mng.cleanupDrag();
    end
    mng.updateInput = function()
        if (mng.hideUI and (mng.state ~= "ENDING")) or (mng.state ~= "SHOP" and mng.state ~= "BATTLE" and mng.state ~= "ANIMATE" and mng.state ~= "ENDING") then
            mng.setHovered(nil);
            mng.pointer.pressed = nil;
            mng.pointer.rightPressed = nil;
            mng.pointer.dragSource = nil;
            mng.pointer.lastLeftDown = love.mouse.isDown(1);
            mng.pointer.lastRightDown = love.mouse.isDown(2);
            return;
        end

        local mx, my = love.mouse.getPosition();
        local hovered = mng.hitTest(mx,my);
        mng.setHovered(hovered);

        local leftDown = love.mouse.isDown(1);
        local rightDown = love.mouse.isDown(2);
        local leftPressed = leftDown and not mng.pointer.lastLeftDown;
        local leftReleased = mng.pointer.lastLeftDown and not leftDown;
        local rightPressed = rightDown and not mng.pointer.lastRightDown;
        local rightReleased = mng.pointer.lastRightDown and not rightDown;

        if leftPressed then
            mng.pointer.pressed = hovered;
            mng.pointer.pressX = mx;
            mng.pointer.pressY = my;
        elseif leftDown and mng.pointer.pressed and not mng.pointer.dragSource then
            local dx = mx - mng.pointer.pressX;
            local dy = my - mng.pointer.pressY;
            if (dx * dx) + (dy * dy) >= (mng.dragThreshold * mng.dragThreshold) then
                local source = mng.pointer.pressed;
                if source.canDrag() then
                    mng.pointer.dragSource = source;
                    source.onDragStart();
                end
            end
        elseif leftReleased then
            if mng.pointer.dragSource then
                mng.finishDrop(hovered);
            else
                mng.finishLeftClick(hovered);
            end
            mng.pointer.pressed = nil;
            mng.pointer.dragSource = nil;
        end

        if rightPressed then
            mng.pointer.rightPressed = hovered;
        elseif rightReleased then
            if hovered and hovered == mng.pointer.rightPressed then
                hovered.onRightClick();
            end
            mng.pointer.rightPressed = nil;
        end

        mng.pointer.lastLeftDown = leftDown;
        mng.pointer.lastRightDown = rightDown;
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
        if pet.discount then
            price = 3 - pet.discount;
        end
        if game.run.gold < price then
            return false;
        end
        game.run.gold = game.run.gold - price;
        pet.fromShop = false;
        pet.discount = 0;
        mng.triggerGoldSpent(price);
        return true;
    end
    mng.buyFood = function(food)
        local price = 3 - food.discount;
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
        game.endscreen.update();
        mng.sellButton.inputUpdate(0,0);
        mng.rollButton.inputUpdate(0,0);
        mng.endButton.inputUpdate(0,0);
        for i=1,#mng.emptySlots,1 do
            local slot = mng.emptySlots[i];
            if not slot then break; end
            slot.inputUpdate(0,0);
        end
        mng.updateInput();
    end
    mng.draw = function()
        mng.sellButton.draw();
        mng.rollButton.draw();
        pushColor();
        love.graphics.setColor(1,0.38,0);
        love.graphics.draw(dice[game.run.tier],12,474);
        popColor();
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
    mng.extras = Array();
    mng.drawExtras = function()
        for i=1,#(mng.extras),1 do
            local extra = mng.extras[i];
            if not extra then break; end
            love.graphics.draw(extra.img,extra.x,extra.y);
        end
    end
    mng.particles = Array();
    mng.spawnStars = function(location)
        local num = math.random(5,7);
        for i=1,num,1 do
            local randomAngularVelocity = math.random() * (math.pi/12); 
            local neg = math.random(2);
            local scale = math.random();
            if neg == 1 then randomAngularVelocity = randomAngularVelocity * -1; end
            local lifetime = 0.8 + ((math.random() * 0.2) - 0.1);
            local starticle = {
                img=star,
                rvel = randomAngularVelocity,
                xvel = (math.random() * 1.2)-0.6,
                yvel= -1 * 
                math.random(),
                rot=0,
                alpha = 1,
                x=location.x,
                y=location.y,
                scale=scale,
                oo=10
            };
            mng.particles.push(starticle);
            asyn.doOverTime(lifetime,function(percent) 
                starticle.rot = starticle.rot + starticle.rvel;
                starticle.alpha = 1-percent;
                starticle.yvel = starticle.yvel + 0.018;
                starticle.x = starticle.x + starticle.xvel;
                starticle.y = starticle.y + starticle.yvel;
            end,function() 
                mng.particles.removeElement(starticle);
            end)
        end
    end
    mng.drawParticles = function()
        for i=1,#mng.particles,1 do
            pushColor();
            local p = mng.particles[i];
            love.graphics.setColor(1,1,1,p.alpha);
            love.graphics.draw(p.img,p.x,p.y,p.rot,p.scale,p.scale,p.oo,p.oo);
            popColor();
        end
    end
    return mng;
end
