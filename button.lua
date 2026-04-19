Button = function(imgpath)
    local button = Clickable();
    button.img = love.graphics.newImage(imgpath);
    button.shaded = false;
    button.onHoverEnter = function()
        button.shaded = true;
    end
    button.onHoverExit = function()
        button.shaded = false;
    end
    button.draw = function(xoff,yoff)
        if not xoff then xoff = 0; end
        if not yoff then yoff = 0; end
        pushColor();
        if button.shaded then
            love.graphics.setColor(0.9,0.9,0.9);
        else
            love.graphics.setColor(1,1,1);
        end
        love.graphics.draw(button.img,button.x+xoff,button.y+yoff);
        popColor();
    end
    return button;
end