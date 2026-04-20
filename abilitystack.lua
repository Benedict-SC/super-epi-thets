AbilityStack = function()
    local aStack = {}
    aStack.stack = Array(); 
    aStack.registerAbilityTrigger = function(sourcePet,abilityType,abilityFunction,args)
        aStack.stack.push({src=sourcePet,type=abilityType,func=abilityFunction,args=args});
    end
    aStack.allCompleteCallback = function() end
    aStack.startProcessing = function(allCompleteCallback)
        aStack.allCompleteCallback = allCompleteCallback;
        aStack.processNext();
    end
    aStack.processNext = function()
        if #aStack.stack > 0 then
            local ability = aStack.stack.pop();
            ability.func(aStack.processNext,ability.args);
        else
            aStack.allCompleteCallback();
        end
    end
    return aStack;
end