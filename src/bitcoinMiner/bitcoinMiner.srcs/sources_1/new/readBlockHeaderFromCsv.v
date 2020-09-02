`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2020 15:48:25
// Design Name: 
// Module Name: readBlockHeaderFromCsv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define MAX_STRING_LENGTH 70

module readBlockHeaderFromCsv(
    `ifdef simulation
    input clk,
    input [31:0] blockHeight,
    `endif
    output [31:0] verLE,
    output [255:0] prevBlockHashLE,
    output [255:0] mrkleRootLE,
    output [31:0] blockTimeLE,
    output [31:0] nBitsLE,
    output [31:0] expectedNonceBE,
    output [255:0] targetBE  
    );
    
    wire [31:0] verBE = 32'h20c00000;
    wire [255:0] prevBlockHashBE = 256'h0000000000000000000972c0f1c3c990c128d517c781cb26d3fe7cb0c8c4c5a9;
    wire [255:0] mrkleRootBE = 256'h273c9bb633f9bd0c7cd57b78e0be80b97b875d220bff00acb17f5700cdd23eb8;
    wire [31:0] blockTimeBE = 32'h5efd70ca;
    wire [31:0] nBitsBE = 32'h1711d519;
    wire [255:0] target;
    
    assign expectedNonceBE = 32'h3615091c;

    
    `ifdef simulation
        reg[`MAX_STRING_LENGTH*8:1] inFilePath;
        wire [31:0] blockHeightRead=32'h0;
        integer inFile0; //file descriptors
        wire [255:0] blockHash, targetValue;
    `endif
    
    initial begin
        `ifdef simulation
            inFilePath = "../../../../bitcoinMiner.srcs/blockHeaderData.csv";           
            inFile0=$fopen(inFilePath,"r"); 
            
            $display("Reading from file");
            
            while ((! $feof(inFile0)) && (blockHeightRead != blockHeight)) begin //read until an "end of file" is reached.    
                $fscanf(inFile0,"%d,%h,%h,%h,%h,%h,%h,%h,%h\n",blockHeightRead,blockHash,verBE,prevBlockHashBE,blockTimeBE, nBitsBE, mrkleRootBE,expectedNonceBE, target);
                $display("BlockHeight:%d\n", blockHeightRead);
                if(blockHeightRead == blockHeight)
                begin
                        //Write the read value into text files.
                    $display("ver=%h\n",verBE); //write as hexadecimal
                    $display("prevBlockHash=%h\n",prevBlockHashBE); //write as hexadecimal
                    $display("mrkleRoot=%h\n",mrkleRootBE); //write as hexadecimal
                    $display("blockTime=%h\n",blockTimeBE); //write as hexadecimal
                    $display("nBits=%h\n",nBitsBE); //write as hexadecimal
                    $display("nonce=%h\n",expectedNonceBE); //write as hexadecimal
                    
                end
                
        
            end 
                //once reading and writing is finished, close all the files.
            $fclose(inFile0);                 
        `endif

    end
    
     
    changeEndian32 u0(.x(verBE), .y(verLE));
    changeEndian256 u1(.x(prevBlockHashBE), .y(prevBlockHashLE));
    changeEndian32 u2(.x(blockTimeBE), .y(blockTimeLE));
    changeEndian32 u3(.x(nBitsBE), .y(nBitsLE));
    changeEndian256 u4(.x(mrkleRootBE), .y(mrkleRootLE));
    calculateTarget t1 (.nBitsBE(nBitsBE), .targetBE(targetBE));
    
    
endmodule
