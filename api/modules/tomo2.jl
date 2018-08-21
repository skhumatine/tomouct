#Tomo.jl
#Julia script to test STM32F4 ERT system
#
# AJW & NP July 2018
# TODO: fix STM bugs! check for new HAL libraries
# In C code:
# #define clearBit(number,bit) ((number)&~(1<<(bit)))
# #define setBit(number,bit) ((number)|(1<<(bit)))
# GPIOD -> ODR = setBit(GPIOD -> ODR, I_ON_OFF);

# Julia: Must read  https://docs.julialang.org/en/latest/manual/style-guide/
#


@time using SerialPorts   # Serial port library (Python-based)

#@time using GR
#plot_type="gr"

@time using PyPlot  #On Windows, don't forget to type ENV["MPLBACKEND"]="qt4agg" before running script.
plot_type="pyplot"

#plot_type="none"


################ Timing Tests for GR vs PyPlot
# RESULT: GR can update plot at 714 fps compared to PyPlot speed of 11.7 per second
#         GR does not need a pause() or sleep() for screen to be updated.
#
#julia> using GR
#julia> @time for n=1:100; plot(randn(100)); sleep(0.00001);end
#  1.341783 seconds (23.20 k allocations: 1.329 MiB, 0.51% gc time)
#julia> @time for n=1:100; plot(randn(100));end
#  0.143278 seconds (22.70 k allocations: 1.311 MiB)
#
# The sleep function is the main delay - even if sleep(0)!!!
#julia> @time for n=1:100; x=(randn(100));sleep(0);end
#  1.348463 seconds (754 allocations: 111.406 KiB)
#
#julia> ENV["MPLBACKEND"]="qt4agg"
#julia> using PyPlot
#julia> @time for n=1:100; plot(randn(100)); sleep(0.00001);clf();end
#  8.569288 seconds (172.17 k allocations: 9.291 MiB)
#
################ End timing tests

function Read_sequence_table_file(file_name)

   # This function reads the sequence table from an ascii text file and converts the information into a string containing only the hex characters.
   # AJW & NB 2018-06-20
   # Read sequence table from the ASCII sequence table file
   # Store in one long string s.

   debug=false   # if set to true, then error messages are printed

   if debug
      println("\nReading sequence table text file: ",file_name)
   end

   file = open(file_name)
   text = readstring(file)
   close(file)

   # Parse string text, extracting the hex bytes and converting them into various formats for transmission to a microcontroller or other usage
   # Currently all data sent to the microntroller is ascii text.
   # Maybe later a binary format could be used.


   N_bytes = length(text)

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

   a = Array{UInt16}(Nsamples) # Create output array

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

function Reorder_to_get_U_curves_old(arr)   # DOES THIS WORK??? CHECK AJW

   #the following double for loop shifts the ADC values around #such that the first ADC value in a block of 16 is the value #sampled nearest to the injection electrode
   #the shift that happens depends on the injection electrode #represented by i
   println("*********************** old ************************")
   Nsamples = length(arr)
   arrTemp = Array{UInt16}(Nsamples) # Create output array

   m=0;

   for i=1:16
      for j=1:16
         index =(i-1)*16+j

         index3= index+(i-1)
         if(j<=(16-i+1))
            m =0;

            arrTemp[index] = arr[index+(i-1)]
         else
            m=m+1;
            index2 = (i-1)*16+m;

            arrTemp[index] = arr[index2]
         end
      end
   end
   k=0;

   return(arrTemp)
end


function Reorder_to_get_U_curves(arr)
   #the following double for loop shifts the ADC values around #such that the first ADC value in a block of 16 is the value #sampled nearest to the injection electrode
   #the shift that happens depends on the injection electrode #represented by i

   Nsamples = length(arr)
   arrTemp = Array{UInt16}(Nsamples) # Create output array

   for i=1:16    # injection number  (injection pairs 0F 10 21 .. FE)
      for ch=1:16   # Amplifier/ADC channel number 1..16
         arrTemp[ Int( (i-1)*16 + ch )] = arr[Int( (i-1)*16 + mod( (ch-1)-(i-1),16) +1 )]
         # This is not how I thought it should be implemented - maybe I'm tired.
      end
   end
   return(arrTemp)
