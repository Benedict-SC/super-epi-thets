math.randomseed(love.timer.getTime());
screenwidth,screenheight=love.window.getDesktopDimensions();
gamewidth=1100;
gameheight=580;
windowwidth=gamewidth;
windowheight=gameheight;
love.window.setTitle("Super Epi Thets");
love.window.setMode(gamewidth,gameheight,{
	fullscreen=false;
	resizable=true;
	x=screenwidth/2 - (gamewidth*2/2);
	y=screenheight/2 - (gameheight*2/2);
	
});
mainfont = love.graphics.newFont("fonts/OpenDyslexic3-Bold.ttf",20);
love.graphics.setFont(mainfont);
smallfont = love.graphics.newFont("fonts/OpenDyslexic3-Regular.ttf",12);
smallfont:setLineHeight(0.8);
smallfont_bold = love.graphics.newFont("fonts/OpenDyslexic3-Bold.ttf",12);
smallfont_bold:setLineHeight(0.8);

require("util");
require("canvas-stack");
require("asyn");
require("sound");
require("commonui");
require("clickable");
require("button");
require("perks");
require("pet");
require("food");
require("abilities");
require("abilitystack");
require("emptyslot");
require("team");
require("shops");
require("field");
require("run");
require("battle");
require("manager");
require("game");
game = Game();
game.init();

DEBUG_TEXT = "";

function love.draw()
    asyn.update();
    --love.graphics.print("Hello World", 400, 300)
    game.draw();
    pushColor();
    love.graphics.setColor(0.1,0.8,0.4);
    love.graphics.print(DEBUG_TEXT,4,4);
    popColor();
end