/***************************************************************
This code was generated by  Spiral 5.0 beta, www.spiral.net --
Copyright (c) 2005, Carnegie Mellon University
All rights reserved.
The code is distributed under a BSD style license
(see http://www.opensource.org/licenses/bsd-license.php)

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, reference to Spiral, this list of conditions and the
  following disclaimer.
  * Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following
  disclaimer in the documentation and/or other materials provided
  with the distribution.
  * Neither the name of Carnegie Mellon University nor the name of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
*AS IS* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
******************************************************************/

use omega;

proc init_fft16() {

}

proc fft16\(ref Y: [] complex, X: [] complex) {
  var a5677, a5678, a5679, a5680, a5681, a5682, a5683, a5684, s2214, s2215, s2216, s2217, s2218, s2219, s2220, s2221, s2222, t5589, t5590, t5591, t5592, t5593, t5594, t5595, t5596, t5597, t5598, t5599, t5600, t5601, t5602, t5603, t5604, t5605, t5606, t5607, t5608, t5609, t5610, t5611, t5612, t5613, t5614, t5615, t5616, t5617, t5618, t5619:complex;
  t5589 = (X(0) + X(8));
  t5590 = (X(0) - X(8));
  t5591 = (X(4) + X(12));
  t5592 = (t5589 + t5591);
  t5593 = (t5589 - t5591);
  a5677 = (1.0i*(X(4) - X(12)));
  t5594 = (t5590 + a5677);
  t5595 = (t5590 - a5677);
  t5596 = (X(1) + X(9));
  t5597 = (X(1) - X(9));
  t5598 = (X(5) + X(13));
  t5599 = (t5596 + t5598);
  s2214 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t5596 - t5598));
  a5678 = (1.0i*(X(5) - X(13)));
  s2215 = ((0.92387953251128674 + 1.0i * 0.38268343236508978)*(t5597 + a5678));
  s2216 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t5597 - a5678));
  t5600 = (X(2) + X(10));
  t5601 = (X(2) - X(10));
  t5602 = (X(6) + X(14));
  t5603 = (t5600 + t5602);
  s2217 = (1.0i*(t5600 - t5602));
  a5679 = (1.0i*(X(6) - X(14)));
  s2218 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t5601 + a5679));
  s2219 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t5601 - a5679));
  t5604 = (X(3) + X(11));
  t5605 = (X(3) - X(11));
  t5606 = (X(7) + X(15));
  t5607 = (t5604 + t5606);
  s2220 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t5604 - t5606));
  a5680 = (1.0i*(X(7) - X(15)));
  s2221 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t5605 + a5680));
  s2222 = ((-0.92387953251128674 - 1.0i * 0.38268343236508978)*(t5605 - a5680));
  t5608 = (t5592 + t5603);
  t5609 = (t5592 - t5603);
  t5610 = (t5599 + t5607);
  Y(0) = (t5608 + t5610);
  Y(8) = (t5608 - t5610);
  a5681 = (1.0i*(t5599 - t5607));
  Y(4) = (t5609 + a5681);
  Y(12) = (t5609 - a5681);
  t5611 = (t5594 + s2218);
  t5612 = (t5594 - s2218);
  t5613 = (s2215 + s2221);
  Y(1) = (t5611 + t5613);
  Y(9) = (t5611 - t5613);
  a5682 = (1.0i*(s2215 - s2221));
  Y(5) = (t5612 + a5682);
  Y(13) = (t5612 - a5682);
  t5614 = (t5593 + s2217);
  t5615 = (t5593 - s2217);
  t5616 = (s2214 + s2220);
  Y(2) = (t5614 + t5616);
  Y(10) = (t5614 - t5616);
  a5683 = (1.0i*(s2214 - s2220));
  Y(6) = (t5615 + a5683);
  Y(14) = (t5615 - a5683);
  t5617 = (t5595 + s2219);
  t5618 = (t5595 - s2219);
  t5619 = (s2216 + s2222);
  Y(3) = (t5617 + t5619);
  Y(11) = (t5617 - t5619);
  a5684 = (1.0i*(s2216 - s2222));
  Y(7) = (t5618 + a5684);
  Y(15) = (t5618 - a5684);

}
