public class Graph {
  ArrayList<ArrayList<Node>> adjacencyList;
  ArrayList<Integer> levelBreadths;
  ArrayList<Node> nodes;
  Float duration;
  Integer nodeCount;
  Float startAngle = 0.0;
  Float endAngle = 90.0;
  Float levelSeparation;
  Float levelsStartDiameter;
  
  Graph() {
    // initialize node count
    nodeCount = 0;
    
    // initialize duration to 0 microseconds
    this.duration = 0.0;
        
    // initialize adjacency list
    adjacencyList = new ArrayList<ArrayList<Node>>(100000);
    
    // initialize node list
    nodes = new ArrayList<Node>(100000);
        
    for(Integer i = 0; i < 100000; ++i) {
     adjacencyList.add(null); 
     nodes.add(null);
    }
    
    // initialize table containing each levels breadth
    this.levelBreadths = new ArrayList<Integer>();
  }
  
  Graph(      
      Float levelSeparation, 
      Float levelsStartDiameter) {
    
    // call initialization constructor
    this();
    
    // define attributes from paremeters
    this.levelSeparation = levelSeparation;
    this.levelsStartDiameter = levelsStartDiameter;
  }
  
  Float getDuration() {
    return(this.duration);
  }
  
  void addNode(Node node) { 
    nodes.set(node.getIndex(), node);
    
    // add duration to graph duration
    this.duration += node.getDuration();
    
    if(!adjacencyList.contains(node)) {
      adjacencyList.set(node.getIndex(), new ArrayList<Node>()); 
    }
    
    // iterate through children passed to function
    for(Integer i = 0; i < node.getChildren().size(); ++i) {
      this.adjacencyList.get(node.getIndex()).add(node.getChildren().get(i));
    }
  }
  
  void drawGraph(Float minDuration) {
      Node node;
      Shape shape = Shape.CIRCLE;
      
      // iterate through all nodes
      for(Integer i = 0; i < this.nodes.size(); ++i) {
        node = this.nodes.get(i);
        
        // if node exists at position
        if(node != null && node.getCoordinates() != null) {
          
          // dont display nodes with less than minimum duration
          if(node.getDuration() >= minDuration && !node.notDrawn()) {
            if(node.getParent() != null) {
              // dont draw if parent not drawn
              if(node.getParent().notDrawn()) {
                node.dontDraw();
                continue;
              }
            }
          
            // if node is is a sub-domain draw circle, otherwise draw diamond
            if(node.isSubDomain()) {
              shape = Shape.CIRCLE;
            } else {
              shape = Shape.DIAMOND;
            }
            
            drawNode(node.getCoordinates(), shape);
          }
        }
      }
      
      // only draw lines on first layer
      if(minDuration == 0) {
        this.drawLines();
      }
  }
  
  void calculateLevelBreadths() {
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer breadth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Node current;
    Node start = null;
    
    // node to start with
    for(Integer i = 0; i < this.nodes.size(); ++i) {
      if(this.nodes.get(i) != null) {
        start = this.nodes.get(i);
        break;
      }
    }
    
    if(start == null) {
      return;
    }
        
    // add start node to queue
    queue.add(start);
    
    while(!queue.isEmpty()) {
      current = queue.poll();

      ++breadth;
      nextElementsToDepthIncrease += adjacencyList.get(current.getIndex()).size();

      if(--elementsToDepthIncrease == 0) {
        levelBreadths.add(breadth);
        breadth = 0;
        elementsToDepthIncrease = nextElementsToDepthIncrease;
        nextElementsToDepthIncrease = 0;
      }      
      
      // for each adacent node
      for(Integer i = 0; i < adjacencyList.get(current.getIndex()).size(); ++i) {
        Node adjacentNode = adjacencyList.get(current.getIndex()).get(i);
        queue.add(adjacentNode);
      }
    }
  }
 
  
  void calculateNodePositions() {
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer depth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Node current;
    Float separationAngle = 0.0;
    Float angle;
    Float parentAngle;
    Float anchorAngle;
    Float radius;
    Integer maximumBreadth;
    Node start = null;
    Integer breadth = 0;
    Float minimumSeparationAngle;
    Integer adjust = 0;
    
    // node to start with
    for(Integer i = 0; i < this.nodes.size(); ++i) {
      if(this.nodes.get(i) != null) {
        start = this.nodes.get(i);
        break;
      }
    }
    
    if(start == null) {
      return;
    }
        
    // add start node to queue
    queue.add(start);
    
    // while queue is not empty
    while(!queue.isEmpty()) {
      // get next node to visit
      current = queue.poll();
      
      // increment breadth
      breadth += 1;
      
      // calculate radius component of polar coordinate
      radius = (levelsStartDiameter / 2) + (levelSeparation / 2) * depth;
      
      separationAngle = (endAngle - startAngle) / levelBreadths.get(depth);
            
      // calculate angle component of polar coordinate
      angle = startAngle + (separationAngle * (elementsToDepthIncrease - 1)) + (separationAngle / 2);   
      
      if(current != null) {
        current.setCoordinates(getCartesian(radius, radians(angle)));
        current.setAngle(radians(angle));
        //assert(current.getAngle() == radians(angle));
        
        // if node has parent
        if(current.getParent() != null && current.getParent().getAngle() != null) {
          parentAngle = current.getParent().getAngle();
          anchorAngle = ((radians(angle) - parentAngle) * 0.25);
          
          // calculate midpoints for bezier anchors
          current.setBezierAnchorA(getCartesian(radius, parentAngle + anchorAngle));
          current.setBezierAnchorB(getCartesian(radius - (levelSeparation / 2), radians(angle) - anchorAngle));
        } else {
          current.setBezierAnchorA(getCartesian(radius - (levelSeparation / 2), radians(angle)));
          current.setBezierAnchorB(getCartesian(radius - (levelSeparation / 2), radians(angle)));
        }
            
        nextElementsToDepthIncrease += adjacencyList.get(current.getIndex()).size();
            
        // dont draw nodes greather than maximum depth
        if(depth > 20) {
          if(current != null) {
            current.dontDraw();
          }
        }
            
        // detects if the current node being visited is on a new level
        if(--elementsToDepthIncrease == 0) {
          ++depth;
          breadth = 0;
          adjust = 0;
          elementsToDepthIncrease = nextElementsToDepthIncrease;
          nextElementsToDepthIncrease = 0;
        }
  
        // for each adacent node
        for(Integer i = 0; i < adjacencyList.get(current.getIndex()).size(); ++i) {
          Node adjacentNode = adjacencyList.get(current.getIndex()).get(i);
          queue.add(adjacentNode);
        }
      }
    }
  }
  
