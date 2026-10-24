/*
:name: test_sdf_device_port_instance
:description: A DEVICE entry that names a module instance annotates all module paths to its outputs, or the primitives driving them when it has no paths, and one that names an output of the cell annotates only the paths to that output, or the primitives driving it (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.8 28.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_device_port_instance.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: (DEVICE port_instance ...) annotates,
// when port_instance is a module instance, all specify paths to the outputs
// of that module, or all primitives driving its outputs when it has no
// specify paths; when port_instance is an output of the module instance, it
// annotates the specify paths to that output only, or the primitives driving
// it when there are none. §32.8 and §28.16: one SDF value is the delay of
// every transition of a path or a primitive.
//
// The cell dv_paths has two buffers from a to y and z with the paths a => y
// and a => z of delay 1; dv_gates has the same buffers and no specify block,
// so its outputs follow a without delay. The wrapper w has the instances p
// and q of dv_paths and g and r of dv_gates. The SDF file annotates
// (DEVICE y (5)) in the cells w.p and w.g, and (DEVICE q (4)) and
// (DEVICE r (3)) in the cell w. So p.y and g.y get 5 while p.z keeps 1 and
// g.z 0, and both outputs of q get 4 and both outputs of r get 3. The input
// rises at 10, and the delay with which each output follows it is printed.
// The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 does not read DEVICE entries.

`timescale 1ns/1ns

module dv_paths (input a, output y, z);
  buf (y, a);
  buf (z, a);
  specify
    (a => y) = 1;
    (a => z) = 1;
  endspecify
endmodule

module dv_gates (input a, output y, z);
  buf (y, a);
  buf (z, a);
endmodule

module dv_wrap (input a, output py, pz, gy, gz, qy, qz, ry, rz);
  dv_paths p (a, py, pz);
  dv_gates g (a, gy, gz);
  dv_paths q (a, qy, qz);
  dv_gates r (a, ry, rz);
endmodule

module test_sdf_device_port_instance;
  reg a = 0;
  wire py, pz, gy, gz, qy, qz, ry, rz;
  integer f;
  integer t[8];

  dv_wrap w (a, py, pz, gy, gz, qy, qz, ry, rz);

  always @(posedge py) t[0] = $time;
  always @(posedge pz) t[1] = $time;
  always @(posedge gy) t[2] = $time;
  always @(posedge gz) t[3] = $time;
  always @(posedge qy) t[4] = $time;
  always @(posedge qz) t[5] = $time;
  always @(posedge ry) t[6] = $time;
  always @(posedge rz) t[7] = $time;

  initial begin
    f = $fopen("test_sdf_device_port_instance.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"dv_paths\") (INSTANCE w.p)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE y (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dv_gates\") (INSTANCE w.g)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE y (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dv_wrap\") (INSTANCE w)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE q (4)) (DEVICE r (3))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_device_port_instance.sdf");
    #10 a = 1;
    #20 $display("rise after 10: p.y %0d p.z %0d g.y %0d g.z %0d q.y %0d q.z %0d r.y %0d r.z %0d",
                 t[0] - 10, t[1] - 10, t[2] - 10, t[3] - 10, t[4] - 10, t[5] - 10,
                 t[6] - 10, t[7] - 10);
  end
endmodule
