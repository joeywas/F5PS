# F5PS

PowerShell module to interact with F5 Distributed Cloud via the API

## Getting Started

Install the F5 PS module from PSGallery for the current user

```powershell
Install-Module F5PS -Scope CurrentUser
```

### Connect to F5 Distribute Cloud

1. Generate an [API Token in F5 Distributed Cloud Console](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials)
2. Run `Set-F5PSConfig -Uri 'tenant.console.ves.volterra.io' -Token 'tokenvalue'` to set cloud console URI and API Token
3. Execute `Connect-F5` to connect to API
