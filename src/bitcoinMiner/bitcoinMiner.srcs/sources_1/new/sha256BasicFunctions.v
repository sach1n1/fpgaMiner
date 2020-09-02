`timescale 1ns/1ps
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


//SIGMA0= ROTR_2(x) XOR ROTR_13(x) XOR ROTR_22(x)
module SIGMA0 (x, y);

	input [31:0] x;
	output [31:0] y;

	assign y = {x[1:0],x[31:2]} ^ {x[12:0],x[31:13]} ^ {x[21:0],x[31:22]};

endmodule

//SIGMA1= ROTR_6(x) XOR ROTR_11(x) XOR ROTR_25(x)
module SIGMA1 (x, y);

	input [31:0] x;
	output [31:0] y;

	assign y = {x[5:0],x[31:6]} ^ {x[10:0],x[31:11]} ^ {x[24:0],x[31:25]};

endmodule

//choice- first input(x) is used to determine whether to use second(y) or third input(z)
//1 in x takes y, 0 in x takes z
module choice (x, y, z, o);

	input [31:0] x, y, z;
	output [31:0] o;

	assign o = z ^ (x & (y ^ z));

endmodule
//majority of three bits of three inputs: x,y,z
//if more 0's then take 0, if 1's then take 1
module majority (x, y, z, o);

	input [31:0] x, y, z;
	output [31:0] o;

	assign o = (x & y) | (z & (x | y));

endmodule

//sigma0 function. ROTR_7(x) XOR ROTR_18(x) XOR SHR_3(x)
module sigma0 (x, y);

	input [31:0] x;
	output [31:0] y;

	assign y[31:29] = x[6:4] ^ x[17:15]; 
	assign y[28:0] = {x[3:0], x[31:7]} ^ {x[14:0],x[31:18]} ^ x[31:3];

endmodule

//sigma1 function. ROTR_17(x) XOR ROTR_19(x) XOR SHR_1(x)
module sigma1 (x, y);

	input [31:0] x;
	output [31:0] y;

	assign y[31:22] = x[16:7] ^ x[18:9];
	assign y[21:0] = {x[6:0],x[31:17]} ^ {x[8:0],x[31:19]} ^ x[31:10];

endmodule
