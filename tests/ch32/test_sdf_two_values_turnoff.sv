/*
:name: test_sdf_two_values_turnoff
:description: Two SDF delay values give a module path its rise delay for 0->1, 0->z and z->1 and its fall delay for 1->0, 1->z and z->0 (IEEE 1800-2023 Section 32.8)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.8 32.4.1 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_two_values_turnoff.expected
*/
// IEEE 1800-2023 §32.8, Table 32-4: with two SDF values v1 and v2, a module
// path takes v1 for 0->1, 0->z and z->1 and v2 for 1->0, 1->z and z->0. The
// path from the enable of a bufif1 to its output gets (3) (7): with data 1 the
// output leaves z after 3 and goes back to z after 7, and with data 0 it
// leaves z after 7 and goes back to z after 3. Transitions before time 10 are
// not printed.

`timescale 1ns/1ns

module sdf_two_values_cell(output y, input a, input en);
  bufif1 (y, a, en);
  specify
    (en => y) = 0;
    (a => y) = 0;
  endspecify
endmodule

module test_sdf_two_values_turnoff;
  reg a = 1, en = 0;
  wire y;
  integer f;

  sdf_two_values_cell u(y, a, en);

  initial begin
    f = $fopen("test_sdf_two_values_turnoff.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_two_values_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH en y (3) (7))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_two_values_turnoff.sdf");
    #10 en = 1;   // z -> 1 after 3
    #10 en = 0;   // 1 -> z after 7
    #10 a = 0;
    #10 en = 1;   // z -> 0 after 7
    #10 en = 0;   // 0 -> z after 3
    #10 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule
