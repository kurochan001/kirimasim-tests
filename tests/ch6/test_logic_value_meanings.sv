/*
:name: test_logic_value_meanings
:description: The four basic values behave as false 0, true 1, unknown x and high-impedance z, and 0 and 1 are complements of each other (IEEE 1800-2023 Section 6.3.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.1 12.4 11.4.7 6.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_logic_value_meanings.expected
*/
// IEEE 1800-2023 §6.3.1: the value set has four basic values: 0 is logic
// zero or false, 1 is logic one or true, x is an unknown value and z is the
// high-impedance state; 0 and 1 are logical complements of each other.
// Line "if" shows that an if statement (§12.4) takes its true branch for 1
// and its false branch for 0, x and z. Line "complement" applies ~ and ! to
// 0 and 1 and to a vector of both. Line "unknown" shows that x is not some
// fixed 0 or 1: x ^ x and x - x stay x (a known value would give 0), while
// 0 and x is 0 and 1 or x is 1 (§11.4.7). Line "nets" puts each value on a
// wire that also has a driver of 0 (§6.6.1): the high-impedance z gives way
// to the 0, and 1 or x fight with it and give x. A z with a driver of 1
// gives 1, so z does not act as a 0 either.

module test_logic_value_meanings;
  logic v0 = 1'b0, v1 = 1'b1, vx = 1'bx, vz = 1'bz;
  logic [3:0] mixed = 4'b0110;
  wire w_z, w_z1, w_1, w_x;

  assign w_z = 1'bz;
  assign w_z = 1'b0;
  assign w_z1 = 1'bz;
  assign w_z1 = 1'b1;
  assign w_1 = 1'b1;
  assign w_1 = 1'b0;
  assign w_x = 1'bx;
  assign w_x = 1'b0;

  function automatic string branch(logic c);
    if (c) return "T";
    else return "F";
  endfunction

  initial begin
    $display("if: 0=%s 1=%s x=%s z=%s", branch(v0), branch(v1), branch(vx), branch(vz));
    $display("complement: ~0=%b ~1=%b !0=%b !1=%b ~0110=%b", ~v0, ~v1, !v0, !v1, ~mixed);
    $display("unknown: x^x=%b x-x=%b 0&x=%b 1|x=%b", vx ^ vx, vx - vx, v0 & vx, v1 | vx);
    #1 $display("nets: z,0=%b z,1=%b 1,0=%b x,0=%b", w_z, w_z1, w_1, w_x);
  end
endmodule
