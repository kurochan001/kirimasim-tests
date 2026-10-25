/*
:name: test_force_release_target_forms
:description: force and release accept a whole variable, a whole net, a constant bit-select and a constant part-select of a vector net, and a concatenation of a net and a variable, and force only the bits named (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release_target_forms.expected
*/
// IEEE 1800-2023 §10.6.2: the left-hand side of a force, and the operand of
// a release, can be a singular variable, a net, a constant bit-select or a
// constant part-select of a vector net, or a concatenation of these.
//
// The test forces one target of each form: the whole variable v8, the whole
// net nw, the bit n8[2] and the part n8[7:5] of the net n8, and the
// concatenation {m4, sv} of a net and a variable. While forced, the drivers
// of the nets and the variables are written: only the forced bits keep the
// forced values (the other bits of n8 follow its driver). After the
// releases, the nets show their drivers at once and the variables keep the
// forced values, since nothing drives them continuously.

module test_force_release_target_forms;
  logic [7:0] v8 = 8'h00;
  logic sv = 1'b0;
  logic [7:0] s8 = 8'h00;
  logic [3:0] s4 = 4'h0, sw = 4'h0;
  wire [7:0] n8 = s8;
  wire [3:0] m4 = s4;
  wire [3:0] nw = sw;

  initial begin
    #1;
    force v8 = 8'ha5;
    force nw = 4'h9;
    force n8[2] = 1'b1;
    force n8[7:5] = 3'b101;
    force {m4, sv} = 5'b1011_1;
    #1 $display("forced:   v8=%h nw=%h n8=%b m4=%b sv=%b", v8, nw, n8, m4, sv);
    v8 = 8'h11;
    sv = 1'b0;
    sw = 4'h3;
    s8 = 8'hff;
    s4 = 4'h6;
    #1 $display("writes:   v8=%h nw=%h n8=%b m4=%b sv=%b", v8, nw, n8, m4, sv);
    s8 = 8'h00;
    #1 $display("s8=00:    v8=%h nw=%h n8=%b m4=%b sv=%b", v8, nw, n8, m4, sv);
    release v8;
    release nw;
    release n8[2];
    release n8[7:5];
    release {m4, sv};
    $display("released: v8=%h nw=%h n8=%b m4=%b sv=%b", v8, nw, n8, m4, sv);
  end
endmodule
