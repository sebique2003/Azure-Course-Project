# ☁️ Azure Cloud Project with Terraform

Basic Azure infrastructure deployed with **Terraform**.

### 🔧 Tools & Technologies
- Terraform
- Azure (azurerm provider)
- GitHub Actions

### 📌 Project Highlights
- 2x Linux VMs
- Azure networking: VNet, Subnet, NICs, Public IPs
- Remote ping test between VMs using null_resource
- GitHub Actions: working with workflows
- Secrets handled securely via GitHub Secrets 🔐

### 📁 Project Structure
```bash
├── main.tf
├── vars.tf
├──.gitignore
├── .github/
│   └── workflows/
│       └── tf-workflow.yml
```
📘 *Created by **Iordache Sebastian-Ionuț** as part of the Azure Foundations Course*
