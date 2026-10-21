/*
:name: test_coverage_definition_control
:description: A coverage control names a module definition to act on every instance of it or an instance to act on that one, so a reset and a start of one instance leave the other instance as it was (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 40.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_definition_control.expected
*/
// IEEE 1800-2023 §40.3.2.1, Table 40-2: with SV_COV_MODULE and a module
// definition name, a control acts on all instances of the module, and with an
// instance name on just that instance. §40.2.2: a reset clears the coverage of
// the scope, and a stop means that later changes do not add to it, while a
// start lets them add again. The design has two instances of the leaf module,
// each with an 8-bit signal. The test stops the definition "leaf", starts it,
// toggles bit 0 of both signals and reads the current values (40.3.2.3), then
// resets only u1: u1 becomes zero and u2 keeps its value. It stops the
// definition again and toggles bit 1 of both, which changes neither. It starts
// only u1 and toggles bit 2 of both: u1 covers the new bit, and u2, still
// stopped, does not change. Which items have coverage depends on the tool, so
// each line is an implication that holds also when a control fails or when the
// tool has no toggle coverage.

`timescale 1ns/1ns

module test_coverage_definition_control_leaf(input logic [7:0] d);
  logic [7:0] t = 8'h00;

  always_comb t = d;
endmodule

module test_coverage_definition_control;
  logic [7:0] d1 = 8'h00, d2 = 8'h00;

  test_coverage_definition_control_leaf u1(.d(d1));
  test_coverage_definition_control_leaf u2(.d(d2));

  int stop_all, start_all, reset_u1, stop_def, start_u1;
  int c1, c2, c1_after, c2_after;
  int u1_before, u2_before, u1_after, u2_after;
  int max_u1, x1_before, x1_after, x2_before, x2_after;

  task automatic show(string what, bit ok);
    if (ok)
      $display("%s: 1", what);
    else
      $display("%s: 0", what);
  endtask

  initial begin
    #1;
    stop_all = $coverage_control(`SV_COV_STOP, `SV_COV_TOGGLE, `SV_COV_MODULE,
                                 "test_coverage_definition_control_leaf");
    #1;
    start_all = $coverage_control(`SV_COV_START, `SV_COV_TOGGLE, `SV_COV_MODULE,
                                  "test_coverage_definition_control_leaf");
    #1 d1 = 8'h01; d2 = 8'h01;      // 3: bit 0 of both
    #1 d1 = 8'h00; d2 = 8'h00;      // 4
    #1;                             // 5
    c1 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    c2 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    reset_u1 = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    c1_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    c2_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    show("reset of u1 clears u1 and leaves u2 unchanged",
         reset_u1 != `SV_COV_OK || (c1_after == 0 && c2_after == c2));
    #1;                             // 6
    stop_def = $coverage_control(`SV_COV_STOP, `SV_COV_TOGGLE, `SV_COV_MODULE,
                                 "test_coverage_definition_control_leaf");
    u1_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    u2_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    #1 d1 = 8'h02; d2 = 8'h02;      // 7: bit 1 of both
    #1 d1 = 8'h00; d2 = 8'h00;      // 8
    #1;                             // 9
    u1_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    u2_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    show("while the definition is stopped, neither instance changes",
         stop_def != `SV_COV_OK || (u1_after == u1_before && u2_after == u2_before));
    start_u1 = $coverage_control(`SV_COV_START, `SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    max_u1 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    x1_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    x2_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    #1 d1 = 8'h04; d2 = 8'h04;      // 10: bit 2 of both
    #1 d1 = 8'h00; d2 = 8'h00;      // 11
    #1;                             // 12
    x1_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u1);
    x2_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u2);
    show("starting the instance u1 lets u1 collect",
         start_u1 != `SV_COV_OK || max_u1 <= 0 || x1_after > x1_before);
    show("u2 stays stopped after starting u1",
         start_u1 != `SV_COV_OK || x2_after == x2_before);
  end
endmodule
