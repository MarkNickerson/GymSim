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
  feather_fail = 12,
  masher_intro = 13,
  masher_win = 14,
  masher_fail = 15,
  win = 20,
  fight_boss = 21
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
completed_tasks = {false, false, true, true} -- run, feather, post
-- which boss options have been chosen
chosen_boss_options = {false, false, false, false}
-- text to show for each boss option
boss_fight_options = {"speed", "agility", "power", "escape"}
-- boss responses
boss_response = {}
boss_response["power"] = "you unleash a flurry of powerful scratches!"
boss_response["speed"] = "the vacuum tries to escape, but you easily catch up and corner it!"
boss_response["agility"] = "the vacuum makes a quick dash at you, but you easily dodge and counter!"
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
fight_boss_prompt = false
--------------------------------------------------------------------------------
-- end global variables
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- begin pico8 game funtions
--------------------------------------------------------------------------------
function _init()
  cls()
  menuitem (4, "hit the gym", function() change_state(1) end)
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
  elseif state == game_states.masher then
    update_masher()
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
  elseif state == game_states.masher_intro then
    update_masher_intro()
  elseif state == game_states.masher_win then
    update_masher_win()
  elseif state == game_states.masher_fail then
    update_masher_fail()
  elseif state == game_states.win then
    update_win()
  elseif state == game_states.fight_boss then
    update_fight_boss()
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
  elseif state == game_states.masher then
    draw_masher()
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
  elseif state == game_states.masher_intro then
    draw_masher_intro()
  elseif state == game_states.masher_win then
    draw_masher_win()
  elseif state == game_states.masher_fail then
    draw_masher_fail()
  elseif state == game_states.win then
    draw_win()
  elseif state == game_states.fight_boss then
    draw_fight_boss()
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
  palt(0, false)
  rectfill(0,0,screen_size,screen_size,12)
  spr(69,48,32, 4, 4)
  local text = "press x to enter"
  write(text, text_x_pos(text), 80,7)
  palt(0, true)
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
    change_state(13)
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
    if player.runningboost and player.featherboost and player.punchingboost and not fight_boss_prompt then
      fight_boss_prompt = true
      change_state(21)
    end
end

function draw_gym()
  -- draw map
  map(0, 0, 0, 0, 128, 32)
  camera(cam.x, cam.y)
  -- draw player sprite
  -- spr(1, player.x, player.y)
  draw_player_small(player.x, player.y)
  draw_boosts()
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
      player.featherboost = true
    end
end

function draw_feather()
  cls(5)
  map(38, 16, 0, 0, 128, 32)
  camera(0, 0)
  -- spr(1,player.x,player.y) --draw player
  spr(65,player.x,player.y+4, 2, 2) --draw player

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
  local text = " avoid obstacles by using"
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
      player.runningboost = true
    end
end

function draw_runner()
  cls()

  -- draw map
  map(38, 0, -((time()*16 % 8)), 0, 128, 32)
  camera(0, 0)

  -- spawn objects
  foreach(trash, draw_obs)
  draw_hearts()
  -- spr(1, player.x, player.y)
  draw_player_small(player.x, player.y-8)
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
  local text = " avoid obstacles by using"
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
-- begin masher
--------------------------------------------------------------------------------

post = {
  x = 30,
  y = 84,
  health = 100
}

function draw_scratching_post(x, y)
  spr(141, x, y)
  spr(142, x+8, y)
  spr(157, x, y+8)
  spr(158, x+8, y+8)
  spr(159, x+16, y+8)
  spr(173, x, y+16)
  spr(174, x+8, y+16)
  spr(175, x+16, y+16)
  spr(194, x+4, y+24)
  spr(188, x-8, y+32)
  spr(189, x, y+32)
  spr(190, x+8, y+32)
  spr(191, x+16, y+32)
end

function masher_input()
  if btnp(0) then --left
    post.health -= 1
  end
  if btnp(1) then --right
    post.health -= 1
  end
