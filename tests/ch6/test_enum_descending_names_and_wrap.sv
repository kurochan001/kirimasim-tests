/*
:name: test_enum_descending_names_and_wrap
:description: Descending enum name ranges preserve declaration order for first last num and prev (IEEE 1800-2023 Section 6.19.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.1 6.19.2 6.19.5.1 6.19.5.2 6.19.5.4 6.19.5.5 6.19.5.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_descending_names_and_wrap.expected
*/
// IEEE 1800-2023 6.19.1 6.19.2 6.19.5.1 6.19.5.2 6.19.5.4 6.19.5.5 6.19.5.7:
// Generated names descend but their assigned values ascend. Prev wraps by
// declaration order, including over a numeric gap.

module test_enum_descending_names_and_wrap;
  typedef enum int { SLOT[2:0] = 7, DONE = 20 } state_t;
  state_t s;
  initial begin
    s = SLOT2;
    $display("bounds=%0d,%0d count=%0d prev=%0d", s.first(), s.last(), s.num(), s.prev());
    s = s.prev(2);
    $display("two_back=%s value=%0d range=%0d,%0d,%0d", s.name(), s, SLOT2, SLOT1, SLOT0);
  end
endmodule
