{ pkgs ? import <nixpkgs> { } }:
let
  pypy =
    let
      packageOverrides = self: super: {
        matplotlib = super.matplotlib.override { enableTk = false; };
        protobuf = super.protobuf.overrideAttrs (_: { disabled = false; });
        psycopg2 = super.psycopg2.overrideAttrs (_: { disabled = false; });
      };
    in
    pkgs.pypy3.override {
      inherit packageOverrides;
      self = pypy;
    };
in
pkgs.matrix-synapse.override { python3 = pypy; }
