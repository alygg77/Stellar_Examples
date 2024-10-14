This repo is made for people who are new in Rust and Soroban to demonstrate how to create tokens and add them to liquid pool in Stellar network using soroban
set up .env file and then run deploy.sh
First, you have to download stellar-cli and rust:
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
cargo install --locked stellar-cli --features opt
echo "source <(stellar completion --shell bash)" >> ~/.bashrc
stellar network add \
  --global testnet \
  --rpc-url https://soroban-testnet.stellar.org:443 \
  --network-passphrase "Test SDF Network ; September 2015"
stellar keys generate --global alice --network testnet
stellar keys address alice
```
Or just follow steps from here: https://developers.stellar.org/docs/build/smart-contracts/getting-started/setup
Then 
```
git clone https://github.com/alygg77/Stellar_Examples.git
cd Stellar_Examples
```
Then set up your details in .env, then:
```
sh deploy.sh
```
Note: this is done in a testnet. To be in a mainnet, change the network in the deploy.sh commands
Also, total supply should be entered considered decimals. So if you enter 8 decimal and want 1 integer total supply, then total supply should be 1 * 10^8.