end

function update_masher()
  masher_input()
  --if btnp(5) then
  if post.health <= 0 then
      change_state(14) -- change state to masher win scene
      completed_tasks[2] = true
      punchingboost = true
  end
  if (flr(minutetimer/60) == 30) then
      change_state(15) -- change state to masher fail scene
    end
end

function draw_masher()
  cls()
  print ('timer:'..flr(minutetimer/60), 90, 10, 4)
  print ('health:'..post.health, post.x-8, post.y-8, 4)
  draw_scratching_post(post.x, post.y)

  draw_player_attack(player.x, player.y)
  --if btnp(0) then -- draw attack cat
  --  draw_player_attack(player.x, player.y)
  --elseif btnp(1) then -- draw attack cat
  --  draw_player_attack(player.x, player.y)
  --else
  --  draw_player_large(player.x, player.y)
  --end

end

function update_masher_intro()
  if btnp(5) then
      change_state(4) -- change state to masher scene
  end
end

function draw_masher_intro()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,12)
  local text = "button mashing sim!"
  write(text, text_x_pos(text), 30,7)
  local text = "hone your punching skills"
  write(text, text_x_pos(text), 50,7)
  local text = " use the left and right arrows"
  write(text, text_x_pos(text), 60,7)
  local text = " to defeat the evil"
  write(text, text_x_pos(text), 75,7)
  local text = " scratching post!"
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

function update_masher_win()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_masher_win()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,14)
  local text = " you won!"
  write(text, text_x_pos(text), 30,7)
  local text = " you'll be able to"
  write(text, text_x_pos(text), 50,7)
  local text = " use a punch attack"
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

function update_masher_fail()
  if btnp(5) then
      change_state(1) -- change state to gym scene
  end
end

function draw_masher_fail()
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
-- end masher
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
    boss_move = "the vacuum goes silent. you win!"
    -- go to end screen if victory
    if btnp(5) then
      change_state(20)
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
  -- spr(21, 20, 60)
  draw_player_large(20, 36)

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
    write_with_bounds(boss_move, 10,80, 3, screen_size - 10)
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
        write_with_bounds(selected_symbol .. boss_fight_options[i], menu_offset.x,menu_offset.y + text_spacing * i,5, screen_size - 10)
      else
        write_with_bounds(" " .. boss_fight_options[i], menu_offset.x,menu_offset.y + text_spacing * i,5, screen_size - 10)
      end
    end
  end
end
--------------------------------------------------------------------------------
-- end boss
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- begin win
--------------------------------------------------------------------------------

function draw_win()
  write_with_bounds("you beat the vacuum! you worked out! nothing can stop you now!", 20, 20, 4, screen_size - 20)
end


function update_win()
  if (btnp(5)) then
    -- reset game
    run()
  end
end

--------------------------------------------------------------------------------
-- end win
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- begin fight boss
--------------------------------------------------------------------------------

function draw_fight_boss()
  cls()
  camera(0, 0)
  rectfill(0,0,screen_size,screen_size,10)
  local text = " nice work!"
  write(text, text_x_pos(text), 30,15)
  local text = " you're ready to face the"
  write(text, text_x_pos(text), 50,15)
  local text = " fearsome vacuum!"
  write(text, text_x_pos(text), 60,15)
  local text = " leave the gym and"
  write(text, text_x_pos(text), 70,15)
  local text = " beat that boss!"
  write(text, text_x_pos(text), 80,7)
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

function update_fight_boss()
  if (btnp(5)) then
    change_state(1) -- change state to gym scene
  end
end

--------------------------------------------------------------------------------
-- end fight boss
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- begin player
--------------------------------------------------------------------------------

