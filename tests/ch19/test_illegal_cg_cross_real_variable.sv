/*
:name: test_illegal_cg_cross_real_variable
:description: A cross can include a coverpoint of a real expression but not a real variable directly (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cross bad_x names the real variable r directly instead of a coverpoint of it
:expected_stderr_regex: test_illegal_cg_cross_real_variable\.sv:32:
*/
// IEEE 1800-2023 §19.6: a variable named in a cross gets an implicit
// coverpoint, but a cross shall not directly include a real variable; it may
// include coverpoints of real expressions, so a cross item is a variable only
// for an integral variable. In cg, cr is a coverpoint of the real r with an
// explicit bin, and the cross ok_x of cr with the integral variable k is
// legal; bad_x names r itself. With cr in place of r in the marked line the
// design is legal and prints done.
// The 5.054 release of Verilator accepts the design and prints done. Icarus
// Verilog 13.0 does not support covergroups and reports errors on the legal
// lines as well, so its error on the marked line does not count.

module test_illegal_cg_cross_real_variable;
  real r;
  bit [1:0] k;

  covergroup cg;
    cr: coverpoint r { bins lo = {[0.0:1.0]}; }
    ok_x: cross cr, k;
    bad_x: cross r, k;   // illegal: r is a real variable
  endgroup

  cg g = new;

  initial begin
    r = 0.5;
    k = 1;
    g.sample();
    $display("done");
  end
endmodule
