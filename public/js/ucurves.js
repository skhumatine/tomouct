
//---------------------------uCurve initial line graph-----------//
//initial ucurve data
var uCurveData = [{
    line: {simplify: false},

}];

var uCurveLayout = {
    title: 'u curves',
    xaxis: {
        title: 'Readings',
        range: [0,256]
    },
    yaxis: {
        title: 'Values',
        range: [0,5000]
    }
};

//find div with id graphUcurves, plot a graph in it
Plotly.plot('graphUcurves',uCurveData ,  uCurveLayout );

//--------------------------Histogram initial graph-------------------///
//histogram data
var histoData = [{

    name: 'First sample',
    type: 'histogram'
}];

//histogram layout
var histoLayout = {
    title: 'Histogram',
    xaxis: {
        title: 'Readings',
        range: [0,5000]
    },
    yaxis: {
        title: 'Values',
       range: [0,200]
    }};

//find div with id graphHistogram, plot a graph in it
Plotly.plot('graphHistogram', histoData,  histoLayout );


//--------------------3d plot data----------------------------//

/**
 *
 *                  x0   x1   x2   x3   x4
 *               |-------------------------|
 *            y0 | z00  z01  z02  z03  z04 |
 *            y1 | z10  z11  z12  z13  z14 |
 *            y2 | z20  z21  z22  z23  z24 |
 *            y3 | z30  z31  z32  z33  z34 |
 *            y4 | z40  z41  z42  z43  z44 |
 *               | ----------------------- |
 *
 * **/

var data3d = [{
    type: 'surface'
}];

var layout3d = {
    title: 'Surface graph',
    height: 700,
    scene: {
        xaxis: {range: [0, 15]},
        yaxis: {range: [0, 15]},
        zaxis: {range: [0, 15]}
    },
    margin: {
        l: 10,
        r: 10,
        b: 10,
        t: 30,
    }
};
Plotly.newPlot('graph3d', data3d, layout3d);




/**-------------------------jQuery -------------**/
//once the page has loaded , invoke the callback function
$(document).ready(function(){


    //get element with id="start" , trigger a function once it is clicked
    $("#startUcurves").click(function(){


       timerId = setInterval(function(){

           //send get request to local server , on response trigger the callback function
           $.get("/api/index", function(data, status){

               // data is an object with structure { 'error': bool, 'result': [] }

               //use the result parameter as data for a new u curve plot
               Plotly.animate('graphUcurves', {
                   data: [{y: data.result}]
               }, {
                   transition: {
                       duration: 0,
                   },
                   frame: {
                       duration: 0,
                       redraw:false
                   }
               });


               //use the result parameter as data for a new histogram plot
               Plotly.animate('graphHistogram', {
                   data: [{x: data.result}]
               }, {
                   transition: {
                       duration: 500,
                       easing: 'linear'
                   }
               })
           });


       }, 100);


    });


    //get element with id="stop" , trigger a function once it is clicked
    $("#stopUcurves").click(function(){


        clearInterval(timerId)


    });



/**___________3d surface plot controls______________**/
    //start displaying random data on the surface plot
    //get a div element with id="start3d" , trigger a function once it is clicked
    $("#start3d").click(function(){


       timer3d = setInterval(function(){



            //use the result parameter as data for a new histogram plot
            Plotly.animate('graph3d', {
                data: [
                    {z: [
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*15,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10],
                            [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10]
                        ]}
                        ]}, {
                transition: {
                    duration: 0,
                },
                frame: {
                    duration: 0,
                    redraw:false
                }
            })


        }, 50);


    });



    //get element with id="stop" , trigger a function once it is clicked
    $("#stop3d").click(function(){


        clearInterval(timer3d)


    });


});


//testing functions ,
// function randomize() {
//
//     // repeat with the interval of 2 seconds
//     timerId = setInterval(function () {
//         Plotly.animate('graph', {
//             data: [{y: [Math.random()*5000, Math.random()*5000, Math.random()*5000,Math.random()*5000,
//                     Math.random()*5000, Math.random()*5000,]}]
//         }, {
//             transition: {
//                 duration: 0,
//             },
//             frame: {
//                 duration: 0,
//                 redraw:false
//             }
//         })
//     }, 100);
//
//     // // after 5 seconds stop
//     // setTimeout(function(){ clearInterval(timerId) }, 5*5000);
//
//
// }
//
// //stop simulation
// function stopRandomize(){
//     clearInterval(timerId)
//
// }s