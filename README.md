# cairo-ipfs

**TL;DR:** Commit to CIDs of IPFS DAG objects with a verified structure using Starknet

## Description

Cairo-ipfs is a StarkNet contract which stores the IPFS CID of a DAG-CBOR object, and allows the user to continuously update the stored object such that a backlink to the previous state is preserved. This means that the stored CID is guaranteed to address an object, `root`, of the form:

```json
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

In future, the structure, and other properties, of the `state` object addressed by the `root` can also be validated.

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
Step 4: Deploy the keccak contract, then copy the deployed address and deploy the IPFS_updateable contract accordingly (note: actual addresses will differ)
```console
$ nile deploy keccak_contract --alias keccak
🚀 Deploying keccak_contract
🌕 artifacts/keccak_contract.json successfully deployed to 0x068a62ac303b1bf393602734ececa8a2aeb4f3d08db43f553f951b65952b5f35
📦 Registering deployment as keccak in localhost.deployments.txt
```
```console
nile deploy IPFS_updateable --alias IPFS 0x068a62ac303b1bf393602734ececa8a2aeb4f3d08db43f553f951b65952b5f
35 14845624774935193025 14127552982796960201 6857829969316356434 1849024585897033403
🚀 Deploying IPFS_updateable
🌕 artifacts/IPFS_updateable.json successfully deployed to 0x0329648c43fa96252c6665884620d5cba194a887f2f762994b506a4bb76c941a
📦 Registering deployment as IPFS in localhost.deployments.txt
```




