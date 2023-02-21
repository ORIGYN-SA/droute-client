import { nat32ToNat; nat64ToNat } "mo:prim";

module {
  public func hashNat32(value: Nat32): Nat {
    var hash = value;

    hash := hash >> 16 ^ hash *% 0x21f0aaad;
    hash := hash >> 15 ^ hash *% 0x735a2d97;

    return nat32ToNat(hash >> 15 ^ hash & 0x3fffffff);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func hashNat64(key: Nat64): Nat {
    var hash = key;

    hash := hash >> 30 ^ hash *% 0xbf58476d1ce4e5b9;
    hash := hash >> 27 ^ hash *% 0x94d049bb133111eb;

    return nat64ToNat(hash >> 31 ^ hash & 0x3fffffff);
  };
};
