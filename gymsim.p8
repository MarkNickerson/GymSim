pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- base game
-- a base to start a game
-- by misato


-- state machine

-- game states
-- there are no enum in lua so followed the advice from here: https://www.allegro.cc/forums/thread/605178
game_states = {
  splash = 0,
  gym = 1,
  feather = 2,
  runner = 3,
  atsume = 4,
  gameover = 5
}

state = game_states.splash
floor = 120
drag = 0.3 -- 0.1 pixel per second

player = {
  x = 8,
  y = 8,
  dx = 0,
  dy = 0,
  hearts = 0,
  speed = 0.5, -- how far the player should travel over 60 seconds
  jump = {x=0, y=-12},
  jumping = false,
  jumpdur = 1,
  jumpt = 0, -- jump timer
  canjump = false
}
g = {x=0,y=0.5}
solid = false
function debug()
  --print(solid, player.x+3, player.y-11, 9)
end

-- state changes
function change_state(game)
  cls()
  if game == 1 then
    state = game_states.gym
  elseif game == 2 then
    state = game_states.feather
  elseif game == 3 then
    state = game_states.runner
  elseif game == 4 then
    state = game_states.atsume
  elseif game == 5 then
    state = game_states.gameover
  end
end

-- entities (aka player, enemies, etc)


-- add other vars as convenience to this player entity
-- for example, the sprite number or the lives left ;)
function solid_tile(x, y)
  local tilex = ((x - (x % 8)) / 8)
  local tiley = ((y - (y % 8)) / 8)

  if (fget(mget(tilex, tiley), 1)) then
    return true
  else
    return false
  end
end

function phys_input()
  local dt = time() - prev_t -- delta time, how much time has passed since last update
  local px = player.x

  -- simeltanious multi button player movement
  if btn(0) and player.canjump then -- left
    player.dx += -1 * player.speed * dt -- -1 makes us move left, dt allows for a ratio of player speed over time
    --if ()
    --end
  end

  if btn(1) and player.canjump then -- right
    player.dx += player.speed * dt
  end

  if btn(2) and player.canjump then
    player.jumping = true
    player.canjump = false
    player.jumpt = player.jumpdur
  end

  -- jumping
  if player.jumpt - dt < 0 then
    player.jumping = false
  end

  if player.jumping then
    player.dy = player.jump.y * dt
    player.jumpt -= dt
  end

  -- drag
  if player.canjump then
    if player.dx < -drag*dt then                -- need a minimum threshold here, can use a times 2 or times 3 value to get a tighter stop
      player.dx += drag * dt
    elseif player.dx > drag*dt then             -- need a maximum threshold
      player.dx += -1 * drag * dt
    else
      player.dx = 0
    end
  end

  -- gravity
  player.dx += g.x * dt -- g is a per second value and needs to be augmented by frame ratio
  player.dy += g.y * dt

  player.x += player.dx
  player.y += player.dy

  if player.y > floor then
    player.y = floor
    player.dy = 0
    player.jumping = false
    player.canjump = true
  end
  prev_t = time()
end


-- player input
function handle_input()
  -- move player
  local px = player.x

  -- left
  if btn(0) and not solid_tile(player.x-1, player.y) then
    player.dx = -2
    player.x -= 1 -- if implementing friction remove this
  end
  -- right
  if btn(1) and not solid_tile(player.x + 8 + 1, player.y)then
    player.dx = 2
    player.x += 1 -- if implementing friction remove this
  end
  -- up
  if btn(2) and not solid_tile(player.x, player.y-1)then
    player.dy = -2
    player.y -= 1
    if player.y < 8 then
        player.y = 8
    end
  end
  -- down
  if btn(3) and not solid_tile(player.x, player.y + 8 + 1)then
    player.dy = 2
    player.y += 1
  end
  -- to use the following we need friction to remove/reduce velocity
  --player.x += player.dx
  local xoffset = 0
  if player.dx > 0 then xoffset = 7 end

  local h = mget((player.x + xoffset)/8, (player.y+7)/8)

  if fget(h, 2) then
    change_state(2)
  end

  player.dy += 0.2
  if state == game_states.feather then
    player.y += player.dy
  end


end

-- pico8 game funtions
function _init()
  cls()
  -- start game time
  prev_t = time() -- we use past time per frame so we have framerate independent movement
end

function _update60()
  solid = solid_tile(player.x, player.y)
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
    end
end

function _draw()
  cls()
  debug()
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
  end
end


-- splash

function update_splash()
    -- usually we want the player to press one button
     if btn(5) then
         change_state(1) -- change state to gym scene
     end
end

function draw_splash()
    rectfill(0,0,screen_size,screen_size,11)
    local text = "gym sim!"
    write(text, text_x_pos(text), 52,7)
end

-- game
x = screen_size  y = screen_size
function update_gym()
    handle_input()
end

function draw_gym()
  -- draw map
  map(0, 0, 0, 0, 128, 32)
  -- draw player sprite
  spr(1, player.x, player.y)
end

-- feather minigame
function update_feather()
    handle_input()
end

function draw_feather()
  cls()
  -- draw map
  map(16, 0, 0, 0, 128, 32)
  -- draw player sprite
  spr(5, player.x, player.y)
end

-- runner game
function update_runner()
    phys_input()
end

function draw_runner()
  cls()
  -- draw map
  map(16, 0, 0, 0, 128, 32)
  -- draw player sprite
  spr(5, player.x, player.y)
end

-- game over

function update_gameover()

end

function draw_gameover()
  rectfill(0,0,screen_size,screen_size,11)
  local text = "gym sim byee!"
  write(text, text_x_pos(text), 52,7)

end

-- utils
function issolid(x, y)
  val=mget(x, y)

 -- check if flag 1 is set (the
 -- orange toggle button in the
 -- sprite editor)
 return fget(val, 1)
end

-- change this if you use a different resolution like 64x64
screen_size = 128


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


-- returns if module of a/b == 0. equals to a % b == 0 in other languages
function mod_zero(a,b)
   return a - flr(a/b)*b == 0
end
__gfx__
00000000000330009999999900000000888888880200002000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ff0009000000900055000800000080222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000f8558f09000000900500500800000080299992000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ff8558ff9000000905000800800000080129921000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000f099990f90000009500000c0800000080129921000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700005555009000000950000a0080000008d112211d00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f00f0090000009500000b080000008dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000040040099999999500000008888888800dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001020402010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020204040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000000000000000000b0c00000204001c00000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000000000000003001b1c00000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000200000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000200000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000200000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000000000004040400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000004000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204000004000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020204040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
