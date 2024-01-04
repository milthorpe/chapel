/*
 * Copyright 2020-2024 Hewlett Packard Enterprise Development LP
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

/*

Automatically included Math symbols

.. _automath-roots:

Roots
^^^^^
:proc:`~Math.cbrt`
:proc:`~Math.sqrt`

.. _automath-rounding:

Rounding
^^^^^^^^
:proc:`~Math.ceil`
:proc:`~Math.floor`
:proc:`~Math.round`
:proc:`~Math.trunc`

.. _automath-complex:

Computations Involving Complex Numbers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
:proc:`~Math.conj`
:proc:`~Math.phase`
:proc:`~Math.riemProj`

.. _automath-inf-nan:

Infinity and NaN
^^^^^^^^^^^^^^^^
:proc:`~Math.inf`
:proc:`~Math.nan`
:proc:`~Math.isFinite`
:proc:`~Math.isInf`
:proc:`~Math.isNan`

.. _automath-comparison:

Comparison Functions
^^^^^^^^^^^^^^^^^^^^
:proc:`~Math.max`
:proc:`~Math.min`
:proc:`~Math.isClose`

.. _automath-sign:

Sign Functions
^^^^^^^^^^^^^^
:proc:`~Math.sgn`
:proc:`~Math.signbit`

.. _automath-other:

Remaining Functions
^^^^^^^^^^^^^^^^^^^
:proc:`~Math.abs`
:proc:`~Math.mod`
*/
pragma "module included by default"
@unstable("The module name 'AutoMath' is unstable.  If you want to use qualified naming on the symbols within it, please 'use' or 'import' the :mod:`Math` module")
module AutoMath {
  import HaltWrappers;
  private use CTypes;

  //////////////////////////////////////////////////////////////////////////
  // Constants (included in chpldocs)
  //

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'e' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param e = 2.7182818284590452354;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log2_e' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param log2_e = 1.4426950408889634074;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log10_e' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param log10_e = 0.43429448190325182765;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'ln_2' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param ln_2 = 0.69314718055994530942;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'ln_10' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param ln_10 = 2.30258509299404568402;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param pi = 3.14159265358979323846;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'half_pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param half_pi = 1.57079632679489661923;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'quarter_pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param quarter_pi = 0.78539816339744830962;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'recipr_pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param recipr_pi = 0.31830988618379067154;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'twice_recipr_pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param twice_recipr_pi = 0.63661977236758134308;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'twice_recipr_sqrt_pi' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param twice_recipr_sqrt_pi = 1.12837916709551257390;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sqrt_2' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param sqrt_2 = 1.41421356237309504880;

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'recipr_sqrt_2' will no longer be included by default, please 'use' or 'import' the 'Math' module to access it")
  param recipr_sqrt_2 = 0.70710678118654752440;

  //////////////////////////////////////////////////////////////////////////
  // Helper constants and functions (not included in chpldocs).
  //
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_double_isinf(x: real(64)): c_int;
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_float_isinf(x: real(32)): c_int;
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_double_isfinite(x: real(64)): c_int;
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_float_isfinite(x: real(32)): c_int;
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_double_isnan(x: real(64)): c_int;
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc chpl_macro_float_isnan(x: real(32)): c_int;

  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  private extern proc fabs(x: real(64)): real(64);


  //
  //////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////
  //
  // Public interface (included in chpldocs).
  //
  // (The entries below are alphabetized (case-insensitively) because chpldocs
  // presents them in declaration order.)
  //
  /* Returns the absolute value of the integer argument.

     :rtype: The type of `x`.
  */
  inline proc abs(x : int(?w)) do return if x < 0 then -x else x;

  /* Returns the absolute value of the unsigned integer argument.

     :rtype: The type of `x`.
  */
  inline proc abs(x : uint(?w)) do return x;

  /* Returns the absolute value of the integer param argument `x`. */
  proc abs(param x : integral) param do return if x < 0 then -x else x;

  /* Returns the magnitude of the real argument `x`. */
  inline proc abs(x : real(64)):real(64) do return fabs(x);

  /* Returns the magnitude of the real argument `x`. */
  inline proc abs(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc fabsf(x: real(32)): real(32);
    return fabsf(x);
  }

  /* Returns the real magnitude of the imaginary argument `x`. */
  inline proc abs(x : imag(64)): real(64) do return fabs(_i2r(x));

  /* Returns the real magnitude of the imaginary argument `x`. */
  inline proc abs(x: imag(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc fabsf(x: real(32)): real(32);
    return fabsf(_i2r(x));
  }

  /* Returns the magnitude (often called modulus) of complex `x`.

     In concert with the related :proc:`phase` (a.k.a. argument)
     of `x`, it can be used to recompute `x`.

     :rtype: ``real(w/2)`` when `x` has a type of ``complex(w)``.
  */
  inline proc abs(x : complex(?w)): real(w/2) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cabsf(x: complex(64)): real(32);
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cabs(x: complex(128)): real(64);
    if w == 64 then
      return cabsf(x);
    else
      return cabs(x);
  }


  /* Returns the absolute value of the integer argument.

     :rtype: The type of `i`.
  */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(i : int(?w)) do return abs(i);

  /* Returns the absolute value of the unsigned integer argument.

     :rtype: The type of `i`.
  */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(i : uint(?w)) do return abs(i);

  /* Returns the absolute value of the integer param argument `i`. */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for param function 'abs', please use 'x' instead")
  proc abs(param i : integral) param do return abs(i);

  /* Returns the magnitude of the real argument `r`. */
  pragma "last resort"
  @deprecated("The argument name 'r' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(r : real(64)):real(64) do return abs(r);

  /* Returns the real magnitude of the imaginary argument `im`. */
  pragma "last resort"
  @deprecated("The argument name 'im' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(im : imag(64)): real(64) do return abs(im);

  /* Returns the real magnitude of the imaginary argument `im`. */
  pragma "last resort"
  @deprecated("The argument name 'im' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(im: imag(32)): real(32) {
    return abs(im);
  }

  /* Returns the magnitude (often called modulus) of complex `z`.

     In concert with the related :proc:`phase` (a.k.a. argument)
     of `z`, it can be used to recompute `z`.

     :rtype: ``real(w/2)`` when `z` has a type of ``complex(w)``.
  */
  pragma "last resort"
  @deprecated("The argument name 'z' is deprecated for 'abs', please use 'x' instead")
  inline proc abs(z : complex(?w)): real(w/2) {
    return abs(z);
  }

  /* Returns the phase (often called `argument`) of complex `z`, an angle (in
     radians).

     In concert with the related :proc:`abs`, the magnitude (a.k.a.
     modulus) of `z`, it can be used to recompute `z`.

     :rtype: ``real(w/2)`` when `z` has a type of ``complex(w)``.
  */
  @deprecated("'carg' is deprecated, please use :proc:`phase` instead")
  inline proc carg(z: complex(?w)): real(w/2) {
    return phase(z);
  }


  // When removing this deprecated function, be sure to remove chpl_acos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc cosine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acos(x: real(64)): real(64) {
    return chpl_acos(x);
  }

  inline proc chpl_acos(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc acos(x: real(64)): real(64);
    return acos(x);
  }

  // When removing this deprecated function, be sure to remove chpl_acos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc cosine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acos(x : real(32)): real(32) {
    return chpl_acos(x);
  }

