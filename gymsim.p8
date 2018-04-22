pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--------------------------------------------------------------------------------
-- acknowledgements
    -- misato for the base game outline
    -- pico monsters: https://www.lexaloffle.com/bbs/?pid=26810#p27211
    --

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- begin states
--------------------------------------------------------------------------------
game_states = {
  splash = 0,
  gym = 1,
  feather = 2,
  runner = 3,
  masher = 4,
  gameover = 5,
  boss = 6,
  run_intro = 7,
  run_win = 8,
  run_fail = 9,
  feather_intro = 10,
  feather_win = 11,
  feather_fail = 12
}

boss_states = {
    boss_turn = 1,
    your_turn = 2,
    ran = 3,
    victory = 4,
    defeat = 5,
}
--------------------------------------------------------------------------------
-- end states
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- begin global variables
--------------------------------------------------------------------------------
state = game_states.splash
boss_state = boss_states.boss_turn

-- boss level things
-- what to print on the next boss move
boss_move = "the boss does something"
-- which workouts have been completed
completed_tasks = {false, false, false, true} -- run, feather, post 
-- which boss options have been chosen
chosen_boss_options = {false, false, false, false}
-- text to show for each boss option
boss_fight_options = {"speed", "agility", "power", "escape"}
-- boss responses
boss_response = {}
boss_response["power"] = "the vacuum cannot handle your power"
boss_response["speed"] = "the vacuum cannot handle your speed"
boss_response["agility"] = "the vacuum cannot handle your agility"
boss_response["escape"] = "you manage to escape"
-- symbol to indicate option is selected
selected_symbol = "\130"
-- current selected option
selected_option = 1


player = {
  x = 8,
  y = 8,
  dx = 0,
  dy = 0,
  speed = 0.5, -- how far the player should travel over 60 seconds
  hearts = 3,
  cw = true,
  runningboost = false,
  featherboost = false,
  punchingboost = false
}

feathers = {}
weights = {}
trash = {}
g = {x=0,y=0.5}
cam = {x = 0,y = 0}
solid = false
screen_size = 128
score = 0
show_feather = true
timer = 0
minutetimer = 0
timermult = 50
--------------------------------------------------------------------------------
-- end global variables
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- begin pico8 game funtions
--------------------------------------------------------------------------------
function _init()
  cls()
  music(0)
  -- start game time
  prev_t = time() -- we use past time per frame so we have framerate independent movement
end

function _update60()

  solid = solid_tile(player.x, player.y)
  minutetimer += 1
  if state == game_states.splash then
    update_splash()
  elseif state == game_states.gym then
    update_gym()
  elseif state == game_states.feather then
    update_feather()
  elseif state == game_states.runner then
    update_runner()
  elseif state == game_states.gameover then
    update_gameover()
  elseif state == game_states.boss then
    update_boss()
  elseif state == game_states.run_intro then
    update_run_intro()
  elseif state == game_states.run_win then
    update_run_win()
  elseif state == game_states.run_fail then
    update_run_fail()
  elseif state == game_states.feather_intro then
    update_feather_intro()
  elseif state == game_states.feather_win then
    update_feather_win()
  elseif state == game_states.feather_fail then
    update_feather_fail()
  end
end

function _draw()
  cls()
  if state == game_states.splash then
    draw_splash()
  elseif state == game_states.gym then
    draw_gym()
  elseif state == game_states.feather then
    draw_feather()
  elseif state == game_states.runner then
    draw_runner()
  elseif state == game_states.gameover then
    draw_gameover()
  elseif state == game_states.boss then
    draw_boss()
  elseif state == game_states.run_intro then
    draw_run_intro()
  elseif state == game_states.run_win then
    draw_run_win()
  elseif state == game_states.run_fail then
    draw_run_fail()
  elseif state == game_states.feather_intro then
    draw_feather_intro()
  elseif state == game_states.feather_win then
    draw_feather_win()
  elseif state == game_states.feather_fail then
    draw_feather_fail()
  end
end
--------------------------------------------------------------------------------
-- end pico8 game funtions
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin splash
--------------------------------------------------------------------------------
function update_splash()
    -- usually we want the player to press one button
     if btnp(5) then
         change_state(6) -- change state to gym scene
     end
end

function draw_splash()
    rectfill(0,0,screen_size,screen_size,11)
    local text = "gym sim!"
    write(text, text_x_pos(text), 52,7)
