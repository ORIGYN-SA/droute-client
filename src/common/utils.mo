import { nat32ToNat } "mo:prim";

module {
  public func hashNat32(value: Nat32): Nat {
    var hash = value;

    hash := hash >> 16 ^ hash *% 0x21f0aaad;
    hash := hash >> 15 ^ hash *% 0x735a2d97;

    return nat32ToNat(hash >> 15 ^ hash & 0x3fffffff);
  };
};