function draw_player_large(x, y)
  -- draw player sprite 32 x 32
  spr(130, x+16, y)
  spr(131, x+24, y)
  spr(144, x, y+8)
  spr(145, x+8, y+8)
  spr(146, x+16, y+8)
  spr(147, x+24, y+8)
  spr(160, x, y+16)
  spr(161, x+8, y+16)
  spr(162, x+16, y+16)
  spr(163, x+24, y+16)
  spr(176, x, y+24)
  spr(177, x+8, y+24)
  spr(178, x+16, y+24)
  spr(179, x+24, y+24)
end

function draw_player_small(x, y)
  -- draw player sprite 16 x 16
  spr(224, x, y)
  spr(225, x+8, y)
  spr(240, x, y+8)
  spr(241, x+8, y+8)
end

function draw_player_attack(x, y)
  -- draw cat scratch attack sprite
  spr(195, x, y)
  spr(196, x+8, y)
  spr(197, x+16, y)
  spr(198, x+24, y)

  spr(211, x, y+8)
  spr(212, x+8, y+8)
  spr(213, x+16, y+8)
  spr(214, x+24, y+8)

  spr(227, x, y+16)
  spr(228, x+8, y+16)
  spr(229, x+16, y+16)
  spr(230, x+24, y+16)

  spr(243, x, y+24)
  spr(244, x+8, y+24)
  spr(245, x+16, y+24)
  spr(246, x+24, y+24)
end

--------------------------------------------------------------------------------
-- end player
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
    music(38)
    player.x = 44
    player.y = 92
    state = game_states.masher
    minutetimer = 0

  elseif game == 5 then
    state = game_states.gameover

  elseif game == 6 then
    if can_boss_be_defeated() then
      music(28)
      boss_move = "you think of all the gains you have from working out. it fills you with resolve!"
    else
      music(8)
      boss_move = "a wild vacuum appears! it looks at you menacingly. you doubt you can beat it in your current state."
    end
    camera(0, 0)
    for i=1,#chosen_boss_options do
      chosen_boss_options[i] = false
    end
    selected_option = 1
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
  elseif game == 13 then
    state = game_states.masher_intro
  elseif game == 14 then
    state = game_states.masher_win
  elseif game == 15 then
    state = game_states.masher_fail
  elseif game == 20 then
    music(33)
    state = game_states.win
  elseif game == 21 then
    state = game_states.fight_boss
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

-- draw boosts in gym
function draw_boosts()
  rectfill(cam.x, cam.y, cam.x + 128, cam.y + 9, 15)
  rectfill(cam.x, cam.y+9, cam.x + 128, cam.y+9.5 , 0)
  local text = "jim's abilities"
  write(text, cam.x + 8, cam.y +1, 14)
  if(player.runningboost == true) then
    spr(48, cam.x + 110, cam.y+1)
  else
    spr(49, cam.x + 110, cam.y+1)
  end

  if(player.featherboost == true) then
    spr(50, cam.x + 100, cam.y+1)
  else
    spr(51, cam.x + 100, cam.y+1)
  end

  if(player.punchingboost == true) then
    spr(52, cam.x + 90, cam.y+1)
  else
    spr(53, cam.x + 90, cam.y+1)
  end
end

-- draw hearts ui
function draw_hearts()
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

