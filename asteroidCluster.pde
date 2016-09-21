class AsteroidCluster {
  Asteroid[] asts ;
  int num_roids;

  AudioPlayer shipHit ;

  // creates asteroids based upon difficulty level
  // randomly selects which art to apply to the asteroid and sends
  // the difficulty request to the asteroid constructor
  
  AsteroidCluster(int this_many, char difficulty) {
    num_roids = this_many ;
    asts = new Asteroid[num_roids] ;

    for (int i = 0; i < num_roids; i++) {
      if ((int)random(50) > 25)
        asts[i] = new Asteroid("asteroid1.png", difficulty);
      else
        asts[i] = new Asteroid("asteroid2.png", difficulty);
    }

    shipHit = minim.loadFile("shipHit.wav");
  }

  // calls upon the update function for each asteroid in game
  // checks collision between each asteroid and other asteroids
  // also checks collision between each asteroid and the player ship
  
  void update_them() {
    for (int i = 0; i < num_roids; i++) {
      asts[i].update(bg_x, bg_y);
    }

    for (int i = 0; i < num_roids; i++) {
      if (!asts[i].live)
        continue;


      for (int j = i+1; j < num_roids; j++) {
        if (asts[i].xpos <= asts[j].xbnd && (asts[i].ycnt <= asts[j].ycnt + asts[j].rock.height/3 && asts[i].ycnt >= asts[j].ycnt - asts[j].rock.height/3)) {
          // do stuff for i approaching j from right
          asts[i].dx *= -1 ;
          asts[i].xpos += 2 ;
          asts[j].dx *= -1 ;
        } else if (asts[i].xbnd >= asts[j].xpos && (asts[i].ycnt <= asts[j].ycnt + asts[j].rock.height/3 && asts[i].ycnt >= asts[j].ycnt - asts[j].rock.height/3)) {
          // do stuff for i approaching j from left
          asts[i].dx *= -1 ;
          asts[i].xpos -= 2 ;
          asts[j].dx *= -1 ;
        } else if (asts[i].ybnd >= asts[j].ypos && (asts[i].xcnt <= asts[j].xcnt + asts[j].rock.width/3 && asts[i].xcnt >= asts[j].xcnt - asts[j].rock.width/3)) {
          // do stuff for i approaching j from top
          asts[i].dy *= -1 ;
          asts[i].ypos -= 2 ;
          asts[j].dy *= -1 ;
        } else if (asts[i].ypos <= asts[j].ybnd && (asts[i].xcnt <= asts[j].xcnt + asts[j].rock.width/3 && asts[i].xcnt >= asts[j].xcnt - asts[j].rock.width/3)) {
          // i approaching j from bottom
          asts[i].dy *= -1 ;
          asts[i].ypos += 2 ;
          asts[j].dy *= -1 ;
        }
      }

      // check ship collision
      if (!falcon1.dead) {
        if ((asts[i].xpos >= 300-bg_x-falcon1.ship.width/2) && (asts[i].xpos <= 300-bg_x + falcon1.ship.width/2) && ((asts[i].ypos >= 300-bg_y - falcon1.ship.height/2 && asts[i].ypos <= 300-bg_y + falcon1.ship.height/2 ) || (asts[i].ybnd >= 300-bg_y - falcon1.ship.height/2 && asts[i].ybnd <= 300-bg_y + falcon1.ship.height/2 ))) {
          shipHit.rewind();
          shipHit.play();
          falcon1.dead = true;
        } else if ((asts[i].xbnd >= 300-bg_x - falcon1.ship.width/2) && (asts[i].xbnd <= 300-bg_x + falcon1.ship.width/2) && ((asts[i].ypos >= 300-bg_y - falcon1.ship.height/2 && asts[i].ypos <= 300-bg_y + falcon1.ship.height/2 ) || (asts[i].ybnd >= 300-bg_y - falcon1.ship.height/2 && asts[i].ybnd <= 300-bg_y + falcon1.ship.height/2 ))) {
          shipHit.rewind();
          shipHit.play();
          falcon1.dead = true;
        }
      }
    }
  }
}