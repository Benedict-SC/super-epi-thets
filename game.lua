Game = function()
    local game = {};
    game.field = Field();
    game.run = Run();
    game.manager = Manager();
    game.petShop = PetShop();
    game.itemShop = ItemShop();
    game.abilityStack = AbilityStack();

    game.team = Team();
    game.team.addNewPet("lorelai");
    game.team.get(1).addExp(2);
    game.team.get(1).addExp(3);
    local mem1 = game.team.get(1);
    mem1.perk = Quag();
    mem1.perk.owner = mem1;
    game.team.addNewPet("molly");
    local mem2 = game.team.get(1);
    mem2.perk = CursedAilment();
    mem2.perk.owner = mem2;
    game.team.get(1).addExp(3);
    game.team.addNewPet("rick");
    --game.team.get(1).addExp(2);
    --game.team.get(1).addExp(3);
    game.team.addNewPet("percy");
    local mem4 = game.team.get(1);
    mem4.perk = ToastyAilment();
    mem4.perk.owner = mem4;
    --game.team.addNewPet("crapgorps");
    --game.team.addNewPet("giovanni");

    game.enemyTeam = Team();
    game.enemyTeam.addNewPet("stink",1)
    game.enemyTeam.get(1).addExp(1);
    game.enemyTeam.addNewPet("scaregrow",2)
    game.enemyTeam.addNewPet("carcrash",4)
    game.enemyTeam.addNewPet("crapgorps",5)
    game.enemyTeam.get(5).addExp(2);
    --game.enemyTeam.get(5).addExp(3);
    --game.enemyTeam.get(5).hp = 20;
    game.enemyTeam.faceRight = false;
    game.enemyTeam.x = 960;

    --game.run.tier = 6;
    --game.run.gold = 99;

    game.fadeAlpha = 0;

    game.init = function()
        game.petShop.roll(1);
        game.itemShop.roll(1);
        game.itemShop.stock("ambrosia");
    end

    game.update = function()
        game.team.update();
        game.petShop.update();
        game.itemShop.update();
        game.manager.update();
    end
    game.draw = function()
        game.update();
        game.field.draw();
        game.run.draw();
        game.team.draw();
        if (game.manager.state == "BATTLE") or ((game.manager.state == "ANIMATE") and game.manager.battle) then
            game.enemyTeam.draw();
        end
        if not game.manager.hideUI then
            game.petShop.draw();
            game.itemShop.draw();
            game.manager.draw();
        end
        game.manager.drawExtras();
        game.manager.drawParticles();
        if game.manager.battle then
            game.manager.battle.draw();
        end
        pushColor();
        love.graphics.setColor(0,0,0,game.fadeAlpha);
        love.graphics.rectangle("fill",0,0,gamewidth,gameheight);
        popColor();
    end
    return game;
end