class sprite {
  PImage cell[];
  float cnt = 0;
  float dir = 0;
  float step = 0;

  int num_of_sprites; // number of images in sprite
  int size_x, size_y;
  PImage spriteName;

  //Pass the name of the sprite, the number of tiles, the number of tiles in x direciton
  // and the number of tiles in y direction 
  sprite(String _spriteName, int _num_of_sprites, int _size_x, int _size_y) {



    spriteName = loadImage(_spriteName);
    size_x = _size_x;
    size_y = _size_y;
    num_of_sprites = _num_of_sprites;

    cell = new PImage[num_of_sprites];

    for (int y = 0; y < size_y; y++) {
      for (int x = 0; x < size_x; x++) {
        cell[y+x] = spriteName.get(x*(spriteName.width/size_x), y*(spriteName.height/size_y), 
          (spriteName.width/size_x), spriteName.height/size_y);
      }
    }
  }


  void assign() {
    if (cnt++ > 10) {
      cnt = 0;
      step += 0.8;
      if (step >= 4) 
        step = 0;
    }
  }

  // Where to display in the screen 
  void display(int posX, int posY) {
    assign();
    float idx = dir*3 + (step == 3 ? 1 : step);
    image(cell[int(idx)], posX, posY);
  }
}