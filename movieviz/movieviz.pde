import java.util.Collections;
import java.util.Set;
import java.util.HashSet;
import controlP5.*;

// controlP5 library
ControlP5 cp5;
Range timeRange;
DropdownList directorsDrop;

// some global variables
PFont font;
ArrayList<Movie> movies = new ArrayList<Movie>();
Movie movie;

// Director variables
ArrayList<Director> directors = new ArrayList<Director>();
Director director;
Director currentDirector = null;
Director clickedDirector;
Director pickedDirector;
Movie lastHoveredMovie = null;

// visual center used by drawBig in Director
int centerX = 400;
int centerY = 400;

// visual center used in director overview
int smallCenterX;
int smallCenterY;

// year range
int yearMin = 1950;
int yearMax = 2014;

// interaction with actors
ArrayList<Actor> actors = new ArrayList<Actor>();
Actor pickedActor;
Actor clickedActor;

void setup() {
  size(1500, 800);
  surface.setTitle("Film Planetarium");
  readData();

  setFont();  
  setYearSlider();
  setDropdownList();
}

void setFont() {
  PFont sourceSansPro = createFont("fonts/SourceSansPro.ttf", 15);
  font = sourceSansPro;
  textFont(font);
}

void resetFontSize() {
  textFont(font, 15); // reset font size
}

void setYearSlider() {
  // timeline range slider
  cp5 = new ControlP5(this);
  timeRange = cp5.addRange("Year")
    .setBroadcast(false)
    .setDecimalPrecision(0)
    .setPosition(200, 20)
    .setSize(400, 40)
    .setHandleSize(20)
    .setRange(1950, 2014)
    .setRangeValues(1961, 1970)  
    //.showTickMarks(true)
    //.setSliderMode(Slider.FLEXIBLE)
    //.snapToTickMarks(true)
    //.setNumberOfTickMarks(6)
    .setBroadcast(true)
    .setColorForeground(color(253, 191, 111, 150)) // yellow
    .setColorBackground(color(100, 100, 100))
    //.setColorTickMark(color(150, 240))
    .setColorActive(color(253, 191, 111)); // yellow
}

// create a DropdownList
void setDropdownList() {

  directorsDrop = cp5.addDropdownList("Directors")
    .setPosition(750, 20)
    .setWidth(150)
    .hide()
    .setColorBackground(color(100, 100, 100))
    .setColorForeground(color(253, 191, 111, 150)) // yellow

    .setBackgroundColor(color(190))
    .setItemHeight(40)
    .setBarHeight(40)
    .setHeight(650)
    .setOpen(false)
    .addItem("Show all", 0);

  populateDropdownList(directorsDrop);
} // end setDropdownList

void populateDropdownList(DropdownList ddl) {
  for (int i = 0; i < directors.size(); i++) {
    ddl.addItem(directors.get(i).name, i+1);
  } // end for
} // end populateDropdownList


void draw() {  

  // black background
  background(0);

  // draw the legend for colors
  drawLegend();

  // overview grid
  int i = 0;
  int r; // the row number
  int c; // the collumn number

  for (Director d : directors) { // iterate through directors
    if (currentDirector == null) { // no director selected

      directorsDrop.hide(); // hide dropdown list

      // create grid with 6 columns
      r = (int) i/6;
      c = i%6 +1;
      int posX = c*170+100;
      int posY = r*200+170;

      // draw small director
      d.drawSmall(posX, posY);

      i++;
      r++;
    } else if (d.getName().equals(currentDirector.getName())) { // director selected

      d.drawBig(); // draw big director
      directorsDrop.show(); // show dropdown list

      // draw legend for director
      fill(255, 255, 255);
      textFont(font, 16);
      text("Director: ", 670, 45);
      resetFontSize();
    }
  }
  noLoop();
} // end draw()


void drawLegend() {

  //text white
  fill(255, 255, 255);

  // legend year
  textFont(font, 16); // bigger font
  text("Period: " + yearMin + " - " + yearMax, 50, 45);

  resetFontSize(); // reset font size

  // legend female actor
  noStroke();
  fill(251, 154, 153, 200); // pink
  rect(200, 760, 15, 15);
  fill(255, 255, 255);
  text("Female", 220, 772);

  // legend male actor
  noStroke();
  fill(166, 206, 227, 200); // blue
  rect(300, 760, 15, 15);
  fill(255, 255, 255);
  text("Male", 320, 772);
} // end drawLegend()

