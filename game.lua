Game = function()
    local game = {};
    game.field = Field();
    game.run = Run();
    game.manager = Manager();
    game.petShop = PetShop();
    game.itemShop = ItemShop();
    game.abilityStack = AbilityStack();

    game.team = Team();
    game.team.addNewPet("poochy");
    game.team.addNewPet("molly");
    game.team.get(1).hp = 17;
    game.team.addNewPet("gorou");
    --game.team.addNewPet("crapgorps");
    --game.team.addNewPet("giovanni");

    game.enemyTeam = Team();
    game.enemyTeam.addNewPet("stink",1)
    game.enemyTeam.get(1).addExp(1);
    game.enemyTeam.addNewPet("gansley",4)
    game.enemyTeam.addNewPet("simphony",2)
    game.enemyTeam.addNewPet("crapgorps",5)
    game.enemyTeam.get(5).addExp(1);
    game.enemyTeam.get(5).hp = 13;
    game.enemyTeam.faceRight = false;
    game.enemyTeam.x = 960;

    game.fadeAlpha = 0;

    game.init = function()
        game.petShop.roll(1);
        game.itemShop.roll(1);
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
        game.enemyTeam.draw();
        if not game.manager.hideUI then
            game.petShop.draw();
            game.itemShop.draw();
            game.manager.draw();
        end
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