# bookstack-setup.service in 25.05 errors out with "doctrine deprecation not found"
# Here we use the 24.11 version of bookstack instead
{nixpkgs24-11}: final: prev: {
  bookstack = nixpkgs24-11.legacyPackages.${final.system}.bookstack;
}
