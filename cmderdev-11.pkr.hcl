packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
    # see https://github.com/hashicorp/packer-plugin-vagrant
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    # see https://github.com/rgl/packer-plugin-windows-update
    windows-update = {
      version = "~>0.16.7"
      source  = "github.com/rgl/windows-update"
    }
  }
}

# ===================================================================================
variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "vm_name" {
  type    = string
  default = "cmderdev-11"
}

variable "windows_version_major" {
  type    = string
  default = "11"
}

variable "vmx_version" {
  type    = string
  default = "14"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

# ===================================================================================
variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"
}


variable "vagrant_box" {
  type = string
}

source "parallels-iso" "cmderdev-11-amd64" {
  boot_command           = ""
  boot_wait              = "6m"
  communicator           = "winrm"
  cpus                   = "${var.cpus}"
  disk_size              = "${var.disk_size}"
  floppy_files         = [
    "provision-autounattend.ps1",
    "provision-openssh.ps1",
    "provision-psremoting.ps1",
    "provision-pwsh.ps1",
    "provision-winrm.ps1",
    "tmp/cmderdev-11/autounattend.xml",
  ]
  guest_os_type          = "win-10"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  memory                 = "${var.memory}"
  parallels_tools_flavor = "win"
  prlctl                 = [["set", "{{ .Name }}", "--efi-boot", "off"]]
  shutdown_command       = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  vm_name                = "${var.vm_name}"
  winrm_password         = "vagrant"
  winrm_timeout          = "${var.winrm_timeout}"
  winrm_username         = "vagrant"
}

source "virtualbox-iso" "cmderdev-11-amd64" {
  boot_wait            = "-1s"
  communicator         = "winrm"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = [
    "provision-autounattend.ps1",
    "provision-openssh.ps1",
    "provision-psremoting.ps1",
    "provision-pwsh.ps1",
    "provision-winrm.ps1",
    "tmp/cmderdev-11/autounattend.xml",
  ]

  guest_additions_mode = "disable"
  guest_os_type        = "Windows10_64"
  headless             = "${var.headless}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.memory}"
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  vm_name              = "${var.vm_name}"
  winrm_password       = "vagrant"
  winrm_timeout        = "${var.winrm_timeout}"
  winrm_username       = "vagrant"
}

source "vmware-iso" "cmderdev-11-amd64" {
  boot_wait         = "1m"
  communicator      = "winrm"
  cpus              = "${var.cpus}"
  disk_adapter_type = "lsisas1068"
  disk_size         = "${var.disk_size}"
  disk_type_id      = "${var.disk_type_id}"
  floppy_files      = [
    "provision-autounattend.ps1",
    "provision-openssh.ps1",
    "provision-psremoting.ps1",
    "provision-pwsh.ps1",
    "provision-winrm.ps1",
    "tmp/cmderdev-11/autounattend.xml",
  ]
  guest_os_type     = "windows9-64"
  headless          = "${var.headless}"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "${var.memory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  version           = "${var.vmx_version}"
  vm_name           = "${var.vm_name}"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vmx_remove_ethernet_interfaces = true
  vnc_port_max                   = 5980
  vnc_port_min                   = 5900
  winrm_password                 = "vagrant"
  winrm_timeout                  = "${var.winrm_timeout}"
  winrm_username                 = "vagrant"
}

build {
  sources = [
    "source.virtualbox-iso.cmderdev-11-amd64",
    "source.vmware-iso.cmderdev-11-amd64",
  ]

  provisioner "powershell" {
    use_pwsh = true
    script   = "disable-windows-updates.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "disable-windows-defender.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "remove-one-drive.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "remove-apps.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "provision.ps1"
  }

  provisioner "windows-update" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "enable-remote-desktop.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "provision-cloudbase-init.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    scripts = [
      "vm-guest-tools.ps1",
      "example/provision-chocolatey.ps1",
      "provision-cmderdev.ps1"
    ]
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "eject-media.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "optimize.ps1"
  }

  post-processor "vagrant" {
    output               = var.vagrant_box
    vagrantfile_template = "Vagrantfile.template"
  }
}
