# What is Packer?

Packer is a free tool developed by HashiCorp. It is used to automate and create machine images for different operating systems.

- Create your own library of images or templates, automatically updated with the latest security patches, any Windows features or roles you need or any other custom configuration you want in the base image.
- Automatically generate new builds in a continuous delivery model ready for provisioning.
- Packer has builders and plugins for many different sources. [Packer plugins | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/plugins)
- Reuse the code for a certain Windows OS, for example code for Windows10 20H2 imaging can be used to create an image for 21H2 with minimal changes.

# Let’s get started!

Download and install [Packer by HashiCorp](https://developer.hashicorp.com/packer/downloads) and a Windows iso from Microsoft. You need an autounattend.xml file to modify Windows settings in your images for the OS installation. You can generate your own autounattend.xml file with [Windows System Image Manager (SIM)](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/windows-system-image-manager-overview-topics). Point the utility to the install.wim and you are ready to create the autounattend.xml file.

Check out the official documentation and tutorials here -> [Packer | HashiCorp Developer](https://developer.hashicorp.com/packer).

- variables.pkr.hcl — Declares variables and optionally set default values.
- windows.auto.pkrvars.hcl — Defines the variables you declared in variables.pkr.hcl. The auto in the file lets Packer know this file should automatically be included in the build run.
- windows.pkr.hcl — the Packer build file.
- common.pkrvars.hcl — Common variables defined for all images.
- data/autounattend.pkrtpl.hcl — Answer file to modify Windows settings in theimage during setup.
- scripts/windows/ — Custom powershell scripts.

Run the packer command where all files are located …

- packer init . — Downloads required plugins for running the build(s).
- packer validate . — Validates the syntax and configuration.
- packer build -force -var-file=”common.pkrvars.hcl” — Run the build(s).

# Declaring variables

Variables must be declared in the variables.pkr.hcl file… [Input and Local Variables guide | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/guides/hcl/variables#defining-variables-and-locals).

    variable "vsphere_password" {
      type        = string // Other examples are number, bool, list(string).
      default     = "mypassword" // Optional or define later in windows.auto.pkrvars.hcl.
      description = "The password for the login to the vCenter Server instance."
      sensitive   = true // Use sensitive variables for secrets or keys to hide them from output.
    }

# Defining variables

Common variables are defined in common.pkrvars.hcl.

    // Virtual Machine Settings
    common_vm_version           = 19
    common_tools_upgrade_policy = true
    common_remove_cdrom         = true

    // Template and Content Library Settings
    common_template_conversion         = false
    common_content_library_name        = "lib"
    common_content_library_ovf         = true
    common_content_library_destroy     = true
    common_content_library_skip_export = true// OVF Export Settings
    common_ovf_export_enabled   = false
    common_ovf_export_overwrite = true// Removable Media Settings
    common_iso_datastore = "datastore1"// Boot and Provisioning Settings
    common_data_source      = "http"
    common_http_ip          = null
    common_http_port_min    = 8000
    common_http_port_max    = 8099
    common_ip_wait_timeout  = "20m"
    common_shutdown_timeout = "15m"// HCP Packer
    common_hcp_packer_registry_enabled = false// vSphere Settings
    vsphere_datacenter = "datacenter"
    vsphere_cluster    = "datacenter"
    vsphere_datastore  = "datastore1"
    vsphere_network    = "VM Network"
    vsphere_folder     = "templates"

Windows specific variables are defined in windows.auto.pkrvars.hcl.

    /*
        DESCRIPTION:
        Microsoft Windows 11 Professional variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
    */
    
    // Installation Operating System Metadata
    vm_inst_os_language = "en-US"
    vm_inst_os_keyboard = "en-US"
    vm_inst_os_image    = "Windows 11 Pro"
    vm_inst_os_kms_key  = "W269N-WFGWX-YVC9B-4J6C9-T83GX"// Guest Operating System Metadata
    vm_guest_os_language = "en-US"
    vm_guest_os_keyboard = "en-US"
    vm_guest_os_timezone = "UTC"
    vm_guest_os_family   = "windows"
    vm_guest_os_name     = "desktop"
    vm_guest_os_version  = "11"
    vm_guest_os_edition  = "pro"// Virtual Machine Guest Operating System Setting
    vm_guest_os_type = "windows9_64Guest"// Virtual Machine Hardware Settings
    vm_firmware              = "efi-secure"
    vm_cdrom_type            = "sata"
    vm_cpu_count             = 4
    vm_cpu_cores             = 1
    vm_cpu_hot_add           = false
    vm_mem_size              = 8192
    vm_mem_hot_add           = false
    vm_vtpm                  = false
    vm_disk_size             = 102400
    vm_disk_controller_type  = ["pvscsi"]
    vm_disk_thin_provisioned = true
    vm_network_card          = "vmxnet3"
    vm_video_mem_size        = 131072
    vm_video_displays        = 1// Removable Media Settings
    iso_url            = null
    iso_path           = " iso"
    iso_file           = "windows11.iso"
    iso_checksum_type  = "sha256"
    iso_checksum_value = "772a500f05970db5a209b2ba0e79860dc4b0f47b1072eca56b72155b17e8db03"// Boot Settings
    vm_boot_order       = "disk,cdrom"
    vm_boot_wait        = "3s"
    vm_boot_command     = ["<spacebar><spacebar>"]
    vm_shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Shutdown by Packer\""// Communicator Settings
    communicator_port    = 5985
    communicator_timeout = "2h"

Sensitive variables can also be defined as local user environment variables so it’s not ending up in a git repo…

    PKR_VAR_vsphere_password=mySecretPass
    PKR_VAR_build_password=mySecretPass

# The autounattend.xml file

This is a very handy feature in Packer to populate the autounattend.xml file with variables at runtime. The cd_content section in windows.pkr.hcl replaces the variables specified in the template file data/autounattend.pkrtpl.hcl so no need to hardcode values in the autounattend.xml file. Add a variable like this ${my_variable_name} and then declare in variables.pkr.hcl and finally define in windows.auto.pkrvars.hcl.

    cd_content = {
        "autounattend.xml" = templatefile("${abspath(path.root)}/data/autounattend.pkrtpl.hcl", {
          build_username       = var.build_username
          build_password       = var.build_password
          vm_inst_os_language  = var.vm_inst_os_language
          vm_inst_os_keyboard  = var.vm_inst_os_keyboard
          vm_inst_os_image     = var.vm_inst_os_image
          vm_inst_os_kms_key   = var.vm_inst_os_kms_key
          vm_guest_os_language = var.vm_guest_os_language
          vm_guest_os_keyboard = var.vm_guest_os_keyboard
          vm_guest_os_timezone = var.vm_guest_os_timezone
        })
    }

# The Packer build file — windows.pkr.hcl

This file contains the flow and logic of all the steps.
    
    /*
        DESCRIPTION:
        Microsoft Windows 11 Professional template using the Packer Builder for VMware vSphere (vsphere-iso).
    */
    
    //  BLOCK: packer
    //  The Packer configuration.
    
    packer {
      required_version = ">= 1.8.3"
      required_plugins {
        vsphere = {
          version = ">= v1.0.8"
          source  = "github.com/hashicorp/vsphere"
        }
      }
      required_plugins {
        windows-update = {
          version = ">= 0.14.1"
          source  = "github.com/rgl/windows-update"
        }
      }
    }
    
    //  BLOCK: locals
    //  Defines the local variables.
    
    locals {
      build_by           = "Built by: HashiCorp Packer ${packer.version}"
      build_date         = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
      build_version      = formatdate("YY.MM", timestamp())
      build_description  = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
      iso_paths          = ["[${var.common_iso_datastore}] ${var.iso_path}/${var.iso_file}", "[] /vmimages/tools-isoimages/${var.vm_guest_os_family}.iso"]
      iso_checksum       = "${var.iso_checksum_type}:${var.iso_checksum_value}"
      manifest_date      = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
      manifest_path      = "${path.cwd}/manifests/"
      manifest_output    = "${local.manifest_path}${local.manifest_date}.json"
      ovf_export_path    = "${path.cwd}/artifacts/${local.vm_name}"
      vm_name            = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition}-v${local.build_version}"
      bucket_name        = replace("${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition}", ".", "")
      bucket_description = "${var.vm_guest_os_family} ${var.vm_guest_os_name} ${var.vm_guest_os_version} ${var.vm_guest_os_edition}"
    }
    
    //  BLOCK: source
    //  Defines the builder configuration blocks.

# Required version and plugins

Specify the required Packer version, here we have the vsphere.iso plugin for VMware, and optionally a plugin that works well for installing Windows updates.

    packer {
      required_version = ">= 1.8.3"
      required_plugins {
        vsphere = {
          version = ">= v1.0.8"
          source  = "github.com/hashicorp/vsphere"
        }
      }
      required_plugins {
        windows-update = {
          version = ">= 0.14.1"
          source  = "github.com/rgl/windows-update"
        }
      }
    }

# Provisioners

Provisioners use built-in and third-party software to install and configure the machine image after booting. A common provisioner is “powershell” for running scripts inside the Windows image OS. Example below runs the sysprep tool to seal the image as a final step.

    provisioner "powershell" {
      elevated_user     = var.build_username
      elevated_password = var.build_password
      inline            = [
        "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit",
        "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
      ]
    }

# Automating Windows Updates…

To use Ansible for Windows Updates, I found two ways of running a playbook. The actual “ansible” provisioner or to run a local shell using the “shell-local” provisioner. I was able to start the playbook with the ansible.windows.win_updates module but the Windows Update part always timed out so I gave this up. Therefore this code is commented out. A pause for 60–120 seconds before running Ansible might solve this.

Then I tried the “windows-update” provisioner and it worked great which actually do a pause for 60 seconds! It may also helped to increase cpu to 4 and memory to 8192. So now when starting the newly built packer image, Windows Update also needs another reboot to finish. After adding another 60 seconds wait time and the “windows-restart” provisioner, everything was working flawlessly!

    provisioner "windows-update" {
      pause_before    = "60s"
      search_criteria = "IsInstalled=0"
      filters = [
        "exclude:$_.Title -like '*VMware*'",
        "exclude:$_.Title -like '*Preview*'",
        "exclude:$_.Title -like '*Defender*'",
        "exclude:$_.InstallationBehavior.CanRequestUserInput",
        "include:$true"
      ]
      restart_timeout = "120m"
    }

    provisioner "powershell" {
      elevated_user     = var.build_username
      elevated_password = var.build_password
      inline            = [
        "Start-Sleep -Seconds 60"
      ]
    }provisioner "windows-restart" {
      restart_check_command = "echo restarted"
      restart_timeout = "10m"
    }

To bypass the Windows 11 TPM chip and other hardware requirements during OS installation check, one solution is to add below “RunSynchronousCommand” commands to the autounattend.xml file. Also set vm_vtpm = false in windows.auto.pkrvars.hcl.

    <RunSynchronous>
       <RunSynchronousCommand wcm:action="add">
        <Order>1</Order>
        <Path>reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t reg_dword /d 0x00000001 /f</Path>
       </RunSynchronousCommand>
       <RunSynchronousCommand wcm:action="add">
        <Order>2</Order>
        <Path>reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t reg_dword /d 0x00000001 /f</Path>
       </RunSynchronousCommand>
       <RunSynchronousCommand wcm:action="add">
        <Order>3</Order>
        <Path>reg add HKLM\System\Setup\LabConfig /v BypassRAMCheck /t reg_dword /d 0x00000001 /f</Path>
       </RunSynchronousCommand>
       <RunSynchronousCommand wcm:action="add">
           <Order>4</Order>
        <Path>reg add HKLM\System\Setup\LabConfig /v BypassCPUCheck /t reg_dword /d 0x00000001 /f</Path>
       </RunSynchronousCommand>
       <RunSynchronousCommand wcm:action="add">
           <Order>5</Order>
        <Path>reg add HKLM\System\Setup\LabConfig /v BypassStorageCheck /t reg_dword /d 0x00000001 /f</Path>
       </RunSynchronousCommand>
       <RunSynchronousCommand>
           <Order>6</Order>
           <!-- Set power scheme to high performance in WinPE for faster imaging. -->
           <Path>cmd /c powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c</Path>
       </RunSynchronousCommand>  
    </RunSynchronous>
