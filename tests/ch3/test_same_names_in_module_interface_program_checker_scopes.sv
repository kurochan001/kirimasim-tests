/*
:name: test_same_names_in_module_interface_program_checker_scopes
:description: Two modules, an interface, a program, a checker and the top module each declare a variable count, and the modules, the interface and the program each also declare a function get; every declaration stays local to its block and holds its own value (IEEE 1800-2023 Section 3.9)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.9 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_same_names_in_module_interface_program_checker_scopes.expected
*/
// IEEE 1800-2023 §3.9: modules, interfaces, programs and checkers each give
// their declarations a local name space; an identifier declared in one of
// them does not affect or conflict with a declaration of the same name in
// another building block.
// The variable count is declared six times with different initial values:
// 10 in ln_mod_a, 20 in ln_mod_b, 30 in ln_if, 40 in the checker ln_chk, 50
// in the program ln_prog and 60 in the top module. ln_mod_a, ln_mod_b, ln_if
// and ln_prog also each declare a function get that returns their own count
// plus 1, 2, 3 or 5. The top module adds 1 to u_a.count only, and then reads
// every instance by its hierarchical name (§23.6) at time 1; the checker
// gives its count through its output. The program prints its own names at
// time 2, and its end ends the simulation (§24.3).
// Icarus Verilog 13.0 does not support checkers (syntax error at the
// checker declaration).

`timescale 1ns/1ns

module ln_mod_a;
  int count = 10;

  function automatic int get();
    return count + 1;
  endfunction
endmodule

module ln_mod_b;
  int count = 20;

  function automatic int get();
    return count + 2;
  endfunction
endmodule

interface ln_if;
  int count = 30;

  function automatic int get();
    return count + 3;
  endfunction
endinterface

checker ln_chk(output int seen);
  int count = 40;

  assign seen = count;
endchecker

program ln_prog;
  int count = 50;

  function automatic int get();
    return count + 5;
  endfunction

  initial #2 $display("program: count=%0d get()=%0d", count, get());
endprogram

module test_same_names_in_module_interface_program_checker_scopes;
  int count = 60;
  int chk_seen;

  ln_mod_a u_a();
  ln_mod_b u_b();
  ln_if u_if();
  ln_chk u_chk(chk_seen);
  ln_prog u_prog();

  initial begin
    u_a.count++;
    #1;
    $display("top: count=%0d", count);
    $display("u_a: count=%0d get()=%0d", u_a.count, u_a.get());
    $display("u_b: count=%0d get()=%0d", u_b.count, u_b.get());
    $display("u_if: count=%0d get()=%0d", u_if.count, u_if.get());
    $display("u_chk: count=%0d", chk_seen);
  end
endmodule
