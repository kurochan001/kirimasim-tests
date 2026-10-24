/*
:name: test_vpi_register_cb_structure
:description: vpi_user.h defines s_cb_data with the fields, field types and order of Figures 38-2 and 38-17 and vpi_register_cb as taking a p_cb_data and returning a vpiHandle; it returns a callback object for an event, a time and an action reason, and the reason decides when the routine in cb_rtn is called (IEEE 1800-2023 Section 38.36)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36 38.8 38.36.1 38.36.2 38.36.3 K.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_register_cb_structure.c
:expected_stdout: @test_vpi_register_cb_structure.expected
*/
// IEEE 1800-2023 §38.36 (Figure 38-17), §38.8 (Figure 38-2): s_cb_data has
// reason (PLI_INT32), cb_rtn (a routine taking struct t_cb_data * and
// returning PLI_INT32), obj (vpiHandle), time (p_vpi_time), value
// (p_vpi_value), index (PLI_INT32) and user_data (PLI_BYTE8 *), in this order,
// and p_cb_data points to it. vpi_register_cb takes a p_cb_data and returns a
// handle to the callback object (vpiCallback, K.2). Its reasons belong to
// three categories: simulation events (38.36.1), simulation times (38.36.2)
// and simulator actions or features (38.36.3). The reason decides when the
// callback occurs, and cb_rtn is the routine that is then called.
//
// At the start of the simulation, the application checks the declarations at
// compile time (C11 _Generic in C, decltype in C++) and with offsetof and
// prints 1 for each check that holds. It then registers one routine,
// on_event_or_time, for a cbValueChange on r and for a cbAfterDelay of 5, and
// another, on_end, for cbEndOfSimulation, and prints whether each returned
// handle is a vpiCallback. The design changes r at 10 and ends at 20. Each
// routine prints its own name, its user_data and the time.

`timescale 1ns/1ns

module test_vpi_register_cb_structure;
  bit [7:0] r;

  initial begin
    #10 r = 7;
    #10 $finish;
  end
endmodule
