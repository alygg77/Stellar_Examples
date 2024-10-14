#!/bin/bash

cd token || { echo "Failed to enter 'token' directory"; exit 1; }
make || { echo "Make failed"; exit 1; }

add_env_var() {
    local key="$1"
    local value="$2"
    local file="$3"

    # Trim any trailing spaces and newlines from the value
    value="$(printf '%s' "$value" | sed 's/[[:space:]]*$//')"

    # Ensure the file exists
    touch "$file"

    # Check if the file is not empty and does not end with a newline
    if [ -s "$file" ] && [ "$(tail -c1 "$file")" != "" ]; then
        # Add a newline to the end of the file
        echo >> "$file"
    fi

    # Append the variable to the file
    echo "${key}=${value}" >> "$file"
}


load_env() {
  set -o allexport
  source ../.env
  set +o allexport
}
env_file="../.env"
# Load environment variables

#TOKEN A CONTRACT DEPLOYMENT
load_env
if grep -q "^TOKEN_A_CONTRACT_ID=" "../.env"; then
  echo "Contract has already been deployed. Skipping deployment..."
else
  deploy_output=$(stellar contract deploy --wasm target/wasm32-unknown-unknown/release/soroban_token_contract.wasm --source alice --network testnet)
  contract_id=$(echo "$deploy_output" | grep -Eo '\b[A-Z0-9]{56}\b' | head -1)
  if [ -z "$contract_id" ]; then
    echo "Error: Failed to extract Contract ID."
    exit 1
  fi
  echo "Extracted Contract ID: $contract_id"
  add_env_var "TOKEN_A_CONTRACT_ID" "$contract_id" "$env_file"
  echo "Contract ID saved to $env_file"
fi

#TOKEN A DEPLOYMENT
load_env
if grep -q "^TOKEN_A_DEPLOYED=1" "../.env"; then
  echo "Token has already been created. Skipping token creation..."
else

  # Ensure all necessary environment variables are set
  : "${TOKEN_A_CONTRACT_ID:?Need to set TOKEN_A_CONTRACT_ID in .env}"
  : "${PRIVATE_KEY_1:?Need to set PRIVATE_KEY_1 in .env}"
  : "${PUBLIC_KEY_1:?Need to set PUBLIC_KEY_1 in .env}"
  : "${TOKEN_A_DECIMALS:?Need to set TOKEN_A_DECIMALS in .env}"
  : "${TOKEN_A_NAME:?Need to set TOKEN_A_NAME in .env}"
  : "${TOKEN_A_TICKER:?Need to set TOKEN_A_TICKER in .env}"

  # Run the stellar contract invoke command using the variables from the .env file
  invoke_output=$(stellar contract invoke --id "$TOKEN_A_CONTRACT_ID" \
    --source-account "$PRIVATE_KEY_1" \
    --network testnet \
    -- initialize \
    --admin "$PUBLIC_KEY_1" \
    --decimal "$TOKEN_A_DECIMALS" \
    --name "$TOKEN_A_NAME" \
    --symbol "$TOKEN_A_TICKER")

  # Print the response from the invoke command
  echo "Stellar contract invoke command response:"
  echo "$invoke_output"
  echo "Stellar contract invoke command executed successfully."
  add_env_var "TOKEN_A_DEPLOYED" "1" "$env_file"
  echo "Stellar contract invoke command executed successfully."
fi

#TOKEN A MINTING
load_env
if grep -q "^TOKEN_A_MINTED=1" "../.env"; then
  echo "Token A has already been minted. Skipping minting..."
else
  : "${TOKEN_A_SUPPLY:?Need to set TOKEN_A_SUPPLY in .env}"

  # Run the stellar contract invoke command to mint the token
  mint_output=$(stellar contract invoke --id "$TOKEN_A_CONTRACT_ID" \
    --source-account "$PRIVATE_KEY_1" \
    --network testnet \
    -- mint \
    --to "$PUBLIC_KEY_1" \
    --amount "$TOKEN_A_SUPPLY")

  add_env_var "TOKEN_A_MINTED" "1" "$env_file"

  # Notify that minting was executed
  echo "Token A minted successfully."
