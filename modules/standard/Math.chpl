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

This module provides frequently used mathematical constants and functions.

It includes wrappers for many of the constants and functions in
the C Math library, which is part of the C Language Standard (ISO/IEC 9899)
as described in Section 7.12.  Please consult that standard for an
authoritative description of the expected properties of those constants and
routines.

In general, where the C math library provides a *double* and a *float* version
of a function, the float version has a suffix 'f'.  In the Chapel interface,
the suffix is dropped, and the type of the operand determines which version is
called -- according to the usual function overloading and resolution rules.
Normally, the result has the same precision
as the argument(s).  Please consult the C standard for specifics.

Error Handling -- At present, Chapel does not provide control over error
handling in the Math module.  The default behavior is as if the macro
``math_errhandling`` is set to 0: Given erroneous input at run-time,
all math functions will return an implementation-defined value; no
exception will be generated.

Automatically Available Symbols
-------------------------------

.. note::

   These symbols can also be accessed using ``Math.`` as their qualified access
   prefix.

.. include:: AutoMath.rst
  :start-line: 7
  :start-after: Automatically included Math symbols
  :end-before: .. function::

Non-Automatically Available Symbols
-----------------------------------

.. _math-constants:

Constants
^^^^^^^^^
:param:`~Math.e`
:param:`~Math.log2E`
:param:`~Math.log10E`
:param:`~Math.ln2`
:param:`~Math.ln10`
:param:`~Math.pi`
:param:`~Math.halfPi`
:param:`~Math.quarterPi`
:param:`~Math.reciprPi`
:param:`~Math.twiceReciprPi`
:param:`~Math.twiceReciprSqrtPi`
:param:`~Math.sqrt2`
:param:`~Math.reciprSqrt2`

.. _math-trigonometry:

Trigonometric Functions
^^^^^^^^^^^^^^^^^^^^^^^
:proc:`~Math.acos`
:proc:`~Math.acosh`
:proc:`~Math.asin`
:proc:`~Math.asinh`
:proc:`~Math.atan`
:proc:`~Math.atan2`
:proc:`~Math.atanh`
:proc:`~Math.cos`
:proc:`~Math.cosh`
:proc:`~Math.sin`
:proc:`~Math.sinh`
:proc:`~Math.tan`
:proc:`~Math.tanh`

.. _math-log:

Log Functions
^^^^^^^^^^^^^
:proc:`~Math.ln`
:proc:`~Math.log`
:proc:`~Math.log10`
:proc:`~Math.log1p`
:proc:`~Math.logBasePow2`
:proc:`~Math.log2`

.. _math-exponential:

Exponential Functions
^^^^^^^^^^^^^^^^^^^^^
:proc:`~Math.exp`
:proc:`~Math.exp2`
:proc:`~Math.expm1`
:proc:`~Math.ldExp`

.. _math-rounding:

Rounding
^^^^^^^^
:proc:`~Math.divCeil`
:proc:`~Math.divCeilPos`
:proc:`~Math.divFloor`
:proc:`~Math.divFloorPos`
:proc:`~Math.nearbyint`
:proc:`~Math.rint`

.. _math-gamma:

Gamma Functions
^^^^^^^^^^^^^^^
:proc:`~Math.gamma`
:proc:`~Math.lnGamma`

.. _math-error:

Error Functions
^^^^^^^^^^^^^^^
:proc:`~Math.erf`
:proc:`~Math.erfc`

.. _math-algorithms:

Algorithms
^^^^^^^^^^
:proc:`~Math.gcd`

.. _math-bessel:

Bessel Functions
^^^^^^^^^^^^^^^^
:proc:`~Math.j0`
:proc:`~Math.j1`
:proc:`~Math.jn`
:proc:`~Math.y0`
:proc:`~Math.y1`
:proc:`~Math.yn`

.. _math-optimization:

Optimization Functions
^^^^^^^^^^^^^^^^^^^^^^
:proc:`~Math.fma`

.. _automath-constant-and-function-definitions:

Automatically Included Constant and Function Definitions
--------------------------------------------------------

.. include:: AutoMath.rst
  :start-after: :proc:`~Math.mod`

.. _math-constant-and-function-definitions:

Constant and Function Definitions for Math
------------------------------------------

*/
module Math {
  private import HaltWrappers;
  private use CTypes;
  public use AutoMath;

  //////////////////////////////////////////////////////////////////////////
  // Constants (included in chpldocs)
  //