end
--------------------------------------------------------------------------------
-- end splash
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin gym
--------------------------------------------------------------------------------
function gym_input()

  local playerdiff=5 --extra distance for up/left edges. adjust as needed
  local allowance= 5
  local px = player.x

    --left
    if btn(0) and not solid_tile(player.x-1, player.y) then
      player.dx = -2
    player.x-=player.speed
    if (player.x-cam.x<64-allowance-playerdiff) then cam.x-=player.speed end
  end

   --right
   if btn(1) and not solid_tile(player.x + 8 + 1, player.y)then
     player.dx = 2
    player.x+=player.speed
    if (player.x-cam.x>64+allowance) then cam.x+=player.speed end
  end

   --up
   if btn(2) and not solid_tile(player.x, player.y-1)then
     player.dy = -2
     	player.y-=player.speed
    if (player.y-cam.y<64-allowance-playerdiff) then cam.y-=player.speed end
  end

   --down
   if btn(3) and not solid_tile(player.x, player.y + 8 + 1)then
     player.dy = 2
    player.y+=player.speed
    if (player.y-cam.y>64+allowance) then cam.y+=player.speed end
  end

  -- to use the following we need friction to remove/reduce velocity
  --player.x += player.dx
  local xoffset = 0
  if player.dx > 0 then xoffset = 7 end

  local h = mget((player.x + xoffset)/8, (player.y+7)/8)

  if fget(h, 7) then -- running game
    change_state(7)
  end
  if fget(h, 6) then -- feather game
    change_state(10)
  end
  if fget(h, 5) then -- mashing game
    change_state(4)
  end
  if fget(h, 4) then -- mashing game
    change_state(6)
  end

  player.dy += 0.2
  if state == game_states.feather then
    player.y += player.dy
  end
end

function update_gym()
    gym_input()
end

function draw_gym()
  -- draw map
  map(0, 0, 0, 0, 128, 32)
  camera(cam.x, cam.y)
  -- draw player sprite
  spr(1, player.x, player.y)
end
--------------------------------------------------------------------------------
-- end gym
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin feather
--------------------------------------------------------------------------------
function feather_input()
  timer += 1
  local lx=player.x
  local ly=player.y
  if (flr(minutetimer/60) <= 10) then
    timermult = 50
  elseif (flr(minutetimer/60) > 10) and (flr(minutetimer/60) <= 20) then
    timermult = 45
  elseif (flr(minutetimer/60) > 20) and (flr(minutetimer/60) <= 30) then
    timermult = 40
  end

  --player movement
  if btn(0) then
    player.x += -1 * player.speed
  end

  if btn(1) then
    player.x += player.speed
  end

  --world collision
  if(world_collision(player)) player.x=lx player.y=ly

  if timer == timermult then
    random_obj()
    if(show_feather == false) then
      create_obs(weights,25, true)
    else
      create_obs(feathers,24, true)
    end
    timer = 0
  end


  collision_obs(weights)
  collision_obs(feathers)
  foreach(feathers, update_feathers)
  foreach(weights, update_weights)
end

function update_feather()
    feather_input()
    if (player.hearts == 0) then
      change_state(12) -- change state to fail splash scene
    end
    if(score == 20) then
      completed_tasks[2] = true
      change_state(11) -- change state to win splash screen
      featherboost = true
    end
end

function draw_feather()
  cls(5)
  camera(0, 0)
  spr(1,player.x,player.y) --draw player

  --print ( 'time:'..flr(time()), 95, 2, 7)
  --print ( 'score:'..score, 95, 10, 7)

  -- spawn objects
  foreach(feathers, draw_obs)
  foreach(weights, draw_obs)
  draw_hearts()
end

function update_feather_intro()
  if btnp(5) then
      change_state(2) -- change state to feather scene
  end
end

function draw_feather_intro()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,12)
  local text = " feather sim!"
  write(text, text_x_pos(text), 30,7)
  local text = " avoid obsticles by using"
  write(text, text_x_pos(text), 50,7)
  local text = " the left and right keys!"
  write(text, text_x_pos(text), 60,7)
  local text = " collect 20 feathers to"
  write(text, text_x_pos(text), 80,7)
  local text = " complete your training"
  write(text, text_x_pos(text), 90,7)
  local text = " and become more agile!"
  write(text, text_x_pos(text), 100,7)
  spr(20, 0, 120)
  spr(20, 8, 120)
  spr(20, 16, 120)
  spr(20, 24, 120)
  spr(20, 32, 120)
  spr(20, 40, 120)
  spr(20, 48, 120)
  spr(20, 56, 120)
  spr(20, 64, 120)
  spr(20, 72, 120)
  spr(20, 80, 120)
  spr(20, 88, 120)
  spr(20, 96, 120)
  spr(20, 104, 120)
  spr(20, 112, 120)
  spr(20, 120, 120)