  inline proc chpl_acos(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc acosf(x: real(32)): real(32);
    return acosf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_acos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acos(z: complex(64)): complex(64) {
    return chpl_acos(z);
  }

  inline proc chpl_acos(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cacosf(z: complex(64)): complex(64);
    return cacosf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_acos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acos(z: complex(128)): complex(128) {
    return chpl_acos(z);
  }

  inline proc chpl_acos(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cacos(z: complex(128)): complex(128);
    return cacos(z);
  }


  // When removing this deprecated function, be sure to remove chpl_acosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic cosine of the argument `x`.

     It is an error if `x` is less than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acosh(x: real(64)): real(64) {
    return chpl_acosh(x);
  }

  inline proc chpl_acosh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc acosh(x: real(64)): real(64);
    return acosh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_acosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic cosine of the argument `x`.

     It is an error if `x` is less than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acosh(x : real(32)): real(32) {
    return chpl_acosh(x);
  }

  inline proc chpl_acosh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc acoshf(x: real(32)): real(32);
    return acoshf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_acosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acosh(z: complex(64)): complex(64) {
    return chpl_acosh(z);
  }

  inline proc chpl_acosh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cacoshf(z: complex(64)): complex(64);
    return cacoshf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_acosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'acosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc acosh(z: complex(128)): complex(128) {
    return chpl_acosh(z);
  }

  inline proc chpl_acosh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cacosh(z: complex(128)): complex(128);
    return cacosh(z);
  }