  /* e - exp(1) or  the base of the natural logarithm */
  param e = 2.7182818284590452354;
  /* log2(e) */
  param log2E = 1.4426950408889634074;
  /* log2(e) */
  @deprecated(notes="'log2_e' is deprecated, please use :param:`log2E` instead")
  param log2_e = 1.4426950408889634074;
  /* log10(e) */
  param log10E = 0.43429448190325182765;
  /* log10(e) */
  @deprecated(notes="'log10_e' is deprecated, please use :param:`log10E` instead")
  param log10_e = 0.43429448190325182765;
  /* ln(2) (natural logarithm) */
  param ln2 = 0.69314718055994530942;
  /* log(2) (natural logarithm) */
  @deprecated(notes="'ln_2' is deprecated, please use :param:`ln2` instead")
  param ln_2 = 0.69314718055994530942;
  /* ln(10) (natural logarithm) */
  param ln10 = 2.30258509299404568402;
  /* log(10) (natural logarithm) */
  @deprecated(notes="'ln_10' is deprecated, please use :param:`ln10` instead")
  param ln_10 = 2.30258509299404568402;
  /* pi - the circumference/the diameter of a circle */
  param pi = 3.14159265358979323846;
  /* pi/2 */
  @unstable("'halfPi' is unstable due to questions about its utility.  If you are seeing negative performance impacts from using 'pi/2' instead of this 'param', please let us know!")
  param halfPi = 1.57079632679489661923;
  /* pi/2 */
  @deprecated(notes="'half_pi' is deprecated, please use :param:`halfPi` or 'pi/2' instead")
  param half_pi = 1.57079632679489661923;
  /* pi/4 */
  @unstable("'quarterPi' is unstable due to questions about its utility.  If you are seeing negative performance impacts from using 'pi/4' instead of this 'param', please let us know!")
  param quarterPi = 0.78539816339744830962;
  /* pi/4 */
  @deprecated(notes="'quarter_pi' is deprecated, please use :param:`quarterPi` or 'pi/4' instead")
  param quarter_pi = 0.78539816339744830962;
  /* 1/pi */
  @unstable("'reciprPi' is unstable due to questions about its utility.  If you are seeing negative performance impacts from using '1/pi' instead of this 'param', please let us know!")
  param reciprPi = 0.31830988618379067154;
  /* 1/pi */
  @deprecated(notes="'recipr_pi' is deprecated, please use :param:`reciprPi` or '1/pi' instead")
  param recipr_pi = 0.31830988618379067154;
  /* 2/pi */
  @unstable("'twiceReciprPi' is unstable due to questions about its utility.  If you are seeing negative performance impacts from using '2/pi' instead of this 'param', please let us know!")
  param twiceReciprPi = 0.63661977236758134308;
  /* 2/pi */
  @deprecated(notes="'twice_recipr_pi' is deprecated, please use :param:`twiceReciprPi` or '2/pi' instead")
  param twice_recipr_pi = 0.63661977236758134308;
  /* 2/sqrt(pi) */
  @unstable("'twiceReciprSqrtPi' is unstable due to questions about its utility.  If you are using this symbol, please let us know!")
  param twiceReciprSqrtPi = 1.12837916709551257390;
  /* 2/sqrt(pi) */
  @deprecated(notes="'twice_recipr_sqrt_pi' is deprecated, please use :param:`twiceReciprSqrtPi` or '2/sqrt(pi)' instead")
  param twice_recipr_sqrt_pi = 1.12837916709551257390;
  /* sqrt(2) */
  @unstable("'sqrt2' is unstable due to questions about its utility.  If you are using this symbol, please let us know!")
  param sqrt2 = 1.41421356237309504880;
  /* sqrt(2) */
  @deprecated(notes="'sqrt_2' is deprecated, please use :param:`sqrt2` or 'sqrt(2)' instead")
  param sqrt_2 = 1.41421356237309504880;
  /* 1/sqrt(2) */
  @unstable("'reciprSqrt2' is unstable due to questions about its utility.  If you are using this symbol, please let us know!")
  param reciprSqrt2 = 0.70710678118654752440;
  /* 1/sqrt(2) */
  @deprecated(notes="'recipr_sqrt_2' is deprecated, please use :param:`reciprSqrt2` or '1/sqrt(2)' instead")
  param recipr_sqrt_2 = 0.70710678118654752440;

  /* Returns the arc cosine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  inline proc acos(x: real(64)): real(64) {
    return chpl_acos(x);
  }

  /* Returns the arc cosine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  inline proc acos(x : real(32)): real(32) {
    return chpl_acos(x);
  }

  /* Returns the arc cosine of the argument `x`. */
  inline proc acos(x: complex(64)): complex(64) {
    return chpl_acos(x);
  }

  /* Returns the arc cosine of the argument `x`. */
  inline proc acos(x: complex(128)): complex(128) {
    return chpl_acos(x);
  }

  /* Returns the inverse hyperbolic cosine of the argument `x`.

     It is an error if `x` is less than 1.
  */
  inline proc acosh(x: real(64)): real(64) {
    return chpl_acosh(x);
  }

  /* Returns the inverse hyperbolic cosine of the argument `x`.

     It is an error if `x` is less than 1.
  */
  inline proc acosh(x : real(32)): real(32) {
    return chpl_acosh(x);
  }

  /* Returns the inverse hyperbolic cosine of the argument `x`. */
  inline proc acosh(x: complex(64)): complex(64) {
    return chpl_acosh(x);
  }

  /* Returns the inverse hyperbolic cosine of the argument `x`. */
  inline proc acosh(x: complex(128)): complex(128) {
    return chpl_acosh(x);
  }

