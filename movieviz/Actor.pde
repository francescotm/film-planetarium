class Actor {
  String name;
  String gender = "F";
  boolean hovering;
  boolean selected;
  String director;
  int distance;
  int order;
  float actorX;
  float actorY;

  // public constructor
  public Actor(String name, String director, int distance, int order) {
    this.name = name;
    this.director = director;
    this.distance = distance;
    this.order = order;
    setGender();
  } // end public Actor

  // public constructor for hovered actor
  public Actor(String name, String director, int distance, boolean selected, int order) {
    this.name = name;
    this.director = director;
    this.distance = distance;
    this.order = order;
    this.hovering = true;
    setGender();
  } // end public Actor

  // public constructor for clicked actor
  public Actor(String name, String director, int distance, int order, boolean selected) {
    this.name = name;
    this.director = director;
    this.distance = distance;
    this.order = order;
    this.selected = true;
    setGender();
  } // end public Actor

  void setGender() {
    String[] actorLines = loadStrings("actors.csv");
    for (int i = 1; i < 58; i++) {   
      String pieces[] = split(actorLines[i], "\",\"");
      if (this.name.equals(pieces[0].substring(1))) {
        this.gender = pieces[1].replace("\"", "");
      }
    }
  }

  void drawOrbitSmall() {

    // calculate radius
    int newDistance = (50/this.distance)*4;

    noFill(); // keep orbits empty

    // draw actor orbit
    if (this.gender.equals("M")) { // if male actor
      stroke(166, 206, 227, 200); // blue
    } else { // if female actor
      stroke(251, 154, 153, 200); // pink
    }

    // draw orbit
    strokeWeight(2);
    ellipse(smallCenterX, smallCenterY, newDistance + 60, newDistance + 60);
  }

  void drawOrbit() {

    // calculate radius
    int newDistance = (20/this.distance)*50;

    noFill(); // keep orbits empty

    // draw actor orbit
    if (this.gender.equals("M")) { // if male actor
      stroke(166, 206, 227, 200); // blue
    } else { // if female actor
      stroke(251, 154, 153, 200); // pink
    }

    strokeWeight(2);
    ellipse(centerX, centerY, newDistance*2, newDistance*2);
  } // end drawOrbit()

  void drawPlanet() {

    int newDistance = (20/this.distance)*50;

    // draw actor planet 
    noStroke();
    int planetSize = 25;

    if (this.selected) {

      planetSize = 32; // increase planet size

      textFont(font, 16);
      text("Movies with " + this.name, 825, 120);
      resetFontSize();

      int i = 0;
      for (Movie m : movies) {
        if ((m.director.contains(currentDirector.name)) && (m.actors.contains(this.name)) && (m.year >= yearMin && m.year <= yearMax)) {
          //println(m.title);
          //textFont(font, 14);
          //text("- " + m.title + " (" + m.year + ")", 900, 200 + i*20);
          //m.draw();
          i++;
        }
      }
      stroke(255, 255, 255); // white
      strokeWeight(3);
    } else if (this.hovering) {

      // count the number of movies with the actor
      int i = 0;
      for (Movie m : movies) {
        if ((m.director.contains(currentDirector.name)) && (m.actors.contains(this.name)) && (m.year >= yearMin && m.year <= yearMax)) {
          i++; // number of movies
        }
      }

      // hovering on actor
      fill(0, 0, 0, 200);
      ellipse(centerX, centerY, 110, 110);
      fill(255);
      textFont(font, 34);
      float textWidth = textWidth(String.valueOf(i));
      // draw number of movies
      text(i, centerX - (textWidth/2), centerY);
      textFont(font, 18);
      // draw “movies” on another line
      text("movies", centerX - 27, centerY +20);
      resetFontSize();

      noStroke();
    } else {
      noStroke();
    }

    if (this.gender.equals("M")) { // if male 
      fill(166, 206, 227); // blue
    } else { // if female 
      fill(251, 154, 153); // pink
    }
    drawRing(centerX, centerY, newDistance, this.name, this.order, planetSize);
  } // end drawPlanet();

  // adapted from: https://forum.processing.org/one/topic/distribute-shapes-around-circle-dependant-on-arc-length#25080000001373377.html
  void drawRing(int cX, int cY, float radius, String actor, int order, int size) {
    //background(140); //draw BG
    float r = radius; //radius of circle
    // Calculate number of ellipses round circumference
    int numDots = 1;
    //int numDots = round(TWO_PI * r / circWid);
    // Calculate angle between two ellipses
    float theta = TWO_PI / order;
    // Adjust radius so that this number of dots exactly matchs the circumference
    //r = (numDots * circWid)/ TWO_PI;
    pushMatrix();
    translate(cX, cY);
    for (float p = 0; p < numDots; p++) {
      //float myTheta = p*theta; //calculate current angle
      this.actorX = r*cos(theta); //calculate xPos
      this.actorY = r*sin(theta); //calculate yPos

      ellipse(this.actorX, this.actorY, size, size); //draw dot

      noStroke();
      float textWidth = textWidth(actor);
      fill(0, 0, 0);
      rect(this.actorX - ((textWidth/2) + 5), this.actorY + 18, textWidth + 10, 20, 8);
      fill(250, 250, 250);
      text(actor, this.actorX - (textWidth/2), this.actorY + 32);
      //println("X and Y for " + actor + ": " + this.actorX, this.actorY);
    }
    popMatrix();
  }

  // checking if point in ellipse
  boolean contains(int px, int py) {
    if ((this.actorX != 0.0) && (this.actorY != 0.0)) {
      // account for the translated coordinates for the ellipse x = -500, y = -400
      return dist(this.actorX, this.actorY, px - centerX, py - centerY) < 15;
    } else {
      return false;
    }
  }


  // on mouse hover
  void hovering() {
    this.hovering = true;
  }
  void noHovering() {
    this.hovering = false;
  }

  // on mouse click
  void select() {
    this.selected = true;
  }
  void noSelect() {
    this.selected = false;
  }
} // end class Actor