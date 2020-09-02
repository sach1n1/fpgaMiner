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

module doubleSHA #(
    parameter MSGSCHITR = 6'd1
)(
    input clk,
    input [607:0] blockHeader,
    input [31:0] nonceBE,
    input [5:0] loopCnt,
    input msgSchIni,
    output [255:0] hashBE,
    output reg isMsg1
    );
    
    wire [255:0] hash2,hash3, finalHash;
    wire [5:0] cnt0,cnt1;
    reg [255:0] hash1;
    
    wire[31:0] nonceLE;
    changeEndian32 nonce (.x(nonceBE), .y(nonceLE));
    
    wire [1023:0] blockHeaderPadded = {64'h0000028000000000, 288'h000000000000000000000000000000000000000000000000000000000000000000000000,32'h80000000, nonceLE, blockHeader};
    
    wire [511:0] msg2 = blockHeaderPadded[1023:512];
    
    reg [255:0] state = 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
    
    initial begin
        isMsg1 <= 1'b1;
    end

	
   sha256Algorithm #(.MSGSCHITR(MSGSCHITR))  firstSHA(
		.clk(clk),
		.stateReg(isMsg1?state:hash1), //state register for second messge is hash of first message.
		.inputBlock(isMsg1? blockHeaderPadded[511:0]: blockHeaderPadded[1023:512]), //this is our 512bit data after padding. 
		.loopCnt(loopCnt),
		.msgSchIni(msgSchIni),
		.hashOutput(hash2)
	);
	
	always@(posedge clk)
	begin 
	    if((^hash2 !== 1'bX) && isMsg1)  begin
	       isMsg1 <= 1'b0;
	       hash1 <= hash2;
	    end
	end
	

	sha256Algorithm #(.MSGSCHITR(MSGSCHITR))  secondSHA (
		.clk(clk),
		.stateReg(state),
		.inputBlock({256'h0000010000000000000000000000000000000000000000000000000080000000, hash2}),
		.loopCnt(loopCnt),
		.msgSchIni(msgSchIni),
		.hashOutput(hash3)
	);
    
    changeEndian256 hash (.x(hash3), .y(hashBE));
    
    
endmodule