end

function update_feather_win()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_feather_win()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,14)
  local text = " you won!"
  write(text, text_x_pos(text), 30,7)
  local text = " you'll be able to"
  write(text, text_x_pos(text), 50,7)
  local text = " use an agility attack"
  write(text, text_x_pos(text), 60,7)
  local text = " when fighting the vacuum!"
  write(text, text_x_pos(text), 70,7)
  local text = " good job!"
  write(text, text_x_pos(text), 90,7)
  spr(22, 0, 120)
  spr(22, 8, 120)
  spr(22, 16, 120)
  spr(22, 24, 120)
  spr(22, 32, 120)
  spr(22, 40, 120)
  spr(22, 48, 120)
  spr(22, 56, 120)
  spr(22, 64, 120)
  spr(22, 72, 120)
  spr(22, 80, 120)
  spr(22, 88, 120)
  spr(22, 96, 120)
  spr(22, 104, 120)
  spr(22, 112, 120)
  spr(22, 120, 120)
end

function update_feather_fail()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_feather_fail()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,9)
  local text = " you failed!"
  write(text, text_x_pos(text), 30,7)
  local text = " you'll have to hit"
  write(text, text_x_pos(text), 50,7)
  local text = " the gym more if you"
  write(text, text_x_pos(text), 60,7)
  local text = " want to beat the vacuum!"
  write(text, text_x_pos(text), 70,7)
  local text = " try again!"
  write(text, text_x_pos(text), 90,7)
  spr(23, 0, 120)
  spr(23, 8, 120)
  spr(23, 16, 120)
  spr(23, 24, 120)
  spr(23, 32, 120)
  spr(23, 40, 120)
  spr(23, 48, 120)
  spr(23, 56, 120)
  spr(23, 64, 120)
  spr(23, 72, 120)
  spr(23, 80, 120)
  spr(23, 88, 120)
  spr(23, 96, 120)
  spr(23, 104, 120)
  spr(23, 112, 120)
  spr(23, 120, 120)
end
--------------------------------------------------------------------------------
-- end feather
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin runner
--------------------------------------------------------------------------------
function runner_input()
  if (flr(minutetimer/60) <= 10) then
    timermult = 25
  elseif (flr(minutetimer/60) > 10) and (flr(minutetimer/60) <= 20) then
    timermult = 15
  elseif (flr(minutetimer/60) > 20) and (flr(minutetimer/60) <= 30) then
    timermult = 13
  end
  timer += 1

  -- up
  if btnp(2) then
    player.y -= 24
    if (player.y<=8) player.y=24
  end
  -- down
  if btnp(3) then
    player.y += 24
    if (player.y>=98) player.y=96
  end

  if timer == timermult then
    random_obj()
    if(show_feather == false) then
      create_obs(trash,37, false)
    else
      create_obs(trash,38, false)
    end
    timer = 0
  end


  trash_collision(trash)

  foreach(trash, update_trash)
end

function update_runner()
    runner_input()
    if (player.hearts == 0) then
      change_state(9) -- change state to fail splash scene
    end
    if (flr(minutetimer/60) == 30) then
      completed_tasks[1] = true
      change_state(8) -- change state to win splash screen
      runningboost = true
    end
end

function draw_runner()
  cls()

  -- draw map
  map(38, 0, -((time()*16 % 8)), 0, 128, 32)
  camera(0, 0)
  -- draw player sprite


  -- spawn objects
  foreach(trash, draw_obs)
  draw_hearts()
  spr(1, player.x, player.y)
  --debug()
end

function update_run_intro()
  if btnp(5) then
      change_state(3) -- change state to running scene
  end
end

function draw_run_intro()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,12)
  local text = " running sim!"
  write(text, text_x_pos(text), 30,7)
  local text = " avoid obsticles by using"
  write(text, text_x_pos(text), 50,7)
  local text = " the up and down keys!"
  write(text, text_x_pos(text), 60,7)
  local text = " survive for 30 seconds to"
  write(text, text_x_pos(text), 75,7)
  local text = " become more speedy!"
  write(text, text_x_pos(text), 85,7)
  spr(20, 0, 120)
  spr(20, 8, 120)
  spr(20, 16, 120)
  spr(20, 24, 120)
  spr(20, 32, 120)
  spr(20, 40, 120)
  spr(20, 48, 120)
  spr(20, 56, 120)
  spr(20, 64, 120)
  spr(20, 72, 120)
  spr(20, 80, 120)
  spr(20, 88, 120)
  spr(20, 96, 120)
  spr(20, 104, 120)
  spr(20, 112, 120)
  spr(20, 120, 120)
