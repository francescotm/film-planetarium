class Movie {
  String title;
  int x;
  int y;
  int year;
  float rating;
  String director;
  String actors;
  boolean hovered;
  boolean selected;
  String imgURL;
  PImage poster;

  public Movie(String title, int year, String director, String actors, float rating, String url) {
    this.title = title;
    this.year = year;
    this.rating = rating;
    this.director = director;
    this.actors = actors;
    this.hovered = false;
    this.selected = false; 
    this.imgURL = url;
  }

  void loadMoviePoster() {

    // default image
    this.poster = loadImage("posters/none.jpg");

    String posterName = null;

    // take director name and take out spaces or dashes
    if ((this.imgURL != null) && !(this.imgURL.equals("N/A"))) {
      String url[] = this.imgURL.split("/M/");
      posterName = url[1];
    }

    if (posterName != null) {
      poster = loadImage("posters/"+posterName);
    } else {
      // do nothing
    }
  }

  void draw() {
    image(poster, x - 6, y - 4);
    int posterWidth = poster.width;
    int posterHeight = poster.height;
    stroke(253, 191, 111);
    noFill();
    rect(x - 6, y - 4, posterWidth - 1, posterHeight - 1, 5);
  }

  boolean contains(int px, int py) {
    if (px >= x - 6 && px <= x + 74 && py >= y - 4 && py <= y + 106) {
      return true;
    } else {
      return false;
    }
  }

  float getRating() {
    return this.rating;
  }
  String getDirector() {
    return this.director;
  }
}