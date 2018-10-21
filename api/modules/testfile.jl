#=
testfile:
- Julia version: 0.6.4
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
        SerialPort("/dev/tty.usbmodem1421",9600)
    catch(error)
        println("\n\nClosing existing connection")
        println(error)


       # error("\n\nCould not open USB port.... aborting script.")
      #return error_responder(req, "Could not open USB port try again!")
    end
