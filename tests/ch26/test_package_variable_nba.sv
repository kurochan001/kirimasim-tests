/*
:name: test_package_variable_nba
:description: Nonblocking assignments to package variables and array elements, named with the package or through imports, update in the NBA region (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 10.4.2 4.4.2.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_variable_nba.expected
*/
// IEEE 1800-2023 §26.3: a variable of a package can be named with the
// package, P::c1[1], or through an import, a wildcard one or an explicit
// one, and can be assigned like any other variable. §10.4.2: a nonblocking
// assignment to it, to a scalar or to an element of an array of one or two
// dimensions, takes effect in the NBA region (4.4.2.4): after #0 the old
// values are still there, and one time unit later the new ones.

package P;
  logic [3:0] pv;
  logic [3:0] a1[2];
  logic [3:0] a2[2][2];
  logic [3:0] c1[2];
endpackage

package Q;
  logic [3:0] qa[2];
endpackage

module test_package_variable_nba;
  import P::*;
  import Q::qa;

  initial begin
    pv = 0;
    a1[1] = 4'h5;
    a2[1][0] = 4'h5;
    qa[1] = 4'h5;
    P::c1[1] = 4'h5;
    pv <= 4'h7;
    a1[1] <= 4'h8;
    a2[1][0] <= 4'h9;
    qa[1] <= 4'hb;
    P::c1[1] <= 4'hc;
    #0 $display("after #0: %h %h %h %h %h", pv, a1[1], a2[1][0], qa[1], P::c1[1]);
    #1 $display("after #1: %h %h %h %h %h", pv, a1[1], a2[1][0], qa[1], P::c1[1]);
  end
endmodule
