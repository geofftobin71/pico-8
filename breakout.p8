pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
 init_start()
end

function init_start()
 ball_r=2.5
 pad_y=119
 pad_h=8
 lives=3
 
 _update60=update_start 
 _draw=draw_start
 
 palt(0,false)
 palt(15,true)
end

function init_game()
 ball_x=23
 ball_y=45
 ball_dx=0.615
 ball_dy=1.17

 pad_x=48
 pad_w=32
 pad_dx=0

 snd=0
 invinciball=300

 _update60=update_game
 _draw=draw_game
end

function init_loselife()
 sfx(2)
 lives-=1
 _draw()

 if lives<1 then
  init_gameover()
 else
  _update60=update_loselife
  _draw=draw_loselife
 end
end

function init_gameover()
 _update60=update_gameover
 _draw=draw_gameover
end

-->8
function update_start()
 if (btnp(5)) init_game()
end

function update_game()
 if (btn(0)) pad_dx=-2.5
 if (btn(1)) pad_dx=2.5

 pad_x+=pad_dx
 pad_x=mid(0,pad_x,128-pad_w)
 pad_dx*=0.75
 if (pad_dx<0.1) pad_dx=0

 local new_x=ball_x+ball_dx
 local new_y=ball_y+ball_dy

 local dist
 local nx,ny,nd,na,ns
 local cx,cy,ca
 local mdx=1
 local mdy=1

 repeat
  dist = nil
  local lines_h={}
  local lines_v={}

  if ball_dy>0 then
   add(lines_h,{px1=pad_x-ball_r,px2=pad_x+pad_w+ball_r,py=pad_y-ball_r,snd=1})
   --[[ if invinciball>0 then
   add(lines_h,{px1=0,px2=128,py=128-ball_r,snd=0})
   end ]]--
  else
   add(lines_h,{px1=0,px2=128,py=ball_r,snd=0})
  end

  if ball_dx>0 then
   add(lines_v,{px=128-ball_r,py1=0,py2=128,snd=0})
   add(lines_v,{px=pad_x-ball_r,py1=pad_y-ball_r,py2=128,snd=1})
  else
   add(lines_v,{px=ball_r,py1=0,py2=128,snd=0})
   add(lines_v,{px=pad_x+pad_w+ball_r,py1=pad_y-ball_r,py2=128,snd=1})
  end

  for l in all(lines_h) do
   nx,ny,nd,na,ns=intersect_h(
   ball_x,ball_y,new_x,new_y,
   l.px1,l.px2,l.py,dist,l.snd
   )
   if nd then
    dist=nd
    cx=nx
    cy=ny
    ca=na
    snd=ns
    mdy*=-1
   end
  end

  for l in all(lines_v) do
   nx,ny,nd,na,ns=intersect_v(
   ball_x,ball_y,new_x,new_y,
   l.px,l.py1,l.py2,dist,l.snd
   )
   if nd then
    dist=nd
    cx=nx
    cy=ny
    ca=na
    snd=ns
    mdx*=-1
   end
  end

  if dist then
   ball_x=cx
   ball_y=cy
   ball_dx*=mdx
   ball_dy*=mdy
   new_x=ball_x+ball_dx*ca
   new_y=ball_y+ball_dy*ca
   sfx(snd)
  end
 until dist == nil

 ball_x=new_x
 ball_y=new_y

 if (invinciball>0) invinciball-=1

 if (ball_y > 128+ball_r) init_loselife()
end

function update_loselife()
 if (btnp(5)) init_game()
end

function update_gameover()
 if (btnp(5)) init_start()
end
-->8
function draw_start()
 cls()
 oprint("breakout",49,41,7)
 oprint("press ❎ to start",32,57,11)
end

function draw_game()
 cls(1)
 --circfill(ball_x,ball_y,ball_r,10)
 spr(1,ball_x-4.5,ball_y-4.5)
 --rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,7)
 spr(16,pad_x,pad_y)
 spr(17,pad_x+8,pad_y)
 spr(17,pad_x+16,pad_y)
 spr(18,pad_x+24,pad_y)

 for i=0,7 do
  spr(20,i*16,8,2,1)
  spr(40,i*16,16,2,1)
  spr(46,i*16,24,2,1)
  spr(36,i*16,32,2,1)
  spr(44,i*16,40,2,1)
  spr(38,i*16,48,2,1)
 end

 if lives then
  for i=1,lives do
   print("♥",i*7-7,1,8)
  end
 end
end

function draw_loselife()
 oprint("press ❎ to continue",25,57,11)
end

