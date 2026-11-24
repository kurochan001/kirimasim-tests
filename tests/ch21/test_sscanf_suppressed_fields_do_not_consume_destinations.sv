/*
:name: test_sscanf_suppressed_fields_do_not_consume_destinations
:description: Suppressed scan conversions consume input but do not change the destination list or assignment count
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_suppressed_fields_do_not_consume_destinations.expected
*/
module test_sscanf_suppressed_fields_do_not_consume_destinations;
  int first, second, assignments;

  initial begin
    first = -1;
    second = -1;
    assignments = $sscanf("99 12 discard 2f", "%*d %d %*s %h", first, second);
    $display("count=%0d first=%0d second=%0d", assignments, first, second);
    first = -1;
    assignments = $sscanf("99", "%*d");
    $display("only_suppressed=%0d first=%0d", assignments, first);
  end
endmodule
