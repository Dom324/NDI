----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:16:28 10/04/2023
-- Design Name:
-- Module Name:    deser - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity deser is
generic(
        DataWidth          : integer := 15
    );
    Port (
        stream      : in  STD_LOGIC;
        shift_en    : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        clk         : in  STD_LOGIC;
        data        : out  STD_LOGIC_VECTOR (DataWidth downto 0)
    );
end deser;

architecture Behavioral of deser is

    signal shift_reg : STD_LOGIC_VECTOR (DataWidth downto 0);
    signal shift_reg_D : STD_LOGIC_VECTOR (DataWidth downto 0);

begin

    process(clk, rst, shift_reg, shift_reg_D) is
        begin
        if rst = '1' then
            shift_reg <= (others => '0');
        elsif rising_edge(clk) then
            shift_reg <= shift_reg_D;
        else
            shift_reg <= shift_reg;
        end if;
    end process;

    process(shift_en, shift_reg, stream) is
    begin
        if shift_en = '1' then
            shift_reg_D <= stream & shift_reg(DataWidth downto 1);
        else
            shift_reg_D <= shift_reg;
        end if;
    end process;

    data<=shift_reg;

end Behavioral;