function draw_gameover()
 oprint("game over",46,41,7)
 oprint("press ❎ to restart",31,57,11)
end
-->8
function oprint(s,x,y,c)
 for i = x-1,x+1 do
  for j = y-1,y+1 do
   print(s,i,j,0)
  end
 end
 print(s,x,y,c)
end

function intersect_h(bx,by,nx,ny,px1,px2,py,dist,snd)
 local pw=px2-px1
 local dx=nx-bx
 local dy=ny-by
 local ax=bx-px1
 local ay=by-py

 local d=-pw*dy

 if (d==0) return nil

 local ua=(pw*ay)/d
 local ub=(dx*ay-dy*ax)/d

 if (ua<0 or ua>1) return nil
 if (ub<0 or ub>1) return nil

 local x=ua*dx
 local y=ua*dy
 local nd=x*x+y*y
 x+=bx
 y+=by

 if dist==nil or nd<dist then
  return x,y,nd,1-ua,snd
 else
  return nil
 end
end

function intersect_v(bx,by,nx,ny,px,py1,py2,dist,snd)
 local ph=py2-py1
 local dx=nx-bx
 local dy=ny-by
 local ax=bx-px
 local ay=by-py1

 local d=ph*dx

 if (d==0) return nil

 local ua=(-ph*ax)/d
 local ub=(dx*ay-dy*ax)/d

 if (ua<0 or ua>1) return nil
 if (ub<0 or ub>1) return nil

 local x=ua*dx
 local y=ua*dy
 local nd=x*x+y*y
 x+=bx
 y+=by

 if dist==nil or nd<dist then
  return x,y,nd,1-ua,snd
 else
  return nil
 end
end
__gfx__
00000000fffffffff99999999999999ffbbbbbbbbbbbbbbff88888888888888ffccccccccccccccffddddddddddddddffeeeeeeeeeeeeeeff66666666666666f
00000000ffffffff977777aaaaa67799b77777aaaa6777bb87777aa677777788c7777aaaaaa677ccd7777aaaaa6777dde7777aaaaa6777ee67777ccccc777766
00700700fff666ff79444aaa000044997b333aa00aa333bb78222aa0222222887c111aa0000011cc7dcccaa00aacccdd7edddaa00aadddee76555cc00cc55566
00077000ff66766f944444aaaa444449b3333aa03300333b82222aa022222228c1111aaaaa11111cdccccaa0caa0cccdeddddaaaaa00ddde65555cc05cc05556
00077000ff67666f94444440aaa44449b3333aa03aa3333b82222aa022222228c1111aa00001111cdccccaa0caa0cccdeddddaa00aadddde65555ccccc005556
00700700ff66666f99444aaaaa004499bb3333aaaa0033bb88222aaaaaa22288cc111aaaaaa111ccddcccaaaaa00ccddeedddaaaaa00ddee66555cc000055566
00000000fff666fff99999000009999ffbbbbbb0000bbbbff88888000000888ffccccc000000cccffddddd00000ddddffeeeee00000eeeeff66666006666666f
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff2222f55555555f2222fff00000000777777777777777d777777777777777d777777777777777d777777777777777d777777777777777d777777777777777d
ff88888066666666088882ff00000000766666666666666d777776666666666d766667777666666d766666666777766d766666666666777d766666666666666d
fc87777077777777077772cf00000000766666666666666d777766666666666d766677776666666d766666667777666d766666666667777d766666666666666d
c7788880666666660888827c00000000766666666666666d777666666666666d766777766666666d766666677776666d766666666677776d766666666666667d
cc88888066666666088882cc00000000766666666666666d776666666666666d767777666666666d766666777766666d766666666777766d766666666666677d
fc88888055555555088882cf00000000766666666666666d766666666666666d777776666666666d766667777666666d766666667777666d766666666666777d
ff82222055555555022222ff00000000766666666666666d766666666666666d777766666666666d766677776666666d766666677776666d766666666667777d
fff2222f00000000f2222fff00000000dddddddddddddddddddddddddddddddd666dddddddddddddddd6666ddddddddddddddd6666dddddddddddddddd6666dd
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
77777777777777709999999999999990ccccccccccccccc0bbbbbbbbbbbbbbb088888888888888801111111111111110eeeeeeeeeeeeeee0aaaaaaaaaaaaaaa0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d555555555556d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d5dddddddddd6d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d5dddddddddd6d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d666666666666d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001837018370183701836018350183401833018320183100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002437024370243702436024350243402433024320243100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000000670106700d6700967007670056700466002660026600165002650016400264000630006300362000620026100161002610006100060000000000000c6000b600076000660001600016000000000000
