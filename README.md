# cairo-ipfs
TL;DR: Commit to CIDs of IPFS DAG objects with verified structure using Starknet

Update contract root with the keccak hash of DAG-CBOR object with links `state',`prev', where `prev` is the root of the contract at the time of calling and `state` is the IPFS CID of the new state

root can always be turned into a valid cid w/ mc: dag-cbor, mh: keccak-256 256 root
```json
   {
       "prev": {"/": "<CIDv1><DAG-CBOR><Keccak-256><256><HASH>"},
       "state" : {"/": "<CIDv1><DAG-CBOR><Keccak-256><256><HASH>"}
   }
```
(In future `state` can be arbitrary CID within size limit)
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
