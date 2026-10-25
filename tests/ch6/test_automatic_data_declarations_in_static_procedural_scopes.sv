/*
:name: test_automatic_data_declarations_in_static_procedural_scopes
:description: Data declarations with the automatic keyword inside a static task, a static function, a loop body block and a block that forks processes give variables initialized on every entry, against explicitly static ones that keep their values (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 9.3.2 A.2.1.3 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_automatic_data_declarations_in_static_procedural_scopes.expected
*/
// IEEE 1800-2023 §6.21 with footnote 14 of A.10: the automatic keyword can be
// used in a data declaration within a procedural context. In a static task,
// function or block such a variable lives for one call or one entry to the
// block and is initialized on each entry; an explicitly static variable is
// initialized once and keeps its value. §9.3.2: processes forked with
// join_none see the automatic variable of the entry that forked them.
//
//   task step: s (static) and a (automatic) both start at 0 and get + 5:
//     s = 5, 10, 15 and a = 5 each call;
//   function bump: fa (automatic, 100) and fs (static, 100) get + 1:
//     fa * 1000 + fs = 101101, 101102, 101103;
//   loop block: ba = i * 2 on each entry, then + 1: 1, 3, 5;
//   fork block: k = i on each entry; the forked process waits k + 1 and
//     prints k, so k = 0, 1, 2 at times 1, 2, 3.
//
// Icarus Verilog 13.0 does not support an automatic variable in a static
// task ("Overriding the default variable lifetime is not yet supported").

`timescale 1ns / 1ns

module test_automatic_data_declarations_in_static_procedural_scopes;
  task step(output int s_out, output int a_out);
    static int s = 0;
    automatic int a = 0;
    s += 5;
    a += 5;
    s_out = s;
    a_out = a;
  endtask

  function int bump();
    automatic int fa = 100;
    static int fs = 100;
    fa++;
    fs++;
    return fa * 1000 + fs;
  endfunction

  initial begin
    int s, a, r;
    repeat (3) begin
      step(s, a);
      $display("task: s=%0d a=%0d", s, a);
    end
    repeat (3) begin
      r = bump();
      $display("function: %0d", r);
    end
    for (int i = 0; i < 3; i++) begin : loop_body
      automatic int ba = i * 2;
      ba += 1;
      $display("block: ba=%0d", ba);
    end
    for (int i = 0; i < 3; i++) begin : fork_body
      automatic int k = i;
      fork
        #(k + 1) $display("fork: k=%0d at %0d", k, $time);
      join_none
    end
  end
endmodule
