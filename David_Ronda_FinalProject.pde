// Jean-Pierre David
// Maximiliano Ronda
// Asteroid clone
// Currently implemented with rocket booster physics and sound coordination and asteroid mapping

/* CONTROLS:
 Navigate menu with arrow keys, press enter to make selection
 Please select easy mode, hard mode not coded in yet
 
 To move ship press F for thrust and D to blast asteroids 

 Hard Level contains 8 asteroids moving 3 times the usual speed trying to destroy your ship
 */


import ddf.minim.*;
boolean gameOver = false;

PFont scoreFont; 
int stage, menuIconPos, score;
PImage main_menu, second_menu, third_menu, tiny_ship, exit, soon, 
  gameManual, optionMenu, pauseBox, scoreBox, livesShip, bg, gameOverLogo;// Images for Menu
boolean pause = false; // To pause the game 

int timer, start; // Used to exit screen and give 7 seconds 


sprite shipSprite; // Sprite for moving icon on the menu screen 

PlayerShip falcon1;
AsteroidCluster roids ;

Minim minim;

//All audio used for Menu
AudioPlayer themeSong; // Theme song in first Menu
AudioSample movingMenu; // Song for moving around in Menu
AudioSample selectOption;// Song when selecting in menu
AudioPlayer gamePlaySong; // Song plays while playing

void setup() {
  minim = new Minim(this);

  size(600, 600);

  bg = loadImage("background1.png");

  scoreFont = loadFont("AmericanTypewriter-48.vlw"); // Score font 

  // Sprite for Main Menu 
  shipSprite = new sprite("ShipSprite.png", 4, 4, 1);

  stage = 1; // start in main screen of game and play theme song
  menuIconPos = 1; // place sprite in first option 

  // All audio used for Menu
  themeSong = minim.loadFile("space-hunter1.mp3");
  movingMenu = minim.loadSample("primaryShot.wav");
  selectOption = minim.loadSample("Laser.wav");
  gamePlaySong = minim.loadFile("space-hunter2.mp3");
}


int bg_x = width/2 - 3774/2 ;
int bg_y = height/2 - 2508/2 ;

void draw() {

  textFont(scoreFont, 25);

if(gameOver == true){
  gameOverLogo = loadImage("gameOver.png");
  image(gameOverLogo, 190,100);
//   text("GAME OVER", 225, 450);
}

  // Start Game Play Song
  if (stage == 5) {

    gamePlaySong.play();
  } else
    gamePlaySong.pause(); 



  // If P or p is pressed pause game, else continue game 
  if (pause == true) {
    pauseMenu();
  } else {
    if (stage == 5) { // actual game


      bg_x = width/2 - falcon1.draw_x ;
      bg_y = height/2 - falcon1.draw_y ;
      image(bg, bg_x, bg_y, bg.width, bg.height) ;
      falcon1.update() ;
      roids.update_them() ;

      pauseBox = loadImage("upperLeftBox.png"); // Pause box 
      image(pauseBox, 0, 0);

      scoreBox = loadImage("upperRightBox.png"); // Score box
      image(scoreBox, height-150, 0);

      text(score, width-65, 20); // Show score next to scoreBox


      // display the lives on the screen with a tiny ship
      for (int i = 0; i < falcon1.lives; i++) {
        livesShip = loadImage("tiny.png");
        image(livesShip, 10*5*i, 30);
      }
    }
  }

  // Stage 1: Main Menu and Theme Song
  if (stage == 1) {
    mainMenu();
    themeSong.play();
  } else
    themeSong.close(); 

  // Stage 2: Second Menu: Select New Game or Exit 
  if (stage == 2) {
    secondMenu();
  }
  // Stage 3: Select easy hard or go back 
  if (stage == 3) {
    thirdMenu();
    score = 0; // reset score to 0 and start again
  }
  //Stage 4 is quit game and show latest score 
  if (stage == 4) {
    exitGame();
  }
  // Stage 6 is game rules
  if (stage == 6) {
    gameRules();
  }
  // Stage 7 is the menu inside stage 5 (the game)
  if (stage == 7) {
    pauseMenu();
  }
}


void keyPressed() {

  // Keys for game movement 
  if (stage == 5) {
    if (key == 'd' || key == 'D') falcon1.boostersOn();
    if (key == 'f' || key == 'F') falcon1.fire();
  }

  // Keys for option
  if (key == 'p'&& pause == false && stage == 5) // Checking in Stage 5 if menu is pressed 
  {  
    noLoop();
    pause = true;
    stage = 7;
    pauseMenu();
  } else if (key == 'p' || key == 'P' && pause == true && stage == 7) 
  { // Pressing P again will unpause the game 
    pause = false;
    stage = 5;
    loop();
  } else if (key == 'q' || key == 'Q' && stage == 7 && pause == true) // Not restarting the game, needs fixing here 
  {

    // Quit and send to New Game 
    pause = false;
    loop();
    stage = 2; 
    menuIconPos = 1;
  }
}

// Stop booster sound 
void keyReleased() {
  if (stage == 5)
    falcon1.boostersOff();
}