end


function Remove_measurements_involving_injection_electrodes(array)

   #the following double for loop converts a 256-element array #into a 208-element array which represents all the #measurements except the ones that come from the injection #electrodes. The resulting array is still in a u-curve

   Nsamples = length(array)
   Nframes = Nsamples/16

   arrFinal = Array{UInt16}(UInt16(Nframes*(16-3))) # Create output array (size 208)

   for i=1:16
      k=0;
      for j=3:1:15
         k=k+1;
         index = (i-1)*16+j
         index2= [(i-1)*13+k]
         arrFinal[index2]= array[index]
      end
   end
   return(arrFinal)
end

function time_frames()
   # This function was written to time how long it takes to poll the instrument 10 times for a single frame.
   # The commands are deliberately not in a for loop
   # The result is printed

   tic()
   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   write(s, "5#")   # Instruct instrument to capture 1 frame
   p = read(s, 513);  # read frame from VCP port

   time_for_N_frame=toq();

   # Note toq() does not print "elapsed .."
   time_for_a_single_frame = time_for_N_frame/10
   capture_rate=1/time_for_a_single_frame

   println("Average time to capture a single frame (averaged over 10 frames) = $(time_for_a_single_frame) seconds")
   println("Capture rate (averaged over 10 frames) = $(round(capture_rate,0)) fps")
end



#***************************************************************************
# ********************* MAIN CODE STARTS HERE ***************************
#***************************************************************************
println("\n\n \n\n")

println("\n\n******* Starting tomo.jl ******* \n\n")

if plot_type=="pyplot"
   println("\n\nREMINDER: If using PyPlot... Did you remember to type ENV[\"MPLBACKEND\"]=\"qt4agg\" before running script")
end

println("\nOpening virtual com port")
@show list_serialports()   # Display available com ports
comport="COM4:" #Hard code the correct com port to use.
baudrate=9600   #Baudrate parameter is ignored is using a virtual comport.


if isdefined(:s)   # If stream s exists, close it.
   close(s)
end

s = try
      SerialPort(comport,baudrate)  # Open com port and assign handle to s.
   catch
      error("\n\nCould not open USB port.... aborting script.")
   end

println("Clearing any old junk data in the input stream")
junk = readavailable(s)   # Clear out any old data
println("Number of junk bytes read:",length(junk))

println("\nDo you wish to upload sequence table to micro? (y/n)")
upload_table_y_n = readline();

if (upload_table_y_n=="y" || upload_table_y_n=="Y")

   println("\nLoading sequence table from file")
   file_name_sequence_table="testtable.txt"
   hex_string = Read_sequence_table_file(file_name_sequence_table)
   println("\n\nhex_string:   ",hex_string)

   println("Uploading sequence table to instrument")
   write(s, "2#")   # Update sequence table
   ack=read(s,1); #acknowledge new sequence table before capturing frame
   println(ack)
   write(s, hex_string*"#")
   #write(s, "#")   # End marker
   read(s, 1)  # acknowledge from microntroller
   #junk =read(s, 1)
   #println(junk);
   println("Checking if any junk data is in the input stream (there should be none)")
   junk = readavailable(s)   # Clear out any old data
   println("Number of junk bytes read:",length(junk))
   println(junk)

end


########### ENTER NUMBER OF FRAMES HERE ###########
println("\nEnter number of frames to capture: ")
N_frames = try
   parse(Int, readline());
catch
   10   # Default is 10
end

println("N_frames = ",N_frames)

Nsamples = 16*16  # Specify number (=16*16)of samples in a frame
N_samples_reduced = 16*(16-3)   # 208 = reduced number after discarding those involving injection electrodes

