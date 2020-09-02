from src import bitcoinBlockchainExplorer

rangeFrom = 641435
rangeTo = 641439

for blockHeight in range(rangeFrom, rangeTo):
    bitcoinBlockchainExplorer.GetBlock(blockHeight)
