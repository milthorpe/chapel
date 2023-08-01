/*
 * Copyright 2020-2023 Hewlett Packard Enterprise Development LP
 * Copyright 2004-2019 Cray Inc.
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ChapelHashing.chpl
//
// hash and related functions
module ChapelHashing {

  use ChapelBase;

  interface Hashable {
    proc Self.hash(): uint;
  }

  proc chpl__defaultHashWrapperCG(x: Hashable): int {
    const hash = x.hash();
    return (hash & max(int)): int;
  }

  pragma "last resort"
  proc chpl__defaultHashWrapper(x): int {
    use Reflection;
    if !canResolve("chpl__defaultHashWrapperCG", x) {
      if canResolveMethod(x, "hash") then
        compilerError(x.type:string + " has a hash function, but does not implement Hashable");
      compilerError("the type '" + x.type:string + "is not Hashable");
    }
    return chpl__defaultHashWrapperCG(x);
  }

  // Mix the bits, so that e.g. numbers in 0..N generate
  // random-looking data across all the bits even if N is small.
  proc _gen_key(i: uint): uint {
    // Thomas Wang's 64b mix function - 2007 version - see
    // http://web.archive.org/web/20071223173210/http://www.concentric.net/~Ttwang/tech/inthash.htm
    var key = i;
    key = (~key) + (key << 21); // key = (key << 21) - key - 1;
    key = key ^ (key >> 24);
    key = (key + (key << 3)) + (key << 8); // key * 265
    key = key ^ (key >> 14);
    key = (key + (key << 2)) + (key << 4); // key * 21
    key = key ^ (key >> 28);
    key = key + (key << 31);
    return key;

    // See commit history for this comment for some other mixers
    // worth considering.
  }
  proc _gen_key(i: int): uint {
    return _gen_key(i:uint);
  }

  inline proc chpl__defaultHashCombine(a:uint, b:uint, fieldnum:int): uint {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_bitops_rotl_64(x: uint(64), n: uint(64)) : uint(64);
    var n:uint = (17 + fieldnum):uint;
    return _gen_key(a ^ chpl_bitops_rotl_64(b, n));
  }

  inline proc bool.hash(): uint {
    if (this) then
      return 0;
    else
      return 1;
  }
  bool implements Hashable;

  inline proc int.hash(): uint {
    return _gen_key(this);
  }
  implements Hashable(int(8));
  implements Hashable(int(16));
  implements Hashable(int(32));
  implements Hashable(int(64));

  inline proc uint.hash(): uint {
    return _gen_key(this);
  }
  implements Hashable(uint(8));
  implements Hashable(uint(16));
  implements Hashable(uint(32));
  implements Hashable(uint(64));

  inline proc enum.hash(): uint {
    return _gen_key(chpl__enumToOrder(this));
  }
  implements Hashable(enum);

  inline proc real.hash(): uint {
    return _gen_key(__primitive( "real2int", this));
  }
  implements Hashable(real(32));
  implements Hashable(real(64));

  inline proc complex.hash(): uint {
    return _gen_key(__primitive("real2int", this.re) ^ __primitive("real2int", this.im));
  }
  implements Hashable(complex(64));
  implements Hashable(complex(128));

  inline proc imag.hash(): uint {
    return _gen_key(__primitive( "real2int", _i2r(this)));
  }
  implements Hashable(imag(32));
  implements Hashable(imag(64));

  inline proc chpl_taskID_t.hash(): uint {
    return _gen_key(this:int);
  }
  chpl_taskID_t implements Hashable;

  inline proc _array.hash(): uint {
    var hash : uint = 0;
    var i = 1;
    for obj in this {
      hash = chpl__defaultHashCombine(obj.hash(), hash, i);
      i += 1;
    }
    return hash;
  }
  _array implements Hashable;

  // Nilable and non-nilable classes will coerce to this.
  inline proc (borrowed RootClass?).hash(): uint {
    return _gen_key(__primitive( "object2int", this));
  }
  implements Hashable(class);
  implements Hashable(class?);

  inline proc locale.hash(): uint {
    return _gen_key(__primitive( "object2int", this._value));
  }
  locale implements Hashable;

  //
  // Implementation of hash for ranges, in case the 'keyType'
  // contains a range in some way (e.g. tuple of ranges).
  //
  inline proc range.hash(): uint {
    use Reflection;
    var ret : uint;
    for param i in 1..numImplementationFields(this.type) {
      if isParam(getImplementationField(this, i)) == false &&
         isType(getImplementationField(this, i)) == false &&
         isNothingType(getImplementationField(this, i).type) == false {
        const ref field = getImplementationField(this, i);
        const fieldHash = field.hash();
        if i == 1 then
          ret = fieldHash;
        else
          ret = chpl__defaultHashCombine(fieldHash, ret, i);
      }
    }
    return ret;
  }
  range implements Hashable;
}
