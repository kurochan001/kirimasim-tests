/*
:name: test_var_keyword_without_data_type_is_logic
:description: Variable declarations that omit the data type after var, in a module and in a procedural block, are of type logic with the range and signing written (4-state, x when not initialized), and var before an explicit type keeps that type (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 A.2.1.3 A.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_var_keyword_without_data_type_is_logic.expected
*/
// IEEE 1800-2023 §6.8 with footnote 14 of A.10: a data declaration may omit
// the explicit data type before its variables only when the keyword var is
// used; the variable is then of type logic, with the packed range and the
// signing that are written.
//
// v1 is logic: 1 bit, x before any assignment, and it can hold z. v6 is
// logic [5:0] and keeps the z and x bits of its initial value. vs is logic
// signed [7:0]: 8'hF6 is -10, less than 0, and sign-extends to 32'hfffffff6
// in an int. vb has the explicit type byte after var. pv, declared with var
// in the initial procedure, is logic [2:0] and starts as xxx.

module test_var_keyword_without_data_type_is_logic;
  var v1;
  var [5:0] v6 = 6'b1z0x01;
  var signed [7:0] vs = 8'hF6;
  var byte vb = -2;

  initial begin
    var [2:0] pv;
    int wide;
    $display("v1=%b bits=%0d", v1, $bits(v1));
    v1 = 1'bz;
    $display("v1=%b", v1);
    $display("v6=%b bits=%0d", v6, $bits(v6));
    wide = vs;
    $display("vs=%0d negative=%0d bits=%0d wide=%h", vs, vs < 0, $bits(vs), wide);
    $display("vb=%0d bits=%0d", vb, $bits(vb));
    $display("pv=%b bits=%0d", pv, $bits(pv));
  end
endmodule
