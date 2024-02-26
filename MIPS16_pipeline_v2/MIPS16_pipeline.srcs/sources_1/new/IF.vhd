----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2023 09:19:59 PM
-- Design Name: 
-- Module Name: IFF - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFF is
Port ( jAddress : in STD_LOGIC_VECTOR (15 downto 0);
       branchAddress : in STD_LOGIC_VECTOR (15 downto 0);
       pc : out STD_LOGIC_VECTOR (15 downto 0);
       jump : in STD_LOGIC;
       pcSrc : in STD_LOGIC;
       clk:in std_logic;
       enableW: in std_logic;
       enableR: in std_logic;
       instr : out STD_LOGIC_VECTOR (15 downto 0));
end IFF;

architecture Behavioral of IFF is
type mem256_16 is array (0 to 255) of std_logic_vector(15 downto 0);
    signal myROM:mem256_16:=(x"0010",--add $1,$0,$0 #init contor bucla i=0
                             x"210A",--addi $2,$0,10 #salvez nr iteratii
                             x"0030",--add $3,$0,$0 #init index locatie mem
                             x"0040",--add $4,$0,$0 #init contor nr pare
                             x"8892",--beq $2,$1,18 #verific daca s-au facut iteratiile, si daca s-au facut se sare la ultima instructiune din program, adica la adresa 24
                             x"0000",--NoOp 3XNoOp pentru a apuca instructiunea de salt conditionat sa calculeze adresa urm instructiuni
                             x"0000",--NoOp
                             x"0000",--NoOp
                             x"4E80",--lw $5,0($3) #salvez elementul curent din sir 
                             x"0000",--NoOp 2XNoOp pentru hazardul de date cauzat de scrierea si apoi citirea din reg5
                             x"0000",--NoOp
                             x"B701",--andi $6,$5,1 #verific daca ultimul bit e 1
                             x"0000",--NoOp 2xNoOp pentru hazardul de date cauzat de scrierea sin apoi citirea din reg6
                             x"0000",--NoOp
                             x"D804",--bne $6,$0,4 #daca e 1, nu e numar par, deci se face salt la finalul buclei
                             x"0000",--NoOp 3xNoOp pentru hazardul de control cauzat de instructiunea de salt conditioant bne
                             x"0000",--NoOp
                             x"0000",--NoOp
                             x"3201",--addi $4,$4,1 #contor nr pare++
                             x"2D81",--addi $3,$3,1 #indexul urm element din sir
                             x"2481",--addi $1,$1,1 # actualizare contor bucla i++
                             x"E004",--j 4 #salt 
                             x"0000",--NoOp
                             x"620C",--sw $4,12($0) #salvez la adr 14 nr elemente pare
                             others=>x"0000");
signal d,sum,muxPC,muxJ:std_logic_vector(15 downto 0);
signal q:std_logic_vector(15 downto 0):=x"0000";
begin
process(clk)
    begin
    if rising_edge(clk) then
        if enableR='1' then
            q<=x"0000";
        else
            if enableW='1' then
                q<=d;
            end if;
        end if;
    end if;
    end process;
    instr<=myROM(conv_integer(q(7 downto 0)));
    sum<=1+q;
    pc<=sum;
    muxPC<=sum when pcSrc='0' else branchAddress;
    muxJ<=muxPC when jump='0' else jAddress;
    d<=muxJ;
end Behavioral;