void stop() {
  falcon1.boosters.close();
  falcon1.shoot.close();
  falcon1.rebirth.close();

  roids.shipHit.close();
  for (int i = 0; i < roids.num_roids; i++)
    roids.asts[i].collide.close();

  minim.stop();
  super.stop();
}

// Show main Menu screen and play theme song
void mainMenu() {
  main_menu = loadImage("MainMenu.png");
  image(main_menu, 0, 0);

  // Show Moving Stars 
  fill(0, 10);
  rect(0, 0, width, height);
  fill(255);
  noStroke();
  ellipse(random(width), random(height), 5, 5);

  // Pressing any Button goes to Second Menu, Stage 2.
  if (stage == 1 && keyPressed == true) {
    keyPressed = false;
    stage = 2;
  }
}

// UI - New Game, Rules, Exit 
void secondMenu() {

  second_menu = loadImage("SecondMenu.png");
  image(second_menu, 0, 0);
  start = millis();

  // New Game if enter is pressed
  if (menuIconPos == 1 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 3;
    menuIconPos = 3;
  }
  // Exit game if enter is pressed 
  if (menuIconPos == 2 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 4; // the manual move here
  }

  // Game rules if enter is pressed 
  if (menuIconPos == 6 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    menuIconPos = 7;
    stage = 6;
  }

  // check location of icon 
  if (key == CODED && keyPressed == true) {
    if (menuIconPos == 1) {
      if (keyCode == DOWN) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 6;
      }
    } else if (menuIconPos == 6 && keyPressed == true) {
      if (keyCode == UP) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 1;
      }
      if (keyCode == DOWN) {
        movingMenu.trigger();
        menuIconPos = 2;
      }
    } else if (menuIconPos == 2 && keyPressed == true) {
      if (keyCode == UP) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 6;
      }
    }
  }

  // Position the sprite 
  if (menuIconPos == 1)
    shipSprite.display(168, 265);

  else if (menuIconPos == 6)
    shipSprite.display(168, 345);

  else if (menuIconPos == 2)
    shipSprite.display(168, 423);
}


// Start third menu which ask user to enter easy, hard, or back 
void thirdMenu() {

  third_menu = loadImage("newThirdMenu.png");
  image(third_menu, 0, 0);

  //easy level if enter is pressed
  if (menuIconPos == 3 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 5;

    falcon1 = new PlayerShip("stealthShip.png", "stealthShipWithFire.png");
    roids = new AsteroidCluster(4, 'e');
  }

  //hard level if enter is pressed
  if (menuIconPos == 4 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 5;
    // Here is the hard level, what are we doing?
    falcon1 = new PlayerShip("stealthShip.png", "stealthShipWithFire.png");
    roids = new AsteroidCluster(8, 'h');
  }

  //back to second menu if enter is pressed
  if (menuIconPos == 5 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 2;
    secondMenu();
    menuIconPos = 1;
  }

  // Move icon around in third menu
  if (key == CODED && keyPressed == true) {
    if (menuIconPos == 3) {
      if (keyCode == DOWN) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 4;
      }
    } else if (menuIconPos == 4 && keyPressed == true) {
      if (keyCode == UP) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 3;
      }
      if (keyCode == DOWN) {
        movingMenu.trigger();
        menuIconPos = 5;
      }
    } else if (menuIconPos == 5 && keyPressed == true) {
      if (keyCode == UP) {
        keyPressed = false;
        movingMenu.trigger();
        menuIconPos = 4;
      }
    }
  }
  // move sprite according to keyboard command 
  if (menuIconPos == 3)
    shipSprite.display(168, 265);

  else if (menuIconPos == 4)
    shipSprite.display(168, 345);

  else if (menuIconPos == 5)
    shipSprite.display(168, 423);
}

// Exit game and show latest score with goodbye statement. closes after 7 seconds
void exitGame() {

  exit = loadImage("endGame.png");
  image(exit, 0, 0);

  timer = millis() - start; // Erase elapse time 

  textFont(scoreFont, 50);
  text(score, 375, 482);

  // Close game after 5 seconds of showing score 
  if (timer > 7000) {
    exit();
  }
}

// In stage 5 (gameplay) is p is pressed we pause and can continue or quit 
void pauseMenu() {

  optionMenu = loadImage("optionMenu.png");
  image(optionMenu, width/2-125, height/2-125);

  fill(255);
  text(score, 320, 400);
  textFont(scoreFont, 20);
  scoreBox = loadImage("upperRightBox.png"); // Score box
  image(scoreBox, 225, 380);


}



// Stage 6: Game Rules 
void gameRules() {
  gameManual = loadImage("gameManual.png");
  image(gameManual, 0, 0);

  // If enter is pressed go back to second menu 
  if (stage == 6 && menuIconPos == 7 && keyPressed == true && key == ENTER || key == RETURN) {
    keyPressed = false;
    selectOption.trigger();
    stage = 2;
    menuIconPos = 1;
  }  

  if (menuIconPos == 7)
    shipSprite.display(200, 530);
}