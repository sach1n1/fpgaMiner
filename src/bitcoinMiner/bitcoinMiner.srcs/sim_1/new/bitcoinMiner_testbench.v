`timescale 10ns / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Technische Universität Berlin 
// Authors:  Anet Luciya Davis
//           Denis Dominik Zebrowski
//           Manjunatha Narayanappa
//           Sachin S Dominic
//           Zhenbang Liu
//
//
//
// Project Name: FPGA Bitcoin Miner (Advanced Embedded System Project Course)
//
// Semester : Summer Semester 2020
//
// Target Devices: Basys 3 (Only simulation is done. Not tested on hardware)
//
// Dependencies: Offline data of bitcoin blocks stored in block_header.csv
// 
// Simulation is running at around 100MHz Clock Frequency (clk) (Corresponds to 400MHz 
// of Basys 3 board). All performance results are calculated with respect to 
// timescale of 10ns.
//////////////////////////////////////////////////////////////////////////////////

module bitcoinMiner_testbench(); 
 
 reg clock=1'b0;
 wire nonceFound;
 wire [31:0] nonceValue;
 `ifdef simulation
 wire [32:0] numberHashGenerated;
 wire [255:0] finalHash;
 `endif
 wire [31:0] blockHeight = 32'd641438;   //Expected Block height of the blockchain can be set here.


 bitcoinMiner dut(
    .clk(clock),
    `ifdef simulation
    .blockHeight(blockHeight),
    `endif
    .nonceFound(nonceFound),
    `ifdef simulation
    .numberHashGenerated(numberHashGenerated),
    .finalHashBE(finalHash),
    `endif
    .nonceValue(nonceValue)    
     );

 //this process block sets up the free running clock
 
  always@(*)
  begin
    while (nonceFound !== 1'b1)
    begin
        #1 clock = ~clock;
    end
    
    $display("Correct Nonce Value: %h\n",nonceValue);
    
    `ifdef simulation
        $display("Correct Hash Value: %h\n",finalHash);
    `endif
   
    $display("Finish");
    $finish;
  end

endmodule
