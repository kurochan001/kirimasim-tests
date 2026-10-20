/*
:name: test_writemem_two_state_enum
:description: $writememh can write unpacked arrays of 2-state types such as int and enum; an enum element is written as its value, which reads back into an int array (IEEE 1800-2023 Section 21.5.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5.2 21.4.1 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writemem_two_state_enum.expected
*/
// IEEE 1800-2023 §21.5.2: $writememb and $writememh can write unpacked
// arrays of 2-state types, such as int and enumerated types, and an enum
// element is written as its value (6.19). state_t has the default values 0, 1
// and 2, so the values read back into an int array name the states; the int
// array, with a negative value, reads back unchanged. The test creates its
// files in the current directory.

module test_writemem_two_state_enum;
  typedef enum {IDLE, BUSY, DONE} state_t;

  state_t states [0:3];
  int as_int [0:3];
  int counts [0:1], counts_back [0:1];

  initial begin
    states = '{BUSY, DONE, IDLE, DONE};
    counts = '{12, -3};
    $writememh("test_writemem_two_state_enum_s.mem", states);
    $readmemh("test_writemem_two_state_enum_s.mem", as_int);
    $writememh("test_writemem_two_state_enum_c.mem", counts);
    $readmemh("test_writemem_two_state_enum_c.mem", counts_back);
    $display("states as values: %0d %0d %0d %0d", as_int[0], as_int[1], as_int[2], as_int[3]);
    $display("counts: %0d %0d", counts_back[0], counts_back[1]);
  end
endmodule
