/*
:name: test_rand_constraints_hold
:description: randomize() succeeds and every result satisfies all the constraint blocks of the class (IEEE 1800-2023 Section 18.6.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.1 18.3 18.4.1 18.5 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_constraints_hold.expected
*/
// IEEE 1800-2023 §18.6.1: randomize() gives new values to the rand variables
// (18.4.1) of an object so that all its active constraints (18.5) hold, and
// returns 1 when it succeeds. The values themselves are random, so the test
// prints only whether every result satisfied set membership (11.4.13),
// relations between variables and bit conditions.

class rch_packet;
  rand bit [7:0] len;
  rand bit [7:0] kind;
  rand bit [15:0] addr;
  constraint c_len  { len inside {[4:16]}; }
  constraint c_kind { kind inside {1, 2, 7}; }
  constraint c_addr { addr > len; addr[1:0] == 2'b00; }
endclass

module test_rand_constraints_hold;
  rch_packet p;
  int succeeded = 0;
  int violations = 0;

  initial begin
    p = new;
    repeat (200) begin
      if (p.randomize()) succeeded++;
      if (!(p.len inside {[4:16]})) violations++;
      if (!(p.kind inside {1, 2, 7})) violations++;
      if (p.addr <= p.len || p.addr[1:0] != 2'b00) violations++;
    end
    $display("randomize succeeded %0d of 200 times, violations=%0d", succeeded, violations);
  end
endmodule
