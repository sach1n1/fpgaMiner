# FPGA Bitcoin Miner
## Applied Embedded System Project
### Summer Semester 2020, TU Berlin

### Contributors


- **Anet Luciya Davis**
- **Denis Dominik Zebrowski**
- **Manjunatha Narayanappa**
- **Sachin Shibu Dominic**
- **Zhenbang Liu**

### Project description

This is an academic project in Advanced Embedded Systems.

### How to use

Possible configurations in *bitcoinMiner.v*:
```
`define test 1
```
 "test" macro defines whether to take nearest value as starting value of the nonce.
Generally nonce will be a random number in uint32 range. Iterating through all the
values from 0 takes lot of time. For testing purposes, we can start from nearest value
to the expected nonce value.  
Valid Values:
- test=0, initial value of nonce = 0
- test=1, initial value of nonce = expectedNonce - 32'h100

```
`define simulation 1
```
"simulation" macro defines how header data to be retrieved. Currently bitcoin block chain data 
is stored offline in a csv file and different blocks can be selected with blockHeight port.
However, during actual bitcoin Mining this data should be retrieved using UART.(Not implememnted in this project).
For synthesis, hardcoded values of bitcoin block header are used.  
**Note:** Comment "simulation" macro for synthesis.  
**Note:** Imported data is stored under *blockHeaderData.csv*. Path to the folder with the file: *..\fpgaMiner\src\bitcoinMiner\bitcoinMiner.srcs*  
Each row in *.csv* file holds the contents of a block header which can be downloaded for each newly mined bitcoin from websites like btc.com.  
One row consists of: *blockHeight; blockVersion; previousBlockHash; merkleRoot; blockTime; nBits; expectedNonce*  
[Example block 641438](https://btc.com/000000000000000000076cc3afafd6f54d6cd76ccfa251bdf2f28924a40d69d5).  
**Note:** This example is the last row in attached *.csv* file.

```
`define parallelInstances 1
```
"parallelInstances" macro defines number of parallel instances of doubleSHA module, each instance iterating with specific nonce range.  
**Note:** Setting higher values will create more instances and finds correct nonce faster at a expense of hardware resources. Make sure FPGA supports it.  
Valid Range: 1, 2, 4, 8... 4294967296 (Should be power of 2). Tested till 64.
```
`define msgSchFacConfig 5 
```
"msgSchFacConfig" macro controls the number of instances of message schedulers in SHA256 algorithm.

Valid Range [0 5]:
- Value 0: 64 Message Schedule Instances (New Hash will be generated every clock cycle)
- Value 1: 32 Message Schedule Instances (New Hash will be generated every 2 clock cycles)
- Value 2: 16 Message Schedule Instances (New Hash will be generated every 4 clock cycles)
- Value 3: 8 Message Schedule Instances (New Hash will be generated every 8 clock cycles)
- Value 4: 4 Message Schedule Instances (New Hash will be generated every 16 clock cycles)
- Value 5: 2 Message Schedule Instances (New Hash will be generated every 32 clock cycles)

### Performance

Refer to the *Performance* section under the **Final Presentation** section and to **Final report** in our **Wiki**: part 3.

### How it works

Refer to the respective sections under the **Final Presentation** section and to **Final report** in our **Wiki**: part 1 & part 2.