  void drawLines() {
    ArrayList<Float> parentCoordinates;
    ArrayList<Float> childCoordinates;
    ArrayList<Float> bezierAnchorA;
    ArrayList<Float> bezierAnchorB;
    Node a;
    Node b;

    for(Integer i = 0; i < adjacencyList.size() - 1; ++i ) {
      if(adjacencyList.get(i) != null) {  
        for(Integer j = 0; j < adjacencyList.get(i).size(); ++j) {
          a = adjacencyList.get(i).get(j).getParent();
          b = adjacencyList.get(i).get(j);
          
          if(!a.dontDraw && !b.dontDraw) {
            parentCoordinates = a.getCoordinates();
            childCoordinates = b.getCoordinates();
            bezierAnchorA = b.getBezierAnchorA();
            bezierAnchorB = b.getBezierAnchorB();
  
            if(childCoordinates != null && parentCoordinates != null) {
              strokeWeight(0.75);
              stroke(0);
              noFill();
              
              bezier(parentCoordinates.get(0), parentCoordinates.get(1), 
              bezierAnchorA.get(0), bezierAnchorA.get(1),
              bezierAnchorB.get(0), bezierAnchorB.get(1),
              childCoordinates.get(0), childCoordinates.get(1)); 
            }
          }
        }
      }
    }
  }
  
  void createSubgraph(
    Random generator,
    Integer maxDepth, 
    Integer depth,
    Integer minChildren,
    Integer maxChildren,
    Node parent,
    Integer pathProbability) {
              
    if(depth >= maxDepth) {
      return;
    }
    
    Integer childCount;
    Integer takePath = 0;

    if(minChildren == maxChildren) {
      childCount = maxChildren;
    } else {
      childCount = generator.nextInt(maxChildren) + minChildren;
    }
  
    for(Integer j = 0; j < childCount; ++j) {
      Node child = new Node();
      child.setIndex(nodeCount);
      ++nodeCount;
      
      // generate random node duration
      child.setDuration((float)generator.nextInt(5) + 1);
      
      // generate randon number to decide if in same domain
      Integer inDomain = generator.nextInt(10);
      if(inDomain > 4) {
        child.setSubDomain(true);
      } else {
        child.setSubDomain(false);
      }
      
      takePath = generator.nextInt(100);
      
      child.setParent(parent);
      parent.addChild(child);
      
      this.addNode(child);
      
      if(takePath <= pathProbability) {
        // recursively call create random subgraph
        createSubgraph(generator, maxDepth, depth + 1, 1, 2, child, pathProbability + 10);
      }
    } 
    
     this.addNode(parent);
  }

  void generateRandom(Integer maxDepth, Integer minChildren, Integer maxChildren) {
  
    Random generator = new Random();
    Integer depth = 0;
    Integer pathProbability = 15;
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0.0);
    root.setSubDomain(false);
    ++nodeCount;
        
    createSubgraph(generator, maxDepth, depth, minChildren, maxChildren, root, pathProbability);    
  }
  
  void generateFull(Integer maxDepth, Integer maxChildren) {
  
    Random generator = new Random();
    Integer depth = 0;
    Integer pathProbability = 100;
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0.0);
    ++nodeCount;
        
    createSubgraph(generator, maxDepth, depth, maxChildren, maxChildren, root, pathProbability);    
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
  
  ArrayList<Node> getNodes() {
    return(this.nodes); 
  }
  
  void printAdjacencyList() {
    for(Integer i = 0; i < this.nodeCount; ++i) {
      print(i + " -> ");
      if(adjacencyList.get(i) != null) {
        for(Integer j = 0; j < adjacencyList.get(i).size(); ++j) {
          if(adjacencyList.get(i).get(j) != null) {
            print(adjacencyList.get(i).get(j).getIndex() + " ");
          }
        }
      }
      println();
    }
  }
  
  ArrayList<Integer> getLevelBreadths() {
    return(this.levelBreadths);
  }
 
  Node constructGraph(ArrayList<Node> nodeTable, Node node) {
    if(node == null) {
      return(null);
    }
    
    for(Integer i = 0; i < node.getChildIndicies().size(); ++i) {
      Node child = constructGraph(nodeTable, nodeTable.get(node.getChildIndicies().get(i)));
      if(child != null) {
        child.setParent(node);
        node.addChild(child);
        ++this.nodeCount;
      }
    }
    
    this.addNode(node);
    return(node);
  }
  
  void setLevelSeparation(Float levelSeparation) {
    this.levelSeparation = levelSeparation;
  }
  
  void setLevelsStartDiameter(Float levelsStartDiameter) {
    this.levelsStartDiameter = levelsStartDiameter;
  }
}