fi






#TOKEN B CONTRACT DEPLOYMENT
load_env
if grep -q "^TOKEN_B_CONTRACT_ID=" "../.env"; then
  echo "Contract B has already been deployed. Skipping deployment..."
else
  deploy_output=$(stellar contract deploy --wasm target/wasm32-unknown-unknown/release/soroban_token_contract.wasm --source alice --network testnet)
  contract_id=$(echo "$deploy_output" | grep -Eo '\b[A-Z0-9]{56}\b' | head -1)
  if [ -z "$contract_id" ]; then
    echo "Error: Failed to extract Contract ID."
    exit 1
  fi
  echo "Extracted Contract ID: $contract_id"
  add_env_var "TOKEN_B_CONTRACT_ID" "$contract_id" "$env_file"
  echo "Contract ID saved to $env_file"
fi

#TOKEN B DEPLOYMENT
load_env
if grep -q "^TOKEN_B_DEPLOYED=1" "../.env"; then
  echo "Token B has already been created. Skipping token creation..."
else

  # Ensure all necessary environment variables are set
  : "${TOKEN_B_CONTRACT_ID:?Need to set TOKEN_B_CONTRACT_ID in .env}"
  : "${PRIVATE_KEY_2:?Need to set PRIVATE_KEY_2 in .env}"
  : "${PUBLIC_KEY_2:?Need to set PUBLIC_KEY_2 in .env}"
  : "${TOKEN_B_DECIMALS:?Need to set TOKEN_B_DECIMALS in .env}"
  : "${TOKEN_B_NAME:?Need to set TOKEN_B_NAME in .env}"
  : "${TOKEN_B_TICKER:?Need to set TOKEN_B_TICKER in .env}"

  # Run the stellar contract invoke command using the variables from the .env file
  invoke_output=$(stellar contract invoke --id "$TOKEN_B_CONTRACT_ID" \
    --source-account "$PRIVATE_KEY_2" \
    --network testnet \
    -- initialize \
    --admin "$PUBLIC_KEY_2" \
    --decimal "$TOKEN_B_DECIMALS" \
    --name "$TOKEN_B_NAME" \
    --symbol "$TOKEN_B_TICKER")

  # Print the response from the invoke command
  echo "Stellar contract invoke command response:"
  echo "$invoke_output"
  echo "Stellar contract invoke command executed successfully."
  add_env_var "TOKEN_B_DEPLOYED" "1" "$env_file"
  echo "Stellar contract invoke command executed successfully."
fi

#TOKEN B MINTING
load_env
if grep -q "^TOKEN_B_MINTED=1" "../.env"; then
  echo "Token B has already been minted. Skipping minting..."
else
  : "${TOKEN_B_SUPPLY:?Need to set TOKEN_B_SUPPLY in .env}"

  # Run the stellar contract invoke command to mint the token
  mint_output=$(stellar contract invoke --id "$TOKEN_B_CONTRACT_ID" \
    --source-account "$PRIVATE_KEY_2" \
    --network testnet \
    -- mint \
    --to "$PUBLIC_KEY_1" \
    --amount "$TOKEN_B_SUPPLY")

  add_env_var "TOKEN_B_MINTED" "1" "$env_file"
  # Notify that minting was executed
  echo "Token B minted successfully."
fi




load_env
cd ..
cd liquidity_pool
make
stellar contract install --wasm target/wasm32-unknown-unknown/release/soroban_liquidity_pool_contract.wasm --source alice --network testnet
####LP DEPLOYMENT
if grep -q "^LP_DEPLOYED=1" "$env_file"; then
  echo "Liquidity pool has already been deployed. Skipping deployment..."
