/*
:name: test_vpi_fsm_reports_separate_enum_binding_and_partselect_name
:description: FSM coverage uses an enum pragma inside a signal declaration and exposes a part-select's explicit report name independently of its enum name
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.4.1 40.4.2 40.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_fsm_reports_separate_enum_binding_and_partselect_name.c
:expected_stdout: @test_vpi_fsm_reports_separate_enum_binding_and_partselect_name.expected
*/
module test_vpi_fsm_reports_separate_enum_binding_and_partselect_name;
  /* tool state_vector cfg_state */
  logic [3:0] /* tool enum serial_codes */ cfg_state = 4'd1;
  parameter [3:0] /* tool enum serial_codes */ SERIAL_INIT = 1, SERIAL_DONE = 9;

  /* tool state_vector control[4:2] frame_rx enum rx_codes */
  logic [5:0] control = 6'b100011;
  parameter [2:0] /* tool enum rx_codes */ RX_IDLE = 0, RX_WAIT = 2, RX_PAYLOAD = 5;

  initial begin
    #1 $vt_fsm_bindings;
    #1;
    cfg_state = SERIAL_DONE;
    control[4:2] = RX_PAYLOAD;
    control[5] = 0;
    #1 $vt_fsm_bindings;
  end
endmodule