  // When removing this deprecated function, be sure to remove chpl_asin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc sine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asin(x: real(64)): real(64) {
    return chpl_asin(x);
  }

  inline proc chpl_asin(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc asin(x: real(64)): real(64);
    return asin(x);
  }

  // When removing this deprecated function, be sure to remove chpl_asin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc sine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asin(x : real(32)): real(32) {
    return chpl_asin(x);
  }

  inline proc chpl_asin(x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc asinf(x: real(32)): real(32);
    return asinf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_asin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asin(z: complex(64)): complex(64) {
    return chpl_asin(z);
  }

  inline proc chpl_asin(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc casinf(z: complex(64)): complex(64);
    return casinf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_asin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asin(z: complex(128)): complex(128) {
    return chpl_asin(z);
  }

  inline proc chpl_asin(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc casin(z: complex(128)): complex(128);
    return casin(z);
  }


  // When removing this deprecated function, be sure to remove chpl_asinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asinh(x: real(64)): real(64) {
    return chpl_asinh(x);
  }

  inline proc chpl_asinh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc asinh(x: real(64)): real(64);
    return asinh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_asinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asinh(x : real(32)): real(32) {
    return chpl_asinh(x);
  }

  inline proc chpl_asinh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc asinhf(x: real(32)): real(32);
    return asinhf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_asinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asinh(z: complex(64)): complex(64) {
    return chpl_asinh(z);
  }

  inline proc chpl_asinh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc casinhf(z: complex(64)): complex(64);
    return casinhf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_asinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'asinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc asinh(z: complex(128)): complex(128) {
    return chpl_asinh(z);
  }

  inline proc chpl_asinh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc casinh(z: complex(128)): complex(128);
    return casinh(z);
  }



  // When removing this deprecated function, be sure to remove chpl_atan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan(x: real(64)): real(64) {
    return chpl_atan(x);
  }

  inline proc chpl_atan(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atan(x: real(64)): real(64);
    return atan(x);
  }

  // When removing this deprecated function, be sure to remove chpl_atan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan(x : real(32)): real(32) {
    return chpl_atan(x);
  }

  inline proc chpl_atan(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atanf(x: real(32)): real(32);
    return atanf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_atan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan(z: complex(64)): complex(64) {
    return chpl_atan(z);
  }

  inline proc chpl_atan(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc catanf(z: complex(64)): complex(64);
    return catanf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_atan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan(z: complex(128)): complex(128) {
    return chpl_atan(z);
  }

  inline proc chpl_atan(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc catan(z: complex(128)): complex(128);
    return catan(z);
  }


  // When removing this deprecated function, be sure to remove chpl_atan2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the ratio of the two arguments.

     This is equivalent to
     the arc tangent of `y` / `x` except that the signs of `y`
     and `x` are used to determine the quadrant of the result. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan2(y: real(64), x: real(64)): real(64) {
    return chpl_atan2(y, x);
  }

  inline proc chpl_atan2(y: real(64), x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atan2(y: real(64), x: real(64)): real(64);
    return atan2(y, x);
  }

  // When removing this deprecated function, be sure to remove chpl_atan2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the arc tangent of the two arguments.

     This is equivalent to
     the arc tangent of `y` / `x` except that the signs of `y`
     and `x` are used to determine the quadrant of the result. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atan2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atan2(y : real(32), x: real(32)): real(32) {
    return chpl_atan2(y, x);
  }

  inline proc chpl_atan2(y : real(32), x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atan2f(y: real(32), x: real(32)): real(32);
    return atan2f(y, x);
  }


  // When removing this deprecated function, be sure to remove chpl_atanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic tangent of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atanh(x: real(64)): real(64) {
    return chpl_atanh(x);
  }

  inline proc chpl_atanh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atanh(x: real(64)): real(64);
    return atanh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_atanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic tangent of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atanh(x : real(32)): real(32) {
    return chpl_atanh(x);
  }

  inline proc chpl_atanh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc atanhf(x: real(32)): real(32);
    return atanhf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_atanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atanh(z: complex(64)): complex(64) {
    return chpl_atanh(z);
  }

  inline proc chpl_atanh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc catanhf(z: complex(64)): complex(64);
    return catanhf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_atanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the inverse hyperbolic tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'atanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc atanh(z: complex(128)): complex(128) {
    return chpl_atanh(z);
  }

  inline proc chpl_atanh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc catanh(z: complex(128)): complex(128);
    return catanh(z);
  }


  /* Returns the cube root of the argument `x`. */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc cbrt(x: real(64)): real(64);

  /* Returns the cube root of the argument `x`. */
  inline proc cbrt(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cbrtf(x: real(32)): real(32);
    return cbrtf(x);
  }


  /* Returns the value of the argument `x` rounded up to the nearest integer. */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc ceil(x: real(64)): real(64);

  /* Returns the value of the argument `x` rounded up to the nearest integer. */
  inline proc ceil(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ceilf(x: real(32)): real(32);
    return ceilf(x);
  }

  /* Returns the complex conjugate of the complex argument `x`.

     :rtype: A complex number of the same type as `x`.
  */
  inline proc conj(x: complex(?w)) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc conjf(x: complex(64)): complex(64);
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc conj(x: complex(128)): complex(128);
    if w == 64 then
      return conjf(x);
    else
      return conj(x);
  }

  /* Returns the complex conjugate of the imaginary argument `x`.

     :rtype: An imaginary number of the same type as `x`.
  */
  inline proc conj(x: imag(?w)) {
    return -x;
  }

  /* Returns the argument `x`.

     :rtype: A number that is not complex or imaginary of the same type as `x`.
  */
  inline proc conj(x: int(?w)) {
    return x;
  }

  inline proc conj(x: uint(?w)) {
    return x;
  }

  inline proc conj(x: real(?w)) {
    return x;
  }

  /* Returns the complex conjugate of the complex argument `z`.

     :rtype: A complex number of the same type as `z`.
  */
  @deprecated("'conjg' with a 'z' argument has been deprecated, please use 'conj' with an 'x' argument instead")
  inline proc conjg(z: complex(?w)) {
    return conj(z);
  }

  /* Returns the complex conjugate of the imaginary argument `z`.

     :rtype: An imaginary number of the same type as `z`.
  */
  @deprecated("'conjg' with a 'z' argument has been deprecated, please use 'conj' with an 'x' argument instead")
  inline proc conjg(z: imag(?w)) {
    return conj(z);
  }

  /* Returns the argument `z`.

     :rtype: A number that is not complex or imaginary of the same type as `z`.
  */
  @deprecated("'conjg' with a 'z' argument has been deprecated, please use 'conj' with an 'x' argument instead")
  inline proc conjg(z: int(?w)) {
    return conj(z);
  }

  @deprecated("'conjg' with a 'z' argument has been deprecated, please use 'conj' with an 'x' argument instead")
  inline proc conjg(z: uint(?w)) {
    return conj(z);
  }

  @deprecated("'conjg' with a 'z' argument has been deprecated, please use 'conj' with an 'x' argument instead")
  inline proc conjg(z: real(?w)) {
    return conj(z);
  }

  /* Returns the projection of `z` on a Riemann sphere. */
  @deprecated("'cproj' has been deprecated, please use :proc:`riemProj` instead")
  inline proc cproj(z: complex(?w)): complex(w) {
    return riemProj(z);
  }

  // When removing this deprecated function, be sure to remove chpl_cos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the cosine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cos(x: real(64)): real(64) {
    return chpl_cos(x);
  }

  inline proc chpl_cos(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cos(x: real(64)): real(64);
    return cos(x);
  }

  // When removing this deprecated function, be sure to remove chpl_cos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the cosine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cos(x : real(32)): real(32) {
    return chpl_cos(x);
  }

  inline proc chpl_cos(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cosf(x: real(32)): real(32);
    return cosf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_cos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cos(z : complex(64)): complex(64) {
    return chpl_cos(z);
  }

  inline proc chpl_cos(z : complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ccosf(z: complex(64)): complex(64);
    return ccosf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_cos and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cos' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cos(z : complex(128)): complex(128) {
    return chpl_cos(z);
  }

  inline proc chpl_cos(z : complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ccos(z: complex(128)): complex(128);
    return ccos(z);
  }


  // When removing this deprecated function, be sure to remove chpl_cosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic cosine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cosh(x: real(64)): real(64) {
    return chpl_cosh(x);
  }

  inline proc chpl_cosh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cosh(x: real(64)): real(64);
    return cosh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_cosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic cosine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cosh(x : real(32)): real(32) {
    return chpl_cosh(x);
  }

  inline proc chpl_cosh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc coshf(x: real(32)): real(32);
    return coshf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_cosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cosh(z: complex(64)): complex(64) {
    return chpl_cosh(z);
  }

  inline proc chpl_cosh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ccoshf(z: complex(64)): complex(64);
    return ccoshf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_cosh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic cosine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'cosh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc cosh(z: complex(128)): complex(128) {
    return chpl_cosh(z);
  }

  inline proc chpl_cosh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ccosh(z: complex(128)): complex(128);
    return ccosh(z);
  }


  // When removing this deprecated function, be sure to remove chpl_divceil and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns :proc:`ceil`\(`m`/`n`),
     i.e., the fraction `m`/`n` rounded up to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divceil' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divCeil` and its argument names have changed to 'x' and 'y'")
  proc divceil(param m: integral, param n: integral) param do
    return chpl_divceil(m, n);

  proc chpl_divceil(param m: integral, param n: integral) param do return
    if isNonnegative(m) then
      if isNonnegative(n) then (m + n - 1) / n
      else                     m / n
    else
      if isNonnegative(n) then m / n
      else                     (m + n + 1) / n;

  // When removing this deprecated function, be sure to remove chpl_divceil and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns :proc:`ceil`\(`m`/`n`),
     i.e., the fraction `m`/`n` rounded up to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divceil' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divCeil` and its argument names have changed to 'x' and 'y'")
  proc divceil(m: integral, n: integral) do return chpl_divceil(m, n);

  proc chpl_divceil(m: integral, n: integral) do return
    if isNonnegative(m) then
      if isNonnegative(n) then (m + n - 1) / n
      else                     m / n
    else
      if isNonnegative(n) then m / n
      else                     (m + n + 1) / n;

  // When removing this deprecated function, be sure to remove chpl_divceilpos
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /*
    A variant of :proc:`divceil` that performs no runtime checks.
    The user must ensure that both arguments are strictly positive
    (not 0) and are of a signed integer type (not `uint`).
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divceilpos' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divCeilPos` and its argument names have changed to 'x' and 'y'")
  proc divceilpos(m: integral, n: integral) {
    return chpl_divceilpos(m, n);
  }

  proc chpl_divceilpos(m: integral, n: integral) {
    if !isIntType(m.type) || !isIntType(n.type) then
      compilerError("divceilpos() accepts only arguments of signed integer types");
    return (m - 1) / n + 1;
  }

  // When removing this deprecated function, be sure to remove chpl_divfloor and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns :proc:`floor`\(`m`/`n`),
     i.e., the fraction `m`/`n` rounded down to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divfloor' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divFloor` and its argument names have changed to 'x' and 'y'")
  proc divfloor(param m: integral, param n: integral) param do return
    chpl_divfloor(m, n);

  proc chpl_divfloor(param m: integral, param n: integral) param do return
    if isNonnegative(m) then
      if isNonnegative(n) then m / n
      else                     (m - n - 1) / n
    else
      if isNonnegative(n) then (m - n + 1) / n
      else                     m / n;

  // When removing this deprecated function, be sure to remove chpl_divfloor and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns :proc:`floor`\(`m`/`n`),
     i.e., the fraction `m`/`n` rounded down to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divfloor' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divFloor` and its argument names have changed to 'x' and 'y'")
  proc divfloor(m: integral, n: integral) do return chpl_divfloor(m, n);

  proc chpl_divfloor(m: integral, n: integral) do return
    if isNonnegative(m) then
      if isNonnegative(n) then m / n
      else                     (m - n - 1) / n
    else
      if isNonnegative(n) then (m - n + 1) / n
      else                     m / n;

  // When removing this deprecated function, be sure to remove chpl_divfloorpos
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /*
    A variant of :proc:`divfloor` that performs no runtime checks.
    The user must ensure that both arguments are strictly positive
    (not 0) and are of a signed integer type (not `uint`).
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'divfloorpos' will no longer be included by default.  Please 'use' or 'import' the :mod:`Math` module to prepare for this move, noting that its name has changed to :proc:`~Math.divFloorPos` and its argument names have changed to 'x' and 'y'")
  proc divfloorpos(m: integral, n: integral) {
    return chpl_divfloorpos(m, n);
  }

  proc chpl_divfloorpos(m: integral, n: integral) {
    if !isIntType(m.type) || !isIntType(n.type) then
      compilerError("divfloorpos() accepts only arguments of signed integer types");
    return m / n;
  }

  // When removing this deprecated function, be sure to remove chpl_erf and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'erf' will no longer be included by default, please 'use' or 'import' the 'Math' module to call it")
  inline proc erf(x: real(64)): real(64) {
    return chpl_erf(x);
  }

  inline proc chpl_erf(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc erf(x: real(64)): real(64);
    return erf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_erf and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'erf' will no longer be included by default, please 'use' or 'import' the 'Math' module to call it")
  inline proc erf(x : real(32)): real(32) {
    return chpl_erf(x);
  }

  inline proc chpl_erf(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc erff(x: real(32)): real(32);
    return erff(x);
  }

  // When removing this deprecated function, be sure to remove chpl_erfc and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'erfc' will no longer be included by default, please 'use' or 'import' the 'Math' module to call it")
  inline proc erfc(x: real(64)): real(64) {
    return chpl_erfc(x);
  }

  inline proc chpl_erfc(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc erfc(x: real(64)): real(64);
    return erfc(x);
  }

  // When removing this deprecated function, be sure to remove chpl_erfc and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'erfc' will no longer be included by default, please 'use' or 'import' the 'Math' module to call it")
  inline proc erfc(x : real(32)): real(32) {
    return chpl_erfc(x);
  }

  inline proc chpl_erfc(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc erfcf(x: real(32)): real(32);
    return erfcf(x);
  }


  // When removing this deprecated function, be sure to remove chpl_exp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of the Napierian `e` raised to the power of the
     argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp(x: real(64)): real(64) {
    return chpl_exp(x);
  }

  inline proc chpl_exp(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc exp(x: real(64)): real(64);
    return exp(x);
  }

  // When removing this deprecated function, be sure to remove chpl_exp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of the Napierian `e` raised to the power of the
     argument. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp(x : real(32)): real(32) {
    return chpl_exp(x);
  }

  inline proc chpl_exp(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc expf(x: real(32)): real(32);
    return expf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_exp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of the Napierian `e` raised to the power of the
     argument. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp(z: complex(64)): complex(64) {
    return chpl_exp(z);
  }

  inline proc chpl_exp(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cexpf(z: complex(64)): complex(64);
    return cexpf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_exp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of the Napierian `e` raised to the power of the
     argument. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp(z: complex(128)): complex(128) {
    return chpl_exp(z);
  }

  inline proc chpl_exp(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cexp(z: complex(128)): complex(128);
    return cexp(z);
  }


  // When removing this deprecated function, be sure to remove chpl_exp2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of `2` raised to the power of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp2(x: real(64)): real(64) {
    return chpl_exp2(x);
  }

  inline proc chpl_exp2(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc exp2(x: real(64)): real(64);
    return exp2(x);
  }

  // When removing this deprecated function, be sure to remove chpl_exp2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the value of `2` raised to the power of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'exp2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc exp2(x : real(32)): real(32) {
    return chpl_exp2(x);
  }

  inline proc chpl_exp2(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc exp2f(x: real(32)): real(32);
    return exp2f(x);
  }


  // When removing this deprecated function, be sure to remove chpl_expm1 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns one less than the value of the Napierian `e` raised to the power
     of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'expm1' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc expm1(x: real(64)): real(64) {
    return chpl_expm1(x);
  }

  inline proc chpl_expm1(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc expm1(x: real(64)): real(64);
    return expm1(x);
  }

  // When removing this deprecated function, be sure to remove chpl_expm1 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns one less than the value of the Napierian `e` raised to the power
     of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'expm1' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc expm1(x : real(32)): real(32) {
    return chpl_expm1(x);
  }

  inline proc chpl_expm1(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc expm1f(x: real(32)): real(32);
    return expm1f(x);
  }


  /* Returns the value of the argument `x` rounded down to the nearest integer. */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc floor(x: real(64)): real(64);

  /* Returns the value of the argument `x` rounded down to the nearest integer. */
  inline proc floor(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc floorf(x: real(32)): real(32);
    return floorf(x);
  }

  /* Returns a value for which :proc:`isInf` will return `true`. */
  inline proc inf param : real(64) do return chpl_INFINITY;

  /* Returns a value for which :proc:`isInf` will return `true`. */
  @deprecated(notes="'INFINITY' has been deprecated in favor of :proc:`inf`, please use that instead")
  inline proc INFINITY param : real(64) do return inf;

  /* Returns `true` if the argument `x` is a representation of a finite value;
     `false` otherwise. */
  inline proc isFinite(x: real(64)): bool do return chpl_macro_double_isfinite(x):bool;

  /* Returns `true` if the argument `x` is a representation of a finite value;
     `false` otherwise. */
  inline proc isFinite(x: real(32)): bool do return chpl_macro_float_isfinite(x):bool;

  /* Returns `true` if the argument `x` is a representation of a finite value;
     `false` otherwise. */
  @deprecated(notes="'isfinite' is deprecated in favor of :proc:`isFinite`, please use that instead")
  inline proc isfinite(x: real(64)): bool do return isFinite(x):bool;

  /* Returns `true` if the argument `x` is a representation of a finite value;
     `false` otherwise. */
  @deprecated(notes="'isfinite' is deprecated in favor of :proc:`isFinite`, please use that instead")
  inline proc isfinite(x: real(32)): bool do return isFinite(x):bool;

  /* Returns `true` if the argument `x` is a representation of *infinity*;
     `false` otherwise. */
  inline proc isInf(x: real(64)): bool do return chpl_macro_double_isinf(x):bool;

  /* Returns `true` if the argument `x` is a representation of *infinity*;
     `false` otherwise. */
  inline proc isInf(x: real(32)): bool do return chpl_macro_float_isinf(x):bool;

  /* Returns `true` if the argument `x` is a representation of *infinity*;
     `false` otherwise. */
  @deprecated(notes="'isinf' is deprecated in favor of :proc:`isInf`, please use that instead")
  inline proc isinf(x: real(64)): bool do return isInf(x):bool;

  /* Returns `true` if the argument `x` is a representation of *infinity*;
     `false` otherwise. */
  @deprecated(notes="'isinf' is deprecated in favor of :proc:`isInf`, please use that instead")
  inline proc isinf(x: real(32)): bool do return isInf(x):bool;

  /* Returns `true` if the argument `x` does not represent a valid number;
     `false` otherwise. */
  inline proc isNan(x: real(64)): bool do return chpl_macro_double_isnan(x):bool;

  /* Returns `true` if the argument `x` does not represent a valid number;
     `false` otherwise. */
  inline proc isNan(x: real(32)): bool do return chpl_macro_float_isnan(x):bool;

  /* Returns `true` if the argument `x` does not represent a valid number;
     `false` otherwise. */
  @deprecated(notes="'isnan' is deprecated in favor of :proc:`isNan`, please use that instead")
  inline proc isnan(x: real(64)): bool do return isNan(x):bool;

  /* Returns `true` if the argument `x` does not represent a valid number;
     `false` otherwise. */
  @deprecated(notes="'isnan' is deprecated in favor of :proc:`isNan`, please use that instead")
  inline proc isnan(x: real(32)): bool do return isNan(x):bool;

  // When removing this deprecated function, be sure to remove chpl_ldexp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'ldexp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the version in the Math module is now named 'ldExp'")
  inline proc ldexp(x:real(64), n:int(32)):real(64) {
    return chpl_ldexp(x, n);
  }

  inline proc chpl_ldexp(x:real(64), n:int(32)):real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ldexp(x:real(64), n:int(32)):real(64);
    return ldexp(x, n);
  }

  // When removing this deprecated function, be sure to remove chpl_ldexp and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'ldexp' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the version in the Math module is now named 'ldExp'")
  inline proc ldexp(x:real(32), n:int(32)):real(32) {
    return chpl_ldexp(x, n);
  }

  inline proc chpl_ldexp(x:real(32), n:int(32)):real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ldexpf(x:real(32), n:int(32)):real(32);
    return ldexpf(x, n);
  }

  // When removing this deprecated function, be sure to remove chpl_lgamma and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'lgamma' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the function has been renamed to 'lnGamma' there")
  inline proc lgamma(x: real(64)): real(64) {
    return chpl_lgamma(x);
  }

  inline proc chpl_lgamma(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc lgamma(x: real(64)): real(64);
    return lgamma(x);
  }

  // When removing this deprecated function, be sure to remove chpl_lgamma and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'lgamma' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the function has been renamed to 'lnGamma' there")
  inline proc lgamma(x : real(32)): real(32) {
    return chpl_lgamma(x);
  }

  inline proc chpl_lgamma(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc lgammaf(x: real(32)): real(32);
    return lgammaf(x);
  }


  // When removing this deprecated function, be sure to remove chpl_log and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log(x: real(64)): real(64) {
    return chpl_log(x);
  }

  inline proc chpl_log(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log(x: real(64)): real(64);
    return log(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log(x : real(32)): real(32) {
    return chpl_log(x);
  }

  inline proc chpl_log(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc logf(x: real(32)): real(32);
    return logf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the natural logarithm of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log(z: complex(64)): complex(64) {
    return chpl_log(z);
  }

  inline proc chpl_log(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc clogf(z: complex(64)): complex(64);
    return clogf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_log and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the natural logarithm of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log(z: complex(128)): complex(128) {
    return chpl_log(z);
  }

  inline proc chpl_log(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc clog(z: complex(128)): complex(128);
    return clog(z);
  }


  // When removing this deprecated function, be sure to remove chpl_log10 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log10' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log10(x: real(64)): real(64) {
    return chpl_log10(x);
  }

  inline proc chpl_log10(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log10(x: real(64)): real(64);
    return log10(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log10 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log10' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log10(x : real(32)): real(32) {
    return chpl_log10(x);
  }

  inline proc chpl_log10(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log10f(x: real(32)): real(32);
    return log10f(x);
  }

  // To prevent this auto-included module from using a non-auto-included module
  // (Math)
  inline proc chpl_log1p(x: real(64)): real(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log1p(x: real(64)): real(64);
    return log1p(x);
  }

  // To prevent this auto-included module from using a non-auto-included module
  // (Math)
  inline proc chpl_log1p(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log1pf(x: real(32)): real(32);
    return log1pf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log1p and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="log1p is no longer included by default, please 'use' or 'import' the 'Math' module to call it")
  proc log1p(x: real(64)): real(64) {
    return chpl_log1p(x);
  }

  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="log1p is no longer included by default, please 'use' or 'import' the 'Math' module to call it")
  inline proc log1p(x : real(32)): real(32) {
    return chpl_log1p(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 2 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log2(x: real(64)): real(64) {
    return chpl_log2(x);
  }

  inline proc chpl_log2(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log2(x: real(64)): real(64);
    return log2(x);
  }

  // When removing this deprecated function, be sure to remove chpl_log2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 2 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log2(x : real(32)): real(32) {
    return chpl_log2(x);
  }

  inline proc chpl_log2(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc log2f(x: real(32)): real(32);
    return log2f(x);
  }

  private inline proc _logBasePow2Help(in val, baseLog2) {
    // These are used here to avoid including BitOps by default.
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_bitops_clz_32(x: c_uint) : uint(32);
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_bitops_clz_64(x: c_ulonglong) : uint(64);

    var lg2 = 0;

    if numBits(val.type) <= 32 {
      var tmp:uint(32) = val:uint(32);
      lg2 = 32 - 1 - chpl_bitops_clz_32(tmp):int;
    } else if numBits(val.type) == 64 {
      var tmp:uint(64) = val:uint(64);
      lg2 = 64 - 1 - chpl_bitops_clz_64(tmp):int;
    } else {
      compilerError("Integer width not handled in logBasePow2");
    }

    return lg2 / baseLog2;
  }

  inline proc chpl_logBasePow2(val: int(?w), baseLog2) {
    if (val < 1) {
      halt("Can't take the log() of a non-positive integer");
    }
    return _logBasePow2Help(val, baseLog2);
  }

  inline proc chpl_logBasePow2(val: uint(?w), baseLog2) {
    return _logBasePow2Help(val, baseLog2);
  }

  // When removing this deprecated function, be sure to remove chpl_log2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 2 logarithm of the argument `x`,
     rounded down.

     :rtype: `int`

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log2(val: int(?w)) {
    return chpl_log2(val);
  }

  inline proc chpl_log2(val: int(?w)) {
    // Note: move chpl_logBasePow2's contents when moving this function's
    // contents to Math
    return chpl_logBasePow2(val, 1);
  }

  // When removing this deprecated function, be sure to remove chpl_log2 and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the base 2 logarithm of the argument `x`,
     rounded down.

     :rtype: `int`

     It is an error if `x` is less than or equal to zero.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'log2' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc log2(val: uint(?w)) {
    return chpl_log2(val);
  }

  inline proc chpl_log2(val: uint(?w)) {
    // Note: move chpl_logBasePow2's contents when moving this function's
    // contents to Math
    return chpl_logBasePow2(val, 1);
  }

  //
  // min and max
  //

  @chpldoc.nodoc
  inline proc max(x: int(8), y: int(8)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: int(16), y: int(16)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: int(32), y: int(32)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: int(64), y: int(64)) do return if x > y then x else y;

  @chpldoc.nodoc
  inline proc max(x: uint(8), y: uint(8)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: uint(16), y: uint(16)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: uint(32), y: uint(32)) do return if x > y then x else y;
  @chpldoc.nodoc
  inline proc max(x: uint(64), y: uint(64)) do return if x > y then x else y;

  @chpldoc.nodoc
  inline proc max(x: real(32), y: real(32)) do return if (x > y) | isNan(x) then x else y;
  @chpldoc.nodoc
  inline proc max(x: real(64), y: real(64)) do return if (x > y) | isNan(x) then x else y;

  @chpldoc.nodoc
  inline proc max(x: int(8), y: uint(8)) do return if x > y then x : uint(8) else y;
  @chpldoc.nodoc
  inline proc max(x: int(16), y: uint(16)) do return if x > y then x : uint(16) else y;
  @chpldoc.nodoc
  inline proc max(x: int(32), y: uint(32)) do return if x > y then x : uint(32) else y;
  @chpldoc.nodoc
  inline proc max(x: int(64), y: uint(64)) do return if x > y then x : uint(64) else y;

  @chpldoc.nodoc
  inline proc max(x: uint(8), y: int(8)) do return if x > y then x else y : uint(8);
  @chpldoc.nodoc
  inline proc max(x: uint(16), y: int(16)) do return if x > y then x else y : uint(16);
  @chpldoc.nodoc
  inline proc max(x: uint(32), y: int(32)) do return if x > y then x else y : uint(32);
  @chpldoc.nodoc
  inline proc max(x: uint(64), y: int(64)) do return if x > y then x else y : uint(64);

  pragma "last resort"
  @chpldoc.nodoc
  proc max(x, y) where isAtomicType(x.type) || isAtomicType(y.type) {
    compilerError("min() and max() are not supported for atomic arguments - apply read() to those arguments first");
  }

  /* Returns the maximum value of two arguments using the ``>`` operator
     for comparison.
     If one of the arguments is :proc:`Math.nan`, the result is also nan.

     :rtype: The type of `x`.
   */
  inline proc max(x, y)
  where !isArray(x) && !isArray(y) &&
        !(isNumeric(_desync(x.type)) && isNumeric(_desync(y.type))) {
    return if x > y then x else y;
  }
  /* Returns the maximum value of 3 or more arguments using the above call.
   */
  inline proc max(x, y, z...?k) do return max(max(x, y), (...z));
  /* Returns the maximum of 2 param ``int``, ``uint``, ``real``, or ``imag``
     values as a param.
   */
  inline proc max(param x: numeric, param y: numeric) param
    where !(isComplex(x) || isComplex(y)) {
    return if x > y then x else y;
  }

  @chpldoc.nodoc
  inline proc min(x: int(8), y: int(8)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: int(16), y: int(16)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: int(32), y: int(32)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: int(64), y: int(64)) do return if x < y then x else y;

  @chpldoc.nodoc
  inline proc min(x: uint(8), y: uint(8)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: uint(16), y: uint(16)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: uint(32), y: uint(32)) do return if x < y then x else y;
  @chpldoc.nodoc
  inline proc min(x: uint(64), y: uint(64)) do return if x < y then x else y;

  @chpldoc.nodoc
  inline proc min(x: real(32), y: real(32)) do return if (x < y) | isNan(x) then x else y;
  @chpldoc.nodoc
  inline proc min(x: real(64), y: real(64)) do return if (x < y) | isNan(x) then x else y;

  @chpldoc.nodoc
  inline proc min(x: int(8), y: uint(8)) do return if x < y then x else y : int(8);
  @chpldoc.nodoc
  inline proc min(x: int(16), y: uint(16)) do return if x < y then x else y : int(16);
  @chpldoc.nodoc
  inline proc min(x: int(32), y: uint(32)) do return if x < y then x else y : int(32);
  @chpldoc.nodoc
  inline proc min(x: int(64), y: uint(64)) do return if x < y then x else y : int(64);

  @chpldoc.nodoc
  inline proc min(x: uint(8), y: int(8)) do return if x < y then x : int(8) else y;
  @chpldoc.nodoc
  inline proc min(x: uint(16), y: int(16)) do return if x < y then x : int(16) else y;
  @chpldoc.nodoc
  inline proc min(x: uint(32), y: int(32)) do return if x < y then x : int(32) else y;
  @chpldoc.nodoc
  inline proc min(x: uint(64), y: int(64)) do return if x < y then x : int(64) else y;

  pragma "last resort"
  @chpldoc.nodoc
  proc min(x, y) where isAtomicType(x.type) || isAtomicType(y.type) {
    compilerError("min() and max() are not supported for atomic arguments - apply read() to those arguments first");
  }


  /* Returns the minimum value of two arguments using the ``<`` operator
     for comparison.

     If one of the arguments is :proc:`Math.nan`, the result is also nan.

     :rtype: The type of `x`.
   */
  inline proc min(x, y)
  where !isArray(x) && !isArray(y) &&
        !(isNumeric(_desync(x.type)) && isNumeric(_desync(y.type))) {
    return if x < y then x else y;
  }
  /* Returns the minimum value of 3 or more arguments using the above call.
   */
  inline proc min(x, y, z...?k) do return min(min(x, y), (...z));
  /* Returns the minimum of 2 param ``int``, ``uint``, ``real``, or ``imag``
     values as a param.
   */
  inline proc min(param x: numeric, param y: numeric) param
    where !(isComplex(x) || isComplex(y)) {
    return if x < y then x else y;
  }

  /* Computes the mod operator on the two arguments, defined as
     ``mod(m,n) = m - n * floor(m / n)``.

     The result is always >= 0 if `n` > 0.
     It is an error if `n` == 0.
  */
  pragma "last resort"
  @deprecated("The argument names 'm' and 'n' are deprecated for param 'mod', please use 'x' and 'y' instead")
  proc mod(param m: integral, param n: integral) param {
    return mod(m, n);
  }

  /* Computes the mod operator on the two arguments, defined as
     ``mod(m,n) = m - n * floor(m / n)``.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.

     The result is always >= 0 if `n` > 0.
     It is an error if `n` == 0.
  */
  pragma "last resort"
  @deprecated("The argument names 'm' and 'n' are deprecated for 'mod', please use 'x' and 'y' instead")
  proc mod(m: integral, n: integral) {
    return mod(m, n);
  }

  /* Computes the mod operator on the two arguments, defined as
     ``mod(x,y) = x - y * floor(x / y)``.

     The result is always >= 0 if `y` > 0.
     It is an error if `y` == 0.

     .. note::
        This does not have the same behavior as the :ref:`Modulus_Operators` (%)
        when `y` is negative.
  */
  proc mod(param x: integral, param y: integral) param {
    param temp = x % y;

    // verbatim copy from the other 'mod', to simplify maintenance
    return
      if isNonnegative(y) then
        if isUintType(x.type)
        then temp
        else ( if temp >= 0 then temp else temp + y )
      else
        // y < 0
        ( if temp <= 0 then temp else temp + y );
  }

  /* Computes the mod operator on the two arguments, defined as
     ``mod(x,y) = x - y * floor(x / y)``.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.

     The result is always >= 0 if `y` > 0.
     It is an error if `y` == 0.

     .. note::
        This does not have the same behavior as the :ref:`Modulus_Operators` (%)
        when `y` is negative.
  */
  proc mod(x: integral, y: integral) {
    const temp = x % y;

    // eliminate some run-time tests if input(s) is(are) unsigned
    return
      if isNonnegative(y) then
        if isUintType(x.type)
        then temp
        else ( if temp >= 0 then temp else temp + y )
      else
        // y < 0
        ( if temp <= 0 then temp else temp + y );
  }

  /* Computes the mod operator on the two numbers, defined as
     ``mod(x,y) = x - y * floor(x / y)``.
  */
  proc mod(x: real(32), y: real(32)): real(32) {
    // This codes up the standard definition, according to Wikipedia.
    // Is there a more efficient implementation for reals?
    return x - y*floor(x/y);
  }

  /* Computes the mod operator on the two numbers, defined as
     ``mod(x,y) = x - y * floor(x / y)``.
  */
  proc mod(x: real(64), y: real(64)): real(64) {
    // This codes up the standard definition, according to Wikipedia.
    // Is there a more efficient implementation for reals?
    return x - y*floor(x/y);
  }

  /* Returns a value for which :proc:`isNan` will return `true`. */
  inline proc nan param : real(64) do return chpl_NAN;

  /* Returns a value for which :proc:`isNan` will return `true`. */
  @deprecated(notes="'NAN' is deprecated in favor of :proc:`nan`, please use that instead")
  inline proc NAN param : real(64) do return nan;


  // When removing this deprecated function, be sure to remove chpl_nearbyint
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`nearbyint` will not raise the "inexact"
     floating-point exception.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'nearbyint' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc nearbyint(x: real(64)): real(64) {
    return chpl_nearbyint(x);
  }

  inline proc chpl_nearbyint(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc nearbyint(x: real(64)): real(64);
    return nearbyint(x);
  }

  // When removing this deprecated function, be sure to remove chpl_nearbyint
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`nearbyint` will not raise the "inexact"
     floating-point exception.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'nearbyint' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc nearbyint(x : real(32)): real(32) {
    return chpl_nearbyint(x);
  }

  inline proc chpl_nearbyint(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc nearbyintf(x: real(32)): real(32);
    return nearbyintf(x);
  }

  /* Returns the phase (often called `argument`) of complex `x`, an angle (in
     radians).

     In concert with the related :proc:`abs`, the magnitude (a.k.a.
     modulus) of `x`, it can be used to recompute `x`.

     :rtype: ``real(w/2)`` when `x` has a type of ``complex(w)``.
  */
  inline proc phase(x: complex(?w)): real(w/2) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cargf(x: complex(64)): real(32);
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc carg(x: complex(128)): real(64);
    if w == 64 then
      return cargf(x);
    else
      return carg(x);
  }

  /* Returns the projection of `x` on a Riemann sphere. */
  inline proc riemProj(x: complex(?w)): complex(w) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cprojf(x: complex(64)): complex(64);
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc cproj(x: complex(128)): complex(128);
    if w == 64 then
      return cprojf(x);
    else
      return cproj(x);
  }

  // When removing this deprecated function, be sure to remove chpl_rint
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`rint` may raise the "inexact" floating-point
     exception.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'rint' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc rint(x: real(64)): real(64) {
    return chpl_rint(x);
  }

  inline proc chpl_rint(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc rint(x: real(64)): real(64);
    return rint(x);
  }

  // When removing this deprecated function, be sure to remove chpl_rint
  // and move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`rint` may raise the "inexact" floating-point
     exception.
  */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'rint' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc rint(x : real(32)): real(32) {
    return chpl_rint(x);
  }

  inline proc chpl_rint(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc rintf(x: real(32)): real(32);
    return rintf(x);
  }


  /* Returns the nearest integral value of the argument `x`, returning that
     value which is larger than `x` in absolute value for the half-way case. */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc round(x: real(64)): real(64);

  /* Returns the nearest integral value of the argument `x`, returning that
     value which is larger than `x` in absolute value for the half-way case. */
  inline proc round(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc roundf(x: real(32)): real(32);
    return roundf(x);
  }


  /* Returns the signum function of the integer argument `i`:
     1 if positive, -1 if negative, 0 if zero.
  */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for 'sgn', please use 'x' instead")
  inline proc sgn(i : int(?w)): int(8) do
    return sgn(i);

  /* Returns the signum function of the unsigned integer argument `i`:
     1 if positive, -1 if negative, 0 if zero.
  */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for 'sgn', please use 'x' instead")
  inline proc sgn(i : uint(?w)): uint(8) do
    return sgn(i);

  /* Returns the signum function of the integer param argument `i`:
     1 if positive, -1 if negative, 0 if zero.
  */
  pragma "last resort"
  @deprecated("The argument name 'i' is deprecated for param 'sgn', please use 'x' instead")
  proc sgn(param i : integral) param do
    return sgn(i);

  /* Returns the signum function of the integer argument `x`:
     1 if positive, -1 if negative, 0 if zero.
  */
  inline proc sgn(x : int(?w)): int(8) do
    return ((x > 0) : int(8) - (x < 0) : int(8)) : int(8);

  /* Returns the signum function of the unsigned integer argument `x`:
     1 if positive, -1 if negative, 0 if zero.
  */
  inline proc sgn(x : uint(?w)): uint(8) do
    return (x > 0) : uint(8);

  /* Returns the signum function of the integer param argument `x`:
     1 if positive, -1 if negative, 0 if zero.
  */
  proc sgn(param x : integral) param do
    return if x > 0 then 1 else if x == 0 then 0 else -1;

  /* Returns the signum function of the real argument `x`:
     1 if positive, -1 if negative, 0 if zero.
  */
  inline proc sgn(x : real(?w)): int(8) do
    return ((x > 0.0) : int(8) - (x < 0.0) : int(8)) : int(8);


  // When removing this deprecated function, be sure to remove chpl_sin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sin(x: real(64)): real(64) {
    return chpl_sin(x);
  }

  inline proc chpl_sin(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc sin(x: real(64)): real(64);
    return sin(x);
  }

  // When removing this deprecated function, be sure to remove chpl_sin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sin(x: real(32)): real(32) {
    return chpl_sin(x);
  }

  inline proc chpl_sin(x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc sinf(x: real(32)): real(32);
    return sinf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_sin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sin(z: complex(64)): complex(64) {
    return chpl_sin(z);
  }

  inline proc chpl_sin(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csinf(z: complex(64)): complex(64);
    return csinf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_sin and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sin' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sin(z: complex(128)): complex(128) {
    return chpl_sin(z);
  }

  inline proc chpl_sin(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csin(z: complex(128)): complex(128);
    return csin(z);
  }


  // When removing this deprecated function, be sure to remove chpl_sinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sinh(x: real(64)): real(64) {
    return chpl_sinh(x);
  }

  inline proc chpl_sinh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc sinh(x: real(64)): real(64);
    return sinh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_sinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic sine of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sinh(x : real(32)): real(32) {
    return chpl_sinh(x);
  }

  inline proc chpl_sinh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc sinhf(x: real(32)): real(32);
    return sinhf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_sinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sinh(z: complex(64)): complex(64) {
    return chpl_sinh(z);
  }

  inline proc chpl_sinh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csinhf(z: complex(64)): complex(64);
    return csinhf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_sinh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic sine of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'sinh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc sinh(z: complex(128)): complex(128) {
    return chpl_sinh(z);
  }

  inline proc chpl_sinh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csinh(z: complex(128)): complex(128);
    return csinh(z);
  }


  /* Returns the square root of the argument `x`.

     It is an error if the `x` is less than zero.
  */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc sqrt(x: real(64)): real(64);

  /* Returns the square root of the argument `x`.

     It is an error if  `x` is less than zero.
  */
  inline proc sqrt(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc sqrtf(x: real(32)): real(32);
    return sqrtf(x);
  }

  /* Returns the square root of the argument `z`. */
  inline proc sqrt(x: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csqrtf(x: complex(64)): complex(64);
    return csqrtf(x);
  }

  /* Returns the square root of the argument `z`. */
  inline proc sqrt(x: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc csqrt(x: complex(128)): complex(128);
    return csqrt(x);
  }

  /* Returns the square root of the argument `z`. */
  pragma "last resort"
  @deprecated("The argument name 'z' is deprecated for 'sqrt', please use 'x' instead")
  inline proc sqrt(z: complex(64)): complex(64) {
    return sqrt(z);
  }

  /* Returns the square root of the argument `z`. */
  pragma "last resort"
  @deprecated("The argument name 'z' is deprecated for 'sqrt', please use 'x' instead")
  inline proc sqrt(z: complex(128)): complex(128) {
    return sqrt(z);
  }


  // When removing this deprecated function, be sure to remove chpl_tan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tan(x: real(64)): real(64) {
    return chpl_tan(x);
  }

  inline proc chpl_tan(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tan(x: real(64)): real(64);
    return tan(x);
  }

  // When removing this deprecated function, be sure to remove chpl_tan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tan(x : real(32)): real(32) {
    return chpl_tan(x);
  }

  inline proc chpl_tan(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tanf(x: real(32)): real(32);
    return tanf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_tan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tan(z: complex(64)): complex(64) {
    return chpl_tan(z);
  }

  inline proc chpl_tan(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ctanf(z: complex(64)): complex(64);
    return ctanf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_tan and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tan' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tan(z: complex(128)): complex(128) {
    return chpl_tan(z);
  }

  inline proc chpl_tan(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ctan(z: complex(128)): complex(128);
    return ctan(z);
  }


  // When removing this deprecated function, be sure to remove chpl_tanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tanh(x: real(64)): real(64) {
    return chpl_tanh(x);
  }

  inline proc chpl_tanh(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tanh(x: real(64)): real(64);
    return tanh(x);
  }

  // When removing this deprecated function, be sure to remove chpl_tanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic tangent of the argument `x`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tanh(x : real(32)): real(32) {
    return chpl_tanh(x);
  }

  inline proc chpl_tanh(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tanhf(x: real(32)): real(32);
    return tanhf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_tanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tanh(z: complex(64)): complex(64) {
    return chpl_tanh(z);
  }

  inline proc chpl_tanh(z: complex(64)): complex(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ctanhf(z: complex(64)): complex(64);
    return ctanhf(z);
  }

  // When removing this deprecated function, be sure to remove chpl_tanh and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the hyperbolic tangent of the argument `z`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tanh' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  inline proc tanh(z: complex(128)): complex(128) {
    return chpl_tanh(z);
  }

  inline proc chpl_tanh(z: complex(128)): complex(128) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc ctanh(z: complex(128)): complex(128);
    return ctanh(z);
  }

  // When removing this deprecated function, be sure to remove chpl_tgamma and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tgamma' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the function has been renamed to 'gamma' there")
  inline proc tgamma(x: real(64)): real(64) {
    return chpl_tgamma(x);
  }

  inline proc chpl_tgamma(x: real(64)): real(64) {
    // Note: this extern proc was originally free standing.  It might be
    // reasonable to make it that way again when the deprecated version is
    // removed
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tgamma(x: real(64)): real(64);
    return tgamma(x);
  }

  // When removing this deprecated function, be sure to remove chpl_tgamma and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'tgamma' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it.  Note that the function has been renamed to 'gamma' there")
  inline proc tgamma(x : real(32)): real(32) {
    return chpl_tgamma(x);
  }

  inline proc chpl_tgamma(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc tgammaf(x: real(32)): real(32);
    return tgammaf(x);
  }


  /* Returns the nearest integral value to the argument `x` that is not larger
     than `x` in absolute value. */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc trunc(x: real(64)): real(64);

  /* Returns the nearest integral value to the argument `x` that is not larger
     than `x` in absolute value. */
  inline proc trunc(x : real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc truncf(x: real(32)): real(32);
    return truncf(x);
  }

  // When removing this deprecated function, be sure to remove chpl_gcd and
  // move its contents into Math.chpl to reduce the symbols living in this
  // module.
  /* Returns the greatest common divisor of the integer argument `a` and
     `b`. */
  pragma "last resort"
  @chpldoc.nodoc
  @deprecated(notes="In an upcoming release 'gcd' will no longer be included by default, please 'use' or 'import' the :mod:`Math` module to call it")
  proc gcd(in a: int,in b: int): int {
    (a, b) = (abs(a), abs(b));
    return chpl_gcd(a, b);
  }

  proc chpl_gcd(in a,in b) {
    while(b != 0) {
      (a, b) = (b, a % b);
    }
    return a;
  }

  /* Returns true if `x` and `y` are approximately equal, else returns false.

     `relTol` specifies the relative tolerance for differences between `x` and
     `y`, while `absTol` specifies the absolute tolerance.  Both must be
     positive when specified.

     `x` and `y` must be either `real`, `imag`, or `complex`.
   */
  inline proc isClose(x, y, relTol = 1e-5, absTol = 0.0): bool {
    if !((isRealValue(x) || isImagValue(x) || isComplexValue(x)) &&
         (isRealValue(y) || isImagValue(y) || isComplexValue(y))) {
      if (isArrayValue(x) || isArrayValue(y)) {
        compilerError("'isClose' does not support promotion, please call it with the individual values");
      } else {
        compilerError("x and y must be either 'real', 'imag', or 'complex', x was '" + x.type: string + "' and y was '" + y.type: string + "'");
      }
    }

    if boundsChecking && (relTol < 0) then
      HaltWrappers.boundsCheckHalt("Input value for relTol must be positive");
    if boundsChecking && (absTol < 0) then
      HaltWrappers.boundsCheckHalt("Input value for absTol must be positive");
    var diff: real = abs(x-y);
    return ( (diff<=abs(relTol*y)) || (diff<=abs(relTol*x)) || (diff<=absTol) );
  }

  /* Returns true if `x` and `y` are approximately equal, else returns false. */
  @deprecated("isclose with 'rtol' and 'atol' arguments is now deprecated, please use :proc:`isClose` with 'relTol' and 'absTol' arguments instead")
  inline proc isclose(x, y, rtol = 1e-5, atol = 0.0): bool {
    if boundsChecking && (rtol < 0) then
      HaltWrappers.boundsCheckHalt("Input value for rtol must be positive");
    if boundsChecking && (atol < 0) then
      HaltWrappers.boundsCheckHalt("Input value for atol must be positive");
    var diff: real = abs(x-y);
    return ( (diff<=abs(rtol*y)) || (diff<=abs(rtol*x)) || (diff<=atol) );
  }

  /* Returns true if the sign of `x` is negative, else returns false. It detects
     the sign bit of zeroes, infinities, and nans */
  @unstable("signbit is unstable and may change its name in the future")
  inline proc signbit(x : real(32)): bool {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_macro_float_signbit(x: real(32)): c_int;
    return chpl_macro_float_signbit(x): bool;
  }

  /* Returns true if the sign of `x` is negative, else returns false. It detects
     the sign bit of zeroes, infinities, and nans */
  @unstable("signbit is unstable and may change its name in the future")
  inline proc signbit(x : real(64)): bool {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_macro_double_signbit(x: real(64)): c_int;
    return chpl_macro_double_signbit(x): bool;
  }

} // end of module AutoMath

// TODO: Consolidate overloaded signatures, to simplify the documentation.
