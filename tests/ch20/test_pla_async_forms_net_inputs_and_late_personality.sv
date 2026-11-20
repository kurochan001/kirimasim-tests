/*
:name: test_pla_async_forms_net_inputs_and_late_personality
:description: $async$nand$array, $async$nor$array, $async$or$array, $async$and$plane, $async$nand$plane and $async$nor$plane, called once before their personality is loaded, follow every later change of their net input terms and of a personality word (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16 20.16.1 20.16.2 20.16.3 20.16.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pla_async_forms_net_inputs_and_late_personality.expected
*/
// IEEE 1800-2023 §20.16: a PLA task takes a memory, input terms that may be
// nets or variables, and output terms that are variables. §20.16.1: an
// asynchronous task evaluates again whenever an input term or a word of the
// memory changes, and updates its outputs without delay. §20.16.2: and, or,
// nand and nor are available in both formats; nand and nor are the
// complements of and and or. §20.16.3: the memory is as wide as the input
// terms and as deep as the output terms, word k gives output term k, and a
// changed word is used at the next evaluation. §20.16.4: in the array
// format a 1 takes the input and a 0 leaves it out; in the plane format a 1
// takes the input, a 0 its complement, and z or ? nothing.
// The six tasks are called once at time 0, while the input nets and the
// memories are still unknown; the words are written after the calls. The
// inputs are the nets w1 to w4, driven by a continuous assignment from drv.
// The array words 1100, 0110 and 1011 select (a1 a2), (a2 a3) and (a1 a3
// a4); the plane words 1?0?, z01z and 0??1 give a1&~a3, ~a2&a3 and ~a1&a4
// for and, and a1|~a3, ~a2|a3 and ~a1|a4 for or. Each line is printed one
// time unit after the change it shows. At the fourth line only the words
// amem[2] = 0100 and pmem[1] = 1011 change, with the inputs held at 1011;
// nor_array, or_array, and_plane and nand_plane change there. The last two
// lines use the new words with new inputs.
// No release of Icarus Verilog 13.0 or Verilator 5.054 implements the PLA
// tasks, so the expected output follows the clauses alone.

module test_pla_async_forms_net_inputs_and_late_personality;
  logic [1:4] amem [1:3];
  logic [1:4] pmem [1:3];
  logic [1:4] drv;
  wire w1, w2, w3, w4;
  logic na1, na2, na3;
  logic [1:3] nra, ora, ap, nap, nrp;

  assign {w1, w2, w3, w4} = drv;

  task automatic show(string what);
    $display("%s in=%b nand_array=%b nor_array=%b or_array=%b", what, drv, {na1, na2, na3},
             nra, ora, " and_plane=%b nand_plane=%b nor_plane=%b", ap, nap, nrp);
  endtask

  initial begin
    $async$nand$array(amem, {w1, w2, w3, w4}, {na1, na2, na3});
    $async$nor$array(amem, {w1, w2, w3, w4}, nra);
    $async$or$array(amem, {w1, w2, w3, w4}, ora);
    $async$and$plane(pmem, {w1, w2, w3, w4}, ap);
    $async$nand$plane(pmem, {w1, w2, w3, w4}, nap);
    $async$nor$plane(pmem, {w1, w2, w3, w4}, nrp);
    amem[1] = 4'b1100;
    amem[2] = 4'b0110;
    amem[3] = 4'b1011;
    pmem[1] = 4'b1?0?;
    pmem[2] = 4'bz01z;
    pmem[3] = 4'b0??1;
    drv = 4'b0010;
    #1 show("inputs");
    drv = 4'b1100;
    #1 show("inputs");
    drv = 4'b1011;
    #1 show("inputs");
    amem[2] = 4'b0100;
    pmem[1] = 4'b1011;
    #1 show("words");
    drv = 4'b0110;
    #1 show("inputs");
    drv = 4'b0001;
    #1 show("inputs");
  end
endmodule
