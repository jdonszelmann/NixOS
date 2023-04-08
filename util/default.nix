{ nixpkgs, ... }@inputs: with builtins; with { lib = (nixpkgs.lib); };
let
  reverse-proxy = import ./reverse-proxy.nix inputs;
in
{
  database = import ./database.nix inputs;
  reverse-proxy = reverse-proxy.reverse-proxy;
  well-known = reverse-proxy.well-known;

  # randomPort isn't actually a random port. Instead it's basically a hash
  # of the app name.
  randomPort = name:
    let
      # take the sha512
      stringHash = hashString "sha512" name;
      nth = i: substring i 1 stringHash;
      # get the first 4 digits
      chars = [ (nth 0) (nth 1) (nth 2) (nth 3) ];
      fromHex = x: {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      }.${x};
      # convert them from hex
      digits = map fromHex chars;
      # into a single 16 bit number
      res = builtins.foldl' (acc: val: acc * 16 + val) 0 digits;
    in
    # if it's in a nice range, let's go! else let's retry with a '-' added
    if res > 9000 && res < 65000 then res else randomPort (name + "-")
  ;
}
