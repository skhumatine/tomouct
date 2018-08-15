//find div with id graph, plot a graph in it
Plotly.plot('graph', [{
    line: {simplify: false},

}],  layout= {
    title: 'u curves',
    xaxis: {
        title: 'Readings',
        range: [0,256]
    },
    yaxis: {
        title: 'Values',
        range: [0,5000]
    }
});

//once the page has loaded , invoke the callback function
$(document).ready(function(){


    //get element with id="start" , trigger a function once it is clicked
    $("#start").click(function(){


       timerId = setInterval(function(){

           //send get request to local server , on response trigger the callback function
           $.get("http://localhost:8080/", function(data, status){

               // data is an object with structure { 'error': bool, 'result': [] }

               //use the result parameter as data for a new plot
               Plotly.animate('graph', {
                   data: [{y: data.result}]
               }, {
                   transition: {
                       duration: 0,
                   },
                   frame: {
                       duration: 0,
                       redraw:false
                   }
               })
           });


       }, 100);


    });


    //get element with id="stop" , trigger a function once it is clicked
    $("#stop").click(function(){


        clearInterval(timerId)


    })




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
// }