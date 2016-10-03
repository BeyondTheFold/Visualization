
try {
    provide('beyondTheFold.node');
} catch(error) {
    beyondTheFold.node = {};
}

function calculateDistance(nodeOne, nodeTwo) {
	var dx = nodeOne.coordinates[0] - nodeTwo.coordinates[0];
	var dy = nodeOne.coordinates[1] - nodeTwo.coordinates[1];
	return(Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2)));
}

class Node {
	constructor(x, y) {
		this.coordinates = [x, y];
	}
}
