local resetting = false;
local reset_time = 0;

local best_score = 0;
local best_generation = {};
local current_generation = {};
generation_queue = {};

function getStage()
    return memory.readbyte(0x0483)
end;

function getScore()
    millions = memory.readbyte(0x00E0) * 1000000;
    hundred_thousands = memory.readbyte(0x00E1) * 100000;
    ten_tousands = memory.readbyte(0x00E2) * 10000;
    thousands = memory.readbyte(0x00E3) * 1000;
    hundreds = memory.readbyte(0x00E4)  * 100;
    tens = memory.readbyte(0x00E5) * 10;
    ones = memory.readbyte(0x00E6) * 1;
    return ones + tens + hundreds + thousands + ten_tousands + hundred_thousands + millions;
end;

function getPlayerX()
    return memory.readbyte(0x0203);
end;

function generateRandomX()
    return math.random(8, 176)
end;

function getLives()
    return memory.readbyte(0x0487);
end;

function setLives(val)
    memory.writebyte(0x0487, val);
end;

setLives(2)
local save_state = savestate.create()
savestate.save(save_state);
savestate.persist(save_state);

function getRandomBool()
    local value = math.random(0, 1);
    if (value == 0) then return false; else return true; end;
end;

function generate_random_input()
    return {
        A=getRandomBool(),
        B=getRandomBool(),
        up=false,
        down=false,
        left=getRandomBool(),
        right=getRandomBool(),
        start=false,
        select=false
    };
end;

function len(T)
    local count = 0;
    for _ in pairs(T) do count = count + 1 end;
    return count;
end;

function generateLocalRandomX(base, weight)
    local low = base -weight;
    local high = base + weight;
    if(low < 8) then low = 8 end;
    if(high > 170) then high = 170 end;
    return math.random(8, 170)
end;

function mutate_generation(generation, score)
    local counter = 0
    local mutations = 0
    local mutant_generation = {}
    print("score: ", score)
    print("generation length: ", len(generation))
    --local average = score/(len(generation))

    for _,input in pairs(generation) do
        local value = input['x']
        local score = input['score']
        if(input['score'] < 1) then
            value = generateRandomX();
            --value = generateLocalRandomX(value, 80);
            mutations = mutations + 1;
            score = 0
        end;
        mutant_generation[counter] = {x=value, score=score}
        --table.insert(mutant_generation, value);
        counter = counter + 1
    end;

    print("Mutated Generation: ", mutations);
    return mutant_generation
end;

resets = 0;

function resetGame()
    savestate.load(save_state)
    resets = resets + 1
    print("generations: ", resets)
    current_generation = {};
    setLives(4)
end;

function getDirectionalInput(dest, fire)
    local left = false;
    local right = false;
    local diff = dest - getPlayerX();
    local b = fire;

    if(diff > 0) then
        right = true;
        left = false;
    else
        right = false;
        left = true;
    end;
    return {
        A=b,
        --A=false,
        B=b,
        up=false,
        down=false,
        left=left,
        right=right,
        start=false,
        select=false
    };
end;


function gameLoop()

    local frame_timer = os.time();
    local last_score = getScore();
    local generation_index = 0;
    local last_lives = getLives();
    local last_stage = getStage();
    local dest = generateRandomX();
    table.insert(current_generation, {x=dest, score=0})
    local fire = false
    local tick_on = 0

    setLives(4)

    local algos ={}

    while(true) do
        if(getStage() ~= last_stage) then
            algos[last_stage] = {}
            count = 0
            for _,i in pairs(current_generation) do
                algos[last_stage][count] = i
                count = count + 1
            end;

            print("STAGE: ", getStage())
            last_stage = getStage()

            if(algos[getStage()] ~= nil) then
                generation_queue = algos[getStage()]
                current_generation = {}
                generation_index = 0;
                tick_on = 0
            end;
        elseif(getLives() < last_lives) then
            for i = 8, 0, -1 do
                index = tick_on - i;
                if(index > 0 and index < len(current_generation)) then
                    current_generation[index]['score'] = current_generation[index]['score'] -200
                end;
            end;


            while(generation_index < len(generation_queue)) do
                dest = generation_queue[generation_index]['x'];
                score = generation_queue[generation_index]['score'];
                table.insert(current_generation, {x=dest, score=score})
                generation_index = generation_index + 1;
            end;

            last_stage = getStage()
            algos[last_stage] = mutate_generation(current_generation, getScore())
            generation_index = 0;
            tick_on = 0
            resetGame();
            if(algos[getStage()] ~= nil) then
                generation_queue = algos[getStage()]
                current_generation = {}
                generation_index = 0;
                tick_on = 0
            end;
            emu.frameadvance();
        else
            if (getPlayerX() == dest) then
                fire = true
                dest = generateRandomX();

                if(generation_index < len(generation_queue)) then
                    dest = generation_queue[generation_index]['x'];
                    generation_index = generation_index + 1;
                end;

                for i = 5, 0, -1 do
                    local index = tick_on - i;
                    if(index > 0 and index < len(current_generation)) then

                        current_generation[index]['score'] = current_generation[index]['score'] + (getScore() - last_score)
                    end;
                end;

                tick_on = tick_on + 1
                table.insert(current_generation, {x=dest, score=getScore() - last_score})
                last_score = getScore();
            end;

            local input = getDirectionalInput(dest, fire);

            joypad.set(1, input);
            last_lives = getLives();
            emu.frameadvance();
        end;
    end;
end;

gameLoop();
