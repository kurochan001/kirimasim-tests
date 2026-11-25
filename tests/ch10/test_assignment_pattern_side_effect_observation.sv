/*
:name: test_assignment_pattern_side_effect_observation
:description: Record evaluation counts for array and structure assignment patterns
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.9.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_pattern_side_effect_observation.expected
*/
module test_assignment_pattern_side_effect_observation;
  typedef struct packed { int left, middle, right; } record_t;
  int calls;
  int array_value[3];
  record_t record_value;

  function automatic int counted(int value);
    calls++;
    return value;
  endfunction

  initial begin
    array_value = '{default:3};
    record_value = '{default:4};
    $display("control array=%0d%0d%0d struct=%0d%0d%0d",
             array_value[0], array_value[1], array_value[2],
             record_value.left, record_value.middle, record_value.right);
`ifdef OBSERVE_ARRAY_TYPE_KEY
    if ($test$plusargs("array_type")) begin
      array_value = '{int:counted(5)};
      $display("array type calls=%0d values=%0d%0d%0d", calls,
               array_value[0], array_value[1], array_value[2]);
    end
`endif
    if ($test$plusargs("array_default")) begin
      array_value = '{default:counted(6)};
      $display("array default calls=%0d values=%0d%0d%0d", calls,
               array_value[0], array_value[1], array_value[2]);
    end
    if ($test$plusargs("array_replication")) begin
      array_value = '{3{counted(7)}};
      $display("array replication calls=%0d values=%0d%0d%0d", calls,
               array_value[0], array_value[1], array_value[2]);
    end
    if ($test$plusargs("struct_type")) begin
      record_value = '{int:counted(5)};
      $display("struct type calls=%0d values=%0d%0d%0d", calls,
               record_value.left, record_value.middle, record_value.right);
    end
    if ($test$plusargs("struct_default")) begin
      record_value = '{default:counted(6)};
      $display("struct default calls=%0d values=%0d%0d%0d", calls,
               record_value.left, record_value.middle, record_value.right);
    end
    if ($test$plusargs("struct_replication")) begin
      record_value = '{3{counted(7)}};
      $display("struct replication calls=%0d values=%0d%0d%0d", calls,
               record_value.left, record_value.middle, record_value.right);
    end
    $finish(0);
  end
endmodule
