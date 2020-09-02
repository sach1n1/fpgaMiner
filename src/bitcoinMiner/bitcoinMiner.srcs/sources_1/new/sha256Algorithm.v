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
`define IDX(x) (((x)+1)*(32)-1):((x)*(32)) //hash[`IDX(0)] = hash[31:0]

module sha256Algorithm #(
    parameter MSGSCHITR = 6'd1
)(
	input clk,
	input [255:0] stateReg, //stores state registers a-h called by the index IDX
	input [511:0] inputBlock, //input block for hash algorithm. Should be exactly 512 bits
	input [5:0] loopCnt,
	input msgSchIni,
	output reg [255:0] hashOutput //hash for input block
);
    // Constants defined by the SHA-2 standard.
	//our K constants, cubic roots of first 64 prime numbers in hex
	localparam cubeRootK = {
		32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
		32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
		32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
		32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
		32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
		32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
		32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
		32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
		32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
		32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
		32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
		32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
		32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
		32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
		32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
		32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};
		
        
        genvar i; //loop variable for generation of instances of digesters
        
        
        generate
        for (i = 0; i < 64/MSGSCHITR; i = i + 1) begin : messageScheduleThread 
		//Using the parameter, the code creates a generate statement which instantiates as many messageScheduleThread as are specified in loop.
			wire [511:0] intermediateBlock; //
			wire [255:0] intermediateState;

			if(i == 0)
				sha256MessageScheduleAndCompression U (
					.clk(clk),
					.K(cubeRootK[32*(63 - loopCnt) +: 32]),
					.inputBlock(msgSchIni ? intermediateBlock : inputBlock),
					.stateReg(msgSchIni ? intermediateState : stateReg),
					.outputBlock(intermediateBlock),
					.outputStateReg(intermediateState)
				);
			else
				sha256MessageScheduleAndCompression U (
					.clk(clk),
					.K(cubeRootK[32*(63 -(MSGSCHITR*i) -loopCnt) +: 32]),
					.inputBlock(msgSchIni ? intermediateBlock : messageScheduleThread[i-1].intermediateBlock),
					.stateReg(msgSchIni ? intermediateState : messageScheduleThread[i-1].intermediateState),
					.outputBlock(intermediateBlock),
					.outputStateReg(intermediateState)
				);
		end
	endgenerate
	
	

//start of sequential logic process of final addition of state registers after 64 iterations
//H0+H63 addition of state registers: a= a[W0]+a[W64], then b, then c, and so on 
	always @ (posedge clk)
	begin
	       if(!msgSchIni)
           begin
               hashOutput[`IDX(0)] <= stateReg[`IDX(0)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(0)];
               hashOutput[`IDX(1)] <= stateReg[`IDX(1)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(1)];
               hashOutput[`IDX(2)] <= stateReg[`IDX(2)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(2)];
               hashOutput[`IDX(3)] <= stateReg[`IDX(3)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(3)];
               hashOutput[`IDX(4)] <= stateReg[`IDX(4)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(4)];
               hashOutput[`IDX(5)] <= stateReg[`IDX(5)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(5)];
               hashOutput[`IDX(6)] <= stateReg[`IDX(6)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(6)];
               hashOutput[`IDX(7)] <= stateReg[`IDX(7)] + messageScheduleThread[64/MSGSCHITR-6'd1].intermediateState[`IDX(7)];	      
                
           end     	   
	   
   end
endmodule



