"""
# module server 

- Julia version: 1.0
- Author: skhum
- Date: 2018-08-15

# Examples

```jldoctest
julia>
```
"""





module api  # name of module to handle any requests on julia

#global module imports
using Joseki, JSON, SerialPorts, HTTP, Printf

#functions or variables to export from the api module
export capture_frame, get_ports, initialise

# req is of type HTTP.Request
#to set type use req::HTTP.Request

#captureframe is a function that is called when one goes to
#'http://localhost:8080/capture-frame', this is set an endpoint in ../index.jl

#captures one frame and returns a sequence of data
function capture_frame(req::HTTP.Request)


 # Open com port and assign handle to s.
    s = try
        SerialPort("/dev/tty.usbmodem1411",9600)

    catch(error)

        println("\n\nerror opening port ", "/dev/tty.usbmodem1421", error)


       # error("\n\nCould not open USB port.... aborting script.")
      return error_responder(req, "Could not open USB port try again!")
    end

println("\n success opening port, information about port ", "/dev/tty.usbmodem1421 \n ")


#set variables and arrays
N_frames = 1 #can only cupture one frame since a web socket is closed after any HTTP response

println("N_frames = ", N_frames)

Nsamples = 16*16  # Specify number (=16*16)of samples in a frame
N_samples_reduced = 16*(16-3)   # 208 = reduced number after discarding those involving injection electrodes
array_ADC_samples=Array{UInt16}(undef,Nsamples)
array_fixed=Array{UInt16}(undef,Nsamples)
array256_Ucurves=Array{UInt16}(undef,Nsamples)
array208_Ucurves=Array{UInt16}(undef,N_samples_reduced)

#begin fetching data from micro
    sleep(1)

   write(s,"5#" )   ## Send command to capture one frame
   ack=read(s, 1); # Read ack from microcontroller
   println(ack, "-Capturing frame " );

    received_frame_string = try
        read(s, 513);  # read frame from Virtual ComPort  (513 bytes inc "#" marker)
        #readavailable(s)

        catch error
            println("error reading ", error)
            error("\nCouldn't read from stream  \n ", error)
        end

   println(" \n received frame ")



   r = Vector{UInt8}(received_frame_string)   # Convert string to UInt8 bytes
  for i=1:Nsamples
      array_ADC_samples[i]=r[2*i]*256 + r[2*i-1]#Convert to UInt16 ADC samples
   end


   # Currently, Bill's pcb V1 maps connects the STM pins to wrong order.
   # It is in the same order as the connector on the Discovery, which is not ADC0..15.
   # Thus we can fix this in software (done currently), or I can rewire the ribbon cable.
   array_fixed = Rearrange_to_fix_PCB_wiring_error(array_ADC_samples);  # Use software fix for PCB wiring error.
   #array_fixed = arr;  # TEMP
   array256_Ucurves = Reorder_to_get_U_curves(array_fixed)

    # create dictionary/object to send back to user
    data = Dict("rawData" => array_ADC_samples, "errorFixed" => array_fixed, "arrayReordered" => array256_Ucurves)
   #  convert data to json
     data_json = JSON.json(data)

    close(s)
    #respond with an array as a result, check Joseki API on github
    json_responder(req, data_json)

#end of captureframe()
 end

#get_ports is a function that is called when one goes to
#'http://localhost:8080/get-ports', this is set as an endpoint in ../index.jl
 #function that returns the available comports when called
 get_ports(req::HTTP.Request) = json_responder(req, list_serialports())


#initialise is a function that is called when one goes to
#'http://localhost:8080/initialise', this is set as an endpoint in ../index.jl
#function that opens a comport and uploads sequence table
function initialise(req::HTTP.Request)


    #get query parameters sent along with the request
    params = HTTP.queryparams(HTTP.URI(req.target))

    #if port is not specified return an error with error message
    if !(haskey(params, "port"))
        return error_responder(req, "No port specified!")
    end

    #if port parameter is specified, open the com port with given port

    #set comport along with baudrate variables
    comport = params["port"]
    baudrate = 9600


    # Open com port and assign handle to s.
    s = try
        SerialPort(comport,baudrate)

    catch(error)

        println("\n\nerror opening port ", comport, error)


       # error("\n\nCould not open USB port.... aborting script.")
      return error_responder(req, "Could not open USB port try again!")
    end

