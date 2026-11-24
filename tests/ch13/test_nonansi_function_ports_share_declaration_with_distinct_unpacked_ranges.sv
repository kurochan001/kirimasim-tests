/*
:name: test_nonansi_function_ports_share_declaration_with_distinct_unpacked_ranges
:description: A non-ANSI input declaration contains two array ports with independent ranges
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5 A.2.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonansi_function_ports_share_declaration_with_distinct_unpacked_ranges.expected
*/
module test_nonansi_function_ports_share_declaration_with_distinct_unpacked_ranges;
  function automatic int score;
    input int first [2:3], second [-1:0];
    return first[2] + 10 * first[3] + 100 * second[-1] + 1000 * second[0];
  endfunction

  initial begin
    int a [8:9], b [5:4];
    a[8] = 3;
    a[9] = 4;
    b[5] = 5;
    b[4] = 6;
    $display("score=%0d", score(a, b));
  end
endmodule
