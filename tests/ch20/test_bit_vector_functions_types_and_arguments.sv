/*
:name: test_bit_vector_functions_types_and_arguments
:description: $countones returns a signed 32-bit int and $onehot, $onehot0 and $isunknown a 2-state bit, all of them take an argument of any bit-stream type such as an unpacked array or structure, and their results can be used wherever an int or a bit can (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 11.4.14 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bit_vector_functions_types_and_arguments.expected
*/
// IEEE 1800-2023 §20.9: $countones returns int; $onehot, $onehot0 and
// $isunknown return bit; they may be used in any context where a value of
// their return type is legal. Their argument follows the rules of the
// argument of $countbits: it is of a bit-stream type (§6.24.3) and is
// treated as the vector {>>{e}} (§11.4.14), so an unpacked array or
// structure is counted over the bits of all of its elements.
// Line 1 shows the result types: $countones is 32 bits and signed (2 - 3 is
// below 0), and $onehot is 1 bit and, being a bit, never unknown, even for
// an all-x argument. Lines 2 to 5 print $countones, $onehot, $onehot0,
// $isunknown and a $countbits of an unpacked array of two bytes with one 1
// bit, an unpacked array of 2-bit logic with one 1 and one x bit, an
// unpacked structure of a byte and a 4-bit logic with three 1 bits and one
// z bit, and a queue of three bytes with two 1 bits. Line 6 uses results as
// an array index, a case expression and in a continuous assignment.
// Neither simulator follows the clause here: Icarus Verilog 13.0 rejects
// unpacked arguments and gives 1 for $isunknown of $onehot of an x vector,
// and release 5.052 of the Verilator tool rejects unpacked arguments.

module test_bit_vector_functions_types_and_arguments;
  typedef struct {
    byte b;
    logic [3:0] n;
  } st_t;
  byte ba [2];
  logic [1:0] la [2];
  st_t st;
  byte dq [$];
  int tbl [2];
  logic [3:0] bus = 4'b10z0;
  wire bus_unknown = $isunknown(bus);
  logic [3:0] all_x = 4'bxxxx;
  string sel;

  initial begin
    ba = '{8'h01, 8'h00};
    la[0] = 2'b0x;
    la[1] = 2'b10;
    st.b = 8'h03;
    st.n = 4'bz100;
    dq = '{8'h00, 8'h10, 8'h01};
    tbl = '{10, 20};
    $display("types: %0d %0d %0d %0d %b", $bits($countones(all_x)), $countones(4'b0011) - 3 < 0,
             $bits($onehot(all_x)), $isunknown($onehot(all_x)), $onehot(all_x));
    $display("ba: %0d %b %b %b %0d", $countones(ba), $onehot(ba), $onehot0(ba), $isunknown(ba),
             $countbits(ba, 'x, 'z));
    $display("la: %0d %b %b %b %0d", $countones(la), $onehot(la), $onehot0(la), $isunknown(la),
             $countbits(la, 'x));
    $display("st: %0d %b %b %b %0d", $countones(st), $onehot(st), $onehot0(st), $isunknown(st),
             $countbits(st, 'z));
    $display("dq: %0d %b %b %b %0d", $countones(dq), $onehot(dq), $onehot0(dq), $isunknown(dq),
             $countbits(dq, '0));
    case ($onehot0(4'b0011))
      1'b0: sel = "not onehot0";
      1'b1: sel = "onehot0";
    endcase
    #1 $display("uses: %0d %s %b", tbl[$onehot(4'b0010)], sel, bus_unknown);
  end
endmodule
