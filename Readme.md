
# Windows DevOps Toolkit, Automated Installer Packaging & Deployment (S3 File Share)



This project is about automating the packaging, distribution, and deployment of a Windows developer toolkit using Azure DevOps pipeline with AWS S3 as a file share (SMB alternative). Instead of passing the installer package as a pipeline artifact between stages, the package is uploaded to an S3 bucket and downloaded by the deployment stage.


## Architecture

```

│                    Azure DevOps Pipeline                     │
│                                                              │
│  Stage 1: Build Package                                      │
│  ├── Install PowerShell Core (pwsh) on Linux agent           │
│  ├── Download components from official sources               │
│  ├── Bundle into DevOpsToolkit-Setup.zip                     │
│  ├── Generate SHA256 checksum                                │
│  ├── Upload to S3: s3://devops-toolkit-packages/             │
│  │   ├── packages/latest/DevOpsToolkit-Setup.zip             │
│  │   └── packages/archive/DevOpsToolkit-Setup-<timestamp>.zip│
│  └── Publish pipeline artifact (backup)                      │
│                                                              │
│  Stage 2: Provision Windows VM                               │
│  ├── Terraform init & apply                                  │
│  ├── Create Windows Server 2022 EC2 instance                 │
│  ├── Configure WinRM via user_data                           │
│  └── Capture public IP                                       │
│                                                              │
│  Stage 3: Deploy & Verify                                    │
│  ├── Download package FROM S3 (not pipeline artifact)        │
│  ├── Create Windows inventory (WinRM)                        │
│  ├── Warm up WinRM connection                                │
│  ├── Run Ansible playbook (deploy-installer.yml)             │
│  │   ├── Copy zip to Windows VM                              │
│  │   ├── Extract package                                     │
│  │   ├── Install Notepad++, Git, Python, AWS CLI             │
│  │   └── Generate installation report                        │
│  └── Verify all installations                                │
│                                                              │
│  Stage 4: Cleanup                                            │
│  └── Terraform destroy (runs always)                         │



│              S3 Bucket: devops-toolkit-packages               │
│                                                              │
│  packages/                                                   │
│  ├── latest/                                                 │
│  │   └── DevOpsToolkit-Setup.zip    ← Always overwritten     │
│  └── archive/                                                │
│      ├── DevOpsToolkit-Setup-20261001-001300-build82.zip     │
│      ├── DevOpsToolkit-Setup-20260930-235500-build81.zip     │
│      └── ...                        ← Timestamped backups    │

```

## Pipeline Artifact vs S3 File Share — Key Differences

| Aspect | Pipeline Artifact | S3 File Share (This Repo) |
|--------|------------------|--------------------------|
| Storage | Azure DevOps internal | AWS S3 bucket |
| Access | Only within same pipeline run | Any pipeline, any time |
| Versioning | Tied to build ID | Timestamped archive + latest |
| Retention | Azure DevOps retention policy | S3 lifecycle rules |
| Cross-pipeline | Needs resource trigger | Direct S3 download |
| Rollback | Re-run old build | Download from archive/ |
| Offline access | No | Yes (aws s3 cp) |
| Cost | Free (included in Azure DevOps) | S3 storage costs (minimal) |

## S3 Bucket Structure

```
devops-toolkit-packages/
├── packages/
│   ├── latest/
│   │   └── DevOpsToolkit-Setup.zip          # Always the newest build
│   └── archive/
│       ├── DevOpsToolkit-Setup-20261001-001300-build82.zip
│       ├── DevOpsToolkit-Setup-20260930-235500-build81.zip
│       └── ...                               # Every build preserved
```

- latest/: Always overwritten with the newest package, the deployment stage pulls from here
- archive/: Timestamped copies of every build, used for rollback

Tools & Technologies


Azure DevOps => CI/CD pipeline orchestration 
PowerShell Core => Cross-platform scripting (runs on Linux agent) 
Terraform => Infrastructure provisioning (Windows EC2 + Security Group) 
Ansible => Configuration management via WinRM 
AWS S3 => Package distribution (SMB file share alternative) 
AWS EC2 => Windows Server 2022 target VM 
Self-hosted Agent => Amazon Linux 2023 EC2 running Azure DevOps agent 

## Packaged Software


Notepad++  `/S` 
Git  `/VERYSILENT /NORESTART` 
Python  `/quiet InstallAllUsers=1 PrependPath=1` 
AWS CLI  `/quiet /norestart` 

## Project Structure

```
windows-package-installer-smb/
├── azure-pipelines.yml              # Pipeline definition (4 stages + S3 upload/download)
├── scripts/
│   ├── download-components.ps1      # Downloads installers from official sources
│   ├── install-all.ps1              # Silent install script (standalone use)
│   └── verify-install.ps1           # Verification script (standalone use)
├── build/
│   ├── package.ps1                  # Bundles components into .zip
│   └── output/                      # Generated package (git-ignored)
├── terraform/
│   ├── main.tf                      # Root module — calls windows_vm module
│   ├── variables.tf                 # Root variables (subnet_id, vpc_id, etc.)
│   ├── outputs.tf                   # Root outputs (public_ip, ami_used)
│   └── modules/
│       └── windows_vm/
│           ├── main.tf              # EC2 instance, security group, WinRM user_data
│           ├── variables.tf         # Module variables
│           └── outputs.tf           # Module outputs
├── ansible/
│   ├── ansible.cfg                  # Ansible configuration
│   ├── playbooks/
│   │   └── deploy-installer.yml     # Main deployment playbook
│   └── roles/
│       └── deploy-toolkit/
│           ├── tasks/main.yml       # Install tasks (win_package, win_copy, etc.)
│           └── defaults/main.yml    # Default variables (install_dir, paths)
└── .gitignore
```


## How to Run

```bash
# Clone the repo
git clone https://github.com/<your-username>/windows-package-installer-smb.git

# Push to trigger pipeline
git push origin master

# Or manually run from Azure DevOps:
# Pipelines → Select pipeline → Run pipeline → Run
```

## Manual S3 Operations






- S3 as SMB alternative : Using S3 bucket with latest/ and archive/ folders to simulate network file share
- Package versioning : Timestamped archives for every build with latest/ always pointing to newest
- Cross-platform scripting : PowerShell Core running on Linux to build Windows packages
- WinRM connectivity : Ansible managing Windows VMs over WinRM 
- Silent installations : Using vendor-specific flags (/S, /VERYSILENT, /quiet)
- Decoupled distribution : Package stored externally — any pipeline or manual process can consume it
- Infrastructure as Code : Terraform provisioning with automatic cleanup
- Self-hosted agents : Running pipelines on custom EC2 instances

## Troubleshooting

Issues I faced:
S3 upload fails => Check AWS credentials in Variable Group; verify bucket name and region 
S3 download empty => Verify upload succeeded; run `aws s3 ls s3://devops-toolkit-packages/packages/latest/` 
WinRM timeout => Increase `winrm_timeout` in Terraform user_data; add WinRM warm-up step 
WinRM InvalidSelectors => Add retries with delay on first task; warm up WinRM before Ansible 
Installer path not found => Check zip nesting — use `zip -r ... .` to avoid wrapper folders 
Gathering facts fails => Add `gather_facts: false` to playbook for Windows targets 
Password rejected => Ensure password meets Windows complexity requirements (uppercase + lowercase + number + special) 