# Define arrays and variables (so that they are still visible outside the for loop at the REPL command line)
array_ADC_samples=Array{UInt16}(Nsamples)
array_fixed=Array{UInt16}(Nsamples)
array256_Ucurves=Array{UInt16}(Nsamples)
array208_Ucurves=Array{UInt16}(N_samples_reduced)
speed_info = 0
time_to_capture_1_frame = 0

# Define arrays to store entire dataset
store_array256_Ucurves=zeros(UInt16, N_frames, Nsamples)
store_array208_Ucurves=zeros(UInt16, N_frames, N_samples_reduced)


# These arrays are used to calculate mean and standard deviation statistics
Sum_X_squared = zeros(N_samples_reduced)
Sum_X = zeros(N_samples_reduced)




n=1   # Frame counter in loop
update_rate_ave = 0


if plot_type=="gr"
   figure(size=(1200,800))   # Create a wide window for plot
end
if plot_type=="pyplot"  #Don't forget to type ENV["MPLBACKEND"]="qt4agg" before running script.
   #ENV["MPLBACKEND"]="qt4agg"
   ##close("all")
   figure(1,figsize=(12,8))   # 12 inches by 5 inches
end

############# TIMING TEST
#println("\n\n Doing a quick timing test to see how long it takes to poll the instrument for one frame (averaged over 10 frames):")
#time_frames()
#time_frames()
#println("\n\n Test complete")
####################


t0 = time()  # Start timer

dbg=true   # Set to true if you want to display debug messages at the standard output (REPL)

while(n<=N_frames)

   #   sleep(0.01)  # slow it down

   if dbg
      println(); println("Frame n=",n)
      println("Sending command to capture one fame and then reading exactly 513 bytes")
   end

   tic()  # start timer
   sleep(1)
   write(s, "5#") # Send command to capture one frame
   ack=read(s, 1); # Read ack from microcontroller
   if dbg println(ack); println("capturing frame)") end
   received_frame_string = read(s, 513);  # read frame from VCP port (513 bytes inc "#" marker)

   if dbg println("received frame)") end

   time_to_capture_1_frame=toq();     # Note toq() does not print "elapsed .." at the REPL

   capture_rate=1/time_to_capture_1_frame
   if dbg
      println("time_to_capture_1_frame: $time_to_capture_1_frame seconds")
      println("Checking if any junk data is in the input stream (there should be none)")
   end
   junk = readavailable(s)  # read any other characters (there should be none)
   if dbg println("Number of junk bytes read:",length(junk)) end

   if dbg println("Processing retrieved data frame") end

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

   array208_Ucurves = Remove_measurements_involving_injection_electrodes(array256_Ucurves)

   # println("length(arr) ",length(arr))
   # println("length(array256_Ucurves) ",length(array256_Ucurves))
   # println("length(array_fixed) ",length(array_fixed))
   # println("length(array208_Ucurves) ",length(array208_Ucurves))
   # println("typeof(array256_Ucurves)",typeof(array256_Ucurves))

   #array_to_plot = array_fixed


   #  title("Raw ADC data");


   #Create a string for adding to the plot
   speed_info = ("N=$(n)   Screen updates: $(round(update_rate_ave,0)) fps    Capture rate (1 frame): $(round(capture_rate,0)) fps")

   number_of_injections_to_plot = 16   # Can reduce to 1 to plot just 1 U-curve
   xrange=1:16*number_of_injections_to_plot

   if dbg println("Updating plots") end

   if plot_type=="gr"
      if false      subplot(4,1,1)
         plot(xrange,array_ADC_samples[xrange],ylim=(0,4095),".-",ylabel="arr raw")
         subplot(4,1,2)
         plot(xrange,array_fixed[xrange],ylim=(0,4095),".-",ylabel="array fixed")
         subplot(4,1,3)
         plot(xrange,array256_Ucurves[xrange],ylim=(0,4095),".-",ylabel="array256U")
         subplot(4,1,4)
      end
      xrange=1:(16-3)*number_of_injections_to_plot
      plot(xrange,array208_Ucurves[xrange],ylim=(0,4095),".-",ylabel="array208U",xlabel=speed_info)
   end

   if plot_type=="pyplot"
      clf()
      ymax = 4095
      subplot(4,1,1)
      plot(xrange,array_ADC_samples[xrange],".-"); ylim([0,ymax]); ylabel("arr raw")
      subplot(4,1,2)
      plot(xrange,array_fixed[xrange],".-"); ylim([0,ymax]); ylabel("arr fixed")
      subplot(4,1,3)
      plot(xrange,array256_Ucurves[xrange],".-"); ylim([0,ymax]); ylabel("array256U")
      subplot(4,1,4)
      xrange=1:(16-3)*number_of_injections_to_plot
      plot(xrange,array208_Ucurves[xrange],".-"); ylim([0,ymax]); ylabel("array208U"); xlabel(speed_info)

      sleep(0.0001)   # Must put in a pause to force screep update on PyPlot (not needed for GR)
   end


   # Store results for later  (UInt16, N_frames, Nsamples)
   store_array256_Ucurves[n,:]=array256_Ucurves
   store_array208_Ucurves[n,:]=array208_Ucurves

   # On the fly stats running totals
   Sum_X_squared = Sum_X_squared + Float64.(array208_Ucurves).^2;
   Sum_X = Sum_X + Float64.(array208_Ucurves);

   time_total=time()-t0
   update_rate_ave=1/(time_total/n)


   #   end

   n=n+1
