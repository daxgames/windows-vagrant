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
variable "cpus" {
  type    = string
  default = "2"
}

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
  default = "cmderdev-10"
}

variable "windows_version_major" {
  type    = string
  default = "10"
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

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_url" {
  type    = string
  default = "./iso/Win10_22H2_English_x64v1.iso"
}

variable "iso_checksum" {
  type    = string
  default = "none"
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "virtio_win_iso" {
  type    = string
  default = "~/virtio-win.iso"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vagrant_box" {
  type = string
}

source "parallels-iso" "cmderdev-10-amd64" {
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
    "tmp/windows-11-23h2/autounattend.xml",
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

source "virtualbox-iso" "cmderdev-10-amd64" {
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
    "tmp/windows-11-23h2/autounattend.xml",
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

source "vmware-iso" "cmderdev-10-amd64" {
  boot_wait         = "1m"
  communicator      = "winrm"
  cpus              = "${var.cpus}"
  disk_adapter_type = "lsisas1068"
  disk_size         = "${var.disk_size}"
  disk_type_id      = "1"
  floppy_files      = [
    "provision-autounattend.ps1",
    "provision-openssh.ps1",
    "provision-psremoting.ps1",
    "provision-pwsh.ps1",
    "provision-winrm.ps1",
    "tmp/windows-11-23h2/autounattend.xml",
  ]
  guest_os_type     = "windows9-64"
  headless          = "${var.headless}"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "${var.memory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  version           = "19"
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
    "source.virtualbox-iso.cmderdev-10-amd64",
    "source.vmware-iso.cmderdev-10-amd64",
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
