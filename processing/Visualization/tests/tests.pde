void testDrawNode() {
  ArrayList<Float> coordinates = new ArrayList<Float>();
  coordinates.add(0.0);
  coordinates.add(0.0);
  
  drawNode(coordinates, Shape.CIRCLE);
}

void testDrawGraph() {
  Graph graph = new Graph(100.0, 200.0);
  //graph.generateRandom(5, 2);
  graph.generateFull(3, 3);
  graph.setEndAngle(45.0);

  graph.calculateLevelBreadths();
  
  // insure level breadths are calculated correctly
  assert(graph.getLevelBreadths().get(0) == 1);
  assert(graph.getLevelBreadths().get(1) == 3);
  assert(graph.getLevelBreadths().get(2) == 9);
  
  assert(graph.getNodes().get(0).getAngle() == graph.getNodes().get(0).getChildren().get(0).getParent().getAngle());
  
  graph.calculateNodePositions();
  graph.drawGraph(0.0);
}

void testGetCartesian() {
  ArrayList<Float> result = getCartesian(1.0, radians(45));
  println(result);
}