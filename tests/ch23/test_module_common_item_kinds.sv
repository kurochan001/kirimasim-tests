/*
:name: test_module_common_item_kinds
:description: A module common item can be a declaration, an interface instance, a continuous assignment, a net alias, an initial, always or final procedure, a loop or conditional generate construct or an elaboration severity task, and each of them takes effect (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.4 25.3 10.3 10.11 9.2.1 9.2.2 9.2.3 27.4 27.5 20.10.1 A.1.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_common_item_kinds.expected
*/
// IEEE 1800-2023 A.1.4: a module_common_item is a
// module_or_generate_item_declaration, an interface or program instance, an
// assertion item, a bind directive, a continuous assignment, a net alias, an
// initial, final or always procedure, a loop or conditional generate
// construct or an elaboration severity task. This module has all of them but
// the program instance, the assertion item and the bind directive:
//   - declarations: the type nib_t, the variable a and the function sq;
//   - u_if, an instance of cm_if, whose v is 9 (25.3);
//   - assign w = a + 1, which follows a (10.3);
//   - alias n1 = n2, so n1 has the value 6 that drives n2 (10.11);
//   - the initial procedure sets a and triggers the event step at times 1
//     and 2 (9.2.1), the always procedure counts both triggers (9.2.2) and
//     the final procedure prints the count at the end of the simulation
//     (9.2.3);
//   - for genvar makes g_l[0..2] with p = 2 * i (27.4) and if (W > 2) makes
//     g_c with c = 5 (27.5);
//   - the elaboration task $info only prints its message, which is not part
//     of the compared output, and does not keep the simulation from starting
//     (20.10.1).
// Icarus Verilog 13.0 stops with a syntax error at the net alias; with the
// alias replaced by a continuous assignment it prints the expected lines.

interface cm_if;
  int v = 9;
endinterface

module test_module_common_item_kinds #(parameter int W = 4);
  typedef logic [W-1:0] nib_t;
  nib_t a;
  function automatic int sq(int x);
    return x * x;
  endfunction

  cm_if u_if();

  wire [3:0] w;
  assign w = a + 4'd1;

  wire [3:0] n1, n2;
  alias n1 = n2;
  assign n2 = 4'd6;

  event step;
  int changes = 0;
  always @(step) changes++;

  initial begin
    #1 a = 4'd5;
    -> step;
    #1 a = 4'd7;
    -> step;
    #1 $display("w=%0d alias=%0d if=%0d sq=%0d loop=%0d cond=%0d", w, n1, u_if.v, sq(a),
                g_l[2].p, g_c.c);
  end

  final $display("final changes=%0d", changes);

  for (genvar i = 0; i < 3; i++) begin : g_l
    int p = 2 * i;
  end

  if (W > 2) begin : g_c
    int c = 5;
  end

  $info("test_module_common_item_kinds elaborated");
endmodule
