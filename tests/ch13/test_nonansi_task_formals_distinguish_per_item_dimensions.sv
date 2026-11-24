/*
:name: test_nonansi_task_formals_distinguish_per_item_dimensions
:description: Non-ANSI task formals keep each unpacked array dimension attached to its own identifier
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 A.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonansi_task_formals_distinguish_per_item_dimensions.expected
*/
module test_nonansi_task_formals_distinguish_per_item_dimensions;
  typedef int pair [2];
  typedef int grid [2][2];

  task automatic pick;
    input int one[2], two[2][2], bias;
    output int result;
    result = one[1] + 10 * two[0][1] + 100 * two[1][0] + 1000 * bias;
  endtask

  initial begin
    pair one;
    grid two;
    int result;
    one = '{1, 2};
    two = '{'{3, 4}, '{5, 6}};
    pick(.two(two), .result(result), .one(one), .bias(7));
    $display("named=%0d", result);
    pick(one, two, 9, result);
    $display("explicit=%0d", result);
  end
endmodule
