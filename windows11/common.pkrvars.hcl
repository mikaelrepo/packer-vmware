/*
    DESCRIPTION:
    Common variables used for all builds.
    - Variables are use by the source blocks.
*/

// Virtual Machine Settings
common_vm_version           = 19
common_tools_upgrade_policy = true
common_remove_cdrom         = true

// Template and Content Library Settings
common_template_conversion         = false
common_content_library_name        = "lib"
common_content_library_ovf         = true
common_content_library_destroy     = true
common_content_library_skip_export = true

// OVF Export Settings
common_ovf_export_enabled   = false
common_ovf_export_overwrite = true

// Removable Media Settings
common_iso_datastore = "datastore1"

// Boot and Provisioning Settings
common_data_source      = "http"
common_http_ip          = null
common_http_port_min    = 8000
common_http_port_max    = 8099
common_ip_wait_timeout  = "20m"
common_shutdown_timeout = "15m"

// HCP Packer
common_hcp_packer_registry_enabled = false

// vSphere Settings
vsphere_datacenter = "datacenter"
vsphere_cluster    = "datacenter"
vsphere_datastore  = "datastore1"
vsphere_network    = "VM Network"
vsphere_folder     = "templates"