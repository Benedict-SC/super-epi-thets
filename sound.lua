sound = {};
sound.bank = {};

sound.play = function(sID) --use only for non-music audio clips
    if not sID then
		return;
    end
    local clip = sound.bank[sID];
	if clip then
        clip.clip:stop();
        clip.clip:play();
	end
end
sound.stop = function(sID)
    if not sID then
		return;
    end
    local clip = sound.bank[sID];
	if clip then
        clip.clip:stop();
	end
end

sound.createWrappedClip = function(name,filename,volumeMult,looping,sourcetype)
    if not volumeMult then
        volumeMult = 1;
    end
    --error(filename);
    local wrapper = {};
    wrapper.name = name;
    wrapper.mult = volumeMult; --never 0;
    wrapper.normalVolume = 1;
    wrapper.loops = looping;
    wrapper.clip = love.audio.newSource(filename,sourcetype);
    wrapper.clip:setLooping(looping);
    wrapper.clip:setVolume(volumeMult);
    wrapper.setVolume = function(vol)
        wrapper.clip:setVolume(vol * volumeMult);
        wrapper.normalVolume = vol;
    end
    wrapper.setHandle = function(handle)
        if wrapper.handle then
            wrapper.handle.cancel = true;
            debug_console_string_3 = wrapper.name .. " got cancelled";
        end
        wrapper.handle = handle;
    end
    return wrapper;
end
sound.makeAndBank = function(name,filename,volumeMult,looping,sourcetype)
    sound.bank[name] = sound.createWrappedClip(name,filename,volumeMult,looping,sourcetype);
end
sound.makeAndBank("bang","audio/bang.mp3",1,false,"static");
sound.makeAndBank("pow","audio/pow.mp3",1,false,"static");
sound.makeAndBank("biff","audio/biff.mp3",1,false,"static");
sound.makeAndBank("hit","audio/hit.mp3",1,false,"static");
sound.makeAndBank("oof","audio/oof.mp3",1,false,"static");
sound.makeAndBank("whack","audio/whack.mp3",1,false,"static");
sound.randomSmack = function()
    local types = {"bang","pow","biff","hit","oof","whack"};
    local picked = types[math.random(#types)];
    sound.play(picked);
end