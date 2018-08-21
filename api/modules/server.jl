"""
# module server 

- Julia version: 0.6.4
- Author: skhum
- Date: 2018-08-15

# Examples

```jldoctest
julia>
```
"""



module api  # name of module to handle any requests on julia

#global module imports
using Joseki, JSON, SerialPorts, HTTP

#functions or variables to export from the api module
export capture_frame, get_ports, initialise, Read_sequence_table_file


# req is of type HTTP.Request
#to set type use req::HTTP.Request

#captureframe is a function that is called when one goes to
#'http://localhost:8080/capture-frame', this is set an endpoint in ../index.jl

#captures one frame and returns a sequence of data
function capture_frame(req::HTTP.Request)

#respond with an array as a result, check Joseki API on github
 json_responder(req, rand!(zeros(Int16,256),0:5000))

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
        SerialPort("COM5",baudrate)
    catch
        println("\n\nClosing existing connection")
        close(s)
        error("\n\nCould not open USB port.... aborting script.")
      return error_responder(req, "Could not open USB port try again!")
    end


#upload sequence table
#file with sequence table
    println("\nLoading sequence table from file")
    file_name_sequence_table="testtable.txt"

    #Loading sequence table from file
    hex_string = Read_sequence_table_file(file_name_sequence_table, params["table"])
    println("\n\nhex_string:   ",hex_string)

    println("Uploading sequence table to instrument \n")

   byte_command = Vector{UInt8}("2") #change 2 from string to byte string

   write(s,byte_command)   # Update sequence table

   ack=read(s,1); #acknowledge new sequence table before capturing frame
   println(ack , "Sequence table Acknowledged")

   #change sequence table to byte string
   write(s, Vector{UInt8}(hex_string))
   #write(s, "#")   # End marker
   read(s, 1)  # acknowledge from microntroller
   #junk =read(s, 1)
   #println(junk);
   println("Checking if any junk data is in the input stream (there should be none)")
   junk = readavailable(s)   # Clear out any old data
   println("Number of junk bytes read:",length(junk))
   println("Junk", junk)




# once port is opened and sequence table is uploaded, send a response
    json_responder(req, "Port successfully opened, sequence table successfully uploaded.")
#end of initialise()
end




#=----------------local functions , not exposed as endpoints--------------------=#
#read sequence table function
function Read_sequence_table_file(file_name, sequence_table)

   # This function reads the sequence table from an ascii text file and converts the information into a string containing only the hex characters.
   # AJW & NB 2018-06-20
   # Read sequence table from the ASCII sequence table file
   # Store in one long string s.

   debug=false   # if set to true, then error messages are printed

   if debug
      println("\nReading sequence table text file: ",file_name)
   end



   println("\nOpening ",file_name)
   text= sequence_table
   file = try
    #if file can be oppened get sequence table from it,
     #else, assign table from HTTP.reqest variable
        open(file_name) do f
        text = readstring(f)
        close(f)
        end

        catch err
            println("\nCouldn't open file ",file_name, err)

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


#end of mudule api
end
