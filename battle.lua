Battle = function(friendly,enemy)
    local battle = {};
    battle.friendly = friendly;
    battle.enemy = enemy;
    battle.begin = function()
        local preCheck = battle.checkOver();
        if preCheck == 2 then
            local enemies = battle.enemy.getAllPets();
            for i=1,#enemies,1 do --mark enemies
                enemies[i].enemy = true;
            end
            battle.beforeBattle();
        else
            battle.finish(preCheck);
        end
    end
    battle.resolveStep = function(next)
        --clear out any dead pets
        local all = battle.allPets();
        for i=1,#all,1 do
            if all[i].fainted then
                battle.removePet(all[i]);
            end
        end
        battle.friendly.lineUp(function() 
            battle.enemy.lineUp(function()
                asyn.wait(0.12,next);
            end);
        end);
    end
    battle.removePet = function(pet)
        if pet.enemy then
            battle.enemy.removePet(pet);
        else
            battle.friendly.removePet(pet);
        end
    end
    battle.beforeBattle = function()
        --activate before battle abilities
        battle.triggerForAll("beforeBattle",nil,function()
            battle.resolveStep(function()
                battle.startBattle();
            end);
        end)
    end
    battle.startBattle = function()
        battle.triggerForAll("startOfBattle",nil,function()
            battle.resolveStep(function()
                battle.roundStart();
            end);
        end)
    end

    battle.roundStart = function()
        local frontFriendly = battle.friendly.get(5);
        local frontEnemy = battle.enemy.get(5);
        local actions = Array();

        if frontFriendly.atk >= frontEnemy.atk then
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,"beforeAttack",el.func,frontFriendly);
                end
            end)
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,"beforeAttack",el.func,frontEnemy);
                end
            end)
        else
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,"beforeAttack",el.func,frontEnemy);
                end
            end)
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,"beforeAttack",el.func,frontFriendly);
                end
            end)
        end
        game.abilityStack.startProcessing(function()
            battle.processFainting(function() 
                battle.resolveStep(function() 
                    if frontFriendly.fainted or frontEnemy.fainted then
                        battle.roundEnd() 
                    else
                        battle.attack() 
                    end
                end); 
            end);
        end)
    end

    battle.attack = function()
        local dist = 40;
        local frontFriendly = battle.friendly.get(5);
        local frontEnemy = battle.enemy.get(5);
        if (not frontFriendly) or (not frontEnemy) then
            battle.processFainting(function() 
                battle.resolveStep(function() 
                    battle.roundEnd();
                end); 
            end);
            return;
        end
        --play a fight animation and then
        asyn.doOverTime(0.3,function(percent) 
            frontFriendly.x = dist*percent;
            frontEnemy.x = -1*dist*percent;
        end,function() 
            local fdmg = frontFriendly.atk + frontFriendly.perk.damageMod - frontEnemy.defense(); --modify this by defense-related perks
            local edmg = frontEnemy.atk + frontEnemy.perk.damageMod - frontFriendly.defense(); --ditto
            frontFriendly.hp = frontFriendly.hp - edmg;
            frontEnemy.hp = frontEnemy.hp - fdmg;
            sound.randomSmack();
            asyn.doOverTime(0.3,function(percent)
                frontFriendly.x = dist - (dist*percent);
                frontEnemy.x = (-1*dist) + (dist*percent);
            end,function() 
                frontFriendly.x = 0;
                frontEnemy.x = 0;
                --activate hurt abilities if fdmg/edmg are positive
                battle.triggerForAll("anyoneAttacked",nil,nil,true)
                battle.triggerForCombatants({ff=frontFriendly,fe=frontEnemy},"afterAttack",nil,nil,true);
                frontFriendly.triggerOne("hurt",{source=frontEnemy,dmg=edmg},nil,true)
                frontEnemy.triggerOne("hurt",{source=frontFriendly,dmg=fdmg},function()
                    battle.processFainting(function() 
                        battle.resolveStep(function() 
                            battle.roundEnd() 
                        end); 
                    end);
                end)
            end);
        end);
    end
    battle.dealDirectDamage = function(amount,source,target,done) 
        local totalDamage = amount - target.defense();
        if totalDamage < 0 then totalDamage = 0; end
        local projectileImage = love.graphics.newImage(source.projectileUrl);
        local origin = source.screenCenter();
        origin.x = origin.x + 20;
        local projectile = {img=projectileImage,x=origin.x,y=origin.y};
        battle.extras.push(projectile);
        local destination = target.screenCenter();
        destination.x = destination.x + 20;
        asyn.doOverTime(0.6,function(percent) 
            local dx = destination.x - origin.x;
            local dy = destination.y - origin.y;
            local arcHeight = 120;
            projectile.x = origin.x + (dx * percent);
            projectile.y = origin.y + (dy * percent) - (4 * arcHeight * percent * (1 - percent));
        end,function() 
            battle.extras.removeElement(projectile);
            target.hp = target.hp - totalDamage;
            if totalDamage == 0 then
                done();
            else 
                target.triggerOne("hurt",{source=source,dmg=totalDamage},done);
            end
        end);
    end
    battle.processFainting = function(done)
        local all = battle.allPets();
        for i=1,#all,1 do
            if (all[i].hp <= 0) and (not all[i].fainted) then
                local fainter = all[i];
                fainter.fainted = true;
                fainter.allAbilities().forEach(function(el)
                    if el.id == "faint" then
                        game.abilityStack.registerAbilityTrigger(fainter,"faint",el.func);
                    end
                end);
                local teammates = fainter.getTeam().getAllPets();
                teammates.forEach(function(tm) 
                    tm.allAbilities().forEach(function(el) 
                        if el.id == "friendFaints" and not (tm == fainter) then
                            game.abilityStack.registerAbilityTrigger(tm,"friendFaints",el.func,fainter);
                        end
                    end);
                end);
            end
        end
        game.abilityStack.startProcessing(done);
    end
    battle.roundEnd = function()

        local check = battle.checkOver();
        if check == 2 then
            battle.resolveStep(function() battle.roundStart() end);
        else
            battle.finish(check);
        end
    end
    battle.finish = function(won)
        asyn.doOverTime(0.8,function(percent) 
            game.fadeAlpha = percent;
        end,function() 
            --replace teams with original teams;
            game.team = game.savedTeam;
            for i=1,5,1 do
                if game.team.get(i) then
                    game.team.get(i).battlesFought = game.team.get(i).battlesFought + 1;
                end
            end
            game.enemyTeam = game.savedEnemyTeam;
            if won == 1 then
                game.run.wins = game.run.wins + 1;
            elseif won == -1 then
                game.run.lives = game.run.lives - 1;
            end
            game.run.newTurn();
            game.petShop.roll(game.run.tier);
            game.itemShop.roll(game.run.tier);
            --hide UI
            game.manager.hideUI = false;
            --fade back in
            asyn.doOverTime(0.8,function(percent) 
                game.fadeAlpha = 1-percent;
            end,function() 
                game.fadeAlpha = 0;
                game.manager.state = "START";
                game.manager.startTurn();
            end);
        end)
    end

    battle.checkOver = function() --1 win, 0 draw, -1 enemy, 2 not over yet
        local fdead = battle.friendly.headcount() == 0;
        local edead = battle.enemy.headcount() == 0;
        if fdead and edead then 
            return 0;
        elseif fdead then
            return -1;
        elseif edead then
            return 1;
        else
            return 2;
        end

    end
    battle.allPets = function()
        local frien = battle.friendly.getAllPets();
        local enem = battle.enemy.getAllPets();
        local all = frien.concat(enem);
        table.sort(all,function(p1,p2) 
            return p1.atk > p2.atk;
        end);
        return all;
    end
    battle.triggerForAll = function(triggerType,args,done,defer)
        local all = battle.allPets();
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
    battle.triggerForCombatants = function(combatants,triggerType,args,done,defer)
        if not combatants then combatants = {}; end
        local frontFriendly = combatants.ff or battle.friendly.get(5);
        local frontEnemy = combatants.fe or battle.enemy.get(5);
        if frontFriendly.atk >= frontEnemy.atk then
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,triggerType,el.func,frontFriendly);
                end
            end)
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,triggerType,el.func,frontEnemy);
                end
            end)
        else
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,triggerType,el.func,frontEnemy);
                end
            end)
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,triggerType,el.func,frontFriendly);
                end
            end)
        end
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end
    battle.extras = Array();
    battle.draw = function()
        for i=1,#battle.extras,1 do
            local extra = battle.extras[i];
            if not extra then break; end
            love.graphics.draw(extra.img,extra.x,extra.y);
        end
    end

    return battle;
end
