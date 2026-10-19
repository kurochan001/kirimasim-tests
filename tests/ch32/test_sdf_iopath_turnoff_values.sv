/*
:name: test_sdf_iopath_turnoff_values
:description: With three SDF delay values, transitions from z use the rise or fall value and transitions to z use the third value (IEEE 1800-2023 Section 32.8)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.8 32.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_turnoff_values.expected
*/
// IEEE 1800-2023 §32.8, Table 32-4: three SDF values v1, v2, v3 give a module
// path the delays 0->1 v1, 1->0 v2, 0->z v3, z->1 v1, 1->z v3 and z->0 v2. The
// path from the enable of a bufif1 to its output gets (2) (3) (7): the output
// leaves z after 3 when the data is 0 and after 2 when it is 1, and goes back
// to z after 7. Transitions before time 10 are not printed.

`timescale 1ns/1ns

module sdf_tristate_cell(output y, input a, input en);
  bufif1 (y, a, en);
  specify
    (a => y) = 1;
    (en => y) = 1;
  endspecify
endmodule

module test_sdf_iopath_turnoff_values;
  reg a = 0, en = 0;
  wire y;
  integer f;

  sdf_tristate_cell u(y, a, en);

  initial begin
    f = $fopen("test_sdf_iopath_turnoff_values.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_tristate_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH en y (2) (3) (7))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_turnoff_values.sdf");
    #10 en = 1;     // 10: z -> 0
    #10 en = 0;     // 20: 0 -> z
    #10 a = 1;      // 30: y stays z
    #10 en = 1;     // 40: z -> 1
    #10 en = 0;     // 50: 1 -> z
    #20 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule
