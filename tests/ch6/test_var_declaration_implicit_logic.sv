/*
:name: test_var_declaration_implicit_logic
:description: A declaration with var can leave out the data type; with no type, or with only a range or signing, the variable is a logic variable that holds x and z and has the given width and signedness (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_var_declaration_implicit_logic.expected
*/
// IEEE 1800-2023 §6.8: after the keyword var the data type is optional; when
// it is left out, or only a range or a signing is given, the variable is of
// type logic. v1 is then a 1-bit logic variable, v4 a 4-bit one, vs a signed
// 4-bit one and vu an unsigned 4-bit one. Each is given a value with x or z
// bits, which a logic variable keeps, and the same bits 4'b1000 show the
// signedness. var with an explicit type, var byte vb, is a byte.

module test_var_declaration_implicit_logic;
  var v1;
  var [3:0] v4;
  var signed [3:0] vs;
  var unsigned [3:0] vu;
  var byte vb;

  initial begin
    v1 = 1'bz;
    v4 = 4'bx10z;
    $display("v1=%b bits %0d v4=%b bits %0d", v1, $bits(v1), v4, $bits(v4));
    vs = 4'b1000;
    vu = 4'b1000;
    vb = 8'hff;
    $display("vs=%0d vu=%0d vb=%0d bits %0d %0d %0d", vs, vu, vb, $bits(vs), $bits(vu), $bits(vb));
    vs = 4'bxz10;
    $display("vs=%b", vs);
  end
endmodule
