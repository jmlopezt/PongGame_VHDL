
-- Basado en ejemplo de Hamblen, J.O., Hall T.S., Furman, M.D.:
-- Rapid Prototyping of Digital Systems : SOPC Edition, Springer 2008.
-- (Capítulo 10) 


library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY controlador_vga_640_x_480 IS
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
			pixel_x			:	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0)
	);		
			
END controlador_vga_640_x_480;
ARCHITECTURE  rtl OF controlador_vga_640_x_480 IS
	SIGNAL hs, vs : STD_LOGIC;
	SIGNAL video_on, video_on_vs, video_on_hs : STD_LOGIC;
	SIGNAL cont_hs, cont_vs :STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

-- La señal video_on está en alta cuando se transmite información de video
-- (para valores de cont_vs entre 0 y 479, y valores de cont_hs entre 0 y 639)
video_on <= video_on_hs AND video_on_vs;

-- La señal vga_clk que va al DAC coincide con el reloj de 25MHz. 
vga_clk <= clock_25MHz;



PROCESS
BEGIN
	WAIT UNTIL(clock_25Mhz'EVENT) AND (clock_25Mhz='1');


-- Se generan las señales de sinronizacion horizontal y vertical
-- a partir de los contadores cont_hs y cont_vs

-- El contador cont_hs cuenta los 640 pixels de cada fila, y añade tiempo extra de sincronización 
-- hs           -----------------------------------__________--------
-- cont_hs      0                640             659       755    799
--
	IF (cont_hs = 799) THEN
   		cont_hs <= "0000000000";
	ELSE
   		cont_hs <= cont_hs + 1;
	END IF;


	IF (cont_hs <= 755) AND (cont_hs >= 659) THEN
 	  	hs <= '0';
	ELSE
 	  	hs <= '1';
	END IF;

-- El contador cont_vs cuenta los 480 pixels de cada columna, y añade tiempo extra de sincronización 
-- vs             -----------------------------------------------_______------------
-- cont_vs         0                                      480    493-494          524
--
	IF (cont_vs >= 524) AND (cont_hs >= 699) THEN
   		cont_vs <= "0000000000";
	ELSIF (cont_hs = 699) THEN
   		cont_vs <= cont_vs + 1;
	END IF;


	IF (cont_vs <= 494) AND (cont_vs >= 493) THEN
   		vs <= '0';
	ELSE
  		vs <= '1';
	END IF;

-- Se generan las señales video_on_hs y video_on_vs que indican que se está enviando información de vídeo 
-- Se generan señales para informar a la salida de la coordenada de pixel a visualizar
	IF (cont_hs <= 639) THEN
   		video_on_hs <= '1';
   		pixel_x <= cont_hs;
	ELSE
	   	video_on_hs <= '0';
	END IF;

	IF (cont_vs <= 479) THEN
   		video_on_vs <= '1';
   		pixel_y <= cont_vs;
	ELSE
   		video_on_vs <= '0';
	END IF;

-- Se registran todas las señales de video para eliminar retardos que puedan emborronar la imagen
		vga_red <= red AND video_on;
		vga_green <= green AND video_on;
		vga_blue <= blue AND video_on;
		vga_hs 	<= hs;
		vga_vs 	<= vs;
		vga_blank <= video_on;



END PROCESS;

END rtl;
