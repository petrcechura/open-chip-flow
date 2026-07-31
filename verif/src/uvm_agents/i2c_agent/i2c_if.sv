//------------------------------------------------------------
//   Copyright 2012 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

interface i2c_if;

    wire sda_wire;
    wire scl_wire;
    wire clk;
    wire rst;
    logic[6:0] addr;
    logic sda_o, sda_en;
    logic scl_o, scl_en;
    wire scl_i;
    wire sda_i;


`ifndef USING_VERILATOR
    pullup pu_sda(sda_wire);
    pullup pu_scl(scl_wire);
    assign sda_wire = sda_en ? sda_o : 1'bZ;
    assign scl_wire = scl_en ? scl_o : 1'bZ;
    assign sda_i = sda_wire;
    assign scl_i = scl_wire;
`endif

endinterface: i2c_if
