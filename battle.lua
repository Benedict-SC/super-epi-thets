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
                next();
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
        battle.resolveStep(function() battle.startBattle() end);
    end
    battle.startBattle = function()
        --activate start of battle abilities
        battle.resolveStep(function() battle.roundStart() end);
    end
    battle.roundStart = function()
        --resolve "before attack" and "before first attack" abilities
        battle.resolveStep(function() battle.attack() end);
    end
    battle.attack = function()
        local dist = 40;
        local frontFriendly = battle.friendly.get(5);
        local frontEnemy = battle.enemy.get(5);
        --play a fight animation and then
        asyn.doOverTime(0.3,function(percent) 
            frontFriendly.x = dist*percent;
            frontEnemy.x = -1*dist*percent;
        end,function() 
            local fdmg = frontFriendly.atk; --modify this by defense-related perks
            local edmg = frontEnemy.atk; --ditto
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
                battle.processFainting(function() 
                    battle.resolveStep(function() 
                        battle.roundEnd() 
                    end); 
                end);
            end);
        end);
    end
    battle.dealDirectDamage = function(amount,source,target) 
        local totalDamage = amount - target.defense();
        local projectileImage = love.graphics.newImage(pet.projectileUrl);
        local origin = source.screenCenter();
        projectileImage.x = origin.x;
        projectileImage.y = origin.y;
        battle.extras.push(projectileImage);
        local destination = target.screenCenter();
        asyn.doOverTime(0.8,function(percent) 
            --todo: map the percent argument to values of projectileImage.x and y such that the image appears to launch up into the air and come back down on the destination.x and y, where percent is the percent of time through the animation.
        end,function() 
            battle.extras.removeElement(projectileImage);
            target.hp = target.hp - totalDamage;
            if target.hp <= 0 then target.fainted = true; end
            target.hurt(source);
        end);
    end
    battle.processFainting = function(done)
        local all = battle.allPets();
        for i=1,#all,1 do
            if all[i].hp <= 0 then
                all[i].fainted = true;
                --trigger faint abilities
            end
        end
        done();
    end
    battle.roundEnd = function()

        local check = battle.checkOver();
        if check == 2 then
            battle.resolveStep(function() battle.roundStart() end);
        else
            battle.finish(preCheck);
        end
    end
    battle.finish = function(won)
        asyn.doOverTime(0.8,function(percent) 
            game.fadeAlpha = percent;
        end,function() 
            --replace teams with instanced teams;
            game.team = game.savedTeam;
            game.enemyTeam = game.savedEnemyTeam;
            if won == 1 then
                game.run.wins = game.run.wins + 1;
            elseif won == -1 then
                game.run.lives = game.run.lives - 1;
            end
            game.run.newTurn();
            game.petShop.roll(game.run.tier);
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
    battle.extras = Array();
    battle.draw = function()
        for i=1,#battle.extras,1 do
            local img = battle.extras[i];
            love.graphics.draw(img,img.x,img.y);
        end
    end

    return battle;
end