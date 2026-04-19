giveAbilitiesToPet = function(pet,copying){
    pet.startOfTurn = function() end
    pet.endOfTurn = function() end
    pet.summoned = function() end
    pet.sell = function() end
    pet.friendSold = function(friend) end
    pet.startOfBattle = function() end
    pet.beforeBattle = function() end
    pet.beforeFirstAttack = function() end
    pet.beforeAttack = function(opponent) end
    pet.hurt = function(source) end
    pet.afterAttack = function(opponent) end
    pet.faint = function() end
    pet.friendGainedAilment = function(friend) end
    pet.spentGoldPastTen = function(amount) end
    pet.randomThingHappens = function() end
    pet.emptyBackSpace = function() end
    pet.friendAteApple = function() end
    pet.boughtFood = function() end
    pet.fedToFriend = function(friend) end
    pet.friendBehindHurt = function(friend) end
    pet.friendAheadHurt = function(friend) end
    pet.friendFaints = function(friend) end
    pet.twoFriendsAttack = function() end
    pet.somethingFlewOverhead = function() end

    if pet.id == "ben" then
        pet.startOfBattle = function()
            local leavesAtOrBelow = 4-pet.level;
            if math.random(6) <= leavesAtOrBelow then
                if pet.enemy then
                    game.enemyTeam.removePet(pet);
                else
                    game.team.removePet(pet);
                end
            end
            game.manager.triggerRandom();
        end
        pet.abilityText = {
            "Start of battle: Randomly leaves (1/2 chance)",
            "Start of battle: Randomly leaves (1/3 chance)",
            "Start of battle: Randomly leaves (1/6 chance)"
        }
        pet.abilities = {{id="startOfBattle",func = pet.startOfBattle}};
    elseif pet.id == "crapgorps" then
        pet.startOfBattle = function()
            local extraHealth = pet.battlesFought;
            if pet.level == 1 then
                extraHealth = math.floor(extraHealth / 2);
            elseif pet.level == 3 then
                extraHealth = extraHealth * 2;
            end
            pet.hp = pet.hp + extraHealth;
        end
        pet.abilityText = {
            "Start of battle: Gain 1 health for each 2 battles fought",
            "Start of battle: Gain 1 health for each battle fought",
            "Start of battle: Gain 2 health for each battle fought"
        }
        pet.abilities = {{id="startOfBattle",func = pet.startOfBattle}}
    elseif pet.id == "giovanni" then
        pet.startOfTurn = function()
            game.manager.triggerRandom();
        end
        pet.abilityText = {
            "Start of turn: Stock a Random soup up to tier 2.",
            "Start of turn: Stock a Random soup up to tier 4.",
            "Start of turn: Stock a Random soup up to tier 6."
        }
        pet.abilities = {{id="startOfTurn",func = pet.startOfTurn}}
    elseif pet.id == "flamethrower" then
        pet.beforeAttack = function(opponent)

        end
        pet.abilityText = {
            "Before attack: Give Toasty to the first enemy ahead.",
            "Before attack: Give Toasty to the first two enemies ahead.",
            "Before attack: Give Toasty to the first three enemies ahead."
        }
        pet.abilities = {{id="beforeAttack",func = pet.beforeAttack}}
    elseif pet.id == "martin" then
        pet.friendGainedAilment = function(friend)
            game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
        end
        pet.abilityText = {
            "Friend gained ailment: Gain 1 gold next turn.",
            "Friend gained ailment: Gain 2 gold next turn.",
            "Friend gained ailment: Gain 3 gold next turn.",
        }
        pet.abilities = {{id="friendGainedAilment",func = pet.friendGainedAilment}}
    elseif pet.id == "gansley" then
        pet.projectileUrl = "img/gansleybuck.png";
        pet.beforeAttack = function(opponent)
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
            end
            game.battle.dealDirectDamage(damageAmount,pet,target);
            game.manager.triggerRandom();
        end
        pet.abilityText = {
            "Before attack: Deal between 1 and 3 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 8 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 20 damage to self or enemy ahead, Randomly."
        }
        pet.abilities = {{id="beforeAttack",func = pet.beforeAttack}}
    elseif pet.id == "wellwatcher" then
        pet.startOfBattle = function()
            pet.fainted = true;
        end
        pet.faint = function()
            if not pet.alreadyDied then
                newWatcher = pet.getCopy();
                newWatcher.projectileUrl = "img/lightning.png";
                newWatcher.alreadyDied = true;
                newWatcher.summoned = function()
                    local dmg = pet.level == 3 and 10 or (pet.level == 2 and 6 or 3);
                    game.battle.dealDirectDamage(dmg,newWatcher,newWatcher);
                end
                newWatcher.hurt = function(source)
                    if source == newWatcher then
                        newWatcher.transform("skywatcher");
                    end
                end
            end
        end
        pet.abilityText = {
            "Start of battle: Gain 1 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 3 damage and transforms into Sky Watcher.",
            "Start of battle: Gain 2 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 6 damage and transforms into Sky Watcher.",
            "Start of battle: Gain 3 gold next turn, faint, and summon a Well Watcher with current perk and stats who immediately takes 10 damage and transforms into Sky Watcher."
        };
        pet.abilities = {{id="startOfBattle",func = pet.startOfBattle}}
    elseif pet.id == "skywatcher" then
        pet.somethingFlewOverhead = function()
            pet.atk = pet.atk + pet.level;
            pet.hp = pet.hp + pet.level;
        end
        pet.abilityText = {
            "Something flew overhead: Gain 1 attack and HP.",
            "Something flew overhead: Gain 2 attack and HP.",
            "Something flew overhead: Gain 3 attack and HP."
        }
        pet.abilities = {{id="somethingFlewOverhead",func = pet.somethingFlewOverhead}}
    elseif pet.id == "gorou" then
        pet.sell = function()

        end
        pet.abilityText = {
            "Sell: Stock one Donut Gun.",
            "Sell: Stock one Donut Gun with double effect.",
            "Sell: Stock one Donut Gun with triple effect."
        }
        pet.abilities = {{id="sell",func = pet.sell}}
    end
}