println("\n success opening port, information about port ", comport, "\n ", s)

println("\n Clearing any old junk data in the input stream")
junk = readavailable(s)   # Clear out any old data
println("\n Number of junk bytes read: ",length(junk))


#upload sequence table
#file with sequence table
    println("\nLoading sequence table from file")
    file_name_sequence_table="testtable.txt"

    #Loading sequence table from file, table is another parameter which comes with the request
    #hex_string = Read_sequence_table_file(file_name_sequence_table, params["table"]) this line is for when a user can provide the text tablefrom the request parameter

    hex_string = Read_sequence_table_file(file_name_sequence_table)
    println("\n\nhex_string:   ", hex_string)

    println("\n Uploading sequence table to instrument \n")

   byte_command = Vector{UInt8}("2#") #change 2 from string to byte string

    println("\nbyte command ", "2#")

   write(s,"2#")   # Update sequence table

   ack=readavailable(s); #acknowledge new sequence table before capturing frame
   println(ack , " -Sequence table Acknowledged")

   #change sequence table to byte string
   write(s, hex_string*"#")

   #write(s, "#")   # End marker
   read(s, 1)  # acknowledge from microntroller
   #junk =read(s, 1)
   #println(junk);
   println("\nChecking if any junk data is in the input stream (there should be none)")
   junk = readavailable(s)   # Clear out any old data
   println("Number of junk bytes read: ",length(junk))
   println("Junk ", junk)



# once port is opened and sequence table is uploaded, send a response
    json_responder(req, "Serial port was successfully opened, sequence table was successfully uploaded")
#end of initialise()
end




#=----------------local functions , not exposed as endpoints--------------------=#
#read sequence table function
function Read_sequence_table_file(file_name)

   # This function reads the sequence table from an ascii text file and converts the information into a string containing only the hex characters.
   # AJW & NB 2018-06-20
   # Read sequence table from the ASCII sequence table file
   # Store in one long string s.

   debug=false   # if set to true, then error messages are printed

   if debug
      println("\nReading sequence table text file: ",file_name)
   end



   println("\nOpening ",file_name)

   #text is the sequence of bytes, it can also be provided by the user.
   text= "I1V1:  db #\$00,#\$0F,#\$00,#\$00,#\$10,#\$00,#\$00,#\$21,#\$00,#\$00,
   #\$32,#\$00,#\$00,#\$43,#\$00,#\$00,#\$54,#\$00,#\$00,#\$65,#\$00,#\$00,#\$76,#\$00,#\$00,#\$87,
   #\$00,#\$00,#\$98,#\$00,#\$00,#\$A9,#\$00,#\$00,#\$BA,#\$00,#\$00,#\$CB,#\$00,#\$00,#\$DC,#\$00,#\$00,#\$ED,#\$00,#\$00,#\$FE,#\$00"

   file = try
    #if file can be oppened get sequence table from it,
     #else, assign table raw text provided above(ideally should be from the user using the browser)
        open(file_name) do f
        text = readstring(f)
        close(f)
        end

        catch err
            println("\nCouldn't open file ", file_name," Will use raw text instead\n ", err)

            #error("\nCouldn't open file ", file_name," \n ", err)


        end


   # Parse string text, extracting the hex bytes and converting them into various formats for transmission to a microcontroller or other usage
   # Currently all data sent to the microntroller is ascii text.
   # Maybe later a binary format could be used.


   N_bytes = length(text)
   #will supply text as it is


   if debug
      println("Text file contains ",N_bytes," ASCII characters")
      println("Extracting binary bytes from the hex data")
      println("Displaying: \$HEX DEC CHAR\n\n")
   end

   # hex_string is a string containing only the sequence of hex characters.
   # result_UInt8  = array of UInt8 bytes hopefully in the format for the write command (may be used in the future, but currently the Julia serial port library can only transmit ASCII strings properly; binary not functional)
   # result_bytes_in_string_format = string of ascii bytes in the format for the write command

   n = 1  # Loop counter

   result_bytes_in_string_format = ""
   result_hex_string = ""
   result_UInt8 = UInt8[]

   byte_string_format =""
   while n<=N_bytes
      if text[n]=='$'
         hex_text = text[n+1:n+2]   #Extract two hex characters
         result_hex_string = result_hex_string*hex_text # Append to hex_string

         # Convert hex_text to UInt8 for other purposes
         byte_array = hex2bytes(hex_text)
         byte = byte_array[1]
         byte_UInt8 = UInt8(byte)
         push!(result_UInt8,byte_UInt8)# Apend to array of UInt8

         # Convert to a single character in string format
         byte_string_format = @sprintf("%c",byte)
         result_bytes_in_string_format = result_bytes_in_string_format * byte_string_format  # Append character to the string

         if debug
            print("\$",hex_text)
            print(" ",byte," ")
            print(" ",byte_UInt8," ")
            #print(@sprintf("%c",byte))
            print(byte_string_format)
            print(",  ")
         end

         n=n+3   # Increment by 3 to next position in text_string
      else
         n=n+1   #
      end
   end


   if debug
      println("\n\nExtracted ",length(result_bytes_in_string_format)," bytes to write to the microcontroller")
      println("\n\nExtracted ",length(result_hex_string)," hex characters (nibbles) to write to the microcontroller")
      println("\n\nhex_string:   ",result_hex_string)
   end

   return result_hex_string   # Currently only the hex string is returned

   #end of read sequence table function
