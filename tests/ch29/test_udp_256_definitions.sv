/*
:name: test_udp_256_definitions
:description: a design with 256 UDP definitions, each instantiated once, compiles and every UDP gives its own output, as an implementation has to allow at least 256 UDP definitions (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_256_definitions.expected
*/
// IEEE 1800-2023 §29.3: an implementation may limit the number of UDP
// definitions in a model, but it shall allow at least 256. The design has
// 256 UDP definitions, u_000 to u_255, and one instance of each, which
// drives bit k of y from the variable a. u_k is an inverter when the number
// of 1 bits of k is odd and a buffer when it is even, so that each
// definition is checked to have its own table: y is printed in hex for
// a = 0 and a = 1, and the two values are each other's inverse.

primitive u_000(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_001(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_002(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_003(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_004(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_005(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_006(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_007(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_008(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_009(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_010(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_011(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_012(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_013(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_014(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_015(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_016(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_017(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_018(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_019(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_020(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_021(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_022(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_023(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_024(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_025(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_026(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_027(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_028(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_029(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_030(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_031(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_032(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_033(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_034(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_035(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_036(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_037(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_038(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_039(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_040(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_041(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_042(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_043(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_044(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_045(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_046(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_047(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_048(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_049(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_050(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_051(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_052(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_053(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_054(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_055(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_056(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_057(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_058(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_059(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_060(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_061(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_062(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_063(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_064(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_065(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_066(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_067(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_068(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_069(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_070(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_071(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_072(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_073(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_074(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_075(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_076(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_077(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_078(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_079(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_080(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_081(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_082(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_083(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_084(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_085(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_086(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_087(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_088(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_089(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_090(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_091(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_092(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_093(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_094(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_095(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_096(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_097(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_098(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_099(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_100(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_101(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_102(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_103(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_104(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_105(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_106(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_107(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_108(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_109(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_110(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_111(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_112(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_113(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_114(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_115(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_116(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_117(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_118(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_119(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_120(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_121(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_122(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_123(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_124(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_125(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_126(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_127(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_128(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_129(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_130(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_131(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_132(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_133(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_134(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_135(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_136(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_137(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_138(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_139(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_140(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_141(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_142(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_143(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_144(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_145(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_146(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_147(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_148(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_149(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_150(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_151(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_152(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_153(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_154(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_155(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_156(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_157(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_158(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_159(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_160(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_161(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_162(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_163(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_164(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_165(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_166(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_167(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_168(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_169(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_170(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_171(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_172(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_173(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_174(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_175(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_176(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_177(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_178(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_179(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_180(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_181(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_182(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_183(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_184(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_185(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_186(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_187(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_188(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_189(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_190(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_191(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_192(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_193(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_194(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_195(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_196(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_197(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_198(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_199(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_200(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_201(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_202(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_203(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_204(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_205(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_206(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_207(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_208(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_209(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_210(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_211(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_212(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_213(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_214(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_215(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_216(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_217(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_218(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_219(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_220(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_221(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_222(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_223(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_224(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_225(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_226(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_227(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_228(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_229(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_230(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_231(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_232(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_233(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_234(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_235(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_236(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_237(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_238(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_239(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_240(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_241(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_242(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_243(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_244(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_245(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_246(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_247(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_248(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_249(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_250(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_251(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_252(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive
primitive u_253(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_254(y, a); output y; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
primitive u_255(y, a); output y; input a;
  table 0 : 0; 1 : 1; endtable
endprimitive

module test_udp_256_definitions;
  logic a;
  wire [255:0] y;
  u_000 g_000(y[0], a);
  u_001 g_001(y[1], a);
  u_002 g_002(y[2], a);
  u_003 g_003(y[3], a);
  u_004 g_004(y[4], a);
  u_005 g_005(y[5], a);
  u_006 g_006(y[6], a);
  u_007 g_007(y[7], a);
  u_008 g_008(y[8], a);
  u_009 g_009(y[9], a);
  u_010 g_010(y[10], a);
  u_011 g_011(y[11], a);
  u_012 g_012(y[12], a);
  u_013 g_013(y[13], a);
  u_014 g_014(y[14], a);
  u_015 g_015(y[15], a);
  u_016 g_016(y[16], a);
  u_017 g_017(y[17], a);
  u_018 g_018(y[18], a);
  u_019 g_019(y[19], a);
  u_020 g_020(y[20], a);
  u_021 g_021(y[21], a);
  u_022 g_022(y[22], a);
  u_023 g_023(y[23], a);
  u_024 g_024(y[24], a);
  u_025 g_025(y[25], a);
  u_026 g_026(y[26], a);
  u_027 g_027(y[27], a);
  u_028 g_028(y[28], a);
  u_029 g_029(y[29], a);
  u_030 g_030(y[30], a);
  u_031 g_031(y[31], a);
  u_032 g_032(y[32], a);
  u_033 g_033(y[33], a);
  u_034 g_034(y[34], a);
  u_035 g_035(y[35], a);
  u_036 g_036(y[36], a);
  u_037 g_037(y[37], a);
  u_038 g_038(y[38], a);
  u_039 g_039(y[39], a);
  u_040 g_040(y[40], a);
  u_041 g_041(y[41], a);
  u_042 g_042(y[42], a);
  u_043 g_043(y[43], a);
  u_044 g_044(y[44], a);
  u_045 g_045(y[45], a);
  u_046 g_046(y[46], a);
  u_047 g_047(y[47], a);
  u_048 g_048(y[48], a);
  u_049 g_049(y[49], a);
  u_050 g_050(y[50], a);
  u_051 g_051(y[51], a);
  u_052 g_052(y[52], a);
  u_053 g_053(y[53], a);
  u_054 g_054(y[54], a);
  u_055 g_055(y[55], a);
  u_056 g_056(y[56], a);
  u_057 g_057(y[57], a);
  u_058 g_058(y[58], a);
  u_059 g_059(y[59], a);
  u_060 g_060(y[60], a);
  u_061 g_061(y[61], a);
  u_062 g_062(y[62], a);
  u_063 g_063(y[63], a);
  u_064 g_064(y[64], a);
  u_065 g_065(y[65], a);
  u_066 g_066(y[66], a);
  u_067 g_067(y[67], a);
  u_068 g_068(y[68], a);
  u_069 g_069(y[69], a);
  u_070 g_070(y[70], a);
  u_071 g_071(y[71], a);
  u_072 g_072(y[72], a);
  u_073 g_073(y[73], a);
  u_074 g_074(y[74], a);
  u_075 g_075(y[75], a);
  u_076 g_076(y[76], a);
  u_077 g_077(y[77], a);
  u_078 g_078(y[78], a);
  u_079 g_079(y[79], a);
  u_080 g_080(y[80], a);
  u_081 g_081(y[81], a);
  u_082 g_082(y[82], a);
  u_083 g_083(y[83], a);
  u_084 g_084(y[84], a);
  u_085 g_085(y[85], a);
  u_086 g_086(y[86], a);
  u_087 g_087(y[87], a);
  u_088 g_088(y[88], a);
  u_089 g_089(y[89], a);
  u_090 g_090(y[90], a);
  u_091 g_091(y[91], a);
  u_092 g_092(y[92], a);
  u_093 g_093(y[93], a);
  u_094 g_094(y[94], a);
  u_095 g_095(y[95], a);
  u_096 g_096(y[96], a);
  u_097 g_097(y[97], a);
  u_098 g_098(y[98], a);
  u_099 g_099(y[99], a);
  u_100 g_100(y[100], a);
  u_101 g_101(y[101], a);
  u_102 g_102(y[102], a);
  u_103 g_103(y[103], a);
  u_104 g_104(y[104], a);
  u_105 g_105(y[105], a);
  u_106 g_106(y[106], a);
  u_107 g_107(y[107], a);
  u_108 g_108(y[108], a);
  u_109 g_109(y[109], a);
  u_110 g_110(y[110], a);
  u_111 g_111(y[111], a);
  u_112 g_112(y[112], a);
  u_113 g_113(y[113], a);
  u_114 g_114(y[114], a);
  u_115 g_115(y[115], a);
  u_116 g_116(y[116], a);
  u_117 g_117(y[117], a);
  u_118 g_118(y[118], a);
  u_119 g_119(y[119], a);
  u_120 g_120(y[120], a);
  u_121 g_121(y[121], a);
  u_122 g_122(y[122], a);
  u_123 g_123(y[123], a);
  u_124 g_124(y[124], a);
  u_125 g_125(y[125], a);
  u_126 g_126(y[126], a);
  u_127 g_127(y[127], a);
  u_128 g_128(y[128], a);
  u_129 g_129(y[129], a);
  u_130 g_130(y[130], a);
  u_131 g_131(y[131], a);
  u_132 g_132(y[132], a);
  u_133 g_133(y[133], a);
  u_134 g_134(y[134], a);
  u_135 g_135(y[135], a);
  u_136 g_136(y[136], a);
  u_137 g_137(y[137], a);
  u_138 g_138(y[138], a);
  u_139 g_139(y[139], a);
  u_140 g_140(y[140], a);
  u_141 g_141(y[141], a);
  u_142 g_142(y[142], a);
  u_143 g_143(y[143], a);
  u_144 g_144(y[144], a);
  u_145 g_145(y[145], a);
  u_146 g_146(y[146], a);
  u_147 g_147(y[147], a);
  u_148 g_148(y[148], a);
  u_149 g_149(y[149], a);
  u_150 g_150(y[150], a);
  u_151 g_151(y[151], a);
  u_152 g_152(y[152], a);
  u_153 g_153(y[153], a);
  u_154 g_154(y[154], a);
  u_155 g_155(y[155], a);
  u_156 g_156(y[156], a);
  u_157 g_157(y[157], a);
  u_158 g_158(y[158], a);
  u_159 g_159(y[159], a);
  u_160 g_160(y[160], a);
  u_161 g_161(y[161], a);
  u_162 g_162(y[162], a);
  u_163 g_163(y[163], a);
  u_164 g_164(y[164], a);
  u_165 g_165(y[165], a);
  u_166 g_166(y[166], a);
  u_167 g_167(y[167], a);
  u_168 g_168(y[168], a);
  u_169 g_169(y[169], a);
  u_170 g_170(y[170], a);
  u_171 g_171(y[171], a);
  u_172 g_172(y[172], a);
  u_173 g_173(y[173], a);
  u_174 g_174(y[174], a);
  u_175 g_175(y[175], a);
  u_176 g_176(y[176], a);
  u_177 g_177(y[177], a);
  u_178 g_178(y[178], a);
  u_179 g_179(y[179], a);
  u_180 g_180(y[180], a);
  u_181 g_181(y[181], a);
  u_182 g_182(y[182], a);
  u_183 g_183(y[183], a);
  u_184 g_184(y[184], a);
  u_185 g_185(y[185], a);
  u_186 g_186(y[186], a);
  u_187 g_187(y[187], a);
  u_188 g_188(y[188], a);
  u_189 g_189(y[189], a);
  u_190 g_190(y[190], a);
  u_191 g_191(y[191], a);
  u_192 g_192(y[192], a);
  u_193 g_193(y[193], a);
  u_194 g_194(y[194], a);
  u_195 g_195(y[195], a);
  u_196 g_196(y[196], a);
  u_197 g_197(y[197], a);
  u_198 g_198(y[198], a);
  u_199 g_199(y[199], a);
  u_200 g_200(y[200], a);
  u_201 g_201(y[201], a);
  u_202 g_202(y[202], a);
  u_203 g_203(y[203], a);
  u_204 g_204(y[204], a);
  u_205 g_205(y[205], a);
  u_206 g_206(y[206], a);
  u_207 g_207(y[207], a);
  u_208 g_208(y[208], a);
  u_209 g_209(y[209], a);
  u_210 g_210(y[210], a);
  u_211 g_211(y[211], a);
  u_212 g_212(y[212], a);
  u_213 g_213(y[213], a);
  u_214 g_214(y[214], a);
  u_215 g_215(y[215], a);
  u_216 g_216(y[216], a);
  u_217 g_217(y[217], a);
  u_218 g_218(y[218], a);
  u_219 g_219(y[219], a);
  u_220 g_220(y[220], a);
  u_221 g_221(y[221], a);
  u_222 g_222(y[222], a);
  u_223 g_223(y[223], a);
  u_224 g_224(y[224], a);
  u_225 g_225(y[225], a);
  u_226 g_226(y[226], a);
  u_227 g_227(y[227], a);
  u_228 g_228(y[228], a);
  u_229 g_229(y[229], a);
  u_230 g_230(y[230], a);
  u_231 g_231(y[231], a);
  u_232 g_232(y[232], a);
  u_233 g_233(y[233], a);
  u_234 g_234(y[234], a);
  u_235 g_235(y[235], a);
  u_236 g_236(y[236], a);
  u_237 g_237(y[237], a);
  u_238 g_238(y[238], a);
  u_239 g_239(y[239], a);
  u_240 g_240(y[240], a);
  u_241 g_241(y[241], a);
  u_242 g_242(y[242], a);
  u_243 g_243(y[243], a);
  u_244 g_244(y[244], a);
  u_245 g_245(y[245], a);
  u_246 g_246(y[246], a);
  u_247 g_247(y[247], a);
  u_248 g_248(y[248], a);
  u_249 g_249(y[249], a);
  u_250 g_250(y[250], a);
  u_251 g_251(y[251], a);
  u_252 g_252(y[252], a);
  u_253 g_253(y[253], a);
  u_254 g_254(y[254], a);
  u_255 g_255(y[255], a);

  initial begin
    a = 1'b0;
    #1 $display("a=0: y=%h", y);
    a = 1'b1;
    #1 $display("a=1: y=%h", y);
  end
endmodule
