/*
:name: test_pla_sync_array_and_plane
:description: the four synchronous and, or, nand and nor array tasks and the four synchronous plane tasks take a personality memory, an input term and an output term, evaluate when the task is executed, update the outputs without delay, and read the plane bit 0 as the complement, 1 as the input and ? as a don't care (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16 20.16.1 20.16.2 20.16.3 20.16.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pla_sync_array_and_plane.expected
*/
// IEEE 1800-2023 §20.16: the PLA tasks have the form
// $array_type$logic$format(memory, input_terms, output_terms), where the
// memory is as deep as the output terms and as wide as the input terms
// (20.16.3). §20.16.4: in the array format a 1 of a personality word selects
// the input and a 0 leaves it out, and in the plane format a 1 takes the
// input, a 0 takes its complement and ? is a don't care like z; the words
// stand in ascending order. §20.16.1: a synchronous call evaluates at the time
// it is executed and updates the outputs without delay, so the outputs keep
// the values of the previous call until the next one. §20.16.2: the logic is
// and, or, nand or nor, so the nand and nor forms negate the and and or of the
// selected literals. The test calls all eight synchronous tasks with the same
// personality and prints the outputs after each call and, for one value of the
// input, after only changing the input, which must leave them unchanged.
//
// For the array personality mem[1]=110, mem[2]=011, mem[3]=101, the outputs
// are out1=v1&v2, out2=v2&v3 and out3=v1&v3 in the and form. For the plane
// personality pmem[1]=10?, pmem[2]=??1, pmem[3]=0?0, they are
// out1=v1&~v2, out2=v3 and out3=~v1&~v3. The nand and nor forms negate those.

module test_pla_sync_array_and_plane;
  logic [1:3] mem [1:3];
  logic [1:3] pmem [1:3];
  logic [1:3] v;
  logic [1:3] a_and, a_or, a_nand, a_nor;
  logic [1:3] p_and, p_or, p_nand, p_nor;

  task automatic evaluate;
    $sync$and$array(mem, v, a_and);
    $sync$or$array(mem, v, a_or);
    $sync$nand$array(mem, v, a_nand);
    $sync$nor$array(mem, v, a_nor);
    $sync$and$plane(pmem, v, p_and);
    $sync$or$plane(pmem, v, p_or);
    $sync$nand$plane(pmem, v, p_nand);
    $sync$nor$plane(pmem, v, p_nor);
  endtask

  initial begin
    mem[1] = 3'b110;
    mem[2] = 3'b011;
    mem[3] = 3'b101;
    pmem[1] = 3'b10?;
    pmem[2] = 3'b??1;
    pmem[3] = 3'b0?0;

    v = 3'b111;
    evaluate;
    $display("v=%b array and=%b or=%b nand=%b nor=%b", v, a_and, a_or, a_nand, a_nor);
    $display("v=%b plane and=%b or=%b nand=%b nor=%b", v, p_and, p_or, p_nand, p_nor);

    v = 3'b100;
    // No task has run yet, so the outputs keep the values of the last call.
    $display("v=%b unchanged array=%b plane=%b", v, a_and, p_and);
    evaluate;
    $display("v=%b array and=%b or=%b nand=%b nor=%b", v, a_and, a_or, a_nand, a_nor);
    $display("v=%b plane and=%b or=%b nand=%b nor=%b", v, p_and, p_or, p_nand, p_nor);

    v = 3'b011;
    evaluate;
    $display("v=%b array and=%b or=%b nand=%b nor=%b", v, a_and, a_or, a_nand, a_nor);
    $display("v=%b plane and=%b or=%b nand=%b nor=%b", v, p_and, p_or, p_nand, p_nor);

    v = 3'b101;
    evaluate;
    $display("v=%b array and=%b or=%b nand=%b nor=%b", v, a_and, a_or, a_nand, a_nor);
    $display("v=%b plane and=%b or=%b nand=%b nor=%b", v, p_and, p_or, p_nand, p_nor);
  end
endmodule
