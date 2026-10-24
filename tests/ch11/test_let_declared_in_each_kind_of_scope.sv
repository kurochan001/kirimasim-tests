/*
:name: test_let_declared_in_each_kind_of_scope
:description: a let can be declared in the compilation-unit scope, a package, a module, an interface, a program, a checker, a generate block, a begin-end and a fork-join block, a function and a task, and is used there (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_declared_in_each_kind_of_scope.expected
*/
// IEEE 1800-2023 §11.12: a let declaration may appear in a module, an
// interface, a program, a checker, a clocking block, a package, the
// compilation-unit scope, a generate block, a sequential or parallel block
// and a subroutine. (The clocking block is the subject of
// test_let_declared_in_clocking_block.)
// Each scope declares its own let with a different body and uses it inside
// the same scope, so every line shows the value of that scope's let. The
// interface let is used through a function of the interface, and the
// checker let in a concurrent assertion of the checker, which passes at the
// rising clock edge at time 5. The program prints last, at time 10; the end
// of its initial procedure then ends the simulation (§24.3).
// Icarus Verilog 13.0 does not parse let declarations.

let cu_inc(v) = v + 1;

package p_ctx;
  let pk(v) = v + 2;
endpackage

interface ifc;
  logic [7:0] s = 8'd10;
  let il = s + 8'd3;
  function automatic int get();
    return il;
  endfunction
endinterface

program prg;
  let pl(v) = v + 4;
  initial #10 $display("program: %0d", pl(1));
endprogram

checker chk(logic clk, logic [7:0] sig);
  let ckl = sig + 8'd5;
  a_chk: assert property (@(posedge clk) ckl == 8'd15) $display("checker: %0d", ckl);
endchecker

module test_let_declared_in_each_kind_of_scope;
  logic clk = 0;
  logic [7:0] sig = 8'd10;
  ifc u_if ();
  prg u_prg ();
  chk u_chk (clk, sig);

  for (genvar g = 0; g < 1; g++) begin : gb
    let gl = g + 7;
    initial #1 $display("generate: %0d", gl);
  end

  function automatic int fn(int v);
    let fl = v * 2;
    return fl;
  endfunction

  task automatic tk(int v);
    let tl = v * 3;
    $display("task: %0d", tl);
  endtask

  let ml = sig + 8'd20;

  initial begin
    #3;
    $display("unit: %0d package: %0d interface: %0d module: %0d", cu_inc(1), p_ctx::pk(1),
             u_if.get(), ml);
    begin
      let bl = sig + 8'd1;
      $display("begin: %0d", bl);
    end
    fork
      begin
        let jl = sig + 8'd2;
        $display("fork: %0d", jl);
      end
    join
    $display("function: %0d", fn(5));
    tk(5);
    #2 clk = 1;
  end
endmodule
