/*
:name: test_ansi_explicit_named_ports
:description: Explicitly named ANSI ports of modules, interfaces and programs connect an array element, a structure member, a concatenation of elements and a typed assignment pattern of elements, take the self-determined type of their expression and only the direction of the port before them, and the port after one gets its kind and type by the rules of a first port (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.2 23.2.2.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ansi_explicit_named_ports.expected
*/
// IEEE 1800-2023 §23.2.2.2: an ANSI port of a module, interface or program
// can be explicitly named, with an expression of objects declared in it: an
// element of an array, a member of a structure, a concatenation of elements
// or an assignment pattern of elements. The type of such a port is the
// self-determined type of its expression. §23.2.2.3: an explicitly named
// port inherits only an omitted direction from the port before it, not its
// kind or data type, and the port right after an explicitly named port
// inherits only its direction; its kind and data type follow the rules of a
// first port.
//   .pi({h, l}) follows input var logic [1:0] a0: an input of 8 bits (two
//      4-bit elements), so 8'hA5 from outside gives h = a, l = 5; with the
//      2 bits of a0 only 2'b01 would arrive;
//   .ps(st.f) is an input of the 6 bits of the member f: 6'h2a arrives
//      (with 2 bits only 6'h02);
//   pz follows .ps: an input net of the default type logic, 1 bit, not
//      the 2 bits of a0 or the 6 bits of .ps;
//   .po(arr[1]) follows output var logic [1:0] b0: an output of the 8
//      bits of arr[1] = 8'hc7, where 2 bits would give 8'h03 outside;
//   .pp(nib_t'{arr[0][3:0], arr[2][3:0]}) is an output of the packed
//      structure type nib_t, 8 bits, {2, 4} = 8'h24;
//   pq follows .pp: an output net of logic, 1 bit, which nothing drives,
//      so the net outside is z (an output variable would be x);
//   the interface ifc has the input .ip(iv[2]), the element of an array,
//      which receives 4'h9; the program prg has the output .op(pv[0]),
//      which drives the 4'h6 of the element outside.
// The initial procedure of prg waits #2 after setting pv[0]: when all
// program initial procedures have ended the simulation ends with an implicit
// $finish (24.3), which at time 0 would come before the report at 1.
// Icarus Verilog 13.0 and Verilator 5.052 do not support explicitly named
// ANSI ports, so this expected output follows the standard alone.

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} ansi_explicit_named_ports_nib_t;

typedef struct {
  logic [5:0] f;
  logic g;
} ansi_explicit_named_ports_st_t;

module ansi_explicit_named_ports_m(input var logic [1:0] a0, .pi({h, l}), .ps(st.f), pz,
                                   output var logic [1:0] b0, .po(arr[1]),
                                   .pp(ansi_explicit_named_ports_nib_t'{arr[0][3:0],
                                                                        arr[2][3:0]}),
                                   pq);
  logic [3:0] h, l;
  ansi_explicit_named_ports_st_t st;
  logic [7:0] arr [0:2];

  initial begin
    arr[0] = 8'h12;
    arr[1] = 8'hc7;
    arr[2] = 8'h34;
    b0 = 2'b00;
  end
endmodule

interface ansi_explicit_named_ports_if(input .ip(iv[2]));
  logic [3:0] iv [0:3];
endinterface

program ansi_explicit_named_ports_p(output .op(pv[0]));
  logic [3:0] pv [0:1];
  initial begin
    pv[0] = 4'h6;
    #2;
  end
endprogram

module test_ansi_explicit_named_ports;
  logic [1:0] a0 = 2'b00;
  logic [7:0] vi = 8'ha5;
  logic [5:0] vs = 6'h2a;
  wire z, q;
  wire [1:0] b0;
  wire [7:0] po, pp;
  logic [3:0] vif = 4'h9;
  wire [3:0] op;

  ansi_explicit_named_ports_m u(.a0(a0), .pi(vi), .ps(vs), .pz(z), .b0(b0), .po(po), .pp(pp),
                                .pq(q));
  ansi_explicit_named_ports_if ifc(.ip(vif));
  ansi_explicit_named_ports_p prg(.op(op));

  initial begin
    #1;
    $display("pi: h=%h l=%h", u.h, u.l);
    $display("ps: st.f=%h", u.st.f);
    $display("pz: %0d bit", $bits(u.pz));
    $display("po: %h", po);
    $display("pp: %h", pp);
    $display("pq: %0d bit, outside %b", $bits(u.pq), q);
    $display("ifc.ip: iv[2]=%h", ifc.iv[2]);
    $display("prg.op: %h", op);
  end
endmodule
