/*
:name: test_interface_nonport_item_kinds
:description: The items of an interface can be a generate region, module common items with attribute instances before them and a modport declaration, and each of them takes effect (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5 25.5.4 27.3 A.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_nonport_item_kinds.expected
*/
// IEEE 1800-2023 §25.3 and A.1.6: a non-port item of an interface can be a
// generate region, an interface_or_generate_item (a module common item with
// any number of attribute instances before it) or a modport declaration,
// among others. ix_if has
//   - generate ... endgenerate (27.3), which makes g_w[0..2] with
//     w = data + i;
//   - attributed items: a continuous assignment sum = 2 * data, a function
//     twice and an initial procedure that sets data to 20;
//   - the modport cons, which gives the module ix_user, whose port has the
//     type ix_if.cons, the input sum and, through the modport expression
//     .total(data), the variable data under the name total (25.5.4), so
//     seen = 20 + 40.
// Icarus Verilog 13.0 rejects the attribute instance before the function
// declaration with a syntax error.

interface ix_if #(parameter int N = 3);
  logic [7:0] data;
  int sum;

  generate
    for (genvar i = 0; i < N; i++) begin : g_w
      logic [7:0] w;
      assign w = data + 8'(i);
    end
  endgenerate

  (* ix_kind = "assign" *) (* ix_note *) assign sum = 2 * data;
  (* ix_kind = "function" *) function automatic int twice(int v);
    return 2 * v;
  endfunction
  (* ix_kind = "initial" *) initial data = 8'd20;

  modport cons (input .total(data), input sum);
endinterface

module ix_user (ix_if.cons p);
  int seen;
  assign seen = p.total + p.sum;
endmodule

module test_interface_nonport_item_kinds;
  ix_if u_if();
  ix_user u_user(.p(u_if));

  initial #1 begin
    $display("data=%0d sum=%0d w0=%0d w2=%0d twice=%0d", u_if.data, u_if.sum, u_if.g_w[0].w,
             u_if.g_w[2].w, u_if.twice(5));
    $display("user seen=%0d", u_user.seen);
  end
endmodule
