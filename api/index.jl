#!/usr/bin/julia

#=
example:
- Julia version: 0.6.4
- Author: skhumbuzo Matine
- Date: 2018-08-15
=#


#if OS is linux
#give permission to script via $chmod a+x index.jl, inside tomouct folder
#to run this file from terminal $./index.jl

#global module imports
using Joseki, JSON

#local file imports
#import modules from server.jl file in modules folder
include(joinpath("modules", "server.jl"))

### Create and run the server

# create endpoints to be assigned to router
#endpoints are functions associated with a specific request
#api is a module defined in server.jl,
endpoints = [
    (api.capture_frame, "GET", "/capture-frame"), #capture_frame is a function defined inside the api module
    (api.get_ports, "GET", "/get-ports"),   # get_ports function defined inside the api module
    (api.initialise, "GET", "/initialise")   # initialise function is defined inside the api module

]

#add/assign endpoints to the server
s = Joseki.server(endpoints)

# Fire up the server
HTTP.serve(s, ip"127.0.0.1", 8080; verbose=false)



