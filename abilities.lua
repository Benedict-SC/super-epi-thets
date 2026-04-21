giveAbilitiesToPet = function(pet,copying)
    pet.startOfTurn = function(done) done(); end
    pet.endOfTurn = function(done) done(); end
    pet.summoned = function(done) done(); end
    pet.sell = function(done) done(); end
    pet.friendSold = function(done,friend) done(); end
    pet.startOfBattle = function(done) done(); end
    pet.beforeBattle = function(done) done(); end
    pet.beforeAttack = function(done,opponent) done(); end
    pet.hurt = function(done,source) done(); end
    pet.afterAttack = function(done,opponent) done(); end
    pet.faint = function(done) done(); end
    pet.friendFaints = function(done,friend) done(); end
    pet.gainedAilment = function(done,ailment) done(); end
    pet.friendGainedAilment = function(done,friend) done(); end
    pet.spentGoldPastTen = function(done,gold) done(); end
    pet.randomThingHappens = function(done) done(); end
    pet.emptyBackSpace = function(done) done(); end
    pet.friendAteApple = function(done) done(); end
    pet.ateFood = function(done,tier) done(); end
    pet.boughtFood = function(done) done(); end
    pet.fedToFriend = function(done,friend) done(); end
    pet.friendBehindHurt = function(done,friend) done(); end
    pet.friendAheadHurt = function(done,friend) done(); end
    pet.twoFriendsAttack = function(done) done(); end
    pet.somethingFlewOverhead = function(done) done(); end
    pet.anyoneAttacked = function(done) done(); end
    pet.abilities = Array();

    if pet.id == "ben" then
        pet.startOfBattle = function(done)
            local leavesAtOrBelow = 4-pet.level;
            if math.random(6) <= leavesAtOrBelow then
                if pet.enemy then
                    game.enemyTeam.removePet(pet);
                else
                    game.team.removePet(pet);
                end
            end
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Start of battle: Randomly leaves (1/2 chance)",
            "Start of battle: Randomly leaves (1/3 chance)",
            "Start of battle: Randomly leaves (1/6 chance)"
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}});
    elseif pet.id == "crapgorps" then
        pet.startOfBattle = function(done)
            local extraHealth = pet.battlesFought;
            if pet.level == 1 then
                extraHealth = math.floor(extraHealth / 2);
            elseif pet.level == 3 then
                extraHealth = extraHealth * 2;
            end
            pet.hp = pet.hp + extraHealth;
            done();
        end
        pet.abilityText = {
            "Start of battle: Gain 1 health for each 2 battles fought",
            "Start of battle: Gain 1 health for each battle fought",
            "Start of battle: Gain 2 health for each battle fought"
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}});
    elseif pet.id == "giovanni" then
        pet.startOfTurn = function(done)
            local types1 = ArrayFromRawArray({"waterysoup","toohot"});
            --local types2 = ArrayFromRawArray({"spellemup","oftheday"});
            --local types3 = ArrayFromRawArray({"cocoasoup","lavacid"});
            local types = types1;
            --[[if pet.level > 1 then
                types = types.concat(types2);
            end
            if pet.level > 2 then
                types = types.concat(types3);
            end]]--
            local soupType = types[math.random(#types)];

            game.itemShop.stock(soupType);
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Start of turn: Stock a Random soup up to tier 2.",
            "Start of turn: Stock a Random soup up to tier 4.",
            "Start of turn: Stock a Random soup up to tier 6."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfTurn",func = pet.startOfTurn}})
    elseif pet.id == "flamethrower" then
        pet.beforeAttack = function(done,opponent)
            local toasty1 = ToastyAilment();
            opponent.gainPerk(toasty1);
            if pet.level > 1 then
                local opp2 = pet.getXthOpponentAhead(2);
                if opp2 then
                    local toasty2 = ToastyAilment();
                    opp2.gainPerk(toasty2)
                end
            end
            if pet.level > 2 then
                local opp3 = pet.getXthOpponentAhead(3);
                if opp3 then
                    local toasty3 = ToastyAilment();
                    opp3.gainPerk(toasty3)
                end
            end
            done();
        end
        pet.abilityText = {
            "Before attack: Give Toasty to the first enemy ahead.",
            "Before attack: Give Toasty to the first two enemies ahead.",
            "Before attack: Give Toasty to the first three enemies ahead."
        }
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func = pet.beforeAttack}})
    elseif pet.id == "martin" then
        pet.friendGainedAilment = function(done,friend)
            if not pet.enemy then
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
            end
            local pos = pet.screenCenter();
            local coin = {img=love.graphics.newImage("img/coin.png"),x=pos.x+50,y=pos.y};
            game.manager.battle.extras.push(coin);
            asyn.doOverTime(0.4,function(percent) 
                coin.y = math.floor(pos.y - (percent*60));
            end,function() 
                asyn.wait(0.2,function() 
                    game.manager.battle.extras.removeElement(coin);
                    done();
                end)
            end)
        end
        pet.abilityText = {
            "Friend gained ailment: Gain 1 gold next turn.",
            "Friend gained ailment: Gain 2 gold next turn.",
            "Friend gained ailment: Gain 3 gold next turn.",
        }
        pet.abilities = ArrayFromRawArray({{id="friendGainedAilment",func = pet.friendGainedAilment}})
    elseif pet.id == "gansley" then
        pet.projectileUrl = "img/gansleybuck.png";
        pet.beforeAttack = function(done,opponent)
            local max = 3;
            if pet.level == 2 then
                max = 8;
            elseif pet.level == 3 then
                max = 20;
            end
            local damageAmount = math.random(max);
            local coinflip = math.random(2);
            local target = opponent;
            if coinflip == 1 then
                target = pet;
                sound.play("danuhoh");
            else
                sound.play("danha");
            end
            game.manager.triggerRandom();
            game.manager.battle.dealDirectDamage(damageAmount,pet,target,done);
        end
        pet.abilityText = {
            "Before attack: Deal between 1 and 3 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 8 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 20 damage to self or enemy ahead, Randomly."
        }
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func=pet.beforeAttack}})
    elseif pet.id == "wellwatcher" then
        pet.startOfBattle = function(done)
            pet.fainted = true;
            sound.play("wellwatch");
            if not pet.enemy then
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
            end
            asyn.wait(0.6,function() pet.faint(done) end);
        end
        pet.faint = function(done)
            if not pet.alreadyDied then
                newWatcher = pet.getCopy();
                newWatcher.projectileUrl = "img/lightning.png";
                asyn.wait(0.5,function() 
                    sound.play("thunder");
                end);
                newWatcher.alreadyDied = true;
                newWatcher.summoned = function(newdone)
                    local dmg = pet.level == 3 and 10 or (pet.level == 2 and 6 or 3);
                    game.manager.battle.dealDirectDamage(dmg,newWatcher,newWatcher,newdone);
                end
                newWatcher.hurt = function(newdone,source)
                    if source == newWatcher then
                        newWatcher.transform("skywatcher");
                        asyn.wait(0.4,newdone);
                    else
                        newdone();
                    end
                end
                local spot = pet.getIndex();
                local team = pet.getTeam();
                team.replacePet(spot,newWatcher);
                newWatcher.summoned(done);
            end
        end
        pet.abilityText = {
            "Start of battle: Gain 1 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 3 damage and transforms into Sky Watcher.",
            "Start of battle: Gain 2 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 6 damage and transforms into Sky Watcher.",
            "Start of battle: Gain 3 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 10 damage and transforms into Sky Watcher."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "skywatcher" then
        pet.somethingFlewOverhead = function(done)
            pet.atk = pet.atk + pet.level;
            pet.hp = pet.hp + pet.level;
            done();
        end
        pet.abilityText = {
            "Something flew overhead: Gain 1 attack and HP.",
            "Something flew overhead: Gain 2 attack and HP.",
            "Something flew overhead: Gain 3 attack and HP."
        }
        pet.abilities = ArrayFromRawArray({{id="somethingFlewOverhead",func = pet.somethingFlewOverhead}})
    elseif pet.id == "gorou" then
        pet.sell = function(done)
            game.itemShop.stock("donutgun" .. pet.level);
            done();
        end
        pet.abilityText = {
            "Sell: Stock one Donut Gun.",
            "Sell: Stock one Donut Gun with double effect.",
            "Sell: Stock one Donut Gun with triple effect."
        }
        pet.abilities = ArrayFromRawArray({{id="sell",func = pet.sell}})
    elseif pet.id == "simphony" then
        pet.friendFaints = function(done,friend)
            pet.hp = pet.hp + 1 + ((pet.level-1)*2);
            done();
        end
        pet.abilityText = {
            "Friend faints: Gain 1 HP.",
            "Friend faints: Gain 3 HP.",
            "Friend faints: Gain 5 HP."
        }
        pet.abilities = ArrayFromRawArray({{id="friendFaints",func = pet.friendFaints}})
    end
end
