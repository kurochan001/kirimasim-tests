/*
:name: test_program_attributed_and_generate_items
:description: A program can hold attributed data declarations, continuous assignments, initial and final procedures and concurrent assertions, and loop, conditional and region generate constructs and elaboration severity tasks, each of which takes effect (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 27.3 27.4 27.5 20.10.1 16.14.1 9.2.3 A.1.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_attributed_and_generate_items.expected
*/
// IEEE 1800-2023 A.1.7: a non-port program item is a continuous assignment, a
// module_or_generate_item_declaration, an initial procedure, a final
// procedure or a concurrent assertion item, each with any number of
// attribute instances before it, or a program_generate_item: a loop or
// conditional generate construct, a generate region or an elaboration
// severity task. pa_prog has one of each:
//   - attributed declaration acc = 0, which the attributed initial procedure
//     sets to 4, and attributed assign total = acc * 2, so total = 8;
//   - an attributed assertion on sig at each posedge of clk (16.14.1) with a
//     pass and a fail action; sig is 1, 0, 1 at the edges at 5, 15 and 25, so
//     passes=2 and fails=1;
//   - for genvar (27.4) gives g_l[2].v = 20; if (N > 2) (27.5) gives
//     g_c.flag = 1; generate case ... endgenerate (27.3) gives g_r.w = 33;
//   - elaboration severity tasks (20.10.1): the $info in the program body
//     only prints its message (not part of the compared output) and does not
//     keep the simulation from starting; the $error in a conditional generate
//     block that N = 3 does not select is not executed, so it does not
//     either.
// The initial procedure ends at time 30, which ends the simulation (24.3);
// the top module also calls $finish at 31, before the next edge of clk at 35.
// Then the attributed final procedure (9.2.3) prints the results.
// Icarus Verilog 13.0 rejects the attribute instances before the continuous
// assignment, and it does not support concurrent assertions.

program pa_prog #(parameter int N = 3) (input var bit clk, input var bit sig, output int total);
  (* pa_kind = "decl" *) int acc = 0;
  int passes = 0, fails = 0;

  (* pa_kind = "assign" *) (* pa_note *) assign total = acc * 2;

  (* pa_kind = "initial" *) initial begin
    acc = 4;
    #30;
  end

  (* pa_kind = "assert" *) a_sig: assert property (@(posedge clk) sig) passes++; else fails++;

  for (genvar i = 0; i < N; i++) begin : g_l
    int v = i * 10;
  end

  if (N > 2) begin : g_c
    int flag = 1;
  end else begin : g_c
    int flag = 0;
  end

  generate
    case (N)
      3: begin : g_r
        int w = 33;
      end
      default: begin : g_r
        int w = 0;
      end
    endcase
  endgenerate

  $info("pa_prog elaborated");

  if (N > 5) begin : g_too_big
    $error("pa_prog N is too big");
  end

  (* pa_kind = "final" *) final
    $display("total=%0d passes=%0d fails=%0d loop=%0d cond=%0d region=%0d", total, passes, fails,
             g_l[2].v, g_c.flag, g_r.w);
endprogram

module test_program_attributed_and_generate_items;
  bit clk = 1'b0, sig = 1'b1;
  int total;

  pa_prog u_prog (.clk(clk), .sig(sig), .total(total));

  always #5 clk = ~clk;
  initial begin
    #10 sig = 1'b0;
    #10 sig = 1'b1;
  end
  initial #31 $finish;
endmodule
