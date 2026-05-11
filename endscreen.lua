EndScreen = function()
    local es = {};
    es.newgame = Button("img/newgame.png");
    es.newgame.x = 50;
    es.newgame.y = 450;
    es.newgame.onClick = function()
        game.run = Run();
        game.team = Team();
        asyn.doOverTime(1.3,function(percent)
            es.alpha = 1-percent;
        end,function() 
            es.alpha = 0;
            game.init();
            game.manager.state = "ANIMATE";
            asyn.doOverTime(0.8,function(percent) 
                game.fadeAlpha = 1-percent;
            end,function() 
                game.fadeAlpha = 0;
                game.manager.state = "SHOP";
            end);
        end)
    end
    es.alpha = 0;
    es.victory = false;

    es.trigger = function(vic)
        game.manager.state = "ENDING";
        es.victory = vic;
        asyn.doOverTime(1.3,function(percent)
            es.alpha = percent;
        end,function() 
            es.alpha = 1;
        end)
    end

    es.update = function()
        if es.alpha > 0 then
            es.newgame.inputUpdate(0,0);
        end
    end
    es.canvas = love.graphics.newCanvas(gamewidth,gameheight);
    es.draw = function()
        love.graphics.pushCanvas(es.canvas);
        love.graphics.clear();
        if es.victory then
            love.graphics.draw(youwin,430,20);
        else
            love.graphics.draw(youlose,430,20);
        end
        es.newgame.draw();
        love.graphics.popCanvas();
        pushColor();
        love.graphics.setColor(1,1,1,es.alpha);
        love.graphics.draw(es.canvas,0,0);
        popColor();
    end
    return es;
end