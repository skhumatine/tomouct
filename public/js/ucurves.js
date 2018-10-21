//todo:  set scripts to start on startup of pi

//---------------------------uCurve initial line graph-----------//
//initial ucurve data
var uCurveData = [{
    line: {simplify: false},

}];

var uCurveLayout = {
    title: 'U Curves',
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


//--------------------3d plot data and initialisations----------------------------//

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

    //opened port
    var openedPort = "";

    var dataArrays = {};

    //get element with id="getPorts" , trigger a function once it is clicked
    //getPorts fetches the available ports from instrument
    $("#getPorts").click(function(){

        // enable initialise instruments button
        $(".needPort").removeClass("w3-disabled");

        // first clear any child in div
        radio_home.innerHTML = '';

        //send get request to local server , on response trigger the callback function
        $.get("/api/get-ports", function(data, status){

            // data is an object with structure { 'error': bool, 'result': [] }

            // if there was an error, display it
            if (data.error){
                console.log('error getting ports: ',  data.result)
            }else {

                console.log(data.result);

                makeRadioButton(data.result);
            }

        });


    });


    //get element with id="getPorts" , trigger a function once it is clicked
    $("#initialise").click(function(){


        // check what input  is selected from the radio buttons
      var selectedPort = $("input[name=port]:checked").val();

      if(selectedPort){
          // do request if port is selected

          console.log("selected port to be opened during initialising ", selectedPort);

          //send get request to local server , on response trigger the callback function
          $.get("/api/initialise?port=" + selectedPort, function(data, status){

              // data is an object with structure { 'error': bool, 'result': [] }
              console.log(data);

             // if there was an error opening the port, alert

              if(!data.error){

                  //show message to tell user that instrument has been initialised, and hide button
                  // to avoid a bug which occurs when the sequence table is uploaded more than once
                  // this is because initialise opens the port then uploads sequence table all the time it is called
                  $("#alertMessage").text("Instrument Successfully initialised." );
                  $("#alert").show();
                  $("#initialise").hide();


                  // enable capture-frames button
                  $(".needInitialise").removeClass("w3-disabled");
                  openedPort = selectedPort; // update value of selected port in case user selects
                  // a different one, this value will be used every time a request is sent to the server
                  $("#openedPort").text("Opened Port: " +openedPort );



              }else {


                  $("#alertMessage").text("Error initialising port \"" + selectedPort + "\" Please select a different port and try again" );
                  $("#alert").show();

              }


          });


      }else{ //else display error message

          $("#alertMessage").text("Please select a port!");
          $("#alert").show();
      }


    });



    //get element with id="startUcurves" , trigger a function once it is clicked
    $("#startUcurves").click(function(){


        //if the instrument was successfully initialised and a port was opened= portOpened variable is assigned.
        //then fetch data

        if(openedPort){
            timerId = setInterval(function(){

                //send get request to local server , on response trigger the callback function
                $.get("/api/capture-frame?port=" + openedPort, function(data, status){

                    // data is an object with structure { 'error': bool, 'result': [] }

                    dataArrays = JSON.parse(data.result);
                    console.log(dataArrays);

                    // check what input  is selected from the radio buttons
                    var graphToShow = $("#graphToShow").val();

                    console.log(graphToShow);

                    // change a graph to show based on the user's selection

                    //raw data is selected
                    if(graphToShow === "rawData"){
                        //use the result parameter as data for a new u curve plot
                        Plotly.animate('graphUcurves', {
                            data: [{y: dataArrays.rawData}]
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
                            data: [{x: dataArrays.rawData}]
                        }, {
                            transition: {
                                duration: 500,
                                easing: 'linear'
                            }
                        })
                    }

                    //errorFixed data is selected
                    if(graphToShow === "errorFixed"){
                        //use the result parameter as data for a new u curve plot
                        Plotly.animate('graphUcurves', {
                            data: [{y: dataArrays.errorFixed}]
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
                            data: [{x: dataArrays.errorFixed}]
                        }, {
                            transition: {
                                duration: 500,
                                easing: 'linear'
                            }
                        })
                    }

                    //array reordered data is selected
                    if(graphToShow === "arrayReordered"){
                        //use the result parameter as data for a new u curve plot
                        Plotly.animate('graphUcurves', {
                            data: [{y: dataArrays.arrayReordered}]
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
                            data: [{x: dataArrays.arrayReordered}]
                        }, {
                            transition: {
                                duration: 500,
                                easing: 'linear'
                            }
                        })
                    }


                });


            }, 200);

        }




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


        }, 10);


    });



    //get element with id="stop" , trigger a function once it is clicked
    $("#stop3d").click(function(){


        clearInterval(timer3d)


    });


});


/**____________radio buttons code, used to dynamically insert radio buttons to the document__________**/
// get the ide of the radio buttons div
var radio_home = document.getElementById("radioButtons");
//this functions ads radio buttons when called
function makeRadioButton(options) {
    var div = document.createElement("div");
    for (var i = 0; i < options.length; i++) {
        var label = document.createElement("label");
        var radio = document.createElement("input");
        radio.type = "radio";
        radio.name = "port";
        radio.value = options[i];
        label.appendChild(radio);
        label.appendChild(document.createTextNode( "  " + options[i]));
        div.appendChild(label);

        //if we are on the last iteration there is no need to create another <br>
        if(i+1<options.length)div.appendChild(document.createElement("br"));
    }
    radio_home.appendChild(div);
}

/**____________________testing functions __________________**/
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