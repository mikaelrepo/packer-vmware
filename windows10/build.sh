  #!/usr/bin/env bash
  
  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init .

  ### Start the Build. ### -var-file="../../../secrets.pkrvars.hcl"
  packer build -force -var-file="common.pkrvars.hcl" .
