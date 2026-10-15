/*
:name: test_udp_combinational_2
:description: Combinational UDP
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_combinational_2.expected
*/
// IEEE 1800-2023 §29.3: Combinational UDP
// Tests combinational user-defined primitive (2-input AND gate)
// Verifies truth table evaluation for all input combinations

primitive and_udp(output out, input a, b);
  table
    // a b : out
       0 0 : 0;
       0 1 : 0;
       1 0 : 0;
       1 1 : 1;
  endtable
endprimitive

module test_udp_combinational_2;
  reg a, b;
  wire out;

  and_udp u1(out, a, b);

  initial begin
    {a, b} = 2'b00; #1 assert(out == 0) else $fatal(1, "out == 0 failed");
    {a, b} = 2'b01; #1 assert(out == 0) else $fatal(1, "out == 0 failed");
    {a, b} = 2'b10; #1 assert(out == 0) else $fatal(1, "out == 0 failed");
    {a, b} = 2'b11; #1 assert(out == 1) else $fatal(1, "out == 1 failed");
    $display("UDP combinational test PASSED");
    $finish;
  end
endmodule
