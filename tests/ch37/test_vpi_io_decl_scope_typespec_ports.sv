/*
:name: test_vpi_io_decl_scope_typespec_ports
:description: The io declarations of an instance, a task, a function and a UDP lead back to their owner, an io declaration gives its instance, its range iteration, its typespec and the same bounds as that typespec, vpiScalar, vpiSigned and vpiVector describe the formal, a virtual interface task argument has a virtual interface variable as expression, and a port gives vpiPortType from its formal (IEEE 1800-2023 Sections 37.13, 37.14)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.13 37.14 37.36 23.2.2.3 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_io_decl_scope_typespec_ports.c
:expected_stdout: @test_vpi_io_decl_scope_typespec_ports.expected
*/
// IEEE 1800-2023 §37.13: vpi_iterate(vpiIODecl) over an instance gives its io
// declarations, and each leads back to the instance with vpiInstance. The
// same relation over a task or function and over a UDP definition gives their
// io declarations, and each leads back with vpiTaskFunc or the untagged UDP
// definition relation (details 1 to 3 of the diagram). The vpiRange iteration
// of an io declaration returns the ranges of its typespec (detail 4), and
// vpiLeftRange and vpiRightRange give the leftmost bounds of that typespec;
// vpiScalar, vpiSigned and vpiVector describe the formal. A ref, interface or
// modport io declaration has a ref obj as vpiExpr; a virtual interface io
// declaration has a vpiVirtualInterfaceVar (detail 2), and its direction is
// undefined (detail 3), so it is not printed. A virtual interface cannot be a
// port (25.9), so the virtual interface formal is the argument tv of the task
// t, which 25.9 allows. §37.14: vpiPortType is vpiPort, vpiInterfacePort or
// vpiModportPort according to the formal (detail 1). The interface port b has
// no modport and is connected with the modport bi.dev (25.5), so a port type
// taken from the actual would make b a modport port.
// The io declarations are sorted by name; vpi_get_str() returns each string
// in the same buffer (§38.11), so the names are copied before the sort.

interface tids_bus;
  logic req, gnt;
  modport dev (input req, output gnt);
endinterface

primitive tids_udp (o, a, b);
  output o;
  input a, b;
  table
    0 0 : 0;
    0 1 : 1;
    1 0 : 1;
    1 1 : 0;
  endtable
endprimitive

module tids_m (
  input logic signed [7:0] din,
  output logic [3:0] dout,
  tids_bus b,
  tids_bus.dev d,
  input logic scalar,
  output logic [7:0] vec,
  ref logic [2:0] rp
);
  task automatic t (input int ti, output int to, ref int tr, input virtual tids_bus tv);
    to = ti;
  endtask

  function int f (input byte fi);
    return fi;
  endfunction
endmodule

module test_vpi_io_decl_scope_typespec_ports;
  logic [7:0] nib = 8'h5a;
  logic [3:0] out;
  logic [7:0] vout;
  logic [2:0] rv;
  logic sc;
  logic uo, ua, ub;
  tids_bus bi ();
  tids_m u (.din(nib), .dout(out), .b(bi.dev), .d(bi.dev),
            .scalar(sc), .vec(vout), .rp(rv));
  tids_udp up (uo, ua, ub);

  initial #1 $vt_io;
endmodule
