variable "release" {
  type = string
}

variable "minor_release" {
  type = string
}

variable "iso_checksum" {
  type = string
}

locals {
  basename = "ubuntu-${var.release}"
}

source "virtualbox-iso" "ubuntu-hardened-server" {
  boot_command = [
    "<esc><esc><esc>",
    "set gfxpayload=keep<enter>",
    "linux /casper/vmlinuz ",
    "\"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" ",
    "quiet splash nomodeset autoinstall ---<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]
  boot_wait = "2s"
  disk_size = 10000
  export_opts = [
    "--manifest",
    "--vsys", "0",
    "--description", "${local.basename} hardened server"
  ]
  format                 = "ova"
  guest_additions_mode   = "disable"
  guest_os_type          = "Ubuntu_64"
  hard_drive_interface   = "sata"
  http_directory         = "http"
  iso_checksum           = "sha256:${var.iso_checksum}"
  iso_urls               = ["https://releases.ubuntu.com/${var.release}/${local.basename}.${var.minor_release}-live-server-amd64.iso"]
  memory                 = 2048
  output_directory       = "build"
  output_filename        = "${local.basename}-hardened-server"
  shutdown_command       = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_handshake_attempts = "300"
  ssh_password           = "vagrant"
  ssh_pty                = true
  ssh_timeout            = "1800s"
  ssh_username           = "vagrant"
  vboxmanage             = [["modifyvm", "{{.Name}}", "--firmware", "EFI"]]
}

build {
  sources = ["source.virtualbox-iso.ubuntu-hardened-server"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "TMPDIR=/var/tmp"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    pause_before      = "10s"
    remote_folder     = "/var/tmp"
    scripts = [
      "${path.root}/scripts/vagrant.sh",
      "${path.root}/scripts/hardening.sh",
      "${path.root}/scripts/cleanup.sh",
      "${path.root}/scripts/minimize.sh"
    ]
  }

  post-processor "vagrant" {
    output = "output/${local.basename}-hardened-server.box"
  }

  post-processor "shell-local" {
    environment_vars = ["BUILD_NAME=${local.basename}-hardened-server"]
    scripts          = ["./scripts/postproc.sh"]
  }
}