/*
:name: test_program_instances_connected_separately
:description: Two instances of one program get their own parameter values and port connections and keep their own copy of a program variable (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.4 24.3 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_instances_connected_separately.expected
*/
// IEEE 1800-2023 §3.4: each program instance can be instantiated and
// connected on its own. §24.3: program ports are connected like the ports of
// a module, and the data of a program is static, one copy per instance.
// p1 and p2 are two instances of sep_prog with other parameter values and
// other variables on their ports. Each adds its STEP to its own calls and
// drives base + calls on its output port: p1 gets 10 + 1 = 11 and p2 gets
// 20 + 5 = 25. If the instances shared calls, p2 would see 1 + 5 = 6; if they
// shared ports, both outputs would be equal. The module reads the outputs
// through its own variables at time 3, and each instance prints its name,
// base, calls and result at its own time after that.

`timescale 1ns/1ns

program sep_prog #(parameter int STEP = 1, parameter int WHEN = 1)
                  (input int base, output int result);
  int calls = 0;

  initial begin
    #WHEN;
    calls += STEP;
    result = base + calls;
    #3 $display("t=%0t %m: base=%0d calls=%0d result=%0d", $time, base, calls, result);
  end
endprogram

module test_program_instances_connected_separately;
  int base1 = 10, base2 = 20;
  int r1, r2;

  sep_prog #(.STEP(1), .WHEN(1)) p1(.base(base1), .result(r1));
  sep_prog #(.STEP(5), .WHEN(2)) p2(.base(base2), .result(r2));

  initial #3 $display("t=%0t module: r1=%0d r2=%0d", $time, r1, r2);
endmodule
