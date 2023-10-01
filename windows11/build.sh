  #!/usr/bin/env bash
  
  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init .

  ### Start the Build. Change this path to your secrets vars.
  packer build -force -var-file="common.pkrvars.hcl" .
