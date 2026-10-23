/*
:name: test_vpi_instance_directive_properties
:description: An instance gives vpiTop, vpiArrayMember, vpiDefNetType and vpiUnconnDrive from where it is and from the `default_nettype and `unconnected_drive directives in force at its module definition, vpiDefDelayMode none without a delay mode directive, and vpiProtected FALSE for unprotected source (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 22.8 22.9 22.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_directive_properties.c
:expected_stdout: @test_vpi_instance_directive_properties.expected
*/
// IEEE 1800-2023 §37.10: an instance has the Boolean properties vpiTop (it is
// a top-level instance), vpiArrayMember (it is an element of an instance
// array) and vpiProtected (its source is protected), and the integer
// properties vpiDefNetType, the default net type, vpiUnconnDrive, the drive of
// unconnected ports, and vpiDefDelayMode. The default net type of a module is
// the one set by the last `default_nettype before it (22.8): tri1, wand, none,
// and wire after `resetall (22.3). Its unconnected drive is set by the last
// `unconnected_drive or `nounconnected_drive before it (22.9): pull1, pull0,
// or none after `nounconnected_drive and `resetall, which vpi_user.h (Annex K)
// names vpiPull1, vpiPull0 and vpiHighZ. No delay mode directive is used, so
// every instance has vpiDelayModeNone, and no source is protected. Only the
// top module is a top-level instance, and only the elements of arr are array
// members.

`default_nettype tri1
`unconnected_drive pull1
module idp_pull1 (input a);
endmodule
`nounconnected_drive

`default_nettype wand
`unconnected_drive pull0
module idp_pull0 (input a);
endmodule

`default_nettype none
`nounconnected_drive
module idp_none;
endmodule

`resetall

module test_vpi_instance_directive_properties;
  idp_pull1 u1();
  idp_pull1 arr [1:0] ();
  idp_pull0 u0();
  idp_none un();

  initial #1 $vt_props;
endmodule
