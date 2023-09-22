

#  ami           = "ami-060b1c20c93e475fd" # Replace with the Windows Server 2022 AMI ID
#  ami           = "ami-0901bbd9d6e996fb7" # Replace with the Netspectrum AMI ID
#  ami           = "ami-0b02670313196539c" # Replace with the Kali Linux AMI ID
#  key           = "DesktopKey-US-EAST-2"

variable "region" {
    default="us-east-2"
}

variable "public_subnet_cidr" {
    default = "10.0.1.0/24"
}

variable "aws-key" {
    description = "SSH Public Key Name Created in AWS (keys are unique per region)."
    type = string
    default = "US-EAST-2-KEY"

}