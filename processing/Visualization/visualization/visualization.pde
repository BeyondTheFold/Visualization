import java.sql.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.ArrayList;
import processing.opengl.*;

Float MINIMUM_TAB_DURATION = 15.0;
Float DIAMETER = 800.0;
Integer LEVELS = 20;
Integer SUPER_LEVELS = 5;
Float START_DIAMTER = 200.0;
Float TOTAL_SLICE_DURATION = 400.0; // in minutes
Float LEVEL_SEPARATION = (DIAMETER - START_DIAMTER) / LEVELS;
Integer MINIMUM_NODE_SEPARATION = 10;

Float pan_x = 0.0;
Float pan_y = 0.0;
Integer click_position_x = 0;
Integer click_position_y = 0;
Float zoom = 0.0;
Float rotate_x = 0.0;
Float rotate_y = 0.0;
Boolean forLaserCutting = false;
Connection connection = null;
Statement statement = null;
Float minimumSeparation = 15.0;
Float maximumSeparation;

enum Shape {
  CIRCLE,
  DIAMOND
}

Float distance(Node a, Node b) {
  Float ax = a.getCoordinates().get(0);
  Float ay = a.getCoordinates().get(1);
  Float bx = b.getCoordinates().get(0);
  Float by = b.getCoordinates().get(1);
  return(sqrt(pow(ax - bx, 2) + pow(ay - by, 2)));
}

ArrayList<Float> getPolar(Float x, Float y) {
  ArrayList<Float> coordinates = new ArrayList<Float>(2);

  Float radius = sqrt((x * x) + (y * y));
  Float angle = atan(y / x);
  coordinates.add(0, radius);
  coordinates.add(1, angle);
  
  return coordinates;
}

void hideOverlappingNodes(ArrayList<Node> A, ArrayList<Node> B) {
  Node a;
  Node b;
  for(Integer i = 0; i < A.size(); ++i) {
    a = A.get(i);
    if(a != null) {
      for(Integer j = 0; j < B.size(); ++j) {
        if(i != j) {
          b = B.get(j);

          if(b != null) {
            if(distance(a, b) < MINIMUM_NODE_SEPARATION) {
              
              // prioritize nodes with children
              if(a.getChildCount() == 0 && b.getChildCount() > 0) {
                if(!a.notDrawn() && !b.notDrawn()) {
                  a.dontDraw();
                }
              } else {
                if(!a.notDrawn() && !b.notDrawn()) {
                  b.dontDraw();
                }
              }
            }
          }
        }
      }
    }
  }
}

ArrayList<Float> getCartesian(Float radius, Float angle) {
  ArrayList<Float> coordinates = new ArrayList<Float>(2);
  
  coordinates.add(0, radius * cos(angle));
  coordinates.add(1, radius * sin(angle));
  
  return coordinates;
}

void drawCylinder(Integer sides, Float radius, Float height) {
  Float angle = (float)360 / sides;
  Float halfHeight = height / 2;
   
  // top of cylinder
  beginShape();
  for(Integer i = 0; i < sides; ++i) {
    Float x = cos(radians(i * angle)) * radius;
    Float y = sin(radians(i * angle)) * radius;
    vertex(x, y, -halfHeight);
  }
  endShape(CLOSE);
   
  // bottom of cylinder
  beginShape();
  for(Integer i = 0; i < sides; ++i) {
    Float x = cos(radians(i * angle)) * radius;
    Float y = sin(radians(i * angle)) * radius;
    vertex(x, y, halfHeight);
  }
  endShape(CLOSE);
   
  // draw body
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
      float x = cos( radians( i * angle ) ) * radius;
      float y = sin( radians( i * angle ) ) * radius;
      vertex( x, y, halfHeight);
      vertex( x, y, -halfHeight);    
  }
  endShape(CLOSE);
}

void connectToDatabase() {
  try {
    Class.forName("org.sqlite.JDBC");
    connection = DriverManager.getConnection("jdbc:sqlite:Library/Safari/LocalStorage/safari-extension_browsingvisualizer-0000000000_0.localstorage");
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
  }
}

