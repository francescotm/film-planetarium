class Director {
  String name;
  int birthyear;
  int order;
  boolean hovering;
  boolean selected;
  ArrayList<String> collaborators = new ArrayList<String>();
  ArrayList<Movie> movieList = new ArrayList<Movie>();

  Actor actor;

  int directorX;
  int directorY;

  public Director(String name, int birthYear, int order) {
    this.name = name;
    this.birthyear = birthYear;
    this.order = order;
    this.hovering = false;
    this.selected = false;
  } // end public Director

  String getName() {
    return this.name;
  }

  void addCollaborator(String actors) {
    collaborators.add(actors);
  }

  // reset collaborators
  void resetCollaborators() {
    this.collaborators.clear();
    for (Movie m : movies) {
      String[] actorSeparated = m.actors.split(", ");
      for (int i = 0; i < actorSeparated.length; i++) {
        if (m.director.contains(this.name) && (m.year >= yearMin && m.year <= yearMax)) {
          this.collaborators.add(actorSeparated[i]);
        }
      }
    }
  }
  public ArrayList<String> getCollaborators() { 
    return this.collaborators;
  }

  public int countCollaborator(String name) {
    int count = 0;
    for (String c : collaborators) {
      if (c.equals(name)) {
        count = Collections.frequency(collaborators, c);
      }
    }
    return count;
  }

  PImage loadDirectorPic(String name) {

    // default image
    PImage none = loadImage("directors/none.png");

    // take director name and take out spaces or dashes
    if (name != null) {
      name = name.toLowerCase();
      name = name.replace(" ", "");  // take out space
      name = name.replace("-", "");  // take out dashes
    }

    // get image using director's name
    PImage director = loadImage("directors/"+name+".png");

    if (director != null) { // if image with director name is present
      return director;      // use it
    } else {                // else
      return none;          // use the default
    }
  }

  void drawSmall(int x, int y) {

    smallCenterX = x;
    smallCenterY = y;

    this.directorX = x;
    this.directorY = y;

    // get director image and draw it
    PImage directorPic = loadDirectorPic(this.name);
    directorPic.resize(50, 50);
    image(directorPic, smallCenterX - 25, smallCenterY - 25);

    // default fill white 
    fill(250, 250, 250);

    //reset the Collaborator arraylist according to the year range
    resetCollaborators();
    Set<String> uniqueCo = new HashSet<String>(collaborators);

    // draw orbits
    int i =1;
    for (String c : uniqueCo) {
      int distance = countCollaborator(c);
      if ((distance > 2) && (!c.equals("N/A"))) {
        actor = new Actor(c, this.name, distance, i);
        actors.add(actor);
        actor.drawOrbitSmall();
        i++;
      } else {
        // do nothing
      }
    }

    float textWidth = textWidth(this.name);
    fill(255);
    text(this.name, smallCenterX - (textWidth/2), smallCenterY + 80);
  }

  void drawBig() { 

    // get director image and draw it
    PImage directorPic = loadDirectorPic(this.name);
    image(directorPic, centerX - 50, centerY - 50);

    // draw blue ellipse around director image
    noFill();
    stroke(166, 206, 227, 200); // blue stroke
    strokeWeight(2);
    ellipse(centerX, centerY, 100, 100); // blue ellipse

    // default fill white 
    fill(250, 250, 250);

    //reset the Collaborator arraylist according to the year range
    resetCollaborators();
    Set<String> uniqueCo = new HashSet<String>(collaborators);

    // draw orbits
    int i =1;
    for (String c : uniqueCo) {
      int distance = countCollaborator(c);
      if ((distance > 2) && (!c.equals("N/A"))) {

        // clicked on actor
        if ((clickedActor != null) && c.equals(clickedActor.name)) {
          actor = new Actor(c, this.name, distance, i, clickedActor.selected);
          actors.add(actor);
        } else {
          // default
          actor = new Actor(c, this.name, distance, i);
          actors.add(actor);
        }

        actor.drawOrbit();

        i++;
      } else {
        // do nothing
      }
    }

    // draw planets
    int j =1;
    for (String c : uniqueCo) {
      int distance = countCollaborator(c);
      if ((distance > 2) && (!c.equals("N/A"))) {
        // clicked on actor
        if ((clickedActor != null) && c.equals(clickedActor.name)) {
          actor = new Actor(c, this.name, distance, j, clickedActor.selected);
          actors.add(actor);
        } else if ((pickedActor != null) && c.equals(pickedActor.name)) {
          // hovering on actor
          actor = new Actor(c, this.name, distance, pickedActor.hovering, j);
          actors.add(actor);
        } else {
          // default
          actor = new Actor(c, this.name, distance, j);
          actors.add(actor);
        }

        actor.drawPlanet();

        j++;
      } else {
        // do nothing
      }
    }    
    drawMovies();
  }

  // draw movie posters
  void drawMovies() {

    if (countMovies() > 0) {

      noFill();
      int i = 0;
      int j; // the row number
      int d; // the collumn number  
      for (Movie m : movieList) {
        if (m.year >= yearMin && m.year <= yearMax) {
          j = (int) i/7;
          d = i%7 +1;
          int posX = d*80+750;
          int posY = j*115+150;
          m.x = posX;
          m.y = posY;          

          if (clickedActor != null && m.actors.contains(clickedActor.name)) { // clicked on actor
            m.loadMoviePoster();
            strokeWeight(1);
            m.draw();
          } else { // all movies
            m.loadMoviePoster();
            strokeWeight(1);
            m.draw();
            noStroke();
            fill(0, 0, 0, 200);
            rect(posX-6, posY-4, 100, 140); // fade poster
          }
          if (m.hovered) {
            m.loadMoviePoster();
            strokeWeight(3);
            m.draw();
            float textWidth = textWidth(m.title + " (" + m.year + ")");
            noStroke();
            fill(37, 37, 37, 250);
            rect(posX - (textWidth/4), posY-35, textWidth + 10, 25, 5);
            fill(255);
            text(m.title + " (" + m.year + ")", posX + 5 - (textWidth/4), posY-18);
            noStroke();
          }

          fill(225);
          i++;
          j++;
        }
      }
    } else {
      text("This one looks like a loner.", 750, centerY - 40);
      text("But as Aristotele said, ", 750, centerY - 10);
      text("“Whosoever is delighted in solitude, ", 750, centerY + 10);
      text("is either a wild beast or a god.”", 750, centerY + 30);
    }
  }

  public void getMovieList() {
    resetCollaborators();
    Set<String> uniqueCo = new HashSet<String>(collaborators);
    for (Movie m : movies) {      
      if (m.director.contains(this.name)) {        
        for (String c : uniqueCo) {
          if (countCollaborator(c) > 2 && m.actors.contains(c)) {
            if (movieList != null && !movieList.contains(m))
              this.movieList.add(m);
          }
        }
      }
    }
  }

  int countMovies() {
    return this.movieList.size();
  }

  // checking if poin in ellipse
  boolean contains(int px, int py) {
    return dist(this.directorX, this.directorY, px, py) < 70;
  } // end contains
} // end class