end

println("\n\ntime_to_capture_1_frame: $time_to_capture_1_frame seconds")
println("\n\n",speed_info)

time_total=time()-t0
update_rate_ave=1/(time_total/n)

println("\n\nFrame rate (averaged) = $(update_rate_ave) fps")

# Save figure as a png file into current directory  (currently only works properly on subplots for Pyplot not GR)
if plot_type=="pyplot"
   savefig("output_plots.png")
end


# Do statistics
println("\n\n Calculating mean and standard deviation and plotting them")
E_X = Sum_X/N_frames;
E_X_squared = Sum_X_squared/N_frames;
Std_X = sqrt.(E_X_squared - E_X.^2);


if plot_type=="pyplot"  #Don't forget to type ENV["MPLBACKEND"]="qt4agg" before running script.
   figure(2,figsize=(12,4))   # 12 inches by 5 inches
   clf()
   subplot(2,1,1)
   ylabel("Average of $(N_frames) frames"); plot(E_X,".-");
   subplot(2,1,2)
   ylabel("Standard Deviation"); plot(Std_X,".-");
   savefig("output_statistics.png")

   figure(3,figsize=(12,4))   # 12 inches by 5 inches
   clf()
   title("Samples over time from the 1st U-curve")
   ylabel("ADC value 0-4095")
   plot(store_array208_Ucurves[:,1:13])
   #mesh(store_array208_Ucurves)
   savefig("output_samples_from_1st_U-curve.png")

   figure(4)
   clf()
   title("Histogram of 1st sample in 1st U-curve")
   xlabel("ADC value 0-4095")
   nbins=20
   PyPlot.plt[:hist](store_array208_Ucurves[:,1],nbins)
   savefig("output_histogram_samples_from_1st_sample_from_1st_U-curve.png")

end

if plot_type=="gr"  #Don't forget to type ENV["MPLBACKEND"]="qt4agg" before running script.
   sleep(2)  # pause for a sec because GR currently wipes over old plot. Does not give multiple figures
   figure(size=(1200,400))   # Create a wide window for plot
   subplot(2,1,1)
   ylabel("Average of $(N_frames) frames"); plot(E_X,".-");
   subplot(2,1,2)
   ylabel("Standard Deviation"); plot(Std_X,".-");

   sleep(2)
   figure(size=(1200,400))   # Create a wide window for plot
   plot(store_array208_Ucurves[:,1:16])
end





println("\n\nClosing USB Virtual Com Port")
close(s)  # Close serial port