else
  deploy_output=$(stellar contract deploy --wasm target/wasm32-unknown-unknown/release/soroban_liquidity_pool_contract.wasm --source alice --network testnet)
  lp_contract_id=$(echo "$deploy_output" | grep -Eo '\b[A-Z0-9]{56}\b' | head -1)

  # Ensure the LP contract ID was extracted
  if [ -z "$lp_contract_id" ]; then
    echo "Error: Failed to extract LP Contract ID."
    exit 1
  fi

  echo "Extracted LP Contract ID: $lp_contract_id"
  add_env_var "LP_CONTRACT_ID" "$lp_contract_id" "$env_file"
  add_env_var "LP_DEPLOYED" "1" "$env_file"
  echo "Marked liquidity pool as deployed."
fi

load_env


#INIT LP
if grep -q "^LP_INIT=1" "$env_file"; then
  echo "Liquidity pool has already been initialized. Skipping initialization..."
else
  # Load environment variables
  load_env
# Ensure all necessary environment variables are set
  : "${LP_CONTRACT_ID:?Need to set LP_CONTRACT_ID in .env}"
  : "${PRIVATE_KEY_1:?Need to set PRIVATE_KEY_1 in .env}"
  : "${TOKEN_WASM_HASH:?Need to set TOKEN_WASM_HASH in .env}"
  : "${TOKEN_A_CONTRACT_ID:?Need to set TOKEN_A_CONTRACT_ID in .env}"
  : "${TOKEN_B_CONTRACT_ID:?Need to set TOKEN_B_CONTRACT_ID in .env}"
  # Initialize the liquidity pool
  # shellcheck disable=SC2034
  lp_output=$(stellar contract invoke --id "$LP_CONTRACT_ID" \
  --source-account "$PRIVATE_KEY_1" \
  --network testnet \
  -- initialize \
  --token_wasm_hash "$TOKEN_WASM_HASH" \
  --token_a "$TOKEN_A_CONTRACT_ID" \
  --token_b "$TOKEN_B_CONTRACT_ID" || { echo "LP initialization failed"; exit 1; })

  echo lp_output

  echo "Liquidity pool initialized successfully."

  # Mark LP as initialized by adding LP_INIT=1 to the .env file
  add_env_var "LP_INIT" "1" "$env_file"
fi

load_env
##ADD LIQUIDITY TO LP
if grep -q "^LP_ADDED_LIQ=1" "$env_file"; then
  echo "Liquidity has already been added to the pool. Skipping liquidity addition..."
else
  # Load environment variables
  load_env

    # Ensure all necessary environment variables are set
    : "${LP_CONTRACT_ID:?Need to set LP_CONTRACT_ID in .env}"
    : "${PRIVATE_KEY_1:?Need to set PRIVATE_KEY_1 in .env}"
    : "${PUBLIC_KEY_1:?Need to set PUBLIC_KEY_1 in .env}"
    : "${TOKEN_A_LP_SUPPLY:?Need to set TOKEN_A_LP_SUPPLY in .env}"
    : "${TOKEN_B_LP_SUPPLY:?Need to set TOKEN_B_LP_SUPPLY in .env}"
  # Add liquidity to the pool
  lp_add=$(stellar contract invoke --id "$LP_CONTRACT_ID" \
    --source-account "$PRIVATE_KEY_1" \
    --network testnet \
    -- deposit \
    --to "$PUBLIC_KEY_1" \
    --desired_a "$TOKEN_A_LP_SUPPLY" \
    --min_a "$TOKEN_A_LP_SUPPLY" \
    --desired_b "$TOKEN_B_LP_SUPPLY" \
    --min_b "$TOKEN_B_LP_SUPPLY"|| { echo "Adding liquidity failed"; exit 1; })
  echo "Liquidity added successfully to the liquidity pool."

  # Mark liquidity as added by adding LP_ADDED_LIQ=1 to the .env file
  add_env_var "LP_ADDED_LIQ" "1" "$env_file"
  echo "Marked liquidity as added."
fi