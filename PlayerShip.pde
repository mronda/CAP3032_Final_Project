class PlayerShip {
	
	
	// Nested class for the player ship bullets, generated upon calling the PlayerShip constructor
  class Shot {
    boolean live; // if shot is live, it will travel to end of the map or until collision
    PImage ammo ;

    int xpos, ypos, draw_x, draw_y;  // position originates at ship, reach end of screen kills draw
    float dx, dy ;

	
	// loads image for the shot and filters out pixels and adds transparency
    Shot() {
      ammo = loadImage("shot.png");

      for (int i = 0; i < ammo.width * ammo.height; i++) {
        if ((ammo.pixels[i] & 0x00FFFFFF) == 0x00FFFFFF)
          ammo.pixels[i] = 0;
      }
      ammo.format = ARGB;
      ammo.updatePixels();

      live = false ;
    }

	
	// uses the information of the ships current facing direction and adjusts
	// dx/dy to travel in this direction
	
    void fire(int x, int y, float trjx, float trjy) { // set dx/dy based upon passed trajectory
      // function called once when fired
      xpos = x-bg_x;    // pass in x from ship
      ypos = y-bg_y;

      draw_x = x; 
      draw_y = y;

      live = true;
      dx = trjx;
      dy = trjy;
    }

	
	// The shot will only travel the length of the window, so therefore cannot go
	// offscreen and hit asteroids elsewhere on the map
	// updates the travel conditions and checks if it hit an asteroid
	// if the asteroid was hit, change the asteroid's hit variable to true
	// stop drawing the shot if it goes off screen or hits an asteroid
    void update() {
      if (live) { // if bullet fired, travel with direction given
        image(ammo, draw_x-ammo.width/2, draw_y-ammo.height/2, ammo.width, ammo.height);
        xpos += dx ;
        ypos += dy ;
        draw_x += dx ;
        draw_y += dy ;

        for (int i = 0; i < roids.num_roids; i++) { // check for collision of ammo to asteroids
          if (!roids.asts[i].live) // if asteroid checking against isnt alive, just skip it
            continue ;

          if (xpos >= roids.asts[i].xpos+roids.asts[i].rock.width/8 && xpos <= roids.asts[i].xbnd-roids.asts[i].rock.width/8 && ypos >= roids.asts[i].ypos+roids.asts[i].rock.height/8 && ypos <= roids.asts[i].ybnd-roids.asts[i].rock.height/8) { // pew pew

            live = false ;
            roids.asts[i].hit = true ;
          }
        }
      }

      if (draw_x > width || draw_x < 0 || draw_y > height || draw_y < 0) {
        live = false;
        dx = 0;
        dy = 0;
      }
    }
  }

  AudioPlayer boosters;  // audio for thrust
  AudioPlayer rebirth;  // audio for rebirth
  PImage ship, ship_b ;  // ship images  

  Shot[] shots;      // array of ammo units
  AudioPlayer shoot ;
  short cartridge_pos ;  // index for cartridge to be fired next
  short cartridge_size ;  // amount of bullets available to be on screen

  int xpos, ypos, draw_x, draw_y, dx, dy, max_speed;
  int  mouse_buff ;
  float trajectory ;

  boolean boosting, dead ;  // boosting is true when applying thrust, dead is true when dead
  int lives, resurrection ;  // amount of player lives and ressurection counter


  // ship constructor sets variable parameters, loads sound files and ship art
  // creates array of shots and initializes them each
  PlayerShip(String shipArt, String shipArt2) { 
    boosters = minim.loadFile("boosters.mp3");
    rebirth = minim.loadFile("recharged.wav");

    dead = false ;
    lives = 3;
    
    
    resurrection = 0 ;

    ship = loadImage(shipArt);
    ship_b = loadImage(shipArt2) ;

    for (int i = 0; i < ship.width * ship.height; i++) {
      if ((ship.pixels[i] & 0x00FFFFFF) == 0x00FFFFFF)
        ship.pixels[i] = 0;
    }
    ship.format = ARGB;
    ship.updatePixels();

    for (int i = 0; i < ship_b.width * ship_b.height; i++) {
      if ((ship_b.pixels[i] & 0x00FFFFFF) == 0x00FFFFFF)
        ship_b.pixels[i] = 0;
    }
    ship_b.format = ARGB;
    ship_b.updatePixels();


    xpos = width/2 ;
    ypos = height/2 ;
    draw_x = bg.width/2 ; //where ship is on map
    draw_y = bg.height/2 ;

    dx = 0 ;
    dy = 0 ;
    max_speed = 10 ;
    mouse_buff = 20 ;

    shoot = minim.loadFile("shipFired.wav") ;
    cartridge_pos = 0 ;
    cartridge_size = 20 ;    
    shots = new Shot[cartridge_size] ;
    for (int i = 0; i < cartridge_size; i++) {
      shots[i] = new Shot();
    }
  }

  
  // updates ship orientation and position, check for death condition and update all ammo
  void update() {
    if (!dead) {
      pushMatrix();
      translate(width/2, height/2);

      trajectory = atan2(mouseY-ypos, mouseX-xpos)+PI/2;
      rotate(trajectory) ;

      if (boosting) {
        image(ship_b, 0-ship_b.width/2, 0-ship_b.height/2, ship_b.width, ship_b.height);
      } else {
        image(ship, 0-ship.width/2, 0-ship.height/2, ship.width, ship.height);
      }
      popMatrix();

      if (draw_x < bg.width - width/2 - dx && draw_x > width/2 - dx)
        draw_x += dx ;
      else
        dx = 0 ;

      if (draw_y + dy > height/2 && draw_y + dy < bg.height - height/2 - dy)
        draw_y += dy ;    
      else
        dy = 0 ;
    } else { // resurrection occurence
      dx = 0;
      dy = 0;
      if (lives > 0) {
        resurrection++ ;
        if (resurrection == 100) {
          resurrection = 0 ;
          lives -= 1;
          dead = false;
          rebirth.play();
          rebirth.rewind();
          println(lives);
        }
      } else {
        // GAME OVER PORTION 
        // Add a new screen that shows the final score and restart(goes to new game)
        // and a quit portion -- exits game 
 
        stage = 7;
        gameOver = true;
          
      }

      pushMatrix();
      translate(width/2, height/2);
      trajectory = atan2(mouseY-ypos, mouseX-xpos)+PI/2;

      popMatrix();
    }

    // update all ammo
    for (int i = 0; i < cartridge_size; i++)
      shots[i].update();
  }

  
  // function called by key press. will adjust velocity depending on which side of
  // of the ship it is on and play sound changes variable for ship image
  void boostersOn() {
    if (!dead) {
      boosting = true ;
      if (!boosters.isPlaying()) {
        boosters.rewind();
        boosters.play();
      }

      if (mouseX > xpos + mouse_buff && (dx != max_speed))
        dx += 1 ;  // move right
      else if (mouseX < xpos - mouse_buff && (dx != -max_speed))
        dx -= 1 ;  // move left

      if (mouseY > ypos + mouse_buff && (dy != -max_speed))
        dy += 1 ; // move down
      else if (mouseY < ypos - mouse_buff && (dy != max_speed))
        dy -= 1 ;  // move up
    }
  }

  // turns off boosting sound, sets variable for ship image without flame
  void boostersOff() {
    boosting = false ;
    boosters.pause();
    boosters.rewind();
  }

  // calls upon a shot object to be fired, sends trajectory data and moves index
  void fire() {
    if (!dead) {
      if (!shots[cartridge_pos].live) { // check for idle round
        shots[cartridge_pos++].fire(xpos, ypos, 10*cos(trajectory-PI/2), 10*sin(trajectory-PI/2)) ; // fire round
        shoot.rewind();
        shoot.play();
      } else
        cartridge_pos++;  // whoops, come back around playboy

      if (cartridge_pos == cartridge_size) cartridge_pos = 0 ;
    }
  }
}