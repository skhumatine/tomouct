#!/usr/bin/julia

#if OS is linux
#give permission to script via $chmod a+x index.jl, inside tomouct folder
#to run this file from terminal $./index.jl

#import server modules from server file in src folder
include("./src/server.jl")


println(server.p);
println(server.p);
