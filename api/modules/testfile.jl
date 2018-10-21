#=
testfile:
- Julia version: 1.0
- Author: skhum
- Date: 2018-08-21
=#


using SerialPorts   #import Serial Ports Module

#=
serial port can be COM5 like in Skhum Matine's PC
or "/dev/ttyACM0" like on the pi
=#


@show list_serialports()  #display avilable com ports

s = try
        SerialPort("/dev/tty.usbmodem1411",9600)
    catch(error)
        println("\n\nClosing existing connection")
        println(error)


       # error("\n\nCould not open USB port.... aborting script.")
      #return error_responder(req, "Could not open USB port try again!")
    end


byte_command = Vector{UInt8}("5") #change 5 from string to byte string

    println("\nbyte command ", byte_command)

   write(s,byte_command )   ## Send command to capture one frame

#p = read(s, 513)

junk = readavailable(s)   # Clear out any old data
   println("Number of junk bytes read: ",length(junk))
   println("Junk ", junk)
