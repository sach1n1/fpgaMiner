`timescale 1ns / 1ps
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


// A quick define to help index 32-bit words inside a larger register.
`define IDX(x) (((x)+1)*(32)-1):((x)*(32)) //it turns e.g. a[`IDX(0)] to a[31:0]


module sha256MessageScheduleAndCompression (clk, K, inputBlock,stateReg, outputBlock, outputStateReg);

	input clk;
	input [31:0] K; //K constans, cube root of prime numbers
	input [511:0] inputBlock; //message schedule, W0-W15 are taken from data input 
	input [255:0] stateReg;

	output reg [511:0] outputBlock;
	output reg [255:0] outputStateReg;


	wire [31:0] SIGMA0_W, SIGMA1_W, choice_W, majority_W, sigma0_W, sigma1_W;

	sigma0	sigma0_blk	(inputBlock[63:32], sigma0_W);
	sigma1	sigma1_blk	(inputBlock[479:448], sigma1_W);

	//line below: sigma1(W[t-2])+W[t-7]+sigma0(W[t-15])+W[t-16]
	//this happens from W16 to W63
	wire [31:0] newWord = sigma1_W + inputBlock[319:288] + sigma0_W + inputBlock[31:0];
	
    //Compression part
    //IDX[0-7] represents a-h
    SIGMA0	SIGMA0_blk	(stateReg[`IDX(0)], SIGMA0_W);
	SIGMA1	SIGMA1_blk	(stateReg[`IDX(4)], SIGMA1_W);
	choice	choice_blk	(stateReg[`IDX(4)], stateReg[`IDX(5)], stateReg[`IDX(6)], choice_W);
	majority	majority_blk	(stateReg[`IDX(0)], stateReg[`IDX(1)], stateReg[`IDX(2)], majority_W);

    // T1 = SIGMA(e)+ Ch(e,f,g)+h+K0+W0
	wire [31:0] T1 = stateReg[`IDX(7)] + SIGMA1_W + choice_W + inputBlock[31:0] + K;
	
	//T2= SIGMA0(a)+major(a,b,c)
	wire [31:0] T2 = SIGMA0_W + majority_W;
	
	always @ (posedge clk)
	begin
		outputBlock[511:480] <= newWord;     //new W15 = newWord
		outputBlock[479:0] <= inputBlock[511:32]; //new W1:W14 = old W2:w15
        //state registers a-h. Initially they are declared with values of square roots of prime numbers starting from "2"
        //the fractional part * 2^32

		outputStateReg[`IDX(0)] <= T1 + T2;
		outputStateReg[`IDX(1)] <= stateReg[`IDX(0)];
		outputStateReg[`IDX(2)] <= stateReg[`IDX(1)];
		outputStateReg[`IDX(3)] <= stateReg[`IDX(2)];
		outputStateReg[`IDX(4)] <= stateReg[`IDX(3)] + T1;	
		outputStateReg[`IDX(5)] <= stateReg[`IDX(4)];
		outputStateReg[`IDX(6)] <= stateReg[`IDX(5)];
		outputStateReg[`IDX(7)] <= stateReg[`IDX(6)];
	end

endmodule