  /* Returns the arc sine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  inline proc asin(x: real(64)): real(64) {
    return chpl_asin(x);
  }

  /* Returns the arc sine of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1.
  */
  inline proc asin(x : real(32)): real(32) {
    return chpl_asin(x);
  }

  /* Returns the arc sine of the argument `x`. */
  inline proc asin(x: complex(64)): complex(64) {
    return chpl_asin(x);
  }

  /* Returns the arc sine of the argument `x`. */
  inline proc asin(x: complex(128)): complex(128) {
    return chpl_asin(x);
  }

  /* Returns the inverse hyperbolic sine of the argument `x`. */
  inline proc asinh(x: real(64)): real(64) {
    return chpl_asinh(x);
  }

  /* Returns the inverse hyperbolic sine of the argument `x`. */
  inline proc asinh(x : real(32)): real(32) {
    return chpl_asinh(x);
  }

  /* Returns the inverse hyperbolic sine of the argument `x`. */
  inline proc asinh(x: complex(64)): complex(64) {
    return chpl_asinh(x);
  }

  /* Returns the inverse hyperbolic sine of the argument `x`. */
  inline proc asinh(x: complex(128)): complex(128) {
    return chpl_asinh(x);
  }

  /* Returns the arc tangent of the argument `x`. */
  inline proc atan(x: real(64)): real(64) {
    return chpl_atan(x);
  }

  /* Returns the arc tangent of the argument `x`. */
  inline proc atan(x : real(32)): real(32) {
    return chpl_atan(x);
  }

  /* Returns the arc tangent of the argument `x`. */
  inline proc atan(x: complex(64)): complex(64) {
    return chpl_atan(x);
  }

  /* Returns the arc tangent of the argument `x`. */
  inline proc atan(x: complex(128)): complex(128) {
    return chpl_atan(x);
  }

  /* Returns the arc tangent of the ratio of the two arguments.

     This is equivalent to
     the arc tangent of `y` / `x` except that the signs of `y`
     and `x` are used to determine the quadrant of the result. */
  inline proc atan2(y: real(64), x: real(64)): real(64) {
    return chpl_atan2(y, x);
  }

  /* Returns the arc tangent of the ratio of the two arguments.

     This is equivalent to
     the arc tangent of `y` / `x` except that the signs of `y`
     and `x` are used to determine the quadrant of the result. */
  inline proc atan2(y : real(32), x: real(32)): real(32) {
    return chpl_atan2(y, x);
  }

  /* Returns the inverse hyperbolic tangent of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1. */
  inline proc atanh(x: real(64)): real(64) {
    return chpl_atanh(x);
  }

  /* Returns the inverse hyperbolic tangent of the argument `x`.

     It is an error if `x` is less than -1 or greater than 1. */
  inline proc atanh(x : real(32)): real(32) {
    return chpl_atanh(x);
  }

  /* Returns the inverse hyperbolic tangent of the argument `x`. */
  inline proc atanh(x: complex(64)): complex(64) {
    return chpl_atanh(x);
  }

  /* Returns the inverse hyperbolic tangent of the argument `x`. */
  inline proc atanh(x: complex(128)): complex(128) {
    return chpl_atanh(x);
  }

  /* Returns the cosine of the argument `x`. */
  inline proc cos(x: real(64)): real(64) {
    return chpl_cos(x);
  }

  /* Returns the cosine of the argument `x`. */
  inline proc cos(x : real(32)): real(32) {
    return chpl_cos(x);
  }

  /* Returns the cosine of the argument `x`. */
  inline proc cos(x : complex(64)): complex(64) {
    return chpl_cos(x);
  }

  /* Returns the cosine of the argument `x`. */
  inline proc cos(x : complex(128)): complex(128) {
    return chpl_cos(x);
  }

  /* Returns the hyperbolic cosine of the argument `x`. */
  inline proc cosh(x: real(64)): real(64) {
    return chpl_cosh(x);
  }

  /* Returns the hyperbolic cosine of the argument `x`. */
  inline proc cosh(x : real(32)): real(32) {
    return chpl_cosh(x);
  }

  /* Returns the hyperbolic cosine of the argument `x`. */
  inline proc cosh(x: complex(64)): complex(64) {
    return chpl_cosh(x);
  }

  /* Returns the hyperbolic cosine of the argument `x`. */
  inline proc cosh(x: complex(128)): complex(128) {
    return chpl_cosh(x);
  }

  /* Returns :proc:`~Math.ceil`\(`x`/`y`),
     i.e., the fraction `x`/`y` rounded up to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  proc divCeil(param x: integral, param y: integral) param do
    return chpl_divceil(x, y);

  /* Returns :proc:`~Math.ceil`\(`x`/`y`),
     i.e., the fraction `x`/`y` rounded up to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  proc divCeil(x: integral, y: integral) do return chpl_divceil(x, y);

  /*
    A variant of :proc:`divCeil` that performs no runtime checks.
    The user must ensure that both arguments are strictly positive
    (not 0) and are of a signed integer type (not `uint`).
  */
  @unstable("divCeilPos is unstable due to questions about its utility.  If you find this function valuable, please let us know!")
  proc divCeilPos(x: integral, y: integral) {
    return chpl_divceilpos(x, y);
  }