end

function Rearrange_to_fix_PCB_wiring_error(array)

   #Function to fix incorrect order of ADC lines on Bill's PCB Version 1.
   # Alternatively, I could put a solder type DB25 onto the ribbon cable and re-order there.
   #
   # Currently, the wiring is as follows:
   #    Amp chan: 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16
   #     STM reg: C0 C1 C2 C3 A0 A1 A2 A2 A4 A5 A6 A7 C4 C5 B0 B1
   # STM ADC num: 10 11 12 13 0  1  2  3  4  5  6  7  14 15 8  9
   #
   # Note: this function has been carefully checked and does the right thing.

   Nsamples = length(array)
   Ninjections = Int(Nsamples/16)   # There are 16 channels
   #println(Ninjections)

   a = Array{UInt16}(undef,Nsamples) # Create output array

   for n=0:Ninjections-1

      offset=Int(n*16)

      PA0 = array[1+offset]   #ADC0
      PA1 = array[2+offset]   #ADC1
      PA2 = array[3+offset]   #ADC2
      PA3 = array[4+offset]   #ADC3
      PA4 = array[5+offset]   #ADC4
      PA5 = array[6+offset]   #ADC5
      PA6 = array[7+offset]   #ADC6
      PA7 = array[8+offset]   #ADC7
      PB0 = array[9+offset]   #ADC8
      PB1 = array[10+offset]   #ADC9
      PC0 = array[11+offset]   #ADC10
      PC1 = array[12+offset]   #ADC11
      PC2 = array[13+offset]   #ADC12
      PC3 = array[14+offset]   #ADC13
      PC4 = array[15+offset]   #ADC14
      PC5 = array[16+offset]   #ADC15

      a[1+offset] = PC0
      a[2+offset] = PC1
      a[3+offset] = PC2
      a[4+offset] = PC3
      a[5+offset] = PA0
      a[6+offset] = PA1
      a[7+offset] = PA2
      a[8+offset] = PA3
      a[9+offset] = PA4
      a[10+offset] = PA5
      a[11+offset] = PA6
      a[12+offset] = PA7
      a[13+offset] = PC4
      a[14+offset] = PC5
      a[15+offset] = PB0
      a[16+offset] = PB1
   end
   return a
end


function Reorder_to_get_U_curves(arr)
   #the following double for loop shifts the ADC values around #such that the first ADC value in a block of 16 is the value #sampled nearest to the injection electrode
   #the shift that happens depends on the injection electrode #represented by i

   Nsamples = length(arr)
   arrTemp = Array{UInt16}(undef,Nsamples) # Create output array

   for i=1:16    # injection number  (injection pairs 0F 10 21 .. FE)
      for ch=1:16   # Amplifier/ADC channel number 1..16
         arrTemp[ Int( (i-1)*16 + ch )] = arr[Int( (i-1)*16 + mod( (ch-1)-(i-1),16) +1 )]
         # This is not how I thought it should be implemented - maybe I'm tired.
      end
   end
   return(arrTemp)
end



#end of mudule api
end