end

function update_run_win()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_run_win()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,14)
  local text = " you won!"
  write(text, text_x_pos(text), 30,7)
  local text = " you'll be able to"
  write(text, text_x_pos(text), 50,7)
  local text = " use a speed attack"
  write(text, text_x_pos(text), 60,7)
  local text = " when fighting the vacuum!"
  write(text, text_x_pos(text), 70,7)
  local text = " good job!"
  write(text, text_x_pos(text), 90,7)
  spr(22, 0, 120)
  spr(22, 8, 120)
  spr(22, 16, 120)
  spr(22, 24, 120)
  spr(22, 32, 120)
  spr(22, 40, 120)
  spr(22, 48, 120)
  spr(22, 56, 120)
  spr(22, 64, 120)
  spr(22, 72, 120)
  spr(22, 80, 120)
  spr(22, 88, 120)
  spr(22, 96, 120)
  spr(22, 104, 120)
  spr(22, 112, 120)
  spr(22, 120, 120)
end

function update_run_fail()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_run_fail()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,9)
  local text = " you failed!"
  write(text, text_x_pos(text), 30,7)
  local text = " you'll have to hit"
  write(text, text_x_pos(text), 50,7)
  local text = " the gym more if you"
  write(text, text_x_pos(text), 60,7)
  local text = " want to beat the vacuum!"
  write(text, text_x_pos(text), 70,7)
  local text = " try again!"
  write(text, text_x_pos(text), 90,7)
  spr(23, 0, 120)
  spr(23, 8, 120)
  spr(23, 16, 120)
  spr(23, 24, 120)
  spr(23, 32, 120)
  spr(23, 40, 120)
  spr(23, 48, 120)
  spr(23, 56, 120)
  spr(23, 64, 120)
  spr(23, 72, 120)
  spr(23, 80, 120)
  spr(23, 88, 120)
  spr(23, 96, 120)
  spr(23, 104, 120)
  spr(23, 112, 120)
  spr(23, 120, 120)
end
--------------------------------------------------------------------------------
-- end runner
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin game over
--------------------------------------------------------------------------------
function update_gameover()
end

function draw_gameover()
  rectfill(0,0,screen_size,screen_size,11)
  local text = "gym sim byee!"
  write(text, text_x_pos(text), 52,7)
end
--------------------------------------------------------------------------------
-- end game over
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin boss
--------------------------------------------------------------------------------
function update_boss()
  if boss_state == boss_states.victory then
    boss_move = "you defeated the vacuum"
    -- go to end screen if victory
    if btnp(5) then
      change_state(1)
    end
  end

  if boss_state == boss_states.boss_turn then
    -- enemy turn, can only advance text
    if btnp(5) then
      if selected_option == 4 then
        -- ran away, return to gym
        change_state(1)
      end
      -- advance to your turn
      boss_state = boss_states.your_turn

      -- reset current selected option
      for i=1,#chosen_boss_options do
        if not chosen_boss_options[i] and completed_tasks[i] then
          selected_option = i
          break
        end
      end

      local is_boss_defeated = true
      for i=1,#chosen_boss_options - 1 do -- do not count escape as a necessary option
        is_boss_defeated = is_boss_defeated and chosen_boss_options[i]
      end
      if is_boss_defeated then
        boss_state = boss_states.victory
      end
    end
    return
  end

  -- check if option has changed
  local original_option = selected_option
  if btnp(2) then
    selected_option = get_prev_option_index(selected_option)

    sfx(20)
  elseif btnp(3) then
    selected_option = get_next_option_index(selected_option)
    sfx(20)
  end

  if selected_option < 1 then
    selected_option = 1
  elseif selected_option > #boss_fight_options then
    selected_option = #boss_fight_options
  end

  if btnp(5) then
    -- an option has been selected
    if completed_tasks[selected_option] then
      -- did the workout for this option
      chosen_boss_options[selected_option] = true
      boss_move = boss_response[boss_fight_options[selected_option]]
      boss_state = boss_states.boss_turn
      sfx(21)
    else
      -- play bad sound
      sfx(33)
      return
    end
  end
end

function draw_boss()
  -- draw player sprite
  spr(21, 20, 60)

  -- draw boss
  spr(67, 100, 20)
  spr(68, 108, 20)
  spr(83, 100, 28)
  spr(84, 108, 28)

  -- draw action box
  rect(0, 120, 118, 70, 4)
  rect(4, 116, 114, 74, 4)
  if boss_state == boss_states.your_turn then
    draw_boss_menu()
  end

  if boss_state == boss_states.boss_turn or boss_state == boss_states.victory then
    write_with_bounds(boss_move, 10,80, 3)
  end
