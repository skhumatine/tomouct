const express = require('express'); //import the express module
const app = express();               //create an instance of the module call it app

const getHandler =  require('./webserver/routes'); //import file to handle all get requests

const PORT = process.env.PORT || 80;


app.use(express.static('public')); //tell server which folder to use to server static files


app.get('*',(req, res)=> getHandler(req, res)); //set app instance to call the get request handler whenever there is a get request


var server = app.listen(PORT, () => {

    var host = server.address().address;
    var port = server.address().port;
    console.log('running at http://' + host + ':' + port)

}); //start the server and listen on port 3000