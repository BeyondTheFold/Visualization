
try {
    provide('beyondTheFold');
    require('beyondTheFold.tree');
} catch(error) {
    beyondTheFold = {};
    beyondTheFold.visualization = {};
}

beyondTheFold.handleDataResponse = function(response) {
    var jsonObject = JSON.parse(response);

};

beyondTheFold.visualization.setCanvas = function(canvasElement) {
    beyondTheFold.canvasElement = canvasElement;
};

