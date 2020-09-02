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
// Module Name: changeBigToLittleEndian
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


`define IDX(x) (((x)+1)*(32)-1):((x)*(32)) 

module changeEndian32(x, y);
    input [31:0] x;
    output [31:0] y;
    
    assign y = {x[7:0], x[15:8], x[23:16], x[31:24]};
endmodule

module changeEndian256(x,y);
    input [255:0] x;
    output [255:0] y;
    
    changeEndian32 e0 (.x(x[`IDX(0)]), .y(y[`IDX(0)]));
    changeEndian32 e1 (.x(x[`IDX(1)]), .y(y[`IDX(1)]));
    changeEndian32 e2 (.x(x[`IDX(2)]), .y(y[`IDX(2)]));
    changeEndian32 e3 (.x(x[`IDX(3)]), .y(y[`IDX(3)]));
    changeEndian32 e4 (.x(x[`IDX(4)]), .y(y[`IDX(4)]));
    changeEndian32 e5 (.x(x[`IDX(5)]), .y(y[`IDX(5)]));
    changeEndian32 e6 (.x(x[`IDX(6)]), .y(y[`IDX(6)]));
    changeEndian32 e7 (.x(x[`IDX(7)]), .y(y[`IDX(7)]));
 
endmodule
    