function can_boss_be_defeated()
  local can_be_defeated = true
  for i=1,4 do
    can_be_defeated = can_be_defeated and completed_tasks[i]
  end
  return can_be_defeated

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
666776666666666611111111cccccccccccccccc02000020088008800550055000000660066666601111111111111111111111111a1bb11111d7777777777d01
66677666666666661dddddd1cccccccccccccccc0222222088888788555557550000777606000060111111111111111181111111a1c11b111d755555555557d0
66677666666666661dddddd1cccccccccccccccc0299992088888878555555750007757666666666111111111111111118121111a5191111d75111111111157d
66677666666666661dd2ddd1cccccccc49cccc940129921088888888555555550077577066868886111119999991111111c12111511191117511111111111157
66677666666666661ddd2dd1cccccccc4c9cc9c40129921008888880055555500075770068868666111199a99a9911111e151115111191115111111011111115
66677666666666661dddddd1cccccccc4cc99cc4d112211d0088880000555500005770006686888611199a999ea99111e1105111511111115111111101111115
66677666666666661dddddd1cccccccc4cccccc4dddddddd000880000005500005000000668666861119a999e99a91111e110511051111115111111111111115
666776666666666611111111cccccccc4555555400dddd0000000000000000005000000066868886111999929999911111111177701111115111111111111115
00000000000000002222222222222222222222222222222226666662000000000000000000000000111999922999911111111166611111115111111111111105
00000000000000002222222222222222492222942221222226222262000000000000000000000000111999922999911111111166611111115111111111100005
000000000000000022222222222222224292292422611002666666660000000000000000000000001119992aa299911111111156511111115661111100000665
000000000000000022222222222222224229922426651502668688860000000000000000000000001119922222299011111111565110011156d66d6666d66d65
00000000000000002222222222222222422222242655555268868666000000000000000000000000111199999999000111111155510001111566666666666651
000000000000000022222222222222224222222425555dd266868886000000000000000000000000111119999990001111115555555011111155555555555511
00000000000000002222222222222222555555552266662266866686000000000000000000000000111111444400011111155511155511111111212222121111
00000000000000002666666222222222555555552222222266868886000000000000000000000000111114444441111111555111115551111111111111111111
0007aa70000766700000008e000000670676ddd00575555000000000000000000000000000000000000000000000000000000000000000000000000000000000
007aaa900076665000028ce800056576788888867666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
07aaa9000766650000828ec0006567506999999d6777777500000000000000000000000000000000000000000000000000000000000000000000000000000000
09aa9000056650000082e88000657660d888888d5666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa0000056600000c8222000565550d999999d5777777500000000000000000000000000000000000000000000000000000000000000000000000000000000
0009a70000056700056c8800056566000d8888d00566665000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009a0000005600065000000650000000d99d000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a000000060005000000050000000000dd0000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc00000077770000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
cccccccc00000d6666d000000000000111100000c000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000
cccccccc000075666657000000000002555100000777777777777777777777777777777000000000000000000000000000000000000000000000000000000000
cccccccc0007656666567000000000222000500077ccccccc77cc7777cc77cc77777cc7700000000000000000000000000000000000000000000000000000000
cccccccc000666d66d6660000000002e200000007ccc000cc77cc7777cc77ccc777cccc700000000000000000000000000000000000000000000000000000000
cccccccc000d66666666d0000000002e200000007ccc777cc77cc7777cc77cccc7ccccc700000000000000000000000000000000000000000000000000000000
cccccccc00066666666660000000002e200000007ccc7770077cc7777cc77cc0ccc0ccc700000000000000000000000000000000000000000000000000000000
ccececcc00066666666660000000022e200000007ccc77777770cc77cc077cc70c07ccc700000000000000000000000000000000000000000000000000000000
cccecccc000666666666600000000222220000007ccc777777770cccc0777cc77077ccc700000000000000000000000000000000000000000000000000000000
cccccccc000556666666600000000255520000007ccc7cccc77770cc07777cc77777ccc700000000000000000000000000000000000000000000000000000000
cccccccc000555d56666600000000222220000007ccc700cc77777cc77777cc77777ccc700000000000000000000000000000000000000000000000000000000
cccccccc000dddd666665000000002555200000070ccccccc77777cc77777cc77777cc0700000000000000000000000000000000000000000000000000000000
cccccccc000666666655500000000222220000007700000007777700777770077777007700000000000000000000000000000000000000000000000000000000
cccccccc00066666dd5550000002222222200000c777777777777777777777777777777c00000000000000000000000000000000000000000000000000000000
cccccccc000666666dddd00000222aaaaa220000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
cccccccc00066666666660000222222222222000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccc000000cccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cc000000ccc07777770cc00ccccc00cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000c0777777ccc77776667cc770ccc077cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000c777ccccccc77777777cc7770c0777cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000c777cccccccccc77ccccc777707777cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000c7770000cccccc77ccccc77c777c77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cc7777770ccccc77ccccc77cc7cc77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccc777ccccc77ccccc77ccccc77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccc777cc00077000cc77ccccc77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cc0000777cc77776667cc77ccccc77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cc777777ccc77777777cc77ccccc77cc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccc777777cccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049999999999990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044449999999990000000000
00000000000000000000777777600000000000000000000000007777776000000000000000000000000077777760000000000000000049999999000000000000
00000000000000000000000777777600000000000000000000000007777776000000000000000000000000077777760000000000000049999990900000000000
00000000000000000000000000007600000000000000000000000000000076000000000000000000000000000000760000000000000049999990090000000000
00000000000000000000000000007600000000000000000000000000000076000000000000000000000000000000760000000000000049999990090000000000
00000000000000000000000000007600000000000000000000000000000076000000000000000000000000000000760000000000000049999990009000000000
00000060006000000000000000007600000000600060000000000000000076000000006000600000000000000000760000000000000049999990009000000000
00000660076000000000000000007600000006600760000000000000000076000000066007600000000000000000760000000000000049999990009000000000
00006660776000000000000000007600000066607760000000000000000076000000666077600000000000000000760000000000000049999990009000000000
00006777776000000000000000077600000067777760000000000000000776000000677777600000000000000007760000000000000049999990009000000000
00067777777700006776677000076000000677777777000067766770000760000006777777770000677667700007600000000000000049999990009000000000
00067777777770766776677667776000000677777777707667766776677760000006777777777076677667766777600000000000000049999990009000000000
00677777777777766776677667760000006777777777777667766776677600000067777777777776677667766776000000000000000049999990111100000000
55575775775557766776677667760000555757757755577667766776677600005557577577555776677667766776000000000000000049999991117710000000
00675775777777766776677667760000006757757777777667766776677600000067577577777776677667766776000000000000000049999991111110000000
55577777775557776776777677776000555777777755577767767776777600005557777777555777677677767776000000000000000049999991111110000000
00677577777777777777777777776000006775777777777777777777777600000067757777777777777777777776000000000000000049999991111110000000
00675757777777777777777777777600006757577777777777777777777660000067575777777777777777777776600000000000000049999990111100000000
00067777777677777777777767777600000677777776777777777777777760000006777777767777777777777777600000000000000049999990000000000000
00006777776777677777777776777760000067777767777767777776777776000000677777677777777777767777760000000000000049999990000000000000
00000066677777677777777766777760000000666777777677777777677776000000006667777777777777776777760000000000000049999990000000000000
00000000667776066666666606677760000000006667777666666666677766000000000066677777666666666777760000000000000049999990000000000000
00000000667760000000000006607760000000000007776600000000077766600000000000067777000000000666777000000000000049999990000000000000
00000006607700000000000006600760000000000077766000000000077706600000000000667770000000000666077000000000000049999990000000000000
00000066007600000000000006600760000000000777066000000000777006600000000006660770000000006660077000000000000049999990000000000000
00000066007600000000000066000760000000007770066000000007770006600000000066600770000000066600077000000000000049999990000000000000
00000066007600000000000066000760000000077700065000000077700006500000000666000750000000666000075000000000000049999990000000000000
00000550055000000000000550005500000000555000550000000555000055000000005550005500000005550000550000000000004999999999900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049999999999999999990000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444444440000000
00000000000000004999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000009000000004999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000099000000004999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000009a9000000004999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009aa9000000004999999000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099aaaa900000004999999000006000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaaaaa99000994999999000006600000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa0aaaaaaa909904999999000006600000066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaaaaaaaa999000000000000000660006667776666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaaaaa99909900000000000007660066777777766600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099aaaa999000990000000000007766067757777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000099aa900000000000000000007766065777557760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000099a90000000000000000006776667777755760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999000000000000000000777677775577760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000677776777557600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000067777677776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000677767767600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777770000000000000000000067777777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600000077000000000000000000006777776666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06607600000007000000000000000000000677766776000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777600000007000000000000000000000677777666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770000007000000000000000000000677776677600000000000000000000000000000000000000000000000000000000000000000000000000000000000
75755570000007000000000000000000000067777766600000000000000000000000000000000000000000000000000000000000000000000000000000000000
57777770000077000000000000000000000066777667600000000000000000000000000000000000000000000000000000000000000000000000000000000000
77755576767677000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777776767670000000000000000000000006777777660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077776767670000000000000000000000067777766660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777770000000000000000000000067777666660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000667777666066600000000000000000000000000000000000000000000000000000000000000000000000000000000
00077600006777000000000000000000000677777660000666600000000000000000000000000000000000000000000000000000000000000000000000000000
00076600006677000000000000000000006777776600000006666600000000000000000000000000000000000000000000000000000000000000000000000000
00776000066007000000000000000006666666666000000000006666000000000000000000000000000000000000000000000000000000000000000000000000
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
0e0e0e0e0e0d030c0c1c1d0c12120c0c0c0c0c0c0c0c1a1b0c12120c1c1d0c0a0e0e0e0e0e0e404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c2c2d0c12120c0c0c0c0c0c0c0c2a2b0c12120c2c2d0c0a0e0d0e0e0e0e505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e030c0c0c0c0c12120c0c0c0c0c0c0c0c0c0c0c12120c0c0c0c0a0d0e0e0d0e0e404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0d0e0e030c0c0c0c0c1212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0e505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c1e1f0c1212121212121212121212121212120c0c0c0c0a0e0e0e0e0e0d404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d030c0c2e2f0c0c0c0c1a1b0c0c0c0c0c0c0c0c1e1f0c0c0c0c0a0e0e0e0e0e0e505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e030c0c0c0c0c0c0c0c2a2b0c0c0c0c0c0c0c0c2e2f0c0c0c0c0a0e0d0e0e0e0e404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e040505050505050505050505050505050505050505050505050b0e0e0e0e0e0e505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0d0e0e0e0e0d0e0e0e0e0d0e0e0e0e0d0e0e0d0e0e0e0d0e0e0e0d0e0e0d0e0e0d0e0e404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0d11111011111011111011111011111011111011111011111011110e0e0e0e0e0d404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e11111011111011111011111011111011111011111011111011110e0e0e0e0e0e505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0d0e0e0e0e11111011111011111011111011111011111011111011111011110e0d0e0e0e0e404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000001c0301d0301a0001c0301d0301a0001c0301d0301a0001c0301d03018000240301800024030180001c0301d0301d0001c0301d030180001c0301d030180001c0301d0301800026030180002603018000
01100000210301f0301d0301c0301f0301d0301c0301a0301d0301c0301a030180301c0301a030180301703018030000001a030000001c030000001d030000001f03000000210300000023030000002403000000
01100000150201300011020100001302011000100200e00011020100000e0200c000100200e0000c0200b0000c020000000e02000000100200000011020000001302018000150201800017020180001802000000
011000001a0301c0301a0001a0301c0301a0001a0301c030180001a0301c03018000210301800021030180001a0301c030180001a0301c030180001a0301c030180001a0301c0301800023030180002303018000
01100000180001060000000106350000010600106350000000000106351063510635000000e600106350000000000106000000010635000001060010635000000000011635040001163500000106350e63500000
011000000c5120c5120c5120c5120c5120c5120c5120c5120e5120e5120e5120e5120e5120e5120e5120e51210522105221052210522105221052210522105221153211532115321153211532115321153211532
01100000115001150011500115001150011500115001150010500105001050010500105001050010500105000e5000e5000e5000e5000e5000e5000e5000e5000c5000c5000c5000c5000c5000c5000c5000c500
01020000070500f050140501d05024000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000000009310033100131007000050000300001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002575028750010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002875035720287500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001573011600157301500015730170001773000000177300000017730000001873000000187300000018730000001a730000001a730000001a730000001c730000001c730000001c730000000000000000
01100000000001570000000000001062300000177000000010625000001062500000187000000010625000001a70000000106251061511625116151362513615106251c700000000000015625000001562500000
011000001042510425104251c0000e425180001142511425114251c00010425180001342513425134251c00011425104250e425230000c4250000010425000000c425000000b425000000c425000000000000000
011000000c4250c4250c4251c00011425180001042510425104251c00013425180001142511425114251c0001542513425114250000010425000000e425000000c42500000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000024510000002b51000000285100000024510000002b51000000000002b51000000000002451024510000000000024510000002b5100000024510000002b51000000000002b51000000000002b5102b510
0110000024510000002b51000000285100000024510000002b51000000000002b51000000000002451024510000000000024510000002b5100000028510000003051000000000002d51000000000003051030500
011000000c5100c000135100c000105100c0000c5100c000135100c0000c000135100c0000c0000c5100c5100c0000c0000e5100c0000c5100c000105100c000105100c0000c0000e5100c0000c0001051010510
011000000c5100c000135100c000105100c0000c5100c000135100c0000c000135100c0000c0000c5100c5100c0000c0000c5100c000135100c000105100c000185100c0000c000155100c0000c0001851018500
011000000450000000045000000000500000000250004500005000000004500000000450000000045000000002500000000050000000000000000000000000000000000000000000000000000000000000000000
01140000151551515518155151551a155151551c1551a15518155181551c155181551f155181551c155181551315513155171551315518155131551a155181551115511155151551115518155111551815517155
010c00001515500000000001515500000000001515500000000001515500000000001315500000181550000015155000000000015155000000000015155000000000015155000000000013155000001015500000
010c00001513515135151351513509135091350913509135151351513515135151350913509135091350913515135151351513515135091350913509135091351513515135151351513509135091350913509135
011400000912009120091200912009120091200912009120091200912009120091200912009120091200912009120091200912009120091200912009120091200912009120091200912009120091200912009120
011400001512015120151201512015120151201512015120151201512015120151201512015120151201512015120151201512015120151201512015120151201512015120151201512015120151201512015120
010c000009155091550000009155091550000009155091550000009155091550000007155071550c1550c15509155091550000009155091550000009155091550000009155091550000007155071550415504155
010c00001815518155000001815518155000001815518155000001815518155000000b1550b15510155101551815518155000001815518155000001815518155000001815518155000000b1550b1550715507155
010c00001515515155000001515515155000001515515155000001515515155000001315513155181551815515155151550000015155151550000015155151550000015155151550000013155131551015510155
010c000009155091550000009155091550000009155091550000009155091550000007155071550c1550c15509155091550000009155091550000009155091550000009155091550000015155151550000000000
010c00001815518155000001815518155000001815518155000001815518155000001715517155101551015518155181550000018155181550000018155181550000018155181550000018155181550000000000
010c00001515515155000001515515155000001515515155000001515515155000001315513155181551815515155151550000015155151550000015155151550000015155151550000013155131550000000000
010c000021050280500000021050240500000021050220500000021050240500000021050220501f0500000021050280500000021050240500000021050220500000021050240500000021050000000000000000
010c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00014244
00 00010244
00 00010344
00 00010244
02 00010444
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
01 191e1d5f
00 195f1e1a
02 191b201e
00 41424344
00 41424344
00 41424344
01 26276844
00 26272844
00 26272944
02 26272844
00 41424344
00 2b6c4344
00 2c424344
00 2b2d6e44
00 2c2e4344
00 41424344
00 30724344
00 30333444
00 31324344
01 35363732
00 38393a32
00 323b3578
02 323b3578

