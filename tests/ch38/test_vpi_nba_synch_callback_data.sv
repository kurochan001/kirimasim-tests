/*
:name: test_vpi_nba_synch_callback_data
:description: A cbNBASynch callback whose request has a value of an undefined format runs before the nonblocking updates of its time step with a new s_cb_data that holds the current time and the registered user_data (IEEE 1800-2023 Section 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36.3 4.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_nba_synch_callback_data.c
:expected_stdout: @test_vpi_nba_synch_callback_data.expected
*/
// IEEE 1800-2023 §38.36.2: a cbNBASynch callback runs just before the
// nonblocking assignments of its time step are done. As for every time
// callback, the value field of the request is ignored, and the routine gets
// a pointer to a new s_cb_data, not to the one given to vpi_register_cb,
// whose time holds the current time and whose user_data is the registered
// one.
//
// At the start of the simulation (38.36.3), at time 0, where a time and a
// delay are the same, the application registers cbNBASynch for 10 from a
// static s_cb_data whose value points to an s_vpi_value with a format that
// no table defines. At 10 the design sets a with a blocking and b with a
// nonblocking assignment. The callback prints the time of its structure, its
// user_data, a and b, and whether its structure is a new one with the
// registered reason.
// Icarus Verilog 13.0 has no cbNBASynch in its vpi_user.h, and with the
// Annex K value it does not register the callback; Verilator 5.052 does not
// register it either.

`timescale 1ns/1ns

module test_vpi_nba_synch_callback_data;
  int a = 0, b = 0;

  initial begin
    #10 a = 1;
    b <= 1;
    #10 $finish;
  end
endmodule
