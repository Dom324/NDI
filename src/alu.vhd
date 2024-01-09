----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    13:58:40 11/01/2023
-- Design Name:
-- Module Name:    alu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
generic(
        constant DATA_WIDTH          : integer := 15
    );
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        data_in         : in  STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
        we_data_fr1     : in  STD_LOGIC;
        we_data_fr2     : in  STD_LOGIC;
        we_result       : in  STD_LOGIC;
        add_res         : out  STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
        mul_res         : out  STD_LOGIC_VECTOR (DATA_WIDTH downto 0)
    );
end alu;

architecture Behavioral of alu is

    signal r_add : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
    signal r_mul : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

    signal s_add : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
    signal s_mul : STD_LOGIC_VECTOR (2*DATA_WIDTH+1 downto 0);
    signal s_mul_top : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

    signal s_add_next : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
    signal s_mul_next : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

    signal r_data1 : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
    signal r_data2 : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

    signal s_data1_next : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);
    signal s_data2_next : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

    signal s_add_overflow : STD_LOGIC;
    signal s_add_underflow : STD_LOGIC;

    signal s_mul_result_should_be_positive : STD_LOGIC;
    signal s_mul_result_should_too_big : STD_LOGIC;
    signal s_mul_overflow : STD_LOGIC;
begin

    process(clk, rst) is
    begin
        if rst = '1' then
            r_data1 <= (others => '0');
            r_data2 <= (others => '0');
            r_add <= (others => '0');
            r_mul <= (others => '0');
        elsif rising_edge(clk) then
            r_data1 <= s_data1_next;
            r_data2 <= s_data2_next;
            r_add <= s_add_next;
            r_mul <= s_mul_next;
        end if;
    end process;

    process(we_data_fr1, we_data_fr2, data_in, r_data1, r_data2, we_result, s_add, s_mul, r_add, r_mul, s_mul_result_should_be_positive, s_mul_top, s_mul_overflow, s_add_overflow, s_add_underflow) is
    begin

        if(we_data_fr1 = '1') then
            s_data1_next <= data_in;
        else
            s_data1_next <= r_data1;
        end if;

        if(we_data_fr2 = '1') then
            s_data2_next <= data_in;
        else
            s_data2_next <= r_data2;
        end if;

        s_add <= std_logic_vector(signed(r_data1) + signed(r_data2));
        s_mul <= std_logic_vector(signed(r_data1) * signed(r_data2));

        s_mul_result_should_be_positive <= (r_data1(DATA_WIDTH) and r_data2(DATA_WIDTH)) or (not r_data1(DATA_WIDTH) and not r_data2(DATA_WIDTH));
        s_mul_top <= s_mul(2*DATA_WIDTH+1 downto DATA_WIDTH+1);

        if(s_mul_top = std_logic_vector(to_unsigned(0, s_mul_top'length))) then
            s_mul_overflow <= '0';
        else
            s_mul_overflow <= '1';
        end if;

        s_add_overflow <= (not r_data1(DATA_WIDTH) and not r_data2(DATA_WIDTH)) and s_add(DATA_WIDTH);
        s_add_underflow <= (r_data1(DATA_WIDTH) and r_data2(DATA_WIDTH)) and not s_add(DATA_WIDTH);

        if(we_result = '1') then
            if(s_add_overflow = '1') then
                s_add_next <= (others => '1');
                s_add_next(DATA_WIDTH) <= '0';
            elsif(s_add_underflow = '1') then
                s_add_next <= (others => '0');
                s_add_next(DATA_WIDTH) <= '1';
            else
                s_add_next <= s_add(DATA_WIDTH downto 0);
            end if;

            if(s_mul_overflow = '1' and s_mul_result_should_be_positive = '1') then
                s_mul_next <= (others => '1');
                s_mul_next(DATA_WIDTH) <= '0';
            elsif(s_mul_overflow = '1' and s_mul_result_should_be_positive = '0') then
                s_mul_next <= (others => '0');
                s_mul_next(DATA_WIDTH) <= '1';
            else
                s_mul_next <= not s_mul_result_should_be_positive & s_mul(DATA_WIDTH-1 downto 0);
            end if;
        else
            s_add_next <= r_add;
            s_mul_next <= r_mul;
        end if;

    end process;

    add_res <= r_add;
    mul_res <= r_mul;

end Behavioral;
