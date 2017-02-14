## Image store

This is local image store. This directory structure is same as in remote (S3 bucket). Image path has following
convention: `<env>/images/<type>-<play>-<version>`.

## Infrastructure state stroe

Infrascructure state is stored per each environment with following formats: `<env>/terraform.tfstate` for terraform state
and `<env>/inventory.ini` for ansible inventory.

## Data backups

All data backups are stored in compresed archive in following format:
`<env>/backups/<datetime>-<identifier:db|elasticsnapshot|etc>-<play>.tar.gz`.
