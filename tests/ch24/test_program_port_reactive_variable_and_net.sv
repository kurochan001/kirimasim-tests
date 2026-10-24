/*
:name: test_program_port_reactive_variable_and_net
:description: Program ports connect to variables and nets of the design; a write of the program updates the variable and drives and resolves the net on the design side within the reactive region set, and design processes sensitive to them run only after that set has finished (IEEE 1800-2023 Section 24.3.2)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.2 24.3.1 4.5 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_program_port_reactive_variable_and_net.expected
*/
// IEEE 1800-2023 §24.3.2: program ports belong to the program, and since a
// program is instantiated in a design scope, they are connected to design
// nets and variables. Program code runs in the reactive region set, so the
// variable on the design side of an output port is updated there, and a net
// on the design side is driven and resolved there as soon as the driver in
// the program changes. Design processes sensitive to them are woken in the
// active region set, which runs again only when the Reactive, Re-Inactive and
// Re-NBA regions are all empty (§4.5).
//   - pr_prog has an output variable port ov (to the design variable mv), an
//     output net port ow driven by assign ow = drv (to the design net mw,
//     which also has a weak 1 driver), an input variable port iv (from the
//     variable src_v) and an input net port iw (from the net src_w = 0).
//   - At 10, the module prints first, in the active region: mv=0 mw=0 (strong
//     0 of the program against weak 1). Then the program resumes in the
//     Reactive region (§24.3.1), sets ov = iv = 1 and drv = ~iw = 1, and waits
//     #0, which resumes it in the Re-Inactive region. By then the program
//     assign has driven mw, so it reads mw=1 (strong 1 with weak 1), and it
//     sets the design variable mark to 1.
//   - The always procedures of the module that wait on mv and mw record the
//     value and mark when they wake at 10: mark is already 1, since they can
//     run only after the reactive region set is empty.
// The initial procedure of the program ends at 15, which ends the simulation
// (§24.3).

`timescale 1ns/1ns

program pr_prog (output logic ov, output wire ow, input logic iv, input wire iw);
  logic drv = 1'b0;

  assign ow = drv;

  initial begin
    ov = 1'b0;
    #10 ov = iv;
    drv = ~iw;
    #0 test_program_port_reactive_variable_and_net.mark = 1'b1;
    $display("%0t program: ov=%b iv=%b iw=%b mw=%b", $time, ov, iv, iw,
             test_program_port_reactive_variable_and_net.mw);
    #5;
  end
endprogram

module test_program_port_reactive_variable_and_net;
  logic mv;
  wire mw;
  logic src_v = 1'b0;
  wire src_w;
  logic mark = 1'b0;
  logic mv_seen, mw_seen, mv_mark, mw_mark;

  assign (weak0, weak1) mw = 1'b1;
  assign src_w = 1'b0;

  pr_prog u_p (.ov(mv), .ow(mw), .iv(src_v), .iw(src_w));

  initial begin
    #5 src_v = 1'b1;
    #5 $display("%0t module: mv=%b mw=%b mark=%b", $time, mv, mw, mark);
  end

  always @(mv) if ($time == 10) begin
    mv_seen = mv;
    mv_mark = mark;
  end
  always @(mw) if ($time == 10) begin
    mw_seen = mw;
    mw_mark = mark;
  end

  initial #11 $display("woken at 10: mv=%b with mark=%b, mw=%b with mark=%b",
                       mv_seen, mv_mark, mw_seen, mw_mark);
endmodule
