/*
:name: test_multidimensional_variable_slice_preserves_untouched_rows
:description: Assigning a fixed multidimensional slice maps both dimensions and leaves rows outside the target slice untouched
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.4.6 6.22.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multidimensional_variable_slice_preserves_untouched_rows.expected
*/
module test_multidimensional_variable_slice_preserves_untouched_rows;
  int source [5:2][8:7];
  int destination [0:3][-3:-2];

  task automatic inspect(input string label_text);
    $display("%s rows=%0d/%0d %0d/%0d %0d/%0d %0d/%0d", label_text,
             destination[0][-3], destination[0][-2], destination[1][-3], destination[1][-2],
             destination[2][-3], destination[2][-2], destination[3][-3], destination[3][-2]);
  endtask

  initial begin
    source = '{'{11, 12}, '{21, 22}, '{31, 32}, '{41, 42}};
    destination = '{'{91, 92}, '{81, 82}, '{71, 72}, '{61, 62}};
    destination[1:2] = source[4:3];
    inspect("initial");
    source[4][8] = 23;
    source[3][7] = 35;
    inspect("snapshot");
    destination[2:3] = source[4:3];
    inspect("changed");
    $finish(0);
  end
endmodule
