# Comin Module
Comin is a NixOS deployment tool that utilizes a GitOps approach, meaning it deploys configurations by periodically polling Git repositories. It operates in pull mode, where the machine itself fetches the latest configuration from the remote repository.

With Comin one can remove the burden of manually updating NixOS machines whenever changes are made to the Git repository it's config lives in.

## Getting Started
Setting the following...
```
megacorp.services.comin = {
  enable = true;
  repo = "https://github.com/rapture-mc/mgc-nixos";
}
```
Will:
- Create a systemd unit **comin.service**
- Continuously poll the git repository for any changes and rebuild the system if necessary
- Add it's own line of generations to the boot menu for rollbacks

To target a specific branch...
```
megacorp.services.comin = {
  enable = true;
  repo = "https://github.com/rapture-mc/mgc-nixos";
  branch = "dev";
}
```
Now the service will only look for changes on the "dev" branch

## Additional Notes

### Checking logs
Logs can be queried by running `sudo journalctl -u comin` like any other systemd service.
