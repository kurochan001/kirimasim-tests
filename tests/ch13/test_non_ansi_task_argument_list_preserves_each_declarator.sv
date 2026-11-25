/*
:name: test_non_ansi_task_argument_list_preserves_each_declarator
:description: A non-ANSI task argument declaration preserves the dimensions of each declarator
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 13.5.2 A.2.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_non_ansi_task_argument_list_preserves_each_declarator.expected
:expected_exit: 0
*/
module test_non_ansi_task_argument_list_preserves_each_declarator;
  task automatic score;
    input int first_value, pair[2], matrix[2][2], last_value;
    output int total;
    total = first_value + 2 * pair[0] + 3 * pair[1]
           + 5 * matrix[0][0] + 7 * matrix[0][1] + 11 * matrix[1][0] + 13 * matrix[1][1]
           + 17 * last_value;
  endtask

  initial begin
    int matrix[2][2], pair[2], total;
    matrix = '{'{2, 4}, '{6, 8}};
    pair = '{13, 17};
    score(7, pair, matrix, 5, total);
    $display("positional %0d", total);
    score(.last_value(29), .pair(pair), .total(total), .matrix(matrix), .first_value(23));
    $display("named %0d", total);
  end
endmodule
