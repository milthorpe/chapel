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
var  buf5: [0..1023] complex;
var  dat5: [0..1023] complex;

proc init_fft1024() {
    for i1709 in 0..31 {
        for i1712 in 0..3 {
            for i1718 in 0..1 {
                for i1724 in 0..1 {
                    dat5(((i1709*32) + (i1712*8) + (i1718*4) + (i1724*2))) = omega(1024, ((i1712 + ((i1718 + (i1724*2))*4))*i1709));
                    dat5(((i1709*32) + (i1712*8) + (i1718*4) + (i1724*2) + 1)) = omega(1024, ((i1712 + ((i1718 + (i1724*2))*4) + 16)*i1709));
                }
            }
        }
    }

}

proc fft1024\(ref Y: [] complex, X: [] complex) {
    for i1710 in 0..31 {
        var s3687, s3688, s3689, s3690, s3691, s3692, s3693,
    s3694, s3695, s3696, s3697, s3698, s3699, s3700, s3701,
    s3702, s3703, s3704, s3705, s3706, s3707, s3708, s3709,
    s3710, s3711, s3712, s3713, s3714, s3715, s3716, s3717,
    s3718, s3719, s3720, s3721, s3722, s3723, s3724, s3725,
    s3726, s3727, s3728, s3729, s3730, s3731, s3732, s3733,
    s3734, s3735, s3736, s3737, s3738, s3739, s3740, s3741,
    s3742, s3743, s3744, s3745, s3746, s3747, s3748, s3749,
    s3750, s3751, s3752, s3753, s3754, s3755, s3756, s3757,
    s3758, s3759, s3760, s3761, s3762, s3763, s3764, s3765,
    s3766, s3767, t6163, t6164, t6165, t6166, t6167, t6168,
    t6169, t6170, t6171, t6172, t6173, t6174, t6175, t6176,
    t6177, t6178, t6179, t6180, t6181, t6182, t6183, t6184,
    t6185, t6186, t6187, t6188, t6189, t6190, t6191, t6192,
    t6193, t6194, t6195, t6196, t6197, t6198, t6199, t6200,
    t6201, t6202, t6203, t6204, t6205, t6206, t6207, t6208,
    t6209, t6210, t6211, t6212, t6213, t6214, t6215, t6216,
    t6217, t6218, t6219, t6220, t6221, t6222, t6223, t6224,
    t6225, t6226, t6227, t6228, t6229, t6230, t6231, t6232,
    t6233, t6234, t6235, t6236, t6237, t6238, t6239, t6240,
    t6241:complex;
        var a3673:int;
        s3687 = X(i1710);
        s3688 = X((512 + i1710));
        t6163 = (s3687 + s3688);
        t6164 = (s3687 - s3688);
        s3689 = X((256 + i1710));
        s3690 = X((768 + i1710));
        t6165 = (s3689 + s3690);
        t6166 = (t6163 + t6165);
        t6167 = (t6163 - t6165);
        s3691 = (1.0i*(s3689 - s3690));
        t6168 = (t6164 + s3691);
        t6169 = (t6164 - s3691);
        s3692 = X((128 + i1710));
        s3693 = X((640 + i1710));
        t6170 = (s3692 + s3693);
        t6171 = (s3692 - s3693);
        s3694 = X((384 + i1710));
        s3695 = X((896 + i1710));
        t6172 = (s3694 + s3695);
        t6173 = (t6170 + t6172);
        s3696 = (1.0i*(s3694 - s3695));
        t6174 = (t6166 + t6173);
        t6175 = (t6166 - t6173);
        s3697 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6171 + s3696));
        t6176 = (t6168 + s3697);
        t6177 = (t6168 - s3697);
        s3698 = (1.0i*(t6170 - t6172));
        t6178 = (t6167 + s3698);
        t6179 = (t6167 - s3698);
        s3699 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6171 - s3696));
        t6180 = (t6169 + s3699);
        t6181 = (t6169 - s3699);
        s3700 = X((32 + i1710));
        s3701 = X((544 + i1710));
        t6182 = (s3700 + s3701);
        t6183 = (s3700 - s3701);
        s3702 = X((288 + i1710));
        s3703 = X((800 + i1710));
        t6184 = (s3702 + s3703);
        t6185 = (t6182 + t6184);
        t6186 = (t6182 - t6184);
        s3704 = (1.0i*(s3702 - s3703));
        t6187 = (t6183 + s3704);
        t6188 = (t6183 - s3704);
        s3705 = X((160 + i1710));
        s3706 = X((672 + i1710));
        t6189 = (s3705 + s3706);
        t6190 = (s3705 - s3706);
        s3707 = X((416 + i1710));
        s3708 = X((928 + i1710));
        t6191 = (s3707 + s3708);
        t6192 = (t6189 + t6191);
        s3709 = (1.0i*(s3707 - s3708));
        t6193 = (t6185 + t6192);
        s3710 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6190 + s3709));
        s3711 = (1.0i*(t6189 - t6191));
        s3712 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6190 - s3709));
        s3713 = X((64 + i1710));
        s3714 = X((576 + i1710));
        t6194 = (s3713 + s3714);
        t6195 = (s3713 - s3714);
        s3715 = X((320 + i1710));
        s3716 = X((832 + i1710));
        t6196 = (s3715 + s3716);
        t6197 = (t6194 + t6196);
        t6198 = (t6194 - t6196);
        s3717 = (1.0i*(s3715 - s3716));
        t6199 = (t6195 + s3717);
        t6200 = (t6195 - s3717);
        s3718 = X((192 + i1710));
        s3719 = X((704 + i1710));
        t6201 = (s3718 + s3719);
        t6202 = (s3718 - s3719);
        s3720 = X((448 + i1710));
        s3721 = X((960 + i1710));
        t6203 = (s3720 + s3721);
        t6204 = (t6201 + t6203);
        s3722 = (1.0i*(s3720 - s3721));
        t6205 = (t6197 + t6204);
        s3723 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6202 + s3722));
        s3724 = (1.0i*(t6201 - t6203));
        s3725 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6202 - s3722));
        s3726 = X((96 + i1710));
        s3727 = X((608 + i1710));
        t6206 = (s3726 + s3727);
        t6207 = (s3726 - s3727);
        s3728 = X((352 + i1710));
        s3729 = X((864 + i1710));
        t6208 = (s3728 + s3729);
        t6209 = (t6206 + t6208);
        t6210 = (t6206 - t6208);
        s3730 = (1.0i*(s3728 - s3729));
        t6211 = (t6207 + s3730);
        t6212 = (t6207 - s3730);
        s3731 = X((224 + i1710));
        s3732 = X((736 + i1710));
        t6213 = (s3731 + s3732);
        t6214 = (s3731 - s3732);
        s3733 = X((480 + i1710));
        s3734 = X((992 + i1710));
        t6215 = (s3733 + s3734);
        t6216 = (t6213 + t6215);
        s3735 = (1.0i*(s3733 - s3734));
        t6217 = (t6209 + t6216);
        s3736 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6214 + s3735));
        s3737 = (1.0i*(t6213 - t6215));
        s3738 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6214 - s3735));
        t6218 = (t6174 + t6205);
        t6219 = (t6174 - t6205);
        t6220 = (t6193 + t6217);
        a3673 = (32*i1710);
        buf5(a3673) = (t6218 + t6220);
        buf5((16 + a3673)) = (t6218 - t6220);
        s3739 = (1.0i*(t6193 - t6217));
        buf5((8 + a3673)) = (t6219 + s3739);
        buf5((24 + a3673)) = (t6219 - s3739);
        s3740 = ((0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6199 + s3723));
        t6221 = (t6176 + s3740);
        t6222 = (t6176 - s3740);
        s3741 = ((0.98078528040323043 + 1.0i * 0.19509032201612825)*(t6187 + s3710));
        s3742 = ((0.83146961230254524 + 1.0i * 0.55557023301960218)*(t6211 + s3736));
        t6223 = (s3741 + s3742);
        buf5((1 + a3673)) = (t6221 + t6223);
        buf5((17 + a3673)) = (t6221 - t6223);
        s3743 = (1.0i*(s3741 - s3742));
        buf5((9 + a3673)) = (t6222 + s3743);
        buf5((25 + a3673)) = (t6222 - s3743);
        s3744 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6198 + s3724));
        t6224 = (t6178 + s3744);
        t6225 = (t6178 - s3744);
        s3745 = ((0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6186 + s3711));
        s3746 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6210 + s3737));
        t6226 = (s3745 + s3746);
        buf5((2 + a3673)) = (t6224 + t6226);
        buf5((18 + a3673)) = (t6224 - t6226);
        s3747 = (1.0i*(s3745 - s3746));
        buf5((10 + a3673)) = (t6225 + s3747);
        buf5((26 + a3673)) = (t6225 - s3747);
        s3748 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6200 + s3725));
        t6227 = (t6180 + s3748);
        t6228 = (t6180 - s3748);
        s3749 = ((0.83146961230254524 + 1.0i * 0.55557023301960218)*(t6188 + s3712));
        s3750 = ((-0.19509032201612825 + 1.0i * 0.98078528040323043)*(t6212 + s3738));
        t6229 = (s3749 + s3750);
        buf5((3 + a3673)) = (t6227 + t6229);
        buf5((19 + a3673)) = (t6227 - t6229);
        s3751 = (1.0i*(s3749 - s3750));
        buf5((11 + a3673)) = (t6228 + s3751);
        buf5((27 + a3673)) = (t6228 - s3751);
        s3752 = (1.0i*(t6197 - t6204));
        t6230 = (t6175 + s3752);
        t6231 = (t6175 - s3752);
        s3753 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6185 - t6192));
        s3754 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6209 - t6216));
        t6232 = (s3753 + s3754);
        buf5((4 + a3673)) = (t6230 + t6232);
        buf5((20 + a3673)) = (t6230 - t6232);
        s3755 = (1.0i*(s3753 - s3754));
        buf5((12 + a3673)) = (t6231 + s3755);
        buf5((28 + a3673)) = (t6231 - s3755);
        s3756 = ((-0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6199 - s3723));
        t6233 = (t6177 + s3756);
        t6234 = (t6177 - s3756);
        s3757 = ((0.55557023301960218 + 1.0i * 0.83146961230254524)*(t6187 - s3710));
        s3758 = ((-0.98078528040323043 + 1.0i * 0.19509032201612825)*(t6211 - s3736));
        t6235 = (s3757 + s3758);
        buf5((5 + a3673)) = (t6233 + t6235);
        buf5((21 + a3673)) = (t6233 - t6235);
        s3759 = (1.0i*(s3757 - s3758));
        buf5((13 + a3673)) = (t6234 + s3759);
        buf5((29 + a3673)) = (t6234 - s3759);
        s3760 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6198 - s3724));
        t6236 = (t6179 + s3760);
        t6237 = (t6179 - s3760);
        s3761 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6186 - s3711));
        s3762 = ((-0.92387953251128674 - 1.0i * 0.38268343236508978)*(t6210 - s3737));
        t6238 = (s3761 + s3762);
        buf5((6 + a3673)) = (t6236 + t6238);
        buf5((22 + a3673)) = (t6236 - t6238);
        s3763 = (1.0i*(s3761 - s3762));
        buf5((14 + a3673)) = (t6237 + s3763);
        buf5((30 + a3673)) = (t6237 - s3763);
        s3764 = ((-0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6200 - s3725));
        t6239 = (t6181 + s3764);
        t6240 = (t6181 - s3764);
        s3765 = ((0.19509032201612825 + 1.0i * 0.98078528040323043)*(t6188 - s3712));
        s3766 = ((-0.55557023301960218 - 1.0i * 0.83146961230254524)*(t6212 - s3738));
        t6241 = (s3765 + s3766);
        buf5((7 + a3673)) = (t6239 + t6241);
        buf5((23 + a3673)) = (t6239 - t6241);
        s3767 = (1.0i*(s3765 - s3766));
        buf5((15 + a3673)) = (t6240 + s3767);
        buf5((31 + a3673)) = (t6240 - s3767);
    }
    for i1709 in 0..31 {
        var s3994, s3995, s3996, s3997, s3998, s3999, s4000,
    s4001, s4002, s4003, s4004, s4005, s4006, s4007, s4008,
    s4009, s4010, s4011, s4012, s4013, s4014, s4015, s4016,
    s4017, s4018, s4019, s4020, s4021, s4022, s4023, s4024,
    s4025, s4026, s4027, s4028, s4029, s4030, s4031, s4032,
    s4033, s4034, s4035, s4036, s4037, s4038, s4039, s4040,
    s4041, s4042, s4043, s4044, s4045, s4046, s4047, s4048,
    s4049, s4050, s4051, s4052, s4053, s4054, s4055, s4056,
    s4057, s4058, s4059, s4060, s4061, s4062, s4063, s4064,
    s4065, s4066, s4067, s4068, s4069, s4070, s4071, s4072,
    s4073, s4074, t6562, t6563, t6564, t6565, t6566, t6567,
    t6568, t6569, t6570, t6571, t6572, t6573, t6574, t6575,
    t6576, t6577, t6578, t6579, t6580, t6581, t6582, t6583,
    t6584, t6585, t6586, t6587, t6588, t6589, t6590, t6591,
    t6592, t6593, t6594, t6595, t6596, t6597, t6598, t6599,
    t6600, t6601, t6602, t6603, t6604, t6605, t6606, t6607,
    t6608, t6609, t6610, t6611, t6612, t6613, t6614, t6615,
    t6616, t6617, t6618, t6619, t6620, t6621, t6622, t6623,
    t6624, t6625, t6626, t6627, t6628, t6629, t6630, t6631,
    t6632, t6633, t6634, t6635, t6636, t6637, t6638, t6639,
    t6640:complex;
        var a3926, a3927, a3928, a3929, a3930, a3931, a3932,
    a3933, a3934, a3935, a3936, a3937, a3938, a3939, a3940,
    a3941, a3942, a3943, a3944, a3945, a3946, a3947, a3948,
    a3949, a3950, a3951, a3952, a3953, a3954, a3955, a3956,
    a3957:int;
        a3926 = (512 + i1709);
        a3927 = (32*i1709);
        s3994 = (dat5(a3927)*buf5(i1709));
        s3995 = (dat5((1 + a3927))*buf5(a3926));
        t6562 = (s3994 + s3995);
        t6563 = (s3994 - s3995);
        a3928 = (256 + i1709);
        a3929 = (768 + i1709);
        s3996 = (dat5((2 + a3927))*buf5(a3928));
        s3997 = (dat5((3 + a3927))*buf5(a3929));
        t6564 = (s3996 + s3997);
        t6565 = (t6562 + t6564);
        t6566 = (t6562 - t6564);
        s3998 = (1.0i*(s3996 - s3997));
        t6567 = (t6563 + s3998);
        t6568 = (t6563 - s3998);
        a3930 = (128 + i1709);
        a3931 = (640 + i1709);
        s3999 = (dat5((4 + a3927))*buf5(a3930));
        s4000 = (dat5((5 + a3927))*buf5(a3931));
        t6569 = (s3999 + s4000);
        t6570 = (s3999 - s4000);
        a3932 = (384 + i1709);
        a3933 = (896 + i1709);
        s4001 = (dat5((6 + a3927))*buf5(a3932));
        s4002 = (dat5((7 + a3927))*buf5(a3933));
        t6571 = (s4001 + s4002);
        t6572 = (t6569 + t6571);
        s4003 = (1.0i*(s4001 - s4002));
        t6573 = (t6565 + t6572);
        t6574 = (t6565 - t6572);
        s4004 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6570 + s4003));
        t6575 = (t6567 + s4004);
        t6576 = (t6567 - s4004);
        s4005 = (1.0i*(t6569 - t6571));
        t6577 = (t6566 + s4005);
        t6578 = (t6566 - s4005);
        s4006 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6570 - s4003));
        t6579 = (t6568 + s4006);
        t6580 = (t6568 - s4006);
        a3934 = (32 + i1709);
        a3935 = (544 + i1709);
        s4007 = (dat5((8 + a3927))*buf5(a3934));
        s4008 = (dat5((9 + a3927))*buf5(a3935));
        t6581 = (s4007 + s4008);
        t6582 = (s4007 - s4008);
        a3936 = (288 + i1709);
        a3937 = (800 + i1709);
        s4009 = (dat5((10 + a3927))*buf5(a3936));
        s4010 = (dat5((11 + a3927))*buf5(a3937));
        t6583 = (s4009 + s4010);
        t6584 = (t6581 + t6583);
        t6585 = (t6581 - t6583);
        s4011 = (1.0i*(s4009 - s4010));
        t6586 = (t6582 + s4011);
        t6587 = (t6582 - s4011);
        a3938 = (160 + i1709);
        a3939 = (672 + i1709);
        s4012 = (dat5((12 + a3927))*buf5(a3938));
        s4013 = (dat5((13 + a3927))*buf5(a3939));
        t6588 = (s4012 + s4013);
        t6589 = (s4012 - s4013);
        a3940 = (416 + i1709);
        a3941 = (928 + i1709);
        s4014 = (dat5((14 + a3927))*buf5(a3940));
        s4015 = (dat5((15 + a3927))*buf5(a3941));
        t6590 = (s4014 + s4015);
        t6591 = (t6588 + t6590);
        s4016 = (1.0i*(s4014 - s4015));
        t6592 = (t6584 + t6591);
        s4017 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6589 + s4016));
        s4018 = (1.0i*(t6588 - t6590));
        s4019 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6589 - s4016));
        a3942 = (64 + i1709);
        a3943 = (576 + i1709);
        s4020 = (dat5((16 + a3927))*buf5(a3942));
        s4021 = (dat5((17 + a3927))*buf5(a3943));
        t6593 = (s4020 + s4021);
        t6594 = (s4020 - s4021);
        a3944 = (320 + i1709);
        a3945 = (832 + i1709);
        s4022 = (dat5((18 + a3927))*buf5(a3944));
        s4023 = (dat5((19 + a3927))*buf5(a3945));
        t6595 = (s4022 + s4023);
        t6596 = (t6593 + t6595);
        t6597 = (t6593 - t6595);
        s4024 = (1.0i*(s4022 - s4023));
        t6598 = (t6594 + s4024);
        t6599 = (t6594 - s4024);
        a3946 = (192 + i1709);
        a3947 = (704 + i1709);
        s4025 = (dat5((20 + a3927))*buf5(a3946));
        s4026 = (dat5((21 + a3927))*buf5(a3947));
        t6600 = (s4025 + s4026);
        t6601 = (s4025 - s4026);
        a3948 = (448 + i1709);
        a3949 = (960 + i1709);
        s4027 = (dat5((22 + a3927))*buf5(a3948));
        s4028 = (dat5((23 + a3927))*buf5(a3949));
        t6602 = (s4027 + s4028);
        t6603 = (t6600 + t6602);
        s4029 = (1.0i*(s4027 - s4028));
        t6604 = (t6596 + t6603);
        s4030 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6601 + s4029));
        s4031 = (1.0i*(t6600 - t6602));
        s4032 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6601 - s4029));
        a3950 = (96 + i1709);
        a3951 = (608 + i1709);
        s4033 = (dat5((24 + a3927))*buf5(a3950));
        s4034 = (dat5((25 + a3927))*buf5(a3951));
        t6605 = (s4033 + s4034);
        t6606 = (s4033 - s4034);
        a3952 = (352 + i1709);
        a3953 = (864 + i1709);
        s4035 = (dat5((26 + a3927))*buf5(a3952));
        s4036 = (dat5((27 + a3927))*buf5(a3953));
        t6607 = (s4035 + s4036);
        t6608 = (t6605 + t6607);
        t6609 = (t6605 - t6607);
        s4037 = (1.0i*(s4035 - s4036));
        t6610 = (t6606 + s4037);
        t6611 = (t6606 - s4037);
        a3954 = (224 + i1709);
        a3955 = (736 + i1709);
        s4038 = (dat5((28 + a3927))*buf5(a3954));
        s4039 = (dat5((29 + a3927))*buf5(a3955));
        t6612 = (s4038 + s4039);
        t6613 = (s4038 - s4039);
        a3956 = (480 + i1709);
        a3957 = (992 + i1709);
        s4040 = (dat5((30 + a3927))*buf5(a3956));
        s4041 = (dat5((31 + a3927))*buf5(a3957));
        t6614 = (s4040 + s4041);
        t6615 = (t6612 + t6614);
        s4042 = (1.0i*(s4040 - s4041));
        t6616 = (t6608 + t6615);
        s4043 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6613 + s4042));
        s4044 = (1.0i*(t6612 - t6614));
        s4045 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6613 - s4042));
        t6617 = (t6573 + t6604);
        t6618 = (t6573 - t6604);
        t6619 = (t6592 + t6616);
        Y(i1709) = (t6617 + t6619);
        Y(a3926) = (t6617 - t6619);
        s4046 = (1.0i*(t6592 - t6616));
        Y(a3928) = (t6618 + s4046);
        Y(a3929) = (t6618 - s4046);
        s4047 = ((0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6598 + s4030));
        t6620 = (t6575 + s4047);
        t6621 = (t6575 - s4047);
        s4048 = ((0.98078528040323043 + 1.0i * 0.19509032201612825)*(t6586 + s4017));
        s4049 = ((0.83146961230254524 + 1.0i * 0.55557023301960218)*(t6610 + s4043));
        t6622 = (s4048 + s4049);
        Y(a3934) = (t6620 + t6622);
        Y(a3935) = (t6620 - t6622);
        s4050 = (1.0i*(s4048 - s4049));
        Y(a3936) = (t6621 + s4050);
        Y(a3937) = (t6621 - s4050);
        s4051 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6597 + s4031));
        t6623 = (t6577 + s4051);
        t6624 = (t6577 - s4051);
        s4052 = ((0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6585 + s4018));
        s4053 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6609 + s4044));
        t6625 = (s4052 + s4053);
        Y(a3942) = (t6623 + t6625);
        Y(a3943) = (t6623 - t6625);
        s4054 = (1.0i*(s4052 - s4053));
        Y(a3944) = (t6624 + s4054);
        Y(a3945) = (t6624 - s4054);
        s4055 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6599 + s4032));
        t6626 = (t6579 + s4055);
        t6627 = (t6579 - s4055);
        s4056 = ((0.83146961230254524 + 1.0i * 0.55557023301960218)*(t6587 + s4019));
        s4057 = ((-0.19509032201612825 + 1.0i * 0.98078528040323043)*(t6611 + s4045));
        t6628 = (s4056 + s4057);
        Y(a3950) = (t6626 + t6628);
        Y(a3951) = (t6626 - t6628);
        s4058 = (1.0i*(s4056 - s4057));
        Y(a3952) = (t6627 + s4058);
        Y(a3953) = (t6627 - s4058);
        s4059 = (1.0i*(t6596 - t6603));
        t6629 = (t6574 + s4059);
        t6630 = (t6574 - s4059);
        s4060 = ((0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6584 - t6591));
        s4061 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6608 - t6615));
        t6631 = (s4060 + s4061);
        Y(a3930) = (t6629 + t6631);
        Y(a3931) = (t6629 - t6631);
        s4062 = (1.0i*(s4060 - s4061));
        Y(a3932) = (t6630 + s4062);
        Y(a3933) = (t6630 - s4062);
        s4063 = ((-0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6598 - s4030));
        t6632 = (t6576 + s4063);
        t6633 = (t6576 - s4063);
        s4064 = ((0.55557023301960218 + 1.0i * 0.83146961230254524)*(t6586 - s4017));
        s4065 = ((-0.98078528040323043 + 1.0i * 0.19509032201612825)*(t6610 - s4043));
        t6634 = (s4064 + s4065);
        Y(a3938) = (t6632 + t6634);
        Y(a3939) = (t6632 - t6634);
        s4066 = (1.0i*(s4064 - s4065));
        Y(a3940) = (t6633 + s4066);
        Y(a3941) = (t6633 - s4066);
        s4067 = ((-0.70710678118654757 + 1.0i * 0.70710678118654757)*(t6597 - s4031));
        t6635 = (t6578 + s4067);
        t6636 = (t6578 - s4067);
        s4068 = ((0.38268343236508978 + 1.0i * 0.92387953251128674)*(t6585 - s4018));
        s4069 = ((-0.92387953251128674 - 1.0i * 0.38268343236508978)*(t6609 - s4044));
        t6637 = (s4068 + s4069);
        Y(a3946) = (t6635 + t6637);
        Y(a3947) = (t6635 - t6637);
        s4070 = (1.0i*(s4068 - s4069));
        Y(a3948) = (t6636 + s4070);
        Y(a3949) = (t6636 - s4070);
        s4071 = ((-0.92387953251128674 + 1.0i * 0.38268343236508978)*(t6599 - s4032));
        t6638 = (t6580 + s4071);
        t6639 = (t6580 - s4071);
        s4072 = ((0.19509032201612825 + 1.0i * 0.98078528040323043)*(t6587 - s4019));
        s4073 = ((-0.55557023301960218 - 1.0i * 0.83146961230254524)*(t6611 - s4045));
        t6640 = (s4072 + s4073);
        Y(a3954) = (t6638 + t6640);
        Y(a3955) = (t6638 - t6640);
        s4074 = (1.0i*(s4072 - s4073));
        Y(a3956) = (t6639 + s4074);
        Y(a3957) = (t6639 - s4074);
    }

}
