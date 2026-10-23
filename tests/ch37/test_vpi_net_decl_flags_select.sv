/*
:name: test_vpi_net_decl_flags_select
:description: Nets give vpiNetDeclAssign for a declaration assignment, vpiExplicitScalared and vpiExplicitVectored for those keywords, the declared drive and charge strengths, net bits whether or not the vector is expanded, with vpiExpanded equal to that of their net, and vpiConstantSelect TRUE without a parent or with constant indices and FALSE for an array net element selected by a variable (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.7.1 6.9.2 37.47
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_decl_flags_select.c
:expected_stdout: @test_vpi_net_decl_flags_select.expected
*/
// IEEE 1800-2023 §37.16: a net has the Boolean properties vpiNetDeclAssign (it
// is declared with an assignment), vpiExplicitScalared and vpiExplicitVectored
// (it is declared with that keyword, 6.9.2) and vpiExpanded, and the integer
// properties vpiStrength0, vpiStrength1 and vpiChargeStrength (6.7.1). The
// bits of a logic net are available whether or not the vector is expanded
// (detail 3), and vpiExpanded of a net bit is that of its parent net
// (detail 21); whether a vector is expanded is up to the tool, so only the
// equality is printed. vpiConstantSelect is TRUE for a net without a parent
// and for a select whose indices are elaboration-time constants, and FALSE
// otherwise (detail 23): the right-hand sides of the continuous assignments
// (37.47) to y1 and y2 are the elements an[1] and an[i] of an array net.

module test_vpi_net_decl_flags_select;
  int i = 1;
  wire w_plain;
  wire [3:0] w_assign = 4'h5;
  wire scalared [3:0] ws;
  wire vectored [3:0] wv;
  wire (strong0, pull1) wst = 1'b1;
  trireg (small) tcs;
  trireg (large) tcl;
  wire [3:0] an [0:2];
  wire [3:0] y1, y2;

  assign y1 = an[1];
  assign y2 = an[i];

  initial #1 $vt_flags;
endmodule
