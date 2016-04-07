

-- Descripción que visualiza franjas de colores en un monitor VGA
--
-- Basado en ejemplo de Hamblen, J.O., Hall T.S., Furman, M.D.:
-- Rapid Prototyping of Digital Systems : SOPC Edition, Springer 2008.
-- (Capítulo 10) 


LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;


ENTITY top_bola IS

PORT(	
     	clock			: IN STD_LOGIC;
		vga_red			: OUT STD_LOGIC;
		vga_green		: OUT STD_LOGIC;
		vga_blue		: OUT STD_LOGIC;
		vga_blank		: OUT STD_LOGIC;
		vga_hs			: OUT STD_LOGIC;
		vga_vs			: OUT STD_LOGIC;
		up		   		: IN std_logic;
		down		   	: IN std_logic;
		up_R		   	: IN std_logic;
		down_R		   	: IN std_logic;
		vga_clk			: OUT STD_LOGIC
		);

END top_bola;

ARCHITECTURE funcional OF top_bola IS


	COMPONENT vga_PLL
		PORT(
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC );
	END COMPONENT;
	
	COMPONENT controlador_vga_640_x_480
		PORT(	
			clock_25Mhz		: 	IN	STD_LOGIC;
			red,green,blue	: 	IN	STD_LOGIC;
			vga_red			:	OUT	STD_LOGIC;
			vga_green		:	OUT	STD_LOGIC;
			vga_blue		:	OUT	STD_LOGIC;
			vga_blank		:	OUT	STD_LOGIC;
			vga_hs			:	OUT STD_LOGIC;
			vga_vs			:	OUT STD_LOGIC;
			vga_clk			:	OUT STD_LOGIC;
			pixel_y			:	OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			pixel_x			:	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0));		
	END COMPONENT;
	
	COMPONENT bola
		PORT(	
			vs				: 	IN	STD_LOGIC;
			pixel_Y			: 	IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
			pixel_X			:	IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
			Red		    	:	OUT STD_LOGIC;
			Green			:	OUT STD_LOGIC;
			up				: 	IN	STD_LOGIC;
			down			: 	IN	STD_LOGIC;
			up_R			: 	IN	STD_LOGIC;
			down_R			: 	IN	STD_LOGIC;			
			Blue			:	OUT STD_LOGIC);		
	END COMPONENT;


SIGNAL clock_25MHz : STD_LOGIC;
SIGNAL Red_Data, Green_Data, Blue_Data,vs : STD_LOGIC;
SIGNAL pixel_x, pixel_y	: STD_LOGIC_VECTOR(9 DOWNTO 0);



BEGIN

vga_vs<=vs;


	-- PLL para generar el reloj de 25 MHz
PLL: vga_pll PORT MAP (
		inclk0 => clock,
		c0 => clock_25Mhz);
		

	-- Controlador de la VGA
VGA:  controlador_vga_640_x_480 PORT MAP (	
		clock_25Mhz	=> clock_25MHz,
		red 	=> red_data,
		green 	=> green_data,
		blue 	=> blue_data,	
		vga_red	=> vga_red,
		vga_green => vga_green,
		vga_blue => vga_blue,
		vga_blank => vga_blank,
		vga_hs	 => vga_hs, 
		vga_vs 	 => vs, 
		vga_clk	 => vga_clk,
		pixel_y  => pixel_y, 
		pixel_x  => pixel_x);		
			
			 	
bol : bola PORT MAP (
		vs 		=> vs,
		pixel_Y => pixel_y, 
		pixel_X => pixel_x,
		Red 	=> red_data,
		up		=> up,
		down	=> down,	
		up_R	=> up_R,
		down_R	=> down_R,	
		Green 	=> green_data,
		Blue 	=> blue_data);

END funcional;

