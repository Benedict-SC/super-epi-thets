Game = function()
    local game = {};
    game.field = Field();
    game.run = Run();
    game.manager = Manager();
    game.petShop = PetShop();

    game.team = Team();
    --game.team.addNewPet("gorou");
    --game.team.addNewPet("crapgorps");
    --game.team.addNewPet("ben");
    --game.team.addNewPet("crapgorps");
    --game.team.addNewPet("giovanni");

    game.enemyTeam = Team();
    game.enemyTeam.addNewPet("wellwatcher",4)
    game.enemyTeam.addNewPet("gansley",3)
    game.enemyTeam.addNewPet("martin",1)
    game.enemyTeam.faceRight = false;
    game.enemyTeam.x = 960;

    game.fadeAlpha = 0;

    game.init = function()
        game.petShop.roll(1);
    end

    game.update = function()
        game.team.update();
        game.petShop.update();
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
            game.manager.draw();
        end
        pushColor();
        love.graphics.setColor(0,0,0,game.fadeAlpha);
        love.graphics.rectangle("fill",0,0,gamewidth,gameheight);
        popColor();
    end
    return game;
end