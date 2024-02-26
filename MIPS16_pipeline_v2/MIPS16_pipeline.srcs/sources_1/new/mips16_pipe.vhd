----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2023 09:04:13 PM
-- Design Name: 
-- Module Name: mips16_pipe - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mips16_pipe is
Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end mips16_pipe;

architecture Behavioral of mips16_pipe is

signal enR,enW:std_logic;
    component monoimpuls is
     port(input: in std_logic;
          clk: in std_logic;
          output: out std_logic);
end component;

signal DO:std_logic_vector(15 downto 0);
component SSD is
    Port ( Digit0 : in STD_LOGIC_VECTOR (3 downto 0);
               Digit1 : in STD_LOGIC_VECTOR (3 downto 0);
               Digit2 : in STD_LOGIC_VECTOR (3 downto 0);
               Digit3 : in STD_LOGIC_VECTOR (3 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0);
               an : out STD_LOGIC_VECTOR (3 downto 0);
               clk : in STD_LOGIC);
end component;

signal pc,instr:std_logic_vector(15 downto 0);
signal branchAdd,jumpAdd: std_logic_vector(15 downto 0);
signal pcsrc:std_logic;
component IFF is
     Port ( jAddress : in STD_LOGIC_VECTOR (15 downto 0);
              branchAddress : in STD_LOGIC_VECTOR (15 downto 0);
              pc : out STD_LOGIC_VECTOR (15 downto 0);
              jump : in STD_LOGIC;
              pcSrc : in STD_LOGIC;
              clk:in std_logic;
              enableW: in std_logic;
              enableR: in std_logic;
              instr : out STD_LOGIC_VECTOR (15 downto 0));
end component;

 signal regDst : STD_LOGIC;
    signal extOp : STD_LOGIC;
    signal ALUsrc : STD_LOGIC;
    signal ALUop : std_logic_vector(1 downto 0);
    signal branch : STD_LOGIC;
    signal sbne : std_logic;
    signal jump : STD_LOGIC;
    signal memWrite : STD_LOGIC;
    signal memtoreg : STD_LOGIC;
    signal regWrite : STD_LOGIC;
 component UC is
    Port ( instr : in STD_LOGIC_VECTOR (15 downto 0);
               regDst : out STD_LOGIC;
               extOp : out STD_LOGIC;
               ALUsrc : out STD_LOGIC;
               ALUop: out std_logic_vector(1 downto 0);
               branch : out STD_LOGIC;
               sbne: out std_logic;
               jump : out STD_LOGIC;
               memWrite : out STD_LOGIC;
               memtoreg : out STD_LOGIC;
               regWrite : out STD_LOGIC);
    end component;
    
signal rd1,rd2,ext_imm,wd: std_logic_vector(15 downto 0);
signal func,wa,muxrd: std_logic_vector(2 downto 0);
signal sa: std_logic;
component ID is
   Port ( clk:in std_logic;
          regWrite : in STD_LOGIC;
          instr : in STD_LOGIC_VECTOR (15 downto 0);
          regDst : in STD_LOGIC;
          extOp : in STD_LOGIC;
          wd : in STD_LOGIC_VECTOR(15 downto 0);
          enable_w : in STD_LOGIC;
          rd1: out std_logic_vector(15 downto 0);
          rd2: out std_logic_vector(15 downto 0);
          ext_imm:  out std_logic_vector(15 downto 0);
          func:out std_logic_vector(2 downto 0);
          sa: out std_logic;
          wa:in std_logic_vector(2 downto 0);
          muxrd:out std_logic_vector(2 downto 0));
          end component;