end

function draw_boss_menu()
  local text_spacing = 10
  local menu_offset = {}
  menu_offset["x"] = 10
  menu_offset["y"] = 65

  for i = 1,#completed_tasks do
    if completed_tasks[i] and not chosen_boss_options[i] then
      -- task has been completed and option not chosen yet so draw it
      if selected_option == i then
        write_with_bounds(selected_symbol .. boss_fight_options[i], menu_offset.x,menu_offset.y + text_spacing * i,5)
      else
        write_with_bounds(" " .. boss_fight_options[i], menu_offset.x,menu_offset.y + text_spacing * i,5)
      end
    end
  end
end
--------------------------------------------------------------------------------
-- end boss
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- begin utility functions
--------------------------------------------------------------------------------

function debug()
  --print(solid, player.x+3, player.y-11, 9)
  --write("game state is " .. tostr(state), 0,0,4)
  -- for button=0,#isbuttonpressed - 1 do
  --   write("btn " .. tostr(button) .. " " .. tostr(wasbuttonreleased[button + 1]), 0,20 + button * 10, 4)
  -- end
  if state == game_states.boss then
  write("boss state is " .. tostr(boss_state), 0,10,4)
  end
  print (timer, player.x + 3, player.y - 11, 9)
end

-- state changes
function change_state(game)
  cls()
  if game == 1 then
    music(0)
    player.x = 16
    player.y = 68
    player.hearts = 3
    cam.x = 0
    cam.y = 0
    player.speed = 1
    timer = 0
    state = game_states.gym

  elseif game == 2 then
    music(22)
    player.x = 60
    player.y = 110
    player.speed = 2.5
    w = 128
    h = 128
    state = game_states.feather
    minutetimer = 0
    score = 0

  elseif game == 3 then
    music(17)
    player.x = 16
    player.y = 48
    state = game_states.runner
    minutetimer = 0

  elseif game == 4 then
    state = game_states.masher

  elseif game == 5 then
    state = game_states.gameover

  elseif game == 6 then
    music(8)
    camera(0, 0)
    for i=1,#chosen_boss_options do
      chosen_boss_options[i] = false
    end
    selected_option = 1
    boss_move = "a wild vacuum appears!"
    boss_state = boss_states.boss_turn -- reset boss state
    state = game_states.boss
  elseif game == 7 then
    state = game_states.run_intro
  elseif game == 8 then
    state = game_states.run_win
  elseif game == 9 then
    state = game_states.run_fail
  elseif game == 10 then
    state = game_states.feather_intro
  elseif game == 11 then
    state = game_states.feather_win
  elseif game == 12 then
    state = game_states.feather_fail
  end
end

-- finds the next valid option from boss fight menu
function get_next_option_index(cur)
  for i=cur + 1,#boss_fight_options do
    if not chosen_boss_options[i] and completed_tasks[i] then
      return i
    end
  end
  return cur -- no more options
end

-- finds the previous valid option from boss fight menu
function get_prev_option_index(cur)
  for i=cur - 1,1,-1 do
    if not chosen_boss_options[i] and completed_tasks[i] then
      return i
    end
  end
  return cur -- no more options
end

-- calculate center position in x axis
-- this is asuming the text uses the system font which is 4px wide
function text_x_pos(text)
    local letter_width = 4

    -- first calculate how wide is the text
    local width = #text * letter_width

    -- if it's wider than the screen then it's multiple lines so we return 0
    if width > screen_size then
        return 0
    end

   return screen_size / 2 - flr(width / 2)
end

-- prints black bordered text
function write(text,x,y,color)
    for i=0,2 do
        for j=0,2 do
            print(text,x+i,y+j, 0)
        end
    end
    print(text,x+1,y+1,color)
end

