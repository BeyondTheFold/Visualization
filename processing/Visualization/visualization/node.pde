public class Node { 
  Integer index;
  Integer parentIndex;
  Node parent;
  ArrayList<Node> children;
  Integer childCount;
  String url;
  Date start;
  Float duration;
  Boolean subDomain;
  ArrayList<Float> coordinates;
  ArrayList<Float> bezierAnchorA;
  ArrayList<Float> bezierAnchorB;
  ArrayList<Integer> childIndicies;
  Float angle;
  Integer tabIndex;
  Boolean dontDraw;
 
  Node() {
    this.children = new ArrayList<Node>();
    this.childCount = 0;
    this.childIndicies = new ArrayList<Integer>();
    this.dontDraw = false;
  }
  
  public Node(Integer index, Integer parentIndex, Date start, Float duration, Boolean subDomain) {
    // call initialization constructor
    this();
    
    // define attributes
    this.index = index;
    this.parentIndex = parentIndex;
    this.start = start;
    this.duration = duration;
    this.subDomain = subDomain;
    this.childCount = 0;
  }
  
  Float getDuration() {
    return(this.duration); 
  }
  
  Integer getParentIndex() {
    return(this.parentIndex); 
  }
  
  Integer getIndex() {
     return(this.index); 
  }
  
  ArrayList<Integer> getChildrenIndicies() {
     return(this.childIndicies); 
  }
  
  void setParent(Node parent) {
    this.parent = parent; 
  }
  
  Node getParent() {
    return(this.parent); 
  }
  
  void setIndex(Integer index) {
    this.index = index; 
  }
  
  void addChild(Node child) {
    this.children.add(child);
    
    if(child != null) {
      ++this.childCount;
    } else {
      println("Error: trying to add null child"); 
    }
  }
  
  ArrayList<Node> getChildren() {
    return(children); 
  }
  
  void setCoordinates(ArrayList<Float> coordinates) {
    this.coordinates = coordinates;
  }

  void setBezierAnchorA(ArrayList<Float> bezierAnchor) {
    this.bezierAnchorA = bezierAnchor;
  }
  
  void setBezierAnchorB(ArrayList<Float> bezierAnchor) {
    this.bezierAnchorB = bezierAnchor;
  }

  ArrayList<Float> getCoordinates() {
    return(this.coordinates);
  }
  
  ArrayList<Float> getBezierAnchorA() {
    return(this.bezierAnchorA);
  }
  
  ArrayList<Float> getBezierAnchorB() {
    return(this.bezierAnchorB);
  }
  
  void setAngle(Float angle) {
    this.angle = angle;
  }
  
  Float getAngle() {
     return(this.angle); 
  }
  
  void setDuration(Float duration) {
    this.duration = duration;
  }
  
  Integer getChildCount() {
    return(this.childCount); 
  }
  
  ArrayList<Integer> getChildIndicies() {
    return(this.childIndicies);
  }
  
  void setChildIndicies(ArrayList<Integer> childIndicies) {
    this.childIndicies = childIndicies;
  }
  
  void setSubDomain(Boolean subDomain) {
    this.subDomain = subDomain;
  }
  
  Boolean isSubDomain() {
    return(this.subDomain); 
  }
  
  void setTabIndex(Integer index) {
    this.tabIndex = index;
  }
  
  Integer getTabIndex() {
    return(this.tabIndex); 
  }
  
  void dontDraw() {
    this.dontDraw = true; 
  }
  
  Boolean notDrawn() {
    return(this.dontDraw); 
  }
}