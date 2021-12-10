# cairo-ipfs

**TL;DR:** Commit to CIDs of IPFS DAG objects with a verified structure using Starknet

## Description

Cairo-ipfs is a StarkNet contract which stores the IPFS CID of a DAG-CBOR object, and allows the user to continuously update the stored object such that a backlink to the previous state is preserved. This means that the stored CID is guaranteed to address an object, `root`, of the form:

```dag-json
{
   "prev"  : CID(XXXXXXXXXXXXXXXX),
   "state" : CID(XXXXXXXXXXXXXXXX)
}
```

After 2 updates, the structure, if we expand the links, can be visualised as:
```
          root2 --> []
                    /\
                   /  \
                  /    \
       root1 --> []  state2
                 /\
                /  \
               /    \
 root0 --> [state0] state1
 ```
Where at all times only the the root is stored.

The stored root can always be turned into a valid cid, with codec: dag-cbor, and hash: keccak-256 

In future, the structure and other properties of the `state` object linked to by `root` can also be validated.

## Dependencies
You'll need ipfs installed, and a [nile](https://github.com/OpenZeppelin/nile) environment running (checkout the [getting started](https://github.com/OpenZeppelin/nile#getting-started) instructions)
## How to use
Step 1: In the root directory, run the following to compile the cairo contracts
```console
$ nile compile
```
Step 2: Put initial state on IPFS
```console
$ ipfs dag put --hash keccak-256 initial_state.json
bafyrwigbexamue2ba3hmtai7hwlcmd6ekiqsduyf5avv7oz6ln3radvjde
```
Step 3: Translate CID to felts (representing the keccak hash) 
```console
$ cid2input bafyrwigbexamue2ba3hmtai7hwlcmd6ekiqsduyf5avv7oz6ln3radvjde
14845624774935193025 14127552982796960201 6857829969316356434 1849024585897033403
```
Step 4: Run your devnet node
```console
$ nile node
```
Step 5: Deploy the keccak contract, then copy the deployed address and deploy the IPFS_updateable contract accordingly (note: actual addresses will differ)
```console
$ nile deploy keccak_contract --alias keccak
🚀 Deploying keccak_contract
🌕 artifacts/keccak_contract.json successfully deployed to 0x068a62ac303b1bf393602734ececa8a2aeb4f3d08db43f553f951b65952b5f35
📦 Registering deployment as keccak in localhost.deployments.txt
```
```console
$ nile deploy IPFS_updateable --alias IPFS 0x068a62ac303b1bf393602734ececa8a2aeb4f3d08db43f553f951b65952b5f
35 14845624774935193025 14127552982796960201 6857829969316356434 1849024585897033403
```
Step 6: Put new state on IPFS and get felts
```console
$ ipfs dag put --hash keccak-256 new_state.json
bafyrwiem4rrwrdgvgmntooopkyweifa4epcyxalov7vl22wqn4ghox7d6e
$ cid2input bafyrwiem4rrwrdgvgmntooopkyweifa4epcyxalov7vl22wqn4ghox7d6e
1960145061859812492 2023317089821866295 13684943306873357603 17429879947768352874
```
Step 7: Put updated root on IPFS
```json
# updated_root.json
{
   "prev" : {"/" : "bafyrwigbexamue2ba3hmtai7hwlcmd6ekiqsduyf5avv7oz6ln3radvjde"},
   "state" : {"/" : "bafyrwiem4rrwrdgvgmntooopkyweifa4epcyxalov7vl22wqn4ghox7d6e"}
}
```
```console
$ ipfs dag put --hash keccak-256 updated_root.json
bafyrwigw43iwbywkfehc3fwevpo6uxz4t2foaq36unzcxnxxia6xrrxxsq
```
Step 8: Call update_root with new state
```console
$ nile call IPFS update_root 1960145061859812492 2023317089821866295 13684943306873357603 17429879947768352
0xe29cae260d1e6d6 0x3c5feaddabc4962d 0x2b72a37e43e08a9e 0x94f7c6783d40f7b6
```

Step 9: Verify stored CID!
```console
$ output2cid 0xe29cae260d1e6d6 0x3c5feaddabc4962d 0x2b72a37e43e08a9e 0x94f7c6783d40f7b6
bafyrwigw43iwbywkfehc3fwevpo6uxz4t2foaq36unzcxnxxia6xrrxxsq
$ ipfs dag get bafyrwigw43iwbywkfehc3fwevpo6uxz4t2foaq36unzcxnxxia6xrrxxsq/prev
{"hello":"world"}
$ ipfs dag get bafyrwigw43iwbywkfehc3fwevpo6uxz4t2foaq36unzcxnxxia6xrrxxsq/state
{"world":"hello"}
```