signal zeroALU : STD_LOGIC;
signal ALUres : STD_LOGIC_VECTOR (15 downto 0);
component EX is
    Port ( pc : in STD_LOGIC_VECTOR (15 downto 0);
           rd1 : in STD_LOGIC_VECTOR (15 downto 0);
           ALUsrc : in STD_LOGIC;
           rd2 : in STD_LOGIC_VECTOR (15 downto 0);
           ext_imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUop : in STD_LOGIC_VECTOR (1 downto 0);
           zeroALU : out STD_LOGIC;
           ALUres : out STD_LOGIC_VECTOR (15 downto 0);
           branchAdd:out std_logic_vector(15 downto 0));
    end component;
    
    signal memData,ALUres2:std_logic_vector(15 downto 0);
    component MEM is
    Port ( clk : in STD_LOGIC;
               enable_W:in std_logic;
               ALUres : in STD_LOGIC_VECTOR (15 downto 0);
               rd2 : in STD_LOGIC_VECTOR (15 downto 0);
               memWrite : in STD_LOGIC;
               memData : out STD_LOGIC_VECTOR (15 downto 0);
               ALUres2 : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    --reg_if_id
     signal instr_if_id,pc_if_id:std_logic_vector(15 downto 0);
     
     --reg id_ex
     signal wb_id_ex:std_logic_vector(1 downto 0);
     signal m_id_ex:std_logic_vector(2 downto 0);
     signal ex_id_ex:std_logic_vector(2 downto 0);
     signal pc_id_ex,rd1_id_ex,rd2_id_ex,ext_imm_id_ex:std_logic_vector(15 downto 0);
     signal sa_id_ex:std_logic;
     signal func_id_ex:std_logic_vector(2 downto 0);
     signal muxrd_id_ex:std_logic_vector(2 downto 0);
     
     --reg ex mem
     signal wb_ex_mem:std_logic_vector(1 downto 0);
     signal m_ex_mem:std_logic_vector(2 downto 0);
     signal rd2_ex_mem, ALUres_ex_mem, branchAdd_ex_mem:std_logic_vector(15 downto 0);
     signal zero_ex_mem:std_logic;
     signal muxrd_ex_mem:std_logic_vector(2 downto 0);
     
     --reg mem wb
     signal wb_mem_wb: std_logic_vector(1 downto 0);
     signal memData_mem_wb,ALUres_mem_wb:std_logic_vector(15 downto 0);
     signal muxrd_mem_wb:std_logic_vector(2 downto 0);

begin
    monopulseR: monoimpuls port map(input=>btn(0),output=>enR,clk=>clk);
    monopulseW: monoimpuls port map(input=>btn(4),output=>enW,clk=>clk);
    segdisplay: SSD port map(Digit0=>DO(3 downto 0),Digit1=>DO(7 downto 4),Digit2=>DO(11 downto 8),Digit3=>DO(15 downto 12),clk=>clk,cat=>cat,an=>an);
    maincontrol: UC port map(instr=>instr_if_id,regDst=>regDst,extOp=>extOp,ALUsrc=>ALUsrc,ALUop=>ALUop,branch=>branch,sbne=>sbne,jump=>jump,memWrite=>memWrite,memtoReg=>memtoReg,regWrite=>regWrite);
    ifschema: IFF port map(jAddress=>jumpAdd,branchAddress=>branchAdd_ex_mem,pc=>pc,jump=>jump,pcSrc=>pcsrc,clk=>clk,enableW=>enW,enableR=>enR,instr=>instr);
    idschema: ID port map(clk=>clk,regWrite=>wb_mem_wb(1),instr=>instr_if_id,regDst=>regDst,extOp=>extOp,wd=>wd, enable_w=>enW,rd1=>rd1,rd2=>rd2,ext_imm=>ext_imm,func=>func,sa=>sa,wa=>muxrd_mem_wb,muxrd=>muxrd);
    exschema: EX port map(pc=>pc_id_ex,rd1=>rd1_id_ex,ALUsrc=>ex_id_ex(2),rd2=>rd2_id_ex,ext_imm=>ext_imm_id_ex,sa=>sa_id_ex,func=>func_id_ex,ALUop=>ex_id_ex(1 downto 0),zeroALU=>zeroALU,ALUres=>ALUres,branchAdd=>branchAdd);
    memschema: MEM port map(clk=>clk,enable_W=>enW,ALUres=>ALUres_ex_mem,rd2=>rd2_ex_mem,memWrite=>m_ex_mem(0),memData=>memData,ALUres2=>ALUres2);
   
    jumpAdd<=pc_if_id(15 downto 13)&instr_if_id(12 downto 0);
    pcsrc<=(m_ex_mem(1) and zero_ex_mem) or (m_ex_mem(2) and (not zero_ex_mem));
    wd<= ALUres_mem_wb when wb_mem_wb(0)='0' else memData_mem_wb;
        
    --reg_if_id
    process(clk,enW)
    begin
    if rising_edge(clk) then
        if enW='1' then
            instr_if_id<=instr;
            pc_if_id<=pc;
         end if;
    end if;
    end process;
   --reg_id_ex
    process(clk,enW)
    begin
    if rising_edge(clk) then
        if enW='1' then
             wb_id_ex(0)<=memtoReg;
             wb_id_ex(1)<=regWrite;
             m_id_ex(0)<=memWrite;
             m_id_ex(1)<=branch;
             m_id_ex(2)<=sbne;
             ex_id_ex(1 downto 0)<=ALUop;
             ex_id_ex(2)<=ALUsrc;
             pc_id_ex<=pc_if_id;
             rd1_id_ex<=rd1;
             rd2_id_ex<=rd2;
             ext_imm_id_ex<=ext_imm;
             sa_id_ex<=sa;
             func_id_ex<=func;
             muxrd_id_ex<=muxrd;
        end if;
    end if;
    end process;
             
    --reg ex mem   
    process(clk,enW)
    begin
    if rising_edge(clk) then
        if enW='1' then
             wb_ex_mem<=wb_id_ex;
             m_ex_mem<=m_id_ex;
             rd2_ex_mem<=rd2_id_ex;
             ALUres_ex_mem<=ALUres;
             branchAdd_ex_mem<=branchAdd;
             zero_ex_mem<=zeroALU;
             muxrd_ex_mem<=muxrd_id_ex;  
        end if;
    end if;
    end process;
             
    --reg mem wb  
    process(clk,enW)
    begin
    if rising_edge(clk) then
        if enW='1' then
             wb_mem_wb<=wb_ex_mem;
             memData_mem_wb<=memData;
             ALUres_mem_wb<=ALUres_ex_mem;
             muxrd_mem_wb<=muxrd_ex_mem;
        end if;
   end if;
   end process;
                         
   process(sw)
   begin
   case sw(7 downto 5) is
       when "000"=> DO <=instr;
       when "001"=> DO <=pc;
       when "010"=> DO <=rd1_id_ex;
       when "011"=> DO <=rd2_id_ex;
       when "100"=> DO <=ext_imm_id_ex;
       when "101"=> DO <=ALUres;
       when "110"=> DO <=memData;
       when others=> DO <=wd;
   end case;
   end process;
   led(10)<=regDst;
   led(9)<=extOp;
   led(8)<=ALUsrc;
   led(7)<=branch;
   led(6)<=sbne;
   led(5)<=jump;
   led(4)<=memWrite;
   led(3)<=memtoReg;
   led(2)<=regWrite;
   led(1)<=ALUop(1);
   led(0)<=ALUop(0);
end Behavioral;
