Clickable = function()
    local clickable = {};
    clickable.x = 0;
    clickable.y = 0;
    clickable.inputUpdate = function(xoff,yoff)
        local img = clickable.img;
        if not img then
            return;
        end

        xoff = xoff or 0;
        yoff = yoff or 0;
        clickable.screenX = clickable.x + xoff;
        clickable.screenY = clickable.y + yoff;
        if game and game.manager and game.manager.registerClickable then
            game.manager.registerClickable(clickable);
        end
    end
    clickable.containsPoint = function(px,py)
        local img = clickable.img;
        if not img then
            return false;
        end
        local x = clickable.screenX or clickable.x;
        local y = clickable.screenY or clickable.y;
        return px >= x and py >= y and px < x + img:getWidth() and py < y + img:getHeight();
    end
    clickable.onHoverEnter = function()
    end
    clickable.onHoverExit = function()
    end
    clickable.onClick = function()
    end
    clickable.onRightClick = function()
    end
    clickable.canDrag = function()
        return false;
    end
    clickable.onDragStart = function()
    end
    clickable.onDrop = function(source)
        return false;
    end
    return clickable;
end
