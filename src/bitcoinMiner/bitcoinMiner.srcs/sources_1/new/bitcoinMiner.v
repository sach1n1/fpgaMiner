`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technische Universität Berlin 
// Authors:  Anet Luciya Davis
//           Denis Dominik Zebrowski
//           Manjunatha Narayanappa
//           Sachin S Dominic
//           Zhenbang Liu
// 
// Create Date: 05.06.2020 19:15:06 
// Module Name: bitcoinMiner
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




`define test 1
// "test" macro defines whether to take nearest value as starting value of the nonce.
// Generally nonce will be a random number in uint32 range. Iterating through all the
// values from 0 takes lot of time. For testing purposes, we can start from nearest value
// to the expected nonce value
//
// Valid Values:
// test=0, initial value of nonce = 0
// test=1, initial value of nonce = expectedNonce - 32'h100

`define simulation 1
//"simulation" macro defines how header data to be retrieved. Currently bitcoin block chain data 
//is stored offline in a csv file and different blocks can be selected with blockHeight port.
//However, during actual bitcoin Mining this data should be retrieved using UART.(Not implememnted in this project).
//For synthesis, hardcoded values of bitcoin block header are used.
//
//Note: Comment "simulation" macro for synthesis.


`define parallelInstances 1   //Default Value: 1
//"parallelInstances" macro defines number of parallel instances of doubleSHA module, each instance iterating with specific 
// nonce range.
//
//Note: Setting higher values will create more instances and finds correct nonce faster at a expense of hardware resources. 
//Make sure FPGA supports it.
//
//Valid Range: 1, 2, 4, 8... 4294967296 (Should be power of 2). Tested till 64.


`define msgSchFacConfig 5   //Default Value: 5
//"msgSchFacConfig" macro controls the number of instances of message schedulers in SHA256 algorithm.
//
//Valid Range [0 5]
// Value 0: 64 Message Schedule Instances (New Hash will be generated every clock cycle)
// Value 1: 32 Message Schedule Instances (New Hash will be generated every 2 clock cycles)
// Value 2: 16 Message Schedule Instances (New Hash will be generated every 4 clock cycles)
// Value 3: 8 Message Schedule Instances (New Hash will be generated every 8 clock cycles)
// Value 4: 4 Message Schedule Instances (New Hash will be generated every 16 clock cycles)
// Value 5: 2 Message Schedule Instances (New Hash will be generated every 32 clock cycles)   


module bitcoinMiner(
    input clk,
    `ifdef simulation
    input [31:0] blockHeight,
    `endif
    output reg  nonceFound,
    `ifdef simulation
    output reg [32:0] numberHashGenerated,
    output reg [255:0] finalHashBE,
    `endif
    output reg [31:0] nonceValue    
    );
     
    `ifdef  msgSchFacConfig
        parameter MSGSCH = `msgSchFacConfig;
    `else
        parameter MSGSCH = 0;
    `endif
    
    parameter [5:0] MSGSCHITR = (6'd1 << MSGSCH);
    reg msgSchIni = 1'b0;
    reg [5:0] loopCnt = 6'd0;
    
    integer j;  
    wire [31:0] ver;    
    wire [255:0] prevBlockHash;        
	wire [255:0] mrkleRoot;		
	wire [31:0] blockTime;		
	wire [31:0] nBits;
	wire [31:0] expectedNonce;
	wire [255:0] targetBE;
	wire isMsg1;
	
	readBlockHeaderFromCsv r0 (
	    `ifdef simulation
	    .clk(clk),
        .blockHeight(blockHeight),
        `endif
        .verLE(ver),
        .prevBlockHashLE(prevBlockHash),
        .mrkleRootLE(mrkleRoot),
        .blockTimeLE(blockTime),
        .nBitsLE(nBits),
        .expectedNonceBE(expectedNonce),
        .targetBE(targetBE)       
    );
	
		
	wire [607:0] blockHeader = {nBits, blockTime, mrkleRoot, prevBlockHash, ver};
	
	reg [31:0] nonceRange [`parallelInstances-1:0];
	wire [255:0] hash [`parallelInstances-1:0];	
	wire [32:0] range = (33'd4294967296)/`parallelInstances;
	wire [7:0] nonceOffset;
	
	assign nonceOffset = (8'd130 % MSGSCHITR == 0)? (8'd130 >> MSGSCH) : ((8'd130  >> MSGSCH) + 8'd1);
	// Initializing outports and assigning nonceRange values based on number of parallel instances.
	initial begin
	   `ifdef simulation
	       numberHashGenerated <=  33'd0;
       `endif
       
	   nonceValue <= 32'h0;
	   nonceFound <= 1'b0;
	   nonceRange[0] <= 32'h0;	   	     
	   for (j=1; j<`parallelInstances; j=j+1)
	   begin
	       nonceRange[j] <=  (j * range)-32'h1;
	   end
	   
	   if (`test)
        begin
           #100 nonceRange[0] <= expectedNonce - 32'h3000; //If test is enabled, nonceRange[0] will start from the nearest expected value. Should be used only for testing purposes.
        end	   
	end
	  
	
	// Creating parallel instances of Hash Calculation. Each instance with specific Nonce range
	genvar h;	 
	generate
        for (h = 0; h < `parallelInstances; h = h + 1) begin : hashInstance                 
           doubleSHA #(.MSGSCHITR(MSGSCHITR)) SHA(
            .clk(clk),
            .blockHeader(blockHeader),
            .nonceBE(nonceRange[h]),
            .loopCnt(loopCnt),
            .msgSchIni(msgSchIni),
            .hashBE(hash[h]),
            .isMsg1(isMsg1)
            );                
        end
   endgenerate
   
   wire [5:0] loopCntNxt;
   assign loopCntNxt = (MSGSCHITR == 1) ? 6'd0 : (loopCnt + 6'd1) & (MSGSCHITR-1);
   
   wire msgSchIniNxt;
   assign msgSchIniNxt = (MSGSCHITR == 1) ? 1'b0 : (loopCntNxt != 0);
   

     always @ (posedge clk)
     begin
        nonceValue <= nonceRange[0];  //The output ports are assigned with values of hash instance 0.
        msgSchIni <= msgSchIniNxt;
        loopCnt <= loopCntNxt;
        if(!isMsg1 && !msgSchIniNxt)            // Waiting till the hash for msg1 is calculated. This hash is used as state register for msg2.
        begin
            $display("-------------------------------------------------------------------------------------------");
            `ifdef simulation
                finalHashBE <= hash[0];   
            `endif
            
             for(j=0; j<`parallelInstances; j=j+1)
             begin
                $display("\nHash Instnace:%d", j);
                $display("Hash generated:%h", hash[j]);
               
                if ((hash[j] < targetBE))
                begin
                    nonceFound <= 1'b1;
                    `ifdef simulation
                        finalHashBE <= hash[j];
                    `endif
                    nonceValue <= nonceRange[j] - nonceOffset;// - 32'h82;
                    $display("Nonce Found");
                end
                else
                begin                              
                   $display("Incrementing nonce:%h", nonceRange[j]);
                    nonceRange[j] <= nonceRange[j] + 32'h1;                    
                end               
             end
             $display("-------------------------------------------------------------------------------------------\n");
             `ifdef simulation
                  if((^hash[0] !== 1'bX))
                  begin            
                    numberHashGenerated <= numberHashGenerated + 32'd`parallelInstances;
                  end
              `endif
        end
         
    end 
       
endmodule
