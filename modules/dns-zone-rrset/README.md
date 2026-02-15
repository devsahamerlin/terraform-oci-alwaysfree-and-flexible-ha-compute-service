# DNS RRSet Module

Manages DNS Resource Record Sets (e.g., A records).

## Resources
- `oci_dns_rrset`: The DNS record set.

## Inputs
- `domain_name`: FQDN.
- `rtype`: Record type (A, CNAME, etc.).
- `zone_name_or_id`: Target zone.
- `public_ip`: IP address for A records.

## Outputs
- `rrset_id`: OCID of the record set.
