#!/usr/bin/julia

#=
example:
- Julia version: 0.6.4
- Author: skhum
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
endpoints = [
    #api is a module defined in server.jl,
    #index is a fucntion defined inside the api module
    (api.index, "GET", "/")


]

#add/assign endpoints to the server
s = Joseki.server(endpoints)

# Fire up the server
HTTP.serve(s, ip"127.0.0.1", 80; verbose=false)