  /* Returns :proc:`~Math.floor`\(`x`/`y`),
     i.e., the fraction `x`/`y` rounded down to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  proc divFloor(param x: integral, param y: integral) param do return
    chpl_divfloor(x, y);

  /* Returns :proc:`~Math.floor`\(`x`/`y`),
     i.e., the fraction `x`/`y` rounded down to the nearest integer.

     If the arguments are of unsigned type, then
     fewer conditionals will be evaluated at run time.
  */
  proc divFloor(x: integral, y: integral) do return chpl_divfloor(x, y);

  /*
    A variant of :proc:`divFloor` that performs no runtime checks.
    The user must ensure that both arguments are strictly positive
    (not 0) and are of a signed integer type (not `uint`).
  */
  @unstable("divFloorPos is unstable due to questions about its utility.  If you find this function valuable, please let us know!")
  proc divFloorPos(x: integral, y: integral) {
    return chpl_divfloorpos(x, y);
  }

  /* Returns the error function of the argument `x`. This is equivalent to
     ``2/sqrt(pi)`` * the integral of ``exp(-t**2)dt`` from 0 to `x`. */
  @unstable("'erf' is unstable and may be renamed or moved to a different module in the future")
  inline proc erf(x: real(64)): real(64) {
    return chpl_erf(x);
  }

  /* Returns the error function of the argument `x`. This is equivalent to
     ``2/sqrt(pi)`` * the integral of ``exp(-t**2)dt`` from 0 to `x`. */
  @unstable("'erf' is unstable and may be renamed or moved to a different module in the future")
  inline proc erf(x : real(32)): real(32) {
    return chpl_erf(x);
  }

  /* Returns the complementary error function of the argument `x`.
     This is equivalent to 1.0 - :proc:`erf`\(`x`).
  */
  @unstable("'erfc' is unstable and may be renamed or moved to a different module in the future")
  inline proc erfc(x: real(64)): real(64) {
    return chpl_erfc(x);
  }

  /* Returns the complementary error function of the argument `x`.
     This is equivalent to 1.0 - :proc:`erf`\(`x`).
  */
  @unstable("'erfc' is unstable and may be renamed or moved to a different module in the future")
  inline proc erfc(x : real(32)): real(32) {
    return chpl_erfc(x);
  }

  /* Returns the value of the Napierian :param:`e` raised to the power of the
     argument `x`. */
  inline proc exp(x: real(64)): real(64) {
    return chpl_exp(x);
  }

  /* Returns the value of the Napierian :param:`e` raised to the power of the
     argument `x`. */
  inline proc exp(x : real(32)): real(32) {
    return chpl_exp(x);
  }

  /* Returns the value of the Napierian :param:`e` raised to the power of the
     argument `x`. */
  inline proc exp(x: complex(64)): complex(64) {
    return chpl_exp(x);
  }

  /* Returns the value of the Napierian :param:`e` raised to the power of the
     argument `x`. */
  inline proc exp(x: complex(128)): complex(128) {
    return chpl_exp(x);
  }

  /* Returns the value of `2` raised to the power of the argument `x`. */
  inline proc exp2(x: real(64)): real(64) {
    return chpl_exp2(x);
  }

  /* Returns the value of `2` raised to the power of the argument `x`. */
  inline proc exp2(x : real(32)): real(32) {
    return chpl_exp2(x);
  }

  /* Returns one less than the value of the Napierian :param:`e` raised to the
     power of the argument `x`. */
  inline proc expm1(x: real(64)): real(64) {
     return chpl_expm1(x); }

  /* Returns one less than the value of the Napierian :param:`e` raised to the
     power of the argument `x`. */
  inline proc expm1(x : real(32)): real(32) {
    return chpl_expm1(x);
  }

  /* Returns the gamma function of the argument `x`. */
  inline proc gamma(x: real(64)): real(64) {
    return chpl_tgamma(x);
  }

  /* Returns the gamma function of the argument `x`. */
  inline proc gamma(x : real(32)): real(32) {
    return chpl_tgamma(x);
  }

  /* Returns the value of the argument `x` multiplied by 2 raised to the
     argument `exp` power, i.e., ``x * 2**exp``. */
  inline proc ldExp(x:real(64), exp:int(32)):real(64) {
    return chpl_ldexp(x, exp);
  }

  /* Returns the value of the argument `x` multiplied by 2 raised to the
     argument `exp` power, i.e., ``x * 2**exp``. */
  inline proc ldExp(x:real(32), exp:int(32)):real(32) {
    return chpl_ldexp(x, exp);
  }

  /* Returns the value of the argument `x` multiplied by 2 raised to the
     argument `n` power, i.e., ``x * 2**n``. */
  @deprecated(notes="'ldexp' with an 'n' argument has been deprecated, please use :proc:`ldExp` with an 'exp' argument instead")
  inline proc ldexp(x:real(64), n:int(32)):real(64) {
    return ldExp(x, n);
  }