void closeConnection() {
  try {
    connection.close();
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
  }
}

String getSessionsFromDatabase() {
  String sessions = "";
 
  try {
    statement = connection.createStatement();
    ResultSet result = statement.executeQuery("SELECT value FROM ItemTable WHERE key='sessions'");
    byte[] b = result.getBytes("value");

    for(byte character : b) {
      if(character != 0) {
        sessions += new String(new byte[] { character });
      }
    }
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
    return(null);
  }

  return(sessions);
}

Slice constructFromJSON(JSONObject json) {
  JSONArray values = json.getJSONArray("sessions");

  Integer index;
  Integer tab;
  String url;
  String sessionStartString;
  Date sessionStart;
  Float duration;
  Integer parent = 0;
  Boolean subDomain;
  
  ArrayList<Node> nodes = new ArrayList<Node>();
  JSONObject session;
  JSONArray childrenArray;
  
  for(Integer i = 0; i < values.size(); ++i) {
    session = values.getJSONObject(i);
    index = session.getInt("index");
    //url = session.getString("url");
    sessionStartString = session.getString("sessionStart");
    sessionStart = new Date();
    duration = (float)session.getInt("sessionDuration");
    duration = ((duration / 1000) / 60);
    parent = session.getInt("parent");
    childrenArray = session.getJSONArray("children");
    subDomain = session.getBoolean("withinParentDomain");
    tab = session.getInt("tab");

    ArrayList<Integer> children = new ArrayList<Integer>();
    
    for(int j = 0; j < childrenArray.size(); ++j) {
      children.add(childrenArray.getInt(j));
    }

    // create table of nodes at their respective indicies
    nodes.ensureCapacity(index + 1);
    while(nodes.size() < index + 1) {
      nodes.add(new Node());
    }
    
    Node node = new Node(index, parent, sessionStart, duration, false);
    node.setTabIndex(tab);
    node.setChildIndicies(children);
    node.setSubDomain(subDomain);
    nodes.set(index, node);
  }
  
  // 
  Slice slice = new Slice(DIAMETER, START_DIAMTER, LEVELS, SUPER_LEVELS);
  ArrayList<Tab> tabs = new ArrayList<Tab>();
  ArrayList<Graph> graphs = new ArrayList<Graph>();
  Integer tabIndex;
  
  // for all nodes without parents
  for(Integer i = 0; i < nodes.size(); ++i) {
    if(nodes.get(i).getIndex() != null && nodes.get(i).getParentIndex() == -1) {
      Graph graph = new Graph();
      graph.constructGraph(nodes, nodes.get(i));

      // insure tabs list has capcity for tab at index
      tabIndex = nodes.get(i).getTabIndex();
      tabs.ensureCapacity(tabIndex);
      while(tabs.size() < tabIndex + 1) {
        tabs.add(new Tab(DIAMETER, LEVEL_SEPARATION, START_DIAMTER));
      }
      
      tabs.get(tabIndex).addGraph(graph);
    }
  }
  
  for(Integer i = 0; i < tabs.size(); ++i) {
    slice.addTab(tabs.get(i));
  }
  
  return(slice);
}

Boolean toBoolean(Integer value) {
  return(value != 0);
}

ArrayList<Node> importFromCsvFile(String filename) {
  Table table = loadTable(filename, "header");
  ArrayList<Node> nodes = new ArrayList<Node>();
  
  for (TableRow row : table.rows()) {
    Integer index = row.getInt("index");
    String url = row.getString("url");
    String sessionStartString = row.getString("sessionStart");
    Date sessionStart = new Date();
    Float duration = (float)row.getInt("sessionDuration");
    Integer parent = row.getInt("parent");
    String children = row.getString("children");
    Boolean subDomain = toBoolean(row.getInt("subDomain"));
    
    Node node = new Node(index, parent, sessionStart, duration, subDomain);
    nodes.add(node);
  }
  
  return(nodes);
}

