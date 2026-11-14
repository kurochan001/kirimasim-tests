/*
:name: test_specify_polarity_operators_full_parallel
:description: The polarity operators + and - can be put before both => and *>, and a negative or positive polarity does not make a buffer or an inverter change differently: each output change takes the delay of its own transition (IEEE 1800-2023 Sections 30.4.7.2 and 30.4.7.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.7.2 30.4.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_polarity_operators_full_parallel.expected
*/
// IEEE 1800-2023 §30.4.7.2: a path has positive polarity when + is put
// before => or *>. §30.4.7.3: it has negative polarity when - is put before
// => or *>; negative polarity says that a rise at the source may cause a fall
// or no transition at the destination, and a fall a rise or none. §30.4.7:
// polarity only describes the path and does not change how data propagates;
// that depends on the logic of the module.
//
// Six cells with one path each, all with the rise delay 20 and the fall
// delay 50 (30.5.1):
//   bp: buffer,   (a +=> y)       bf: buffer,   (a +*> y)
//   bn: buffer,   (a -=> y)       bm: buffer,   (a -*> y)
//   ip: inverter, (a +*> y)       im: inverter, (a -*> y)
// a rises at 100: every buffer output rises at 120, also with negative
// polarity, and every inverter output falls at 150, also with positive
// polarity. a falls at 200: the inverter outputs rise at 220 and the buffer
// outputs fall at 250.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs. The 5.054
// release of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_polarity_operators_full_parallel_bp (input a, output y);
  buf g (y, a);
  specify
    (a +=> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel_bf (input a, output y);
  buf g (y, a);
  specify
    (a +*> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel_bn (input a, output y);
  buf g (y, a);
  specify
    (a -=> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel_bm (input a, output y);
  buf g (y, a);
  specify
    (a -*> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel_ip (input a, output y);
  not g (y, a);
  specify
    (a +*> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel_im (input a, output y);
  not g (y, a);
  specify
    (a -*> y) = (20, 50);
  endspecify
endmodule

module test_specify_polarity_operators_full_parallel;
  reg a = 0;
  wire bp, bf, bn, bm, ip, im;
  logic [5:0] prev;

  test_specify_polarity_operators_full_parallel_bp ubp (a, bp);
  test_specify_polarity_operators_full_parallel_bf ubf (a, bf);
  test_specify_polarity_operators_full_parallel_bn ubn (a, bn);
  test_specify_polarity_operators_full_parallel_bm ubm (a, bm);
  test_specify_polarity_operators_full_parallel_ip uip (a, ip);
  test_specify_polarity_operators_full_parallel_im uim (a, im);

  initial begin
    #100 a = 1;
    #100 a = 0;
  end

  initial begin
    #95 prev = {bp, bf, bn, bm, ip, im};
    repeat (20) begin
      #10 if ({bp, bf, bn, bm, ip, im} != prev)
        $display("%0d: bp=%b bf=%b bn=%b bm=%b ip=%b im=%b", $time - 5, bp, bf, bn, bm, ip, im);
      prev = {bp, bf, bn, bm, ip, im};
    end
    $finish;
  end
endmodule