  /* Returns the value of the argument `x` multiplied by 2 raised to the
     argument `n` power, i.e., ``x * 2**n``. */
  @deprecated(notes="'ldexp' with an 'n' argument has been deprecated, please use :proc:`ldExp` with an 'exp' argument instead")
  inline proc ldexp(x:real(32), n:int(32)):real(32) {
    return ldExp(x, n);
  }

  /* Returns the natural logarithm of the absolute value
     of the gamma function of the argument `x`.
  */
  inline proc lnGamma(x: real(64)): real(64) {
    return chpl_lgamma(x);
  }

  /* Returns the natural logarithm of the absolute value
     of the gamma function of the argument `x`.
  */
  inline proc lnGamma(x : real(32)): real(32) {
    return chpl_lgamma(x);
  }

  /* Returns the natural logarithm of the absolute value
     of the gamma function of the argument `x`.
  */
  @deprecated(notes="'lgamma' has been deprecated in favor of :proc:`lnGamma`, please use that instead")
  inline proc lgamma(x: real(64)): real(64) {
    return lnGamma(x);
  }

  /* Returns the natural logarithm of the absolute value
     of the gamma function of the argument `x`.
  */
  @deprecated(notes="'lgamma' has been deprecated in favor of :proc:`lnGamma`, please use that instead")
  inline proc lgamma(x : real(32)): real(32) {
    return lnGamma(x);
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc ln(x: real(64)): real(64) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc ln(x : real(32)): real(32) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`. */
  inline proc ln(x: complex(64)): complex(64) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`. */
  inline proc ln(x: complex(128)): complex(128) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'ln' that takes an int argument is unstable and may change its return type in the future")
  inline proc ln(x: int(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return ln(x: real(32));
    } else {
      return ln(x: real(w));
    }
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'ln' that takes an uint argument is unstable and may change its return type in the future")
  inline proc ln(x: uint(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return ln(x: real(32));
    } else {
      return ln(x: real(w));
    }
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log(x: real(64)): real(64) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log(x : real(32)): real(32) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`. */
  inline proc log(x: complex(64)): complex(64) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`. */
  inline proc log(x: complex(128)): complex(128) {
    return chpl_log(x);
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log' that takes an int argument is unstable and may change its return type in the future")
  inline proc log(x: int(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log(x: real(32));
    } else {
      return log(x: real(w));
    }
  }

  /* Returns the natural logarithm of the argument `x`.

     It is an error if `x` is equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log' that takes an uint argument is unstable and may change its return type in the future")
  inline proc log(x: uint(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log(x: real(32));
    } else {
      return log(x: real(w));
    }
  }

  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log10(x: real(64)): real(64) {
    return chpl_log10(x);
  }

  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log10(x : real(32)): real(32) {
    return chpl_log10(x);
  }

  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log10' that takes an int argument is unstable and may change its return type in the future")
  inline proc log10(x: int(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log10(x: real(32));
    } else {
      return log10(x: real(w));
    }
  }

  /* Returns the base 10 logarithm of the argument `x`.

     It is an error if `x` is equal to zero.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log10' that takes an uint argument is unstable and may change its return type in the future")
  inline proc log10(x: uint(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log10(x: real(32));
    } else {
      return log10(x: real(w));
    }
  }

  /* Returns the natural logarithm of `x` + 1.

     It is an error if `x` is less than or equal to -1.
  */
  pragma "fn synchronization free"
  pragma "codegen for CPU and GPU"
  extern proc log1p(x: real(64)): real(64);

  /* Returns the natural logarithm of `x` + 1.

     It is an error if `x` is less than or equal to -1.
  */
  inline proc log1p(x : real(32)): real(32) {
    return chpl_log1p(x);
  }

  /* Returns the natural logarithm of `x` + 1.

     It is an error if `x` is less than or equal to -1.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log1p' that takes an int argument is unstable and may change its return type in the future")
  inline proc log1p(x: int(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log1p(x: real(32));
    } else {
      return log1p(x: real(w));
    }
  }

  /* Returns the natural logarithm of `x` + 1.
  */
  @chpldoc.nodoc
  @unstable("The version of 'log1p' that takes an uint argument is unstable and may change its return type in the future")
  inline proc log1p(x: uint(?w)) {
    if (w < 32) {
      // These were coerced to real(32) prior to the existence of this overload,
      // so maintain that behavior for now.
      return log1p(x: real(32));
    } else {
      return log1p(x: real(w));
    }
  }

  /* Returns the log to the base `2**exp` of the given `x` value.
     If `exp` is `1`, then returns the log to the base `2`;
     if `exp` is `2`, then returns the log to the base `4`, etc.
     Any fractional part is discarded.

     :rtype: `int`
  */
  @unstable("'logBasePow2' is unstable due to questions about its utility.  If you rely on this function, please let us know!")
  inline proc logBasePow2(x: int(?w), exp) {
    return chpl_logBasePow2(x, exp);
  }

  /* Returns the log to the base `2**exp` of the given `x` value.
     If `exp` is `1`, then returns the log to the base `2`;
     if `exp` is `2`, then returns the log to the base `4`, etc.
     Any fractional part is discarded.

     :rtype: `int`
  */
  @unstable("'logBasePow2' is unstable due to questions about its utility.  If you rely on this function, please let us know!")
  inline proc logBasePow2(x: uint(?w), exp) {
    return chpl_logBasePow2(x, exp);
  }

  /* Returns the log to the base `2**baseLog2` of the given `in` value.
     If `baseLog2` is `1`, then returns the log to the base `2`;
     if `baseLog2` is `2`, then returns the log to the base `4`, etc.
     Any fractional part is discarded.

     :rtype: `int`
  */
  pragma "last resort"
  @deprecated("The 'val' and 'baseLog2' argument names are now deprecated, please use 'x' and 'exp' respectively")
  inline proc logBasePow2(val: int(?w), baseLog2) {
    return chpl_logBasePow2(val, baseLog2);
  }

  /* Returns the log to the base `2**baseLog2` of the given `in` value.
     If `baseLog2` is `1`, then returns the log to the base `2`;
     if `baseLog2` is `2`, then returns the log to the base `4`, etc.
     Any fractional part is discarded.

     :rtype: `int`
  */
  pragma "last resort"
  @deprecated("The 'val' and 'baseLog2' argument names are now deprecated, please use 'x' and 'exp' respectively")
  inline proc logBasePow2(val: uint(?w), baseLog2) {
    return chpl_logBasePow2(val, baseLog2);
  }

  /* Returns the base 2 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log2(x: real(64)): real(64) {
    return chpl_log2(x);
  }

  /* Returns the base 2 logarithm of the argument `x`.

     It is an error if `x` is less than or equal to zero.
  */
  inline proc log2(x : real(32)): real(32) {
    return chpl_log2(x);
  }

  /* Returns the base 2 logarithm of the argument `x`,
     rounded down.

     :rtype: `int`

     It is an error if `x` is less than or equal to zero.
  */
  @unstable("The version of 'log2' that takes an int argument is unstable")
  inline proc log2(x: int(?w)) {
    return chpl_log2(x);
  }

  /* Returns the base 2 logarithm of the argument `x`,
     rounded down.

     :rtype: `int`

     It is an error if `x` is equal to zero.
  */
  @unstable("The version of 'log2' that takes an uint argument is unstable")
  inline proc log2(x: uint(?w)) {
    return chpl_log2(x);
  }

  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`nearbyint` will not raise the "inexact"
     floating-point exception.
  */
  @unstable("nearbyint is unstable while we design more thorough rounding support")
  inline proc nearbyint(x: real(64)): real(64) {
    return chpl_nearbyint(x);
  }

  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`nearbyint` will not raise the "inexact"
     floating-point exception.
  */
  @unstable("nearbyint is unstable while we design more thorough rounding support")
  inline proc nearbyint(x : real(32)): real(32) {
    return chpl_nearbyint(x);
  }

  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`rint` may raise the "inexact"
     floating-point exception.
  */
  @unstable("rint is unstable while we design more thorough rounding support")
  inline proc rint(x: real(64)): real(64) {
    return chpl_rint(x);
  }

  /* Returns the rounded integral value of the argument `x` determined by the
     current rounding direction.  :proc:`rint` may raise the "inexact" floating-point
     exception.
  */
  @unstable("rint is unstable while we design more thorough rounding support")
  inline proc rint(x : real(32)): real(32) {
    return chpl_rint(x);
  }

  /* Returns the sine of the argument `x`. */
  inline proc sin(x: real(64)): real(64) {
    return chpl_sin(x);
  }

  /* Returns the sine of the argument `x`. */
  inline proc sin(x: real(32)): real(32) {
    return chpl_sin(x);
  }

  /* Returns the sine of the argument `x`. */
  inline proc sin(x: complex(64)): complex(64) {
    return chpl_sin(x);
  }

  /* Returns the sine of the argument `x`. */
  inline proc sin(x: complex(128)): complex(128) {
    return chpl_sin(x);
  }

  /* Returns the hyperbolic sine of the argument `x`. */
  inline proc sinh(x: real(64)): real(64) {
    return chpl_sinh(x);
  }

  /* Returns the hyperbolic sine of the argument `x`. */
  inline proc sinh(x : real(32)): real(32) {
    return chpl_sinh(x);
  }

  /* Returns the hyperbolic sine of the argument `x`. */
  inline proc sinh(x: complex(64)): complex(64) {
    return chpl_sinh(x);
  }

  /* Returns the hyperbolic sine of the argument `x`. */
  inline proc sinh(x: complex(128)): complex(128) {
    return chpl_sinh(x);
  }

  /* Returns the tangent of the argument `x`. */
  inline proc tan(x: real(64)): real(64) {
    return chpl_tan(x);
  }

  /* Returns the tangent of the argument `x`. */
  inline proc tan(x : real(32)): real(32) {
    return chpl_tan(x);
  }

  /* Returns the tangent of the argument `x`. */
  inline proc tan(x: complex(64)): complex(64) {
    return chpl_tan(x);
  }

  /* Returns the tangent of the argument `x`. */
  inline proc tan(x: complex(128)): complex(128) {
    return chpl_tan(x);
  }

  /* Returns the hyperbolic tangent of the argument `x`. */
  inline proc tanh(x: real(64)): real(64) {
    return chpl_tanh(x);
  }

  /* Returns the hyperbolic tangent of the argument `x`. */
  inline proc tanh(x : real(32)): real(32) {
    return chpl_tanh(x);
  }

  /* Returns the hyperbolic tangent of the argument `x`. */
  inline proc tanh(x: complex(64)): complex(64) {
    return chpl_tanh(x);
  }

  /* Returns the hyperbolic tangent of the argument `x`. */
  inline proc tanh(x: complex(128)): complex(128) {
    return chpl_tanh(x);
  }

  /* Returns the gamma function of the argument `x`. */
  @deprecated("'tgamma' has been deprecated in favor of :proc:`gamma`, please use that instead")
  inline proc tgamma(x: real(64)): real(64) {
    return chpl_tgamma(x);
  }

  /* Returns the gamma function of the argument `x`. */
  @deprecated("'tgamma' has been deprecated in favor of :proc:`gamma`, please use that instead")
  inline proc tgamma(x : real(32)): real(32) {
    return chpl_tgamma(x);
  }

  /* Returns the greatest common divisor of the integer arguments `x` and
     `y`. */
  proc gcd(in x: int,in y: int): int {
    (x, y) = (abs(x), abs(y));
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the integer arguments `x` and
     `y`. */
  proc gcd(in x: int(32),in y: int(32)): int(32) {
    (x, y) = (abs(x), abs(y));
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the integer arguments `x` and
     `y`. */
  proc gcd(in x: int(16),in y: int(16)): int(16) {
    (x, y) = (abs(x), abs(y));
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the integer arguments `x` and
     `y`. */
  proc gcd(in x: int(8),in y: int(8)): int(8) {
    (x, y) = (abs(x), abs(y));
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the unsigned integer arguments `x`
     and `y`. */
  proc gcd(in x: uint(64),in y: uint(64)): uint(64) {
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the unsigned integer arguments `x`
     and `y`. */
  proc gcd(in x: uint(32),in y: uint(32)): uint(32) {
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the unsigned integer arguments `x`
     and `y`. */
  proc gcd(in x: uint(16),in y: uint(16)): uint(16) {
    return chpl_gcd(x, y);
  }

  /* Returns the greatest common divisor of the unsigned integer arguments `x`
     and `y`. */
  proc gcd(in x: uint(8),in y: uint(8)): uint(8) {
    return chpl_gcd(x, y);
  }

  /* Returns the Bessel function of the first kind of order `0` of `x`. */
  @unstable("'j0' is unstable and may be renamed or moved to a different module in the future")
  inline proc j0(x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_j0(x: real(32)): real(32);
    return chpl_float_j0(x);
  }

  /* Returns the Bessel function of the first kind of order `0` of `x`. */
  @unstable("'j0' is unstable and may be renamed or moved to a different module in the future")
  inline proc j0(x: real(64)): real(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc j0(x: real(64)): real(64);
    return j0(x);
  }

  /* Returns the Bessel function of the first kind of order `1` of `x`. */
  @unstable("'j1' is unstable and may be renamed or moved to a different module in the future")
  inline proc j1(x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_j1(x: real(32)): real(32);
    return chpl_float_j1(x);
  }

  /* Returns the Bessel function of the first kind of order `1` of `x`. */
  @unstable("'j1' is unstable and may be renamed or moved to a different module in the future")
  inline proc j1(x: real(64)): real(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc j1(x: real(64)): real(64);
    return j1(x);
  }

  /* Returns the Bessel function of the first kind of order `n` of `x`. */
  @unstable("'jn' is unstable and may be renamed or moved to a different module in the future")
  inline proc jn(n: int, x: real(32)): real(32) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_jn(n: c_int, x: real(32)): real(32);
    return chpl_float_jn(n.safeCast(c_int), x);
  }

  /* Returns the Bessel function of the first kind of order `n` of `x`. */
  @unstable("'jn' is unstable and may be renamed or moved to a different module in the future")
  inline proc jn(n: int, x: real(64)): real(64) {
    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc jn(n: c_int, x: real(64)): real(64);
    return jn(n.safeCast(c_int), x);
  }

  /* Returns the Bessel function of the second kind of order `0` of `x`, where
     `x` must be greater than 0. */
  @unstable("'y0' is unstable and may be renamed or moved to a different module in the future")
  inline proc y0(x: real(32)): real(32) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for y0() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_y0(x: real(32)): real(32);
    return chpl_float_y0(x);
  }

  /* Returns the Bessel function of the second kind of order `0` of `x`,
     where `x` must be greater than 0. */
  @unstable("'y0' is unstable and may be renamed or moved to a different module in the future")
  inline proc y0(x: real(64)): real(64) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for y0() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc y0(x: real(64)): real(64);
    return y0(x);
  }

  /* Returns the Bessel function of the second kind of order `1` of `x`,
     where `x` must be greater than 0. */
  @unstable("'y1' is unstable and may be renamed or moved to a different module in the future")
  inline proc y1(x: real(32)): real(32) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for y1() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_y1(x: real(32)): real(32);
    return chpl_float_y1(x);
  }

  /* Returns the Bessel function of the second kind of order `1` of `x`,
     where `x` must be greater than 0. */
  @unstable("'y1' is unstable and may be renamed or moved to a different module in the future")
  inline proc y1(x: real(64)): real(64) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for y1() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc y1(x: real(64)): real(64);
    return y1(x);
  }

  /* Returns the Bessel function of the second kind of order `n` of `x`,
     where `x` must be greater than 0. */
  @unstable("'yn' is unstable and may be renamed or moved to a different module in the future")
  inline proc yn(n: int, x: real(32)): real(32) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for yn() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc chpl_float_yn(n: c_int, x: real(32)): real(32);
    return chpl_float_yn(n.safeCast(c_int), x);
  }

  /* Returns the Bessel function of the second kind of order `n` of `x`,
     where `x` must be greater than 0. */
  @unstable("'yn' is unstable and may be renamed or moved to a different module in the future")
  inline proc yn(n: int, x: real(64)): real(64) {
    if boundsChecking && x < 0 then
      HaltWrappers.boundsCheckHalt("Input value for yn() must be non-negative");

    pragma "fn synchronization free"
    pragma "codegen for CPU and GPU"
    extern proc yn(n: c_int, x: real(64)): real(64);
    return yn(n.safeCast(c_int), x);
  }

  @chpldoc.nodoc
  private inline proc fmaImplExternCall(x: real(?w), y: real(w), z: real(w)) {
    extern proc fmaf(x: real(32), y: real(32), z: real(32)): real(32);
    extern proc fma(x: real(64), y: real(64), z: real(64)): real(64);
    var ret: x.type;
    select x.type {
      when real(32) do ret = fmaf(x, y, z);
      when real(64) do ret = fma(x, y, z);
      otherwise do compilerError('Unhandled type in fma() impl!');
    }
    return ret;
  }

  @chpldoc.nodoc
  private inline
  proc fmaSelectPrimitiveOrExternCall(x: real(?w), y: real(w), z: real(w)) {
    param targetCompiler = __primitive("get compiler variable",
                                       "CHPL_TARGET_COMPILER");
    param isLlvmCompile = targetCompiler == "llvm";

    // The backend will emit a 'llvm.fma.*' instruction, which should be
    // optimized into a hardware instruction if the architecture is
    // specified and `--specialize` is thrown.
    if isLlvmCompile {
      return __primitive("fma", x, y, z);

    // Call C 'fma()' here rather than have the backend do it. It's up to
    // the C compiler if any optimization occurs here at all. We have
    // to call 'fma()' for correctness, as (x*y+z) will introduce more error.
    // TODO: Is there a path for the builtin Clang to reliably emit a
    // hardware instruction, e.g., through a Clang intrinsic call?
    } else {
      return fmaImplExternCall(x, y, z);
    }
  }

  /*  Performs a fused multiply-add operation that multiplies ``x`` and ``y``
      and adds ``z`` to the result. The advantage of ``fma()`` over the
      expression ``(x*y)+z`` is that it avoids the additional error
      introduced by performing two separate floating point operations.
      It can also be faster on machines that implement the operation as a
      single instruction.

      .. note::

        When compiling with ``CHPL_TARGET_COMPILER=llvm``, this procedure
        should reliably generate a single hardware instruction on ``x86``
        if ``--specialize`` is thrown and ``CHPL_TARGET_CPU`` is set
        (provided that the ``x86`` CPU supports hardware FMA).

        When compiling with C, this procedure will call out to the ``fma()``
        routines defined in the C header `math.h`. Any optimization performed
        is decided by the C compiler.
  */
  @unstable("The 'fma()' procedure was recently added, and may change based on feedback")
  inline proc fma(x: real(64), y: real(64), z: real(64)): real(64) {
    return fmaSelectPrimitiveOrExternCall(x, y, z);
  }

  @unstable("The 'fma()' procedure was recently added, and may change based on feedback")
  inline proc fma(x: real(32), y: real(32), z: real(32)): real(32) {
    return fmaSelectPrimitiveOrExternCall(x, y, z);
  }

  @unstable("The 'fma()' procedure was recently added, and may change based on feedback")
  inline proc fma(x: imag(64), y: imag(64), z: imag(64)): imag(64) {
    type t = real(64);
    return fmaSelectPrimitiveOrExternCall(x:t, y:t, z:t):imag(64);
  }

  @unstable("The 'fma()' procedure was recently added, and may change based on feedback")
  inline proc fma(x: imag(32), y: imag(32), z: imag(32)): imag(32) {
    type t = real(32);
    return fmaSelectPrimitiveOrExternCall(x:t, y:t, z:t):imag(32);
  }
}