void drawNode(ArrayList<Float> coordinates, Shape shape) {
  Float x = coordinates.get(0);
  Float y = coordinates.get(1);
  ArrayList<Float> polarCoordinates = getPolar(x, y);
  Float radians = polarCoordinates.get(1);

  fill(0);
  noStroke();

  if(shape == Shape.CIRCLE) {
    ellipse(x, y, 10, 10);
  } else if(shape == Shape.DIAMOND) {
    pushMatrix();
    translate(x, y);
    rotate(radians + PI/4);
    rect(0, 0, 10, 10);
    popMatrix();
  }
}

void drawNode(float radius, float angle, Shape shape) {
  Float radians = radians(angle);
  ArrayList<Float> coordinates = getCartesian(radius, radians);
  Float x = coordinates.get(0);
  Float y = coordinates.get(1);

  if(shape == Shape.CIRCLE) {
    fill(0, 0, 0);
    noStroke();
    ellipse(x, y, 10, 10);
  } else if(shape == Shape.DIAMOND) {
    pushMatrix();
    translate(x, y);
    rotate(radians + PI/4);
    rect(0, 0, 10, 10);
    popMatrix();
  }
}

void mousePressed() {
  click_position_x = mouseX;
  click_position_y = mouseY;
}

void mouseDragged() {  
  if(mouseButton == RIGHT) {
    Float delta_x = (float)mouseX - click_position_x;
    Float delta_y = (float)mouseY - click_position_y;
    // panning
    if(pan_x + delta_x < 100 && pan_x + delta_x > -100) {
      pan_x += delta_x;
    }
    
    if(pan_y + delta_y < 100 && pan_y + delta_y > -100) {
      pan_y += delta_y;
    }
  }
  
  if(mouseButton == LEFT) {
    // rotation
    rotate_x += (float)(mouseX - click_position_x);
    rotate_y += (float)(mouseY - click_position_y);

  }
}

void mouseWheel(MouseEvent event) {
  zoom += (float)event.getCount(); 
}

JSONObject json;

void settings() {
  //fullScreen();
  size(1000, 800);
}


void setup() {
  smooth();
  ellipseMode(CENTER);
  rectMode(CENTER);
  background(255);
  translate((width / 2), (height / 2));
  
  // file name to change for test data
  //json = loadJSONObject("test_data_7.json");
  
  /*  
  Slice slice = new Slice(DIAMETER, START_DIAMTER, LEVELS, SUPER_LEVELS);
  slice.generateRandom();
  slice.calculatePositions();
  slice.drawSlice(0.0); 
  */
  
  //testDrawNode();
  //testGetCartesian();
  //testDrawGraph();
  
}

void draw() {
  clear();
  smooth();
  ellipseMode(CENTER);
  rectMode(CENTER);
  background(255);
  
  connectToDatabase();
  json = parseJSONObject(getSessionsFromDatabase());
  closeConnection();

  Slice slice = constructFromJSON(json);
  slice.calculatePositions();
  slice.drawInfo();
  
  pushMatrix();
  translate((width / 2), (height / 2));
  slice.drawSlice(0.0);
  popMatrix();
  
  delay(200);

  //json = parseJSONObject(getSessionsFromDatabase());

  /*
  lights();
  

  pushMatrix();
  rotateX( PI/4 );
  rotateY( radians( frameCount ) );
  rotateZ( radians( frameCount ) );
  drawCylinder(20, 30.0, 40.0);
  popMatrix();
  */
 
  /*   pushMatrix();
  slice.drawSlice(1); 
  popMatrix();
  
  
  pushMatrix();
  //translate((width / 2) + pan_x, (height / 2) + pan_y, zoom);
  translate(width / 2, height / 2, 0);
  slice.drawSlice(0); 
  popMatrix();
  
  //translate((width / 2) + pan_x, (height / 2) + pan_y, 10);
  camera((width/2.0) + pan_x, (height/2.0) + pan_y, (height/2.0) / tan(PI*30.0 / 180.0), 
        (width / 2.0) + pan_x, (height/2.0) + pan_y, 0, 
        0, 1, 0);
  */
}