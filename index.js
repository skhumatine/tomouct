const express = require('express'); //import the express module
const app = express();               //create an instance of the module call it app

const getHandler =  require('./webserver/routes'); //import file to handle all get requests

app.use(express.static('public')); //tell server which folder to use to server static files


app.get('*',(req, res)=> getHandler(req, res)); //set app instance to call the get request handler whenever there is a get request


app.listen(80, () => console.log('Tomo web-server listening @port 80')); //start the server an listen on port 3000