public class Tab {
  ArrayList<Graph> graphs;
  Float duration;
  Integer drawnDuration;
  Float startAngle;
  Float endAngle;
  Float levelSeparation;
  Float levelStartDiameter;
  Float diameter;
  Integer nodeCount;
  
  Tab() {
    this.graphs = new ArrayList<Graph>();
  }
  
  Tab(Float diameter, Float levelSeparation, Float levelStartDiameter) {
    this.nodeCount = 0;
    this.diameter = diameter;
    this.levelSeparation = levelSeparation;
    this.levelStartDiameter = levelStartDiameter;
    this.duration = 0.0; 
    this.graphs = new ArrayList<Graph>();
  }
  
  Float getDuration() {
    return(this.duration); 
  }
  
  void addGraph(Graph graph) {
    graph.setLevelSeparation(levelSeparation);
    graph.setLevelsStartDiameter(levelStartDiameter);
    this.graphs.add(graph);
    this.duration += graph.getDuration();
    this.nodeCount += graph.getNodeCount();
  }
  
  void generateRandom() {
    Random generator = new Random();

    Integer randomGraphCount = generator.nextInt(3) + 2;
    
    for(Integer i = 0; i < randomGraphCount; ++i) {
      Graph graph = new Graph(levelSeparation, levelStartDiameter);
      graph.generateRandom(10, 1, 4);
      
      this.addGraph(graph);
    }
  }
  
  void calculateGraph() {
    Float graphStartAngle = this.startAngle;
    Float graphEndAngle;
    Float graphAngle;
    Float tabAngle = endAngle - startAngle;

    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < graphs.size(); ++i) {
        graphAngle = tabAngle / graphs.size();
        graphEndAngle = (float)graphStartAngle + graphAngle;
        graphs.get(i).setStartAngle(graphStartAngle);
        graphs.get(i).setEndAngle(graphEndAngle);
        graphs.get(i).calculateLevelBreadths();
        graphs.get(i).calculateNodePositions();
        graphStartAngle = graphEndAngle;
    }
    
    for(Integer i = 0; i < graphs.size(); ++i) {
      for(Integer j = 0; j < graphs.size(); ++j) {
        hideOverlappingNodes(graphs.get(i).getNodes(), graphs.get(j).getNodes());
      }
    }
  }
  
  void drawTab(Float minDuration) {    
    for(Integer i = 0; i < graphs.size(); ++i) {
      this.graphs.get(i).drawGraph(minDuration);
    }
    
    if(minDuration == 0) {
      drawSpoke(diameter / 2, this.startAngle);
      drawSpoke(diameter / 2, this.endAngle);
    }
  }
  
  void drawSpoke(Float radius, Float angle) {
    ArrayList<Float> coordinates = getCartesian(radius, radians(angle));
    
    strokeWeight(.5);
    stroke(0);
    line(0.0, 0.0, coordinates.get(0), coordinates.get(1));
  }
  
  void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
  
  Integer getNodeCount() {
    return(this.nodeCount); 
  }
  
  void setDiamerter(Float diameter) {
    this.diameter = diameter;
  }
  
  void setLevelSeparation(Float levelSeparation) {
    this.levelSeparation = levelSeparation;
  }
  
  void setLevelStartDiameter(Float levelStartDiameter) {
    this.levelStartDiameter = levelStartDiameter;
  }
}