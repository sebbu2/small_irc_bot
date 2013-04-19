private import std.bind;
private import std.stdio;
private import std.socket;
private import std.socketstream;
private import std.string;
private import std.regexp;
private import std.conv;
private import std.thread;
private import std.typetuple;
private import std.utf;
private import std.cstream;

private import std.date;
private import std.c.time;

private import std.c.stdlib;

private import bot_base;

extern(C) void foo() {
	writefln("the program was exited.");
}

/*char[][char[]] regexp_pseudo;
char[][char[]] regexp_ident;
char[][char[]] regexp_host; //*/

/* regexp */

void main(char[][] args) {
	atexit(&foo);
	
	regexp_pseudo["sebbu"]=r"^(sebbu([0-9]{1})?|sebbu[[a-zA-Z]+]|sebbu`[a-zA-Z]+|zsbe17fr_?|cdefg55|169807976)_?$";
	regexp_ident["sebbu"]=r"^(n=)?~?(sebbu(2|3)?|zsbe17fr_?|cdefg55|bitlbee|169807976|mrfoo)$";
	regexp_host["sebbu"]=r"^([-a-zA-Z0-9]+.[-a-zA-Z0-9]+.abo.wanadoo.fr|[-a-zA-Z0-9]+.iut21.u-bourgogne.fr|[-a-zA-Z0-9]+.ovh.net|[-a-zA-Z0-9]+.kimsufi.com|[0-9A-Fa-f]{8}.[0-9A-Fa-f]{8}.[0-9A-Fa-f]{8}.IP|(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|ayumi-fr.bip2.com|CsAdmin.Otaku\-IRC.net|ns34938.ovh.net|Informatique.ChanAdmin.Yumeru.Net|YAHOO|(yahoo|hotmail|login.icq|login.oscar.aol|jabber|jabberfr).(fr|com|org|net)|MSN|ICQ|AIM|IRC|([^.]\.)?[oO]taku-[iI][rR][cC].[nN][eE][tT])$";
	
	regexp_pseudo["sebbu-test"]=r"^(sebbu(-test|-robot)?([0-9]{1})?|sebbu[[a-zA-Z]+]|sebbu`[a-zA-Z]+|zsbe17fr_?|cdefg55|test|(\[(O|o)taku\])?(T|t)riggers?|169807976)_?$";
	regexp_ident["sebbu-test"]=r"^(n=)?~?(sebbu(-test|-robot)?(2|3)?|zsbe17fr_?|cdefg55|bitlbee|test|169807976|mrfoo|triggers)$";
	regexp_host["sebbu-test"]=r"^([-a-zA-Z0-9]+.[-a-zA-Z0-9]+.abo.wanadoo.fr|[-a-zA-Z0-9]+.iut21.u-bourgogne.fr|[-a-zA-Z0-9]+.ovh.net|[-a-zA-Z0-9]+.kimsufi.com|otaku-irc.net|[0-9A-Fa-f]{8}.[0-9A-Fa-f]{8}.[0-9A-Fa-f]{8}.IP|(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|ayumi-fr.bip2.com|CsAdmin.Otaku\-IRC.net|ns34938.ovh.net|Informatique.ChanAdmin.Yumeru.Net|YAHOO|(yahoo|hotmail|login.icq|login.oscar.aol|jabber|jabberfr).(fr|com|org|net)|MSN|ICQ|AIM|IRC)$";

	//char[][char[]][char[]][char[]] access=null;
	
	/*if( ("geek.otaku-irc.net" in commandes)==null ) commandes["geek.otaku-irc.net"]=null;
	if( ("localhost" in commandes)==null ) commandes["localhost"]=null;
	if( ("#sebbu" in commandes["geek.otaku-irc.net"])==null) commandes["geek.otaku-irc.net"]["#sebbu"]=null;
	if( ("#sebbu" in commandes["localhost"])==null) commandes["localhost"]["#sebbu"]=null;
	if( ("coca" in commandes["geek.otaku-irc.net"]["#sebbu"])==null ) commandes["geek.otaku-irc.net"]["#sebbu"]["coca"]=null;
	if( ("coca" in commandes["localhost"]["#sebbu"])==null ) commandes["localhost"]["#sebbu"]["coca"]=null;
	if( ("say" in commandes["geek.otaku-irc.net"]["#sebbu"])==null ) commandes["geek.otaku-irc.net"]["#sebbu"]["say"]=null;
	if( ("say" in commandes["localhost"]["#sebbu"])==null ) commandes["localhost"]["#sebbu"]["say"]=null;
	if( ("act" in commandes["geek.otaku-irc.net"]["#sebbu"])==null ) commandes["geek.otaku-irc.net"]["#sebbu"]["act"]=null;
	if( ("act" in commandes["localhost"]["#sebbu"])==null ) commandes["localhost"]["#sebbu"]["act"]=null;*/
	/*add_command("localhost", "#sebbu", "coca", 0, "act sert le coca a {NICK}", 1, "act sert le coca a {ARGS}");
	add_command("irc.otaku-irc.net", "#sebbu", "coca", 0, "act sert le coca a {NICK}", 1, "act sert le coca a {ARGS}");
	add_command("localhost", "#sebbu", "say", 0, "say {ARGS}", 0, "");
	add_command("irc.otaku-irc.net", "#sebbu", "say", 0, "say {ARGS}", 0, "");
	add_command("localhost", "#sebbu", "act", 0, "act {ARGS}", 0, "");
	add_command("irc.otaku-irc.net", "#sebbu", "act", 0, "act {ARGS}", 0, "");*/
	
	//foo.say	=	(BindAlias!(small_irc_bot.send)(char[]));
	ip=get_ip();
	
	small_irc_bot test=new small_irc_bot;
	delete test;
	//test=new small_irc_bot("localhost", 6667, "sebbu-test");
	test=new small_irc_bot("irc.otaku-irc.net", 6667, "sebbu-test");
	//test=new small_irc_bot("irc.mirana.idapnet.org", 6667, "sebbu-test");
	test.connect();
	writefln("\nconnected\n");
	bool loop=true;
	bool traitement= false;
	char[] ligne;
	RegExp myRegExp;
	while(loop&&test.connected) {
		ligne=test.read();
		test.display_r(ligne);
		traitement=test.eval(ligne);
		if(!traitement) {
			//test.display_r(ligne);
		}
		myRegExp=std.regexp.search(ligne, "^ERROR :Closing Link(.*)$");
		
		if(myRegExp) {
			loop=false;
		}
		if(!test.connected) loop=false;
		Thread.yield();
	}
	th_run= false;
	delete test;
	
	Thread[] t=Thread.getAll();
	//for(int i=0;i<t.length;i++) {
	while(Thread.nthreads>1) {
		int i=1;
		try {
			if(t[i]!=Thread.getThis()) {
				try {
					t[i].resume();
				}
				catch(ThreadError) { }
				t[i].wait();
			}
		}
		catch(ThreadError) { }
		finally { i++; }
	}
	writefln("program ended");
	din.getc();
}