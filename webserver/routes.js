
const fs = require('fs'); //require filesystem module
const axios = require('axios');

getHandler = function(req, res) {


    //if it's a request
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


    //if
    if(req.path === '/api/index'){

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



};

module.exports = getHandler;