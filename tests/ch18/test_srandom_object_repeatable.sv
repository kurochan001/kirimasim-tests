/*
:name: test_srandom_object_repeatable
:description: An object seeded with srandom gives the same randomize results as another object of its class seeded with the same value, and seeding it again repeats them (IEEE 1800-2023 Section 18.15)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.15 18.13.3 18.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_srandom_object_repeatable.expected
*/
// IEEE 1800-2023 §18.15, §18.14.1: each object has its own random number
// generator, used only by its randomize(). Packet seeds it with srandom()
// (18.13.3) in new, so p1 and p2, both created with seed 200, give the same
// three results. Seeding p1 again with 300 before each of two runs gives the
// same three results both times. The values depend on the implementation, so
// the test compares them.

class Packet;
  rand bit [15:0] header;
  rand bit [7:0] len;
  constraint short_c { len < 64; }

  function new(int seed);
    this.srandom(seed);
  endfunction

  function bit [23:0] value();
    return {header, len};
  endfunction
endclass

module test_srandom_object_repeatable;
  Packet p1 = new(200), p2 = new(200);

  function automatic void run(Packet p, output bit [23:0] got[3]);
    for (int i = 0; i < 3; i++) begin
      void'(p.randomize());
      got[i] = p.value();
    end
  endfunction

  initial begin
    bit [23:0] a[3], b[3], c[3], d[3];
    run(p1, a);
    run(p2, b);
    $display("p1 and p2 seeded with 200 agree: %0d", a == b);
    p1.srandom(300);
    run(p1, c);
    p1.srandom(300);
    run(p1, d);
    $display("p1 seeded again with 300 repeats: %0d", c == d);
  end
endmodule
