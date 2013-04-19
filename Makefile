WS2_32 = D:\dmd\lib\WS2_32.LIB
LIB = D:\dmd\lib\\

all: small_irc_bot.exe

small_irc_bot.exe: bot_base.obj dcc_chat.obj small_irc_bot.obj test.obj
	link.exe small_irc_bot.obj+bot_base.obj+test.obj+dcc_chat.obj,,,$(WS2_32)+user32+kernel32/noi;

test.obj: test.d
	dmd -c test.d

small_irc_bot.obj: small_irc_bot.d
	dmd -c small_irc_bot.d

bot_base.obj: bot_base.d
	dmd -c bot_base.d

dcc_chat.obj: dcc_chat.d
	dmd -c dcc_chat.d

mrproper: clean
	del small_irc_bot.exe

clean:
	del bot_base.obj dcc_chat.obj test.obj small_irc_bot.obj

distclean: mrproper

