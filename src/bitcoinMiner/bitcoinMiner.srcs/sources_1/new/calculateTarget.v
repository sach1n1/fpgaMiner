`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technische Universität Berlin
// 
// Authors:  Anet Luciya Davis
//           Denis Dominik Zebrowski
//           Manjunatha Narayanappa
//           Sachin S Dominic
//           Zhenbang Liu
// 
// Create Date: 05.06.2020 19:15:06 
// Module Name: calculateTarget
//
// Project Name: FPGA Bitcoin Miner (Advanced Embedded System Project Course)
//
// Semester : Summer Semester 2020
//
// Target Devices: Basys 3
//
// Dependencies: Offline data of bitcoin blocks stored in block_header.csv
// 
// Simulation is running at around 100MHz Clock Frequency (clk) (Corresponds to 400MHz 
// of Basys 3 board). All performance results are calculated with respect to 
// timescale of 10ns.
// optLevel defines the number of parallel Hash Instance with specific nonce range.
//
//////////////////////////////////////////////////////////////////////////////////

module calculateTarget(
    input [31:0] nBitsBE,
    output [255:0] targetBE
    );
    
    assign targetBE = nBitsBE[23:0] * 2**((nBitsBE[31:24] -3)<<3);
endmodule

