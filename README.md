# FPGACounter
This was my final project for an embedded systems course at FIU. 

The main code can be found in `SevSegCounter.vhd`. 

The constraints file is appropriately labeled. 


Several issues were presented during the development of this FPGA application. They will be cataloged here in the order in which they were encountered. In the initial stages of the project, I developed a simple BCD 7-segment display counter of a single digit. At this point, when pressing a button to increment or decrement, the value would jump several places ahead. I determined this was due to switch bouncing. The buttons were debounced using a very simple sampling technique utilizing a cascading flip-flop circuit. At each rising edge of the clock, the input was sampled. Only after two successful sequential logic-level high inputs and a third logic-level low input, will the actual be processed and used in the counter logic.


The next issue was encountered when attempting to display two seven segment displays at once. The PModSSD uses the same control signals for both displays, and uses a ‘digit-select’ pin which determines which digit will be controlled at any given time. My first attempt was naive, and attempted to switch the digit-select signal at the rising edge of each clock cycle. After running  this code on the FPGA board, although both digits were lit, several segments were either dimly lit or not lit at all. I reasoned that this must be due to the clock signal being too fast for the PModSSD and there was not enough time to provide sufficient power to light the individual segments. Thus, I limited the digit-select switching to a fraction of each clock cycle. The refresh rate was determined experimentally.


The final major roadblock in the design was digit conversion. The counter signal in the VHDL code is stored as an unsigned binary number, making conversion to binary and hexadecimal quite easy. I needed to determine a way to use the binary coded signal and convert to a decimal value. This was solved by converting the unsigned binary std_logic_vector to an integer, performing modulo math and converting to a 4-bit unsigned binary std_logic_vector.


There are several key areas that could be improved upon in a more in-depth project. For example, the process which translates the binary values of the counter to decimal uses a very simple algorithm that only functions for a 2-digit decimal number. For each additional decimal digit, a new line of code and a new signal would be necessitated, growing the program size and memory space by O(n). If the seven segment display had more than two digits available, a different, more robust method would be needed, like the double-dabble algorithm. The use of a more well-defined algorithm would result in a single block of code that could process an arbitrary length decimal digit.


This project could very easily be converted to an automatic counter. A switch or toggle button could be used to begin a loop that will increment the counter variable. This would lend itself very well to creating a stopwatch or timer display. The program could also find applications in an industrial setting, where a control signal could be incremented and decremented at will and displayed on a seven segment display.

