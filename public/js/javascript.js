Plotly.plot('graph', [{
    x: [1, 2,3],
    y: [0, 0.5, 2],
    line: {simplify: false},

}],  layout= {
    width: 800,
        height: 500});

function randomize() {

    // repeat with the interval of 2 seconds
    var timerId = setInterval(function () {
        Plotly.animate('graph', {
            data: [{y: [Math.random(), Math.random(), Math.random()]}],
            traces: [0],
            layout: {
                width: 800,
                height: 500}
        }, {
            transition: {
                duration: 500,
                easing: 'cubic-in-out'
            }
        })
    }, 100);

    // after 5 seconds stop
    setTimeout(function(){ clearInterval(timerId) }, 5000);


}