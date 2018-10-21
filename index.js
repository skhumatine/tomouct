const express = require('express'); //import the express module
const app = express();               //create an instance of the module call it app

const getHandler =  require('./webserver/routes'); //import file to handle all get requests

const PORT = process.env.PORT || 80; // this checks if a port is provided in the OS env variable,
                                    // if none is provided it assigns the server port to be 80


app.use(express.static('public')); //tell server which folder to use to server static files


app.get('*',(req, res)=> getHandler(req, res)); //set app instance to call the get request handler whenever there is a get request

//the code below here starts the server and displays the host address and port number on the terminal
var server = app.listen(PORT, () => {

    var host = server.address().address;
    var port = server.address().port;
    console.log('running at http://' + host + ':' + port)

}); //start the server and listen on the provided PORT viriable