/*
:name: test_illegal_end_name_differs_from_begin_name
:description: a block name after end has to be the name of the block given after begin (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.4 9.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the block named outer_b ends with end : inner_b
:expected_stderr_regex: test_illegal_end_name_differs_from_begin_name\.sv:32:
*/
// IEEE 1800-2023 §9.3.4: a block name may follow end, join, join_any or
// join_none after a colon; it is not required, but it shall be an error if
// it differs from the name of the block. The fork block par_b ends with its
// own name, and an unnamed block and a named one end without a name, which
// is legal; the block outer_b ends with another name.

module test_illegal_end_name_differs_from_begin_name;
  int a, b;

  initial begin
    fork : par_b
      a = 1;
    join : par_b
    begin : quiet_b
      b = 2;
    end
    begin : outer_b
      a = a + b;
    end : inner_b   // illegal: another name than outer_b
    $display("%0d", a);
  end
endmodule
