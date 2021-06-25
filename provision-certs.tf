resource "aws_instance" "controller" {
  provisioner "local-exec" {
    command = <<EOT
      wget -q --show-progress --https-only --timestamping \
        https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
        https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
      chmod +x cfssl cfssljson
      sudo mv cfssl /usr/local/bin/
      sudo mv cfssljson /usr/local/bin/
      cd csrs
      cfssl gencert -initca ca-csr.json | cfssljson -bare ca
      EOT
  }
}