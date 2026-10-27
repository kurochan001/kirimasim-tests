/*
:name: test_pla_all_forms
:description: All sixteen PLA tasks use the array_type, logic and format components of the signature, every timing and format form supports and, or, nand and nor, both timing forms update without delay, and ? is the same don't care as z (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16 20.16.1 20.16.2 20.16.3 20.16.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pla_all_forms.expected
*/
// IEEE 1800-2023 20.16: the PLA system task is
// $array_type$logic$format(memory, input_terms, output_terms), where array_type
// is sync or async, logic is and, or, nand or nor, and format is array or
// plane. The test calls all sixteen names, with a memory as deep as the output
// term and as wide as the input term (20.16.3). 20.16.4: in the array format a
// 1 selects the input and a 0 leaves it out; in the plane format a 1 takes the
// input, a 0 its complement, and z and ? nothing. 20.16.2: each form has the
// four logic types, and the nand and nor rows are the negations of the and and
// or rows. 20.16.1: a synchronous call evaluates when executed and an
// asynchronous one whenever an input or the personality changes; both update
// without delay.
//
// Array personality mem[1]=110, mem[2]=011, mem[3]=101 gives
// out1=v1&v2, out2=v2&v3 and out3=v1&v3 for the and form. Plane personality
// pmem[1]=10?, pmem[2]=??1, pmem[3]=0?0 gives out1=v1&~v2, out2=v3 and
// out3=~v1&~v3. The z row qmem[1]=z11 and the ? row qmem[2]=?11 must give
// the same value v2&v3.

`timescale 1ns/1ns

module test_pla_all_forms;
  logic [1:3] mem [1:3];
  logic [1:3] pmem [1:3];
  logic [1:3] qmem [1:2];
  logic [1:3] v;
  logic [1:3] sa, so, sn, sr;
  logic [1:3] spa, spo, spn, spr;
  logic [1:3] aa, ao, an, ar;
  logic [1:3] apa, apo, apn, apr;
  logic [1:2] qout;

  task automatic sync_all;
    $sync$and$array(mem, v, sa);
    $sync$or$array(mem, v, so);
    $sync$nand$array(mem, v, sn);
    $sync$nor$array(mem, v, sr);
    $sync$and$plane(pmem, v, spa);
    $sync$or$plane(pmem, v, spo);
    $sync$nand$plane(pmem, v, spn);
    $sync$nor$plane(pmem, v, spr);
  endtask

  task automatic async_all;
    $async$and$array(mem, v, aa);
    $async$or$array(mem, v, ao);
    $async$nand$array(mem, v, an);
    $async$nor$array(mem, v, ar);
    $async$and$plane(pmem, v, apa);
    $async$or$plane(pmem, v, apo);
    $async$nand$plane(pmem, v, apn);
    $async$nor$plane(pmem, v, apr);
  endtask

  initial begin
    mem[1] = 3'b110;
    mem[2] = 3'b011;
    mem[3] = 3'b101;
    pmem[1] = 3'b10?;
    pmem[2] = 3'b??1;
    pmem[3] = 3'b0?0;
    qmem[1] = 3'bz11;
    qmem[2] = 3'b?11;

    v = 3'b111;
    sync_all;
    async_all;
    $async$and$plane(qmem, v, qout);
    #1;
    $display("v=%b sync array and=%b or=%b nand=%b nor=%b", v, sa, so, sn, sr);
    $display("v=%b sync plane and=%b or=%b nand=%b nor=%b", v, spa, spo, spn, spr);
    $display("v=%b async array and=%b or=%b nand=%b nor=%b", v, aa, ao, an, ar);
    $display("v=%b async plane and=%b or=%b nand=%b nor=%b", v, apa, apo, apn, apr);

    v = 3'b100;
    $display("v=%b sync unchanged array=%b plane=%b", v, sa, spa);
    #1;
    $display("v=%b async array and=%b or=%b nand=%b nor=%b", v, aa, ao, an, ar);
    $display("v=%b async plane and=%b or=%b nand=%b nor=%b", v, apa, apo, apn, apr);
    sync_all;
    $display("v=%b sync array and=%b or=%b nand=%b nor=%b", v, sa, so, sn, sr);
    $display("v=%b sync plane and=%b or=%b nand=%b nor=%b", v, spa, spo, spn, spr);

    v = 3'b011;
    #1;
    $display("v=%b async array and=%b or=%b nand=%b nor=%b", v, aa, ao, an, ar);
    $display("v=%b async plane and=%b or=%b nand=%b nor=%b", v, apa, apo, apn, apr);
    sync_all;
    $display("v=%b sync array and=%b or=%b nand=%b nor=%b", v, sa, so, sn, sr);
    $display("v=%b sync plane and=%b or=%b nand=%b nor=%b", v, spa, spo, spn, spr);

    v = 3'b101;
    #1;
    $display("v=%b async array and=%b or=%b nand=%b nor=%b", v, aa, ao, an, ar);
    $display("v=%b async plane and=%b or=%b nand=%b nor=%b", v, apa, apo, apn, apr);
    sync_all;
    $display("v=%b sync array and=%b or=%b nand=%b nor=%b", v, sa, so, sn, sr);
    $display("v=%b sync plane and=%b or=%b nand=%b nor=%b", v, spa, spo, spn, spr);

    pmem[1] = 3'b1z0;
    #1;
    $display("v=%b new personality async plane and=%b or=%b nand=%b nor=%b",
             v, apa, apo, apn, apr);
    sync_all;
    $display("v=%b new personality sync plane and=%b or=%b nand=%b nor=%b",
             v, spa, spo, spn, spr);

    v = 3'b111;
    #1 $display("q v=%b z/?=%b", v, qout);
    v = 3'b011;
    #1 $display("q v=%b z/?=%b", v, qout);
    v = 3'b101;
    #1 $display("q v=%b z/?=%b", v, qout);
    v = 3'bxxx;
    #1 $display("q v=%b z/?=%b", v, qout);
    $finish;
  end
endmodule
