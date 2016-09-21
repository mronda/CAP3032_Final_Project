class Asteroid {
  PImage rock;
  AudioPlayer collide ;
  int xpos, ypos, xbnd, ybnd, xcnt, ycnt;
  int dx, dy ;
  int hp;
  boolean hit, live ;
  
	// Constructor function, inputs string with image to load, character e for easy, h for hard
	// filters the loaded image for white pixels and adds transparency
	// sets parameters and places asteroid art at random location
	
  Asteroid(String asteroidArt, char difficulty){
    collide = minim.loadFile("asteroidCollide.wav") ;
    rock = loadImage(asteroidArt) ;
    for (int i = 0; i < rock.width * rock.height; i++) { // image filtering to create transparency
      if ((rock.pixels[i] & 0x00FFFFFF) == 0x00FFFFFF) {
        rock.pixels[i] = 0;
      }
    }
    rock.format = ARGB;
    rock.updatePixels();

    xpos = (int)random(2, bg.width - rock.width) ;
    ypos = (int)random(2, bg.height - rock.height) ;
    
    if(difficulty == 'e'){
        dx = 1 ; // speed of the asteroids
        dy = 1 ;
    }
    else{
        dx = 3 ;
        dy = 3 ;
    }
    
    hp = 10;
    live = true ;
    hit = false;
  }

  
  // updates ship coordinate data and hitpoints
  // if the ship was hit by a shot, the sound is played here
  // once the asteroid is dead this function is essentially nop
  void update(int x_in, int y_in) {
    if (hit && live) {
      hp-- ;
      // hits registered here, scores can be added here
      
      score += 10;
      hit = false ;
      collide.rewind();
      collide.play();

      if (hp == 0) {
        live = false ; // remove drawing and what not
        dx = 0;
        dy = 0;
        xpos = 0;
        ypos = 0;
      }
    }

    if (live) {
      image(rock, (xpos + x_in), (ypos + y_in), rock.width, rock.height);

      if (xpos > bg.width-rock.width || xpos < 1)
        dx *= -1 ;

      if (ypos > bg.height-rock.height || ypos < 1)
        dy *= -1 ;

      xpos += dx ;
      ypos += dy ;

      xcnt = xpos + rock.width/2 ;
      ycnt = ypos + rock.height/2 ;

      xbnd = xpos + rock.width ;
      ybnd = ypos + rock.height ;
    }
  }
}