void readData() {

  // load movies
  String[] lines = loadStrings("movies.csv");
  for (int i = 1; i < 434; i++) {  
    String pieces[] = split(lines[i], "\",\"");
    // pieces[15] --> imdb rating
    // pieces[21] --> tomato rating
    movie = new Movie(pieces[0].substring(1), int(pieces[1]), pieces[6], pieces[8], float(pieces[21]), pieces[13]);
    movies.add(movie);
  }

  // load directors
  String[] directorLines = loadStrings("directors.csv");
  for (int i = 1; i < 19; i++) {   
    String pieces[] = split(directorLines[i], "\",\"");
    director = new Director(pieces[0].substring(1), int(pieces[1].replace("\"", "")), i);
    directors.add(director);
  }

  // add actors in directors
  for (Movie m : movies) {
    for (Director d : directors) {
      String[] actorSeparated = m.actors.split(", ");
      for (int i = 0; i < actorSeparated.length - 1; i++) {
        if (d == currentDirector && (m.year >= yearMin && m.year <= yearMax)) {
          d.collaborators.add(actorSeparated[i]);
        }
      }
    }
  }

  for (Director d : directors) {
    d.getMovieList();
  }
} // end readData

// controlP5 interaction with dropdownlist and year slider
void controlEvent(ControlEvent theControlEvent) {

  // dropdown list
  if (theControlEvent.isGroup()) {
    // do nothing
  } else if (theControlEvent.isController() && theControlEvent.isFrom("Directors")) {

    //println("event from controller : "+theControlEvent.getController().getValue()+" from "+theControlEvent.getController());
    float index = theControlEvent.getController().getValue();

    if (index > 0) { // choose a director
      Director selectedDirector = directors.get((int)index - 1); // get director's name
      setCurrentDirector(selectedDirector); // set current director
    } else { // option "Show all"
      setCurrentDirector(null); // no director, show overview
    }
    // else, it's the year slider
  } else if (theControlEvent.isController() && theControlEvent.isFrom("Year")) { 
    yearMin = int(theControlEvent.getController().getArrayValue(0));
    yearMax = int(theControlEvent.getController().getArrayValue(1));
  }
}

// select a director
void setCurrentDirector(Director director) {
  this.currentDirector = director;
  // println(this.currentDirector);
  redraw();
}

// hover on actor
Actor pick(int px, int py) {
  for (int i = 0; i < actors.size(); i++) {
    if (actors.get(i).contains(px, py)) {
      actors.get(i).hovering(); // hover actor
      return actors.get(i);
    } else {
      actors.get(i).noHovering(); // remove hover from other actors
    }
  }
  return null;
}

// click actor
Actor click(int px, int py) {
  clickedActor = null;
  for (int i = 0; i < actors.size(); i++) {
    if (actors.get(i).contains(px, py)) {
      clickedActor = actors.get(i);
      actors.get(i).select(); // select  actor
    } else {
      actors.get(i).noSelect(); // remove select from other actors
    }
  }
  return clickedActor;
}

// pick director in overview
Director pickDirector(int px, int py) {
  for (int i = 0; i < directors.size(); i++) {
    if (directors.get(i).contains(px, py)) {
      return directors.get(i);
    }
  }
  return null;
}

// click director in overview
Director clickDirector(int px, int py) {
  clickedDirector = null;
  for (int i = 0; i < directors.size(); i++) {
    if (directors.get(i).contains(px, py)) {
      clickedDirector = directors.get(i);
      currentDirector = directors.get(i); // select director
    } else {
      // do nothing
    }
  }
  return clickedDirector;
}

Movie moviePick(int px, int py) {
  if (currentDirector != null) {
    for (Movie m : currentDirector.movieList) {
      if (m.contains(px, py))
        return m;
    }
  }
  return null;
}

// mouse interaction
void mouseMoved() { 

  // hovering director
  pickedDirector = pickDirector(mouseX, mouseY);

  // hovering actor
  pickedActor = pick(mouseX, mouseY);

  // change cursor
  if ((pickedActor != null && currentDirector != null) || (pickedDirector != null && currentDirector == null)) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }

  // hovering Movie Poster
  Movie hoveredMovie = moviePick(mouseX, mouseY);
  if (hoveredMovie != null) {
    if (lastHoveredMovie != null) {
      lastHoveredMovie.hovered = false;
    }
    hoveredMovie.hovered = true;
    lastHoveredMovie = hoveredMovie;
  } else {
    if (lastHoveredMovie != null) {
      lastHoveredMovie.hovered = false;
    }
  }
  redraw();
}


void mouseClicked() {

  // click director
  if (currentDirector == null) {
    clickedDirector = clickDirector(mouseX, mouseY);
    if (clickedDirector != null) {
      println("You clicked " + clickedDirector.name);
    }
  }

  // click actor
  Actor clickedActor = click(mouseX, mouseY);
  if (clickedActor != null) {
    println("You clicked " + clickedActor.name);
  }
  actors.clear();
  redraw();
}
void mouseDragged() {
  redraw();
}

void mouseReleased() {
  redraw();
}