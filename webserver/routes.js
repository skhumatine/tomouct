
const fs = require('fs'); //require filesystem module
const axios = require('axios');

getHandler = function(req, res) {


    //if the a request to the server is localhost:80/, run this code
    if(req.path === '/'){
        fs.readFile(__dirname + './../public/index.html', function(err, data) { //read file index.html in public folder
            if (err) {
                res.writeHead(404, {'Content-Type': 'text/html'}); //display 404 on error
                return res.end("404 Not Found");
            }
            res.writeHead(200, {'Content-Type': 'text/html'}); //write HTML
            res.write(data); //write data from index.html
            return res.end();
        });

    }


    //if the request to the server is localhost:80/api/capture-frame, run this code
    if(req.path === '/api/capture-frame'){

        axios.get('http://localhost:8080/capture-frame')
            .then(function (response) {
                // handle success

                //send the response with data from the request
                res.send(response.data)
            }).catch((error)=>{

                //log error
                console.log(error);

                res.writeHead(404, {'Content-Type': 'text/html'}); //display 404 on error
                return res.end("404 Not Found");
            })
    }

    //if the request to the server is localhost:80/api/get-ports, run this code
    if(req.path === '/api/get-ports'){

        axios.get('http://localhost:8080/get-ports')
            .then(function (response) {
                // handle success

                //send the response with data from the request
                res.send(response.data)
            }).catch((error)=>{

            //log error
            console.log(error);

            res.writeHead(404, {'Content-Type': 'text/html'}); //display 404 on error
            return res.end("404 Not Found");
        })
    }

    //if the request to the server is localhost:80/api/initialise?port="PORT_NAME", run this code
    if(req.path === '/api/initialise'){

        console.log('request port on initialise ',  req.query.port);

        //if there is a quesry parameter port run this code, if not return error
        if(req.query.port){

            axios.get('http://localhost:8080/initialise?port=' +req.query.port)
                .then(function (response) {
                    // handle success

                    //send the response with data from the request
                    res.send(response.data)

                }).catch((error)=>{

                //log error
                console.log(error);

                res.writeHead(404, {'Content-Type': 'text/html'}); //display 404 on error
                return res.end("404 Not Found");
            })

        }else{
            //log error
            console.log("No port provided on initialise....");

            res.writeHead(404, {'Content-Type': 'text/html'}); //display 404 on error
            return res.end("404 Not Found");

        }

    }



};

module.exports = getHandler;