-- prints black bordered text and wraps around to next line
function write_with_bounds(text,base_x,base_y,color, x_bound)
  if (x_bound == nil) then
    x_bound = screen_size
  end
  local tokens = mysplit(text)
  local xpos = base_x
  for i=1,#tokens do
    local word_length = (#(tokens[i]) + 1) * 4
    if word_length + xpos >= x_bound then
      -- go to next line, reset x position
      base_y = base_y + 8
      xpos = base_x
    end
    write(tokens[i] .. " ",xpos,base_y,color)
    xpos += word_length
  end
end

-- splits string into list
function mysplit(inputstr, sep)
  if sep == nil then
    sep = " "
  end
  local t={}
  local word = ""
  word = sub(inputstr, 0, 0)
  for i=1, #inputstr + 1 do
     local char = sub(inputstr,i, i)
     if char == sep then
       t[#t + 1] = word
       word = ""
     else
       word = word .. char
     end
  end
  t[#t + 1] = word
  return t
end

-- returns if module of a/b == 0. equals to a % b == 0 in other languages
function mod_zero(a,b)
   return a - flr(a/b)*b == 0
end

-- draw hearts ui
function draw_hearts()
  rectfill(0, 0, 128, 8, 12)
  if(player.hearts == 3) then
    spr(22, 110, 1)
    spr(22, 101, 1)
    spr(22, 92, 1)
  elseif (player.hearts == 2) then
    spr(23, 110, 1)
    spr(22, 101, 1)
    spr(22, 92, 1)
  elseif (player.hearts == 1) then
    spr(23, 110, 1)
    spr(23, 101, 1)
    spr(22, 92, 1)
  elseif (player.hearts == 0) then
    spr(23, 110, 1)
    spr(23, 101, 1)
    spr(23, 92, 1)
  end
  if(state == game_states.runner) then
    print ('timer:'..flr(minutetimer/60), 90, 10, 0)
  end
  if(state == game_states.feather) then
    print ('score:'..score, 90, 10, 0)
  end
end

-- check for solid tiles
function solid_tile(x, y)
  local tilex = ((x - (x % 8)) / 8)
  local tiley = ((y - (y % 8)) / 8)

  if (fget(mget(tilex, tiley), 1)) then
    return true
  else
    return false
  end
end

-----------------------------------
-- begin feather utility functions
-----------------------------------
function random_obj()
  po = flr(rnd(20))

    if po % 2 == 0 then
      show_feather = true
    else
      show_feather = false
    end
end

function create_obs(obj, sprite, top)
  -- empty table to fill with below values
  local o = {}
  if (top == true) then
    o.x = flr(rnd(110)) + 10
    o.y = 0
  else
    o.x = 128
    o.y = (flr(rnd(4)) + 1) * 24
  end
  o.sprite = sprite

  add(obj, o)
  return o
end

function update_feathers(o)
  o.y += 2
end


function update_weights(o)
  o.y += 4
end

function update_trash(o)
  o.x -= 1
end

function draw_obs(o)
  spr(o.sprite, o.x, o.y)
end

function collision_obs(obj)
  for f in all(obj) do
      local distance = sqrt((f.y - player.y)^2 + (f.x - player.x)^2)
      if distance <= 9 then
        del(obj, f)
        if (obj == feathers) then
          score += 1
          sfx(7)
        elseif (obj == weights) then
          player.hearts -= 1
          sfx(6)
        end
      end

      if (f.y>128) del(obj, f)
  end
end

function trash_collision(obj)
  for f in all(obj) do
    if(f.x == player.x) and (f.y == player.y) then
      del(obj, f)
      sfx(6)
      player.hearts -= 1
    end
    if (f.x<=0) del(obj, f)
  end
end



function world_collision(a)
  local cb = false

  if(a.cw) then
    cb = (a.x<0 or a.x+8>w or
          a.y<0 or a.y+8>h)
  end
  return cb
end
-----------------------------------
-- end feather utility functions
-----------------------------------

--------------------------------------------------------------------------------
-- end utility functions
--------------------------------------------------------------------------------

__gfx__
000000000003300033444411334554113345541111111111111111113333333333333333333333331145543311455433111111113333333b3333333355555555
00000000000ff0003355556133455411334554111111111111111111333333333333333333333333114554331145543311111111333333b333333333dddddddd
007007000f8558f03355556733455411334554111111111111111111333333333333333333333333114554331145543311111111333333b33333333366666666
00077000ff8558ff3355556733455411334554444444444444444411444444443344444444444433114554334445543311101111b33333333333333366666666
00077000f099990f33555567334554113345555555555555555554115555555533455555555554331145543355555433111101113b3333333333333366666666
007007000055550033555567334554113345555555555555555554115555555533455555555554331145543355555433111111113b3333333333333366666666
0000000000f00f0033555561334554113344444444444444444554114444444433455444444554331145543344444433111111113b3333333333333366666666
00000000004004003344441133455411333333333333333333455411111111113345541111455433114554333333333311111111333333333333333366666666
666776666666666611111111cccccccccccccccc02000020088008800550055004444444440000441111111111111111111111111a1bb11111d7777777777d01
66677666666666661dddddd1cccccccccccccccc0222222088888788555557550444444444000044111111111111111181111111a1c11b111d755555555557d0
66677666666666661dddddd1cccccccccccccccc0299992088888878555555750440000004400440111111111111111118121111a5191111d75111111111157d
66677666666666661dd2ddd1cccccccc49cccc940129921088888888555555550440000004400440111119999991111111c12111511191117511111111111157
66677666666666661ddd2dd1cccccccc4c9cc9c40129921008888880055555500444400000400400111199a99a9911111e151115111191115111111011111115
66677666666666661dddddd1cccccccc4cc99cc4d112211d0088880000555500044440000044440011199a999ea99111e1105111511111115111111101111115
66677666666666661dddddd1cccccccc4cccccc4dddddddd000880000005500004400000000440001119a999e99a91111e110511051111115111111111111115
666776666666666611111111cccccccc4555555400dddd0000000000000000000440000000044000111999929999911111111177701111115111111111111115
00000000000000002222222222222222222222222222222222225555000000000000000000000000111999922999911111111166611111115111111111111105
00000000000000002222222222222222492222942221222222222555000000000000000000000000111999922999911111111166611111115111111111100005
000000000000000022222222222222224292292422611002222255550000000000000000000000001119992aa299911111111156511111115661111100000665
000000000000000022222222222222224229922426651502222d55250000000000000000000000001119922222299011111111565110011156d66d6666d66d65
0000000000000000222222222222222242222224265555527766d222000000000000000000000000111199999999000111111155510001111566666666666651
000000000000000022222222222222224222222425555dd276662222000000000000000000000000111119999990001111115555555011111155555555555511
00000000000000002222222222222222555555552266662266662222000000000000000000000000111111444400011111155511155511111111212222121111
00000000000000002666666222222222555555552222222266662222000000000000000000000000111114444441111111555111115551111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000d6666d0000000000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000075666657000000000002555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000765666656700000000022200050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666d66d6660000000002e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000d66666666d0000000002e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066666666660000000002e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066666666660000000022e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666666666600000000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000556666666600000000255520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555d56666600000000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dddd66666500000000255520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666666655500000000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066666dd55500000022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666666dddd00000222aaaaa2200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666666666600002222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001100202020202020202020000000000000000000000000000202040408080000000000002020000002020404080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0d0e0e0d0e0e0e0e0e0e0d0e0e0d0e0e0e0e0e0e0d0e0e0d0e0e0e0e0e0e0e0d0e0e0d0e0e0e131313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0d0e0e0d0e0e0e0e0e0e0d0e0e0d0e0e0e0e0e0e0d0e0e0d0e0e0e0e0e0e0e0e0e0e131313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e141414141414141414141414141414141400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0d232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08070707070707070707070707070707070707070707070707070707070707090e0e0e0e0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0a0e0d0e0e0d0e222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212121212121212121212121212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212121212121212121212121212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030c0c0c0c0c0c0c0c0c0c0c12120c0c0c0c0c0c0c0c0c0c0c12120c1e1f0c0a0e0e0e0e0e0e222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040505050505060c0c0c0c0c12120c1a1b0c0c0c0c0c1c1d0c12120c2e2f0c0a0d0e0e0d0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e030c0c1e1f0c12120c2a2b0c0c0c0c0c2c2d0c12120c0c0c0c0a0e0e0e0e0e0e232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c2e2f0c12120c0c0c0c0c0c0c0c0c0c0c12120c1a1b0c0a0d0e0e0d0e0e242424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0d0e0e030c0c0c0c0c12120c0c0c0c1e1f0c0c0c0c0c12120c2a2b0c0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c0c0c0c12120c0c0c0c2e2f0c0c0c0c0c12120c0c0c0c0a0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d030c0c1c1d0c12120c0c0c0c0c0c0c0c1a1b0c12120c1c1d0c0a0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c2c2d0c12120c0c0c0c0c0c0c0c2a2b0c12120c2c2d0c0a0e0d0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e030c0c0c0c0c12120c0c0c0c0c0c0c0c0c0c0c12120c0c0c0c0a0d0e0e0d0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0d0e0e030c0c0c0c0c1212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c1e1f0c1212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d030c0c2e2f0c0c0c0c1a1b0c0c0c0c0c0c0c0c1e1f0c0c0c0c0a0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c0c0c0c0c0c0c2a2b0c0c0c0c0c0c0c0c2e2f0c0c0c0c0a0e0d0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e040505050505050505050505050505050505050505050505050b0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0d0e0e0e0e0d0e0e0e0e0d0e0e0e0e0d0e0e0d0e0e0e0d0e0e0e0d0e0e0d0e0e0d0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d11111011111011111011111011111011111011111011111011110e0e0e0e0e0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e11111011111011111011111011111011111011111011111011110e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e11111011111011111011111011111011111011111011111011110e0d0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010e00000c055000000c0550000013055000000c055000000c055000000c0550000015055000000c055000000c055000000c0550000015055000001305500000110550000010055000000e055000000c05500000
010e00001005300000000000000010053000000000000000100530000000000000001005300000000001005310053000000000000000100530000000000000000c053000000e0530000010053000001105300000
010e00000c1500c15000000101500000011150000001115013150000001115010150000000c1500e150000000e1500e1500000011150000001315000000131501115000000101500e150000000e1500c15000000
010e00000c1700c170000001114000000101400c140000001314010140000000c1400e140000000e140000000e1501015000000101501115000000111501315000000101500e150000000e1500c1500c15000000
010e00000c1500c15000000101500000011150000001115013150000001115010150000000c1500e150000000e1500e1500000010150101500000011150111501315000000151500000017150000001815018150
010e00000c1500c15000000101500000011150000001115013150000001115010150000000c1500e150000000c1500e150000000c1500e150000000c1500e15010150000000e150000000c1500c1500000000000
0104000017453124730e4730b47308473000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070000285702b570305700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001075000000107500000013750000001075000000107500000010750000001375000000107500000010750000001075000000157500000010750000001075000000107500000013750000001075000000
010800000c635000040000000000000000000000000000000c6350000000000000000000000000000000000011635000000000000000000000000000000000001063500000106350000015635000001063500000
0108000010140000000e1400000010140000000e14000000131400000013140000001014000000000000000010140000001014000000111400000010140000000000000000000000000000000000000000000000
010800001d542000001d5421d5421d542000001c542000001a542000001a5421a5421a542000001c542000001a542000001c5421c5421a542000001c542000001c542000001d5420000021542000000000000000
011000001d542000001d542000001d542000001d542000001c542000001c542000001c542000001c542000001a54200000000001a542000001a542000001d5421c54200000000000000000000000000000000000
011000001a54200000000001a542000001a542000001d5421c5420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001d542000001d5421d5421d542000001c542000001a542000001a5421a5421a542000001c5420000018542000001a542000001a542000001a542000001854218542000000000000000000000000000000
01100000105730e57300000105730e57300000105730e57300000105730e5730e5730c57300000105731057310573000001057300000105730000010573000001357300000115730000010573000000e5730c573
0110000010155000001015500000101550e1550000010155000001015500000101551515500000151550000010155000001015500000101550e15500000101550000010155000001015517155000001715500000
011000001c0451c0451c0451c04500000000001f0451f0451c0451c0451c0451c045000000000021045210451c0451c0451c0451c04500000000001f0451f0451f0451d0451c0451a0451c045000001c04500000
011000002804528045280452804500000000002b0452b0452804528045280452804500000000002d0452d0452804528045280452804500000000002b0452b0452b04529045280452604528045000002804528045
010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002803500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002d04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000150502b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001075300000000000000010753000000000000000107530000000000000001075310753000000000010753000000000000000107530000000000000001075300000000000000010753117531375315753
01100000107300e73011730137300c700107300e73013730157300c7000e7300c700117300c700107300c700107301173013730157300c700107301173013730157300c700107300c700137300c700117300c500
01100000210201f0201d0201c0201f0201d0201c0201a0201d0201c0201a020180201c0201a020180201702018020000001a020000001c020000001d020000001f02000000210200000023020000002402000000
01100000150201300011020100001302011000100200e00011020100000e0200c000100200e0000c0200b0000c020000000e02000000100200000011020000001302018000150201800017020180001802000000
011000001a0301c0301a0001a0301c0301a0001a0301c030180001a0301c03018000210301800021030180001a0301c030180001a0301c030180001a0301c030180001a0301c0301800023030180002303018000
01100000180001060000000106350000010600106350000000000106351063510635000000e600106350000000000106000000010635000001060010635000000000011635040001163500000106350e63500000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000070500f050140501d05024000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000000009310033100131007000050000300001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002575028750010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002875035720287500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00014244
00 00010244
00 00010344
00 00010244
00 00010344
02 00010444
00 41424344
00 49424344
01 090a4b44
00 08090a4b
00 08090a0b
00 08090a4c
00 08090a0e
00 08090a44
00 08090a0c
02 08090a0d
00 41424344
01 0f101152
00 0f105112
00 0f101112
02 0f104344
00 41424344
01 191e1d44
00 191d1e1a
02 191b4f1e

