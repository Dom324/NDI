----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    14:18:24 10/04/2023
-- Design Name:
-- Module Name:    ser - Behavioral
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

entity ser is
    generic(
        DataWidth        : integer := 15
    );
    Port (
        data        : in  STD_LOGIC_VECTOR (DataWidth downto 0);
        load_en     : in  STD_LOGIC;
        shift_en    : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        clk         : in  STD_LOGIC;
        stream      : out  STD_LOGIC
    );
end ser;

architecture Behavioral of ser is

    signal shift_reg    : STD_LOGIC_VECTOR (DataWidth downto 0);
    signal shift_reg_D  : STD_LOGIC_VECTOR (DataWidth downto 0);

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

    process(load_en, shift_en, data, shift_reg) is
    begin
        if load_en = '1' then
            shift_reg_D <= data;
        elsif shift_en = '1' then
            shift_reg_D <= '0' & shift_reg(DataWidth downto 1);
        else
            shift_reg_D <= shift_reg;
        end if;
    end process;

    stream <= shift_reg(0);

end Behavioral;

