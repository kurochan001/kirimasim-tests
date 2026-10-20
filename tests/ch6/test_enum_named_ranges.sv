/*
:name: test_enum_named_ranges
:description: In an enumeration, name[N] generates N names numbered from 0 and name[N:M] the names numbered from N to M, counting up or down, each taking consecutive values, starting from an assigned constant if there is one (IEEE 1800-2023 Section 6.19.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.2 6.19.1 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_named_ranges.expected
*/
// IEEE 1800-2023 §6.19.2: rd[3] generates rd0, rd1 and rd2; wr[2:3] = 10
// generates wr2 and wr3 with the values 10 and 11; nop[4:2] counts down,
// generating nop4, nop3 and nop2. Each name takes the next value after the
// previous one unless a constant is given. §6.19.1: typedef names the type.
// The members are listed in order with the methods of 6.19.5.

module test_enum_named_ranges;
  typedef enum {idle, rd[3], wr[2:3] = 10, nop[4:2]} op_t;

  op_t op;

  initial begin
    op = op.first();
    forever begin
      $display("%s=%0d", op.name(), op);
      if (op == op.last()) break;
      op = op.next();
    end
  end
endmodule
