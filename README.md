# VerilogPong
EC311 Fall 2015 Final Project - David, Artem, and Jessica

Pong was made completely in behavioral Verilog to program the following device:

Family: Spartan6 
Device: XC6SLX16
Package: CSG324

The hierarchy of the modules is as follows:

vga_display.v //Container that holds all of the state machines and calls all of the other modules. 
  -vga_controller_640_60.v  //Driver to control outputting onto the VGA Display
  
  -bin_to_4_led.v //Converts binary score to Seven Segment LED Display        (declares the two modules below aside from itself)
    -bin_to_bcd   //converts from binary to BCD
    -dec_to_led   //converts decimal digit to Seven Segment LED Display
  
  -vga_display.ucf //Maps inputs and outputs to the FPGA components
