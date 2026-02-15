# Database Module

Deploys an Autonomous Transaction Processing (ATP) database in the Always Free tier.

## Resources
- `oci_database_autonomous_database`: The ATP instance.
- `oci_database_autonomous_database_wallet`: Wallet for database connection.

## Inputs
- `compartment_id`: OCID of the compartment.
- `subnet_id`: OCID of the database subnet.
- `db_name`: Database name.
- `admin_password`: Admin password.

## Outputs
- `atp_id`: Database OCID.
- `atp_connection_strings`: Connection URLs.
- `atp_wallet_content`: Base64 encoded wallet.
