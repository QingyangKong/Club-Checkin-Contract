# deployemnt process
# run the script to generate abi and bin
# deploy log contract
# deploy clubs and players contract with address with addr of log contract
# write addrs of these 3 contracts to config of app
# update abi and bin in compiledContract.js

count=`ls -1 ./erc20/*.abi 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    rm ./erc20/*.abi;
fi

count=`ls -1 ./erc20/*.bin 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    rm ./erc20/*.bin;
fi
~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./erc20/ClubToken.sol --abi --bin -o ./erc20/ --optimize

count=`ls -1 *.abi 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    rm *.abi;
fi

count=`ls -1 *.bin 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    rm *.bin;
fi

rm ./clubClubs/*
~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./ClubCheckInClubs.sol --abi --bin -o ./clubClubs/ --optimize 

rm ./clubUser/*
~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./ClubCheckInPlayer.sol --abi --bin -o ./clubUser/ --optimize 

rm ./clubLog/*
~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./ClubCheckInLog.sol --abi --bin -o ./clubLog/ --optimize 

rm ./clubProxy/*
~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./Proxy.sol --abi --bin -o ./clubProxy/ --optimize 
#~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./controlContract/ClubCheckInControl.sol --abi --bin -o ./controlContract/ --optimize 
#~/Downloads/solc/solc24/solidity-ubuntu-trusty\ \(1\)/solc ./erc20Contract/ClubToken.sol --abi --bin -o ./erc20Contract/ --optimize 
