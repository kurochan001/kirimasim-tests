/*
:name: test_object_stability_seeding
:description: The randomize() results of an object do not depend on calls of other objects' randomize(), of $urandom, $random or std::randomize() in between, and two objects created right after the creating thread is given the same seed get the same results (IEEE 1800-2023 Section 18.14.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14.3 18.15 18.13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_object_stability_seeding.expected
*/
// IEEE 1800-2023 §18.14.3, §18.15: each object has its own random number
// generator, used only by its randomize(), so its results do not depend on
// calls of randomize() of other objects or of other random functions. o1,
// seeded with srandom(11) (18.13.3), gives four results; seeded again, it
// gives the same four with o2.randomize(), $urandom, $random and
// std::randomize() called between its calls.
// The generator of a new object is seeded with the next value of the
// generator of the thread that creates it. The thread is seeded with 21 just
// before o3 is created and again just before o4, so o3 and o4 give the same
// results, also when their calls alternate. The values themselves depend on
// the tool and are only compared.

class osd_obj;
  rand bit [31:0] v;
endclass

module test_object_stability_seeding;
  osd_obj o1, o2, o3, o4;
  bit [31:0] s1[4], s2[4], s3[4], s4[4];
  int unsigned u;
  int r;
  int z;

  initial begin
    o1 = new;
    o2 = new;
    o1.srandom(11);
    foreach (s1[i]) begin
      void'(o1.randomize());
      s1[i] = o1.v;
    end
    o1.srandom(11);
    foreach (s2[i]) begin
      void'(o2.randomize());
      u = $urandom;
      r = $random;
      void'(std::randomize(z));
      void'(o1.randomize());
      s2[i] = o1.v;
    end
    $display("o1 repeats its results with other generators used in between: %0d", s1 == s2);

    process::self().srandom(21);
    o3 = new;
    process::self().srandom(21);
    o4 = new;
    foreach (s3[i]) begin
      void'(o3.randomize());
      s3[i] = o3.v;
      void'(o4.randomize());
      s4[i] = o4.v;
    end
    $display("o3 and o4, created after the same thread seed, agree: %0d", s3 == s4);
  end
endmodule
