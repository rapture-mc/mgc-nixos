{ nixpkgs2411 }: final: prev: {
  bookstack = nixpkgs2411.legacyPackages.${final.system}.bookstack;
}
