private import std.bind;
private import std.typetuple;
private import std.c.time;
private import std.c.stdlib;
private import std.conv;
private import std.cstream;
private import std.date;
private import std.dateparse;
private import std.file;
private import std.regexp;
private import std.socket;
private import std.socketstream;
private import std.stdio;
private import std.string;
private import std.thread;
private import std.utf;

char[][char[]] regexp_pseudo=null;
char[][char[]] regexp_ident=null;
char[][char[]] regexp_host=null;

Thread[char[]][char[]] dcc_chats=null;
long thread_count;

bool th_run= true;

char[] ip;

Tuple!(char[], int, char[])[int][char[]][char[]][char[]] commandes=null;
char[][char[]][char[]][char[]] access=null;

bool save_command(char[] serveur,char[] salon) {
	try {
		char[] res;
		char[] key_1=serveur,key_2=salon;
		if( (key_1 in commandes)==null || (key_2 in commandes[key_1])==null ) throw new Exception(std.conv.toString(__LINE__));
		res ~= "a:"~std.string.toString(commandes[key_1][key_2].length)~ ":{";
		foreach(char[] key_3; commandes[key_1][key_2].keys.sort) { // commande
			res ~= "s:"~std.string.toString(key_3.length)~ ":\"" ~key_3~ "\";";
			res ~= "a:"~std.string.toString(commandes[key_1][key_2][key_3].length)~ ":{";
			foreach(int key_4; commandes[key_1][key_2][key_3].keys.sort) { // index
				res ~= "i:"~ std.string.toString(key_4)~ ";";
				res ~= "a:"~std.string.toString(commandes[key_1][key_2][key_3][key_4].length)~ ":{";
				// debut tuple
				res ~= "i:0;";
				res ~= "s:"~std.string.toString(commandes[key_1][key_2][key_3][key_4].value[0].length)~ ":\"" ~commandes[key_1][key_2][key_3][key_4].value[0]~ "\";";
				res ~= "i:1;";
				res ~= "i:" ~std.string.toString(commandes[key_1][key_2][key_3][key_4].value[1])~ ";";
				res ~= "i:2;";
				res ~= "s:"~std.string.toString(commandes[key_1][key_2][key_3][key_4].value[2].length)~ ":\"" ~commandes[key_1][key_2][key_3][key_4].value[2]~ "\";";
				// fin tuple
				res ~= "}";
			}
			res ~= "}";
		}
		res ~= "}";
		writefln(res);
		res ~= "\r\n";
		char[] path;
		char[] delim;
		if(!exists(serveur)) mkdir(serveur);
		version(Windows) {
			delim= "\\";
		}
		else {
			delim= "/";
		}
		path=serveur~ delim~ salon;
		if(!exists(path)) mkdir(path);
		if(exists(path~delim~ "command.db")) std.file.remove(path~delim~ "command.db");
		std.file.write(path~delim~ "command.db",res);
	}
	catch(FileException e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	catch(Exception e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	return true;
}

bool load_command(char[] serveur,char[] salon) {
	try {
		char[] path;
		char[] delim;
		if(!exists(serveur)) mkdir(serveur);
		version(Windows) {
			delim= "\\";
		}
		else {
			delim= "/";
		}
		path=serveur~ delim~ salon;
		if(!exists(path)) mkdir(path);
		if(exists(path~delim~ "command.db")) {
			char[] res=cast(char[])std.file.read(path~delim~ "command.db");
			//writefln(res);
			uint pos=0;
			int pos2=0;
			int ar;
			int ar2;
			
			char[] commande;
			int commande_cpt;
			int index;
			char[] cmd;
			int cmd_cpt;
			int mode;
			char[] cmd2;
			int cmd2_cpt;
			
			if( res[pos..pos + 2] != "a:" ) throw new Exception(std.string.toString(__LINE__));
			pos+= 2;
			pos2=std.string.find(res[pos..$], ':');
			if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
				throw new Exception(std.string.toString(__LINE__));
			}
			ar=std.conv.toInt(res[pos..pos + pos2]);
			pos+= pos2;
			if( res[pos..pos + 2] != ":{" ) throw new Exception(std.string.toString(__LINE__));
			pos+= 2;
			for(int i;i<ar;i++) {
				if( res[pos..pos + 2] != "s:" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				pos2=std.string.find(res[pos..$], ':');
				if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
					throw new Exception(std.string.toString(__LINE__));
				}
				commande_cpt=std.conv.toInt(res[pos..pos + pos2]);
				pos+= pos2;
				if( res[pos..pos + 2] != ":\"" ) throw new Exception(std.string.toString(__LINE__)); //"
				pos+= 2;
				commande=res[pos..pos + commande_cpt];
				pos+= commande_cpt;
				if( res[pos..pos + 2] != "\";" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				
				if( res[pos..pos + 2] != "a:" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				pos2=std.string.find(res[pos..$], ':');
				if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
					throw new Exception(std.string.toString(__LINE__));
				}
				ar2=std.conv.toInt(res[pos..pos + pos2]);
				pos+= pos2;
				if( res[pos..pos + 2] != ":{" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				for(int j;j<ar2;j++) {
					if( res[pos..pos + 2] != "i:" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					pos2=std.string.find(res[pos..$], ';');
					if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
						throw new Exception(std.string.toString(__LINE__));
					}
					int k=std.conv.toInt(res[pos..pos + pos2]);
					if(k!=j) throw new Exception("line "~std.string.toString(__LINE__)~ " : index error");
					index=k;
					pos+= pos2;
					if( res[pos..pos + 1] != ";" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 1;
					if( res[pos..pos + 5] != "a:3:{" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 5;
					if( res[pos..pos + 4] != "i:0;" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 4;
					if( res[pos..pos + 2] != "s:" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					pos2=std.string.find(res[pos..$], ':');
					if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
						throw new Exception(std.string.toString(__LINE__));
					}
					cmd_cpt=std.conv.toInt(res[pos..pos + pos2]);
					pos+= pos2;
					if( res[pos..pos + 2] != ":\"" ) throw new Exception(std.string.toString(__LINE__)); //"
					pos+= 2;
					cmd=res[pos..pos + cmd_cpt];
					pos+= cmd_cpt;
					if( res[pos..pos + 2] != "\";" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					if( res[pos..pos + 4] != "i:1;" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 4;
					if( res[pos..pos + 2] != "i:" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					pos2=std.string.find(res[pos..$], ';');
					if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
						throw new Exception(std.string.toString(__LINE__));
					}
					mode=std.conv.toInt(res[pos..pos + pos2]);
					pos+= pos2;
					if( res[pos..pos + 1] != ";" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 1;
					if( res[pos..pos + 4] != "i:2;" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 4;
					if( res[pos..pos + 2] != "s:" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					pos2=std.string.find(res[pos..$], ':');
					if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
						throw new Exception(std.string.toString(__LINE__));
					}
					cmd2_cpt=std.conv.toInt(res[pos..pos + pos2]);
					pos+= pos2;
					if( res[pos..pos + 2] != ":\"" ) throw new Exception(std.string.toString(__LINE__)); //"
					pos+= 2;
					cmd2=res[pos..pos + cmd2_cpt];
					pos+= cmd2_cpt;
					if( res[pos..pos + 2] != "\";" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 2;
					if( res[pos..pos + 1] != "}" ) throw new Exception(std.string.toString(__LINE__));
					pos+= 1;
					bool test=replace_command(serveur,salon,commande,index,cmd,mode,cmd2);
					writefln("replacing command %s index %d on %s at %s", commande, index, salon, serveur);
				}
				if( res[pos..pos + 1] != "}" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 1;
			}
			if( res[pos..pos + 1] != "}" ) throw new Exception(std.string.toString(__LINE__));
			pos+= 1;
			return true;
		}
		return false;
	}
	catch(FileException e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	catch(Exception e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
}

bool save_access(char[] serveur,char[] salon) {
	try {
		char[] res;
		char[] key_1=serveur,key_2=salon;
		if( (key_1 in access)==null || (key_2 in access[key_1])==null ) throw new Exception(std.conv.toString(__LINE__));
		res ~= "a:"~std.string.toString(access[key_1][key_2].length)~ ":{";
		foreach(char[] key_3; access[key_1][key_2].keys.sort) {
			res ~= "s:"~std.string.toString(key_3.length)~ ":\"" ~key_3~ "\";";
			res ~= "s:"~std.string.toString(access[key_1][key_2][key_3].length)~ ":\"" ~access[key_1][key_2][key_3]~ "\";";
		}
		res ~= "}";
		writefln(res);
		res ~= "\r\n";
		char[] path;
		char[] delim;
		if(!exists(serveur)) mkdir(serveur);
		version(Windows) {
			delim= "\\";
		}
		else {
			delim= "/";
		}
		path=serveur~ delim~ salon;
		if(!exists(path)) mkdir(path);
		if(exists(path~delim~ "access.db")) std.file.remove(path~delim~ "access.db");
		std.file.write(path~delim~ "access.db",res);
	}
	catch(FileException e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	catch(Exception e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	return true;
}

bool load_access(char[] serveur,char[] salon) {
	try {
		char[] path;
		char[] delim;
		if(!exists(serveur)) mkdir(serveur);
		version(Windows) {
			delim= "\\";
		}
		else {
			delim= "/";
		}
		path=serveur~ delim~ salon;
		if(!exists(path)) mkdir(path);
		if(exists(path~delim~ "access.db")) {
			char[] res=cast(char[])std.file.read(path~delim~ "access.db");
			//writefln(res);
			uint pos=0;
			int pos2=0;
			
			int ar;
			
			char[] ps;
			int ps_cpt;
			char[] pa;
			int pa_cpt;
			
			if( res[pos..pos + 2] != "a:" ) throw new Exception(std.string.toString(__LINE__));
			pos+= 2;
			pos2=std.string.find(res[pos..$], ':');
			if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
				throw new Exception(std.string.toString(__LINE__));
			}
			ar=std.conv.toInt(res[pos..pos + pos2]);
			pos+= pos2;
			if( res[pos..pos + 2] != ":{" ) throw new Exception(std.string.toString(__LINE__));
			pos+= 2;
			for(int i;i<ar;i++) {
				if( res[pos..pos + 2] != "s:" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				pos2=std.string.find(res[pos..$], ':');
				if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
					throw new Exception(std.string.toString(__LINE__));
				}
				ps_cpt=std.conv.toInt(res[pos..pos + pos2]);
				pos+= pos2;
				if( res[pos..pos + 2] != ":\"" ) throw new Exception(std.string.toString(__LINE__)); //"
				pos+= 2;
				ps=res[pos..pos + ps_cpt];
				pos+= ps_cpt;
				if( res[pos..pos + 2] != "\";" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				if( res[pos..pos + 2] != "s:" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				pos2=std.string.find(res[pos..$], ':');
				if( pos2 < 0 || !std.string.isNumeric(res[pos..pos + pos2]) ) {
					throw new Exception(std.string.toString(__LINE__));
				}
				pa_cpt=std.conv.toInt(res[pos..pos + pos2]);
				pos+= pos2;
				if( res[pos..pos + 2] != ":\"" ) throw new Exception(std.string.toString(__LINE__)); //"
				pos+= 2;
				pa=res[pos..pos + pa_cpt];
				pos+= pa_cpt;
				if( res[pos..pos + 2] != "\";" ) throw new Exception(std.string.toString(__LINE__));
				pos+= 2;
				//writefln("bot_base : debug line %d : access => '%s' : '%s'", __LINE__, ps, pa);
				replace_access(serveur,salon,ps,pa);
			}
			return true;
		}
		return false;
	}
	catch(FileException e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
	catch(Exception e) {
		writefln("bot_base : "~ std.string.toString(__LINE__));
		writefln(e.msg);
		return false;
	}
}

Date conv(d_time time) {
	DateParse dp;
	Date d;
	d.year=std.date.YearFromTime(time);
	d.month=std.date.MonthFromTime(time);
	d.day=std.date.DateFromTime(time);
	d.weekday=std.date.WeekDay(time);
	d.hour=std.date.HourFromTime(time);
	d.minute=std.date.MinFromTime(time);
	d.second=std.date.SecFromTime(time);
	d.ms=std.date.msFromTime(time);
	d.tzcorrection=getLocalTZA()/msPerHour;
	return d;
}

void show(d_time time) {
	writefln("%s",toString(time));
}

void show(Date d) {
	writefln("%s",toString(d));
}

char[] toString(d_time d) {
	Date date=conv(d);
	return toString(date);
}

char[] toString(Date d) {
	return std.string.format("%02d/%02d/%04d %02d:%02d:%02d.%03d",d.day,d.month,d.year,d.hour,d.minute,d.second,d.ms);
}

int really_do_nothing(char c) {
	//Thread.getThis.pause();
	Thread.getThis.yield();
	return 0;
}

int do_nothing(char c) {
	char s;
	while(th_run){ s=c; }
	return 1;
}

char[] get_ip() {
	char[][uint] reponse=get_url_ar("checkip.dyndns.org", 80, "/");
	//foreach(char[] str;reponse) {
	//writefln(reponse.length);
	writefln("bot_base : "~ std.string.toString(__LINE__));
	if(reponse.length>=1) {
		int find=std.string.find(reponse[0], ":");
		if(find>0) {
			char[] response2=reponse[0][find+2..$];
			find=std.string.find(response2, "<");
			if(find>0) {
				char[] response3=response2[0..find];
				return response3;
				/*response= "PRIVMSG " ~ response2 ~ " :"~response3~ "\n";
				send(response);
				return true;*/
			}
			else {
				writefln("bot_base : "~ std.string.toString(__LINE__));
			}
		}
		else {
			writefln("bot_base : "~ std.string.toString(__LINE__));
		}
	}
	else {
		writefln("bot_base : "~ std.string.toString(__LINE__));
	}
	return "";
}

char[][uint] get_url_ar(char[] host, uint port, char[] path) {
	char[][uint] result;
	uint cpt=0;
	
	// open a socket:
	InternetHost ih = new InternetHost;
	ih.getHostByName(host);
	InternetAddress ia = new InternetAddress(ih.addrList[0], port);
	TcpSocket sock = new TcpSocket();
	sock.connect(ia);
	
	// send the HTTP request
	sock.send("GET " ~ path ~ " HTTP/1.0\n");
	sock.send("Host: " ~ host ~ "\n\n");
	
	// read and print the result:
	char[] line;
	SocketStream stream = new SocketStream(sock);
	while (! stream.eof()) {
		line = stream.readLine();
		if (line=="") break;
		//result[cpt++]=line;
		printf ("%s\n", toStringz(line));
	}
	while (! stream.eof()) {
		line = stream.readLine();
		if (line=="") break;
		result[cpt]= null;
		result[cpt]=line;
		cpt++;
		printf ("%s\n", toStringz(line));
	}
	return result;
}

char[] get_url(char[] host, uint port, char[] path) {
	char[] result;
	uint cpt=0;
	
	// open a socket:
	InternetHost ih = new InternetHost;
	ih.getHostByName(host);
	InternetAddress ia = new InternetAddress(ih.addrList[0], port);
	TcpSocket sock = new TcpSocket();
	sock.connect(ia);
	
	// send the HTTP request
	sock.send("GET " ~ path ~ " HTTP/1.0\n");
	sock.send("Host: " ~ host ~ "\n\n");
	
	// read and print the result:
	char[] line;
	SocketStream stream = new SocketStream(sock);
	while (! stream.eof()) {
		line = stream.readLine();
		if (line=="") break;
		result~=line~ "\r\n";
		printf ("%s\n", toStringz(line));
	}
	return result;
}

bool replace_command(char[] serveur,char[] salon,char[] commande,int index,char[] cmd,int mode,char[] cmd2) {
	bool res=del_command(serveur,salon,commande,index);
	if(!res) writefln("bot_base line %d commande inexistante ",__LINE__);
	return add_command(serveur,salon,commande,index,cmd,mode,cmd2);
}

bool add_command(char[] serveur,char[] salon,char[] commande,int index,char[] cmd,int mode,char[] cmd2) {
	if(index>=0) {
		if((serveur in commandes)==null) commandes[serveur]=null;
		if((salon in commandes[serveur])==null) commandes[serveur][salon]=null;
		if((commande in commandes[serveur][salon])==null) commandes[serveur][salon][commande]=null;
		if((index in commandes[serveur][salon][commande])==null) {
			commandes[serveur][salon][commande][index]=tuple!(char[],int,char[])(cmd,mode,cmd2);
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}

bool add_access(char[] serveur,char[] salon,char[] nick,char[] password) {
	if((serveur in access)==null) access[serveur]=null;
	if((salon in access[serveur])==null) access[serveur][salon]=null;
	if((nick in access[serveur][salon])==null) {
		access[serveur][salon][nick]=password;
		return true;
	}
	else {
		return false;
	}
}

bool replace_access(char[] serveur,char[] salon,char[] nick,char[] password) {
	bool res=del_access(serveur,salon,nick);
	if(!res) writefln("bot_base line %d access inexistant ",__LINE__);
	return add_access(serveur,salon,nick,password);
}

bool del_access(char[] serveur,char[] salon,char[] nick) {
	if((serveur in access)==null) return false;
	if((salon in access[serveur])==null) return false;
	if((nick in access[serveur][salon])==null) return false;
	access[serveur][salon].remove(nick);
	return true;
}

bool del_access(char[] serveur,char[] salon) {
	if((serveur in access)==null) return false;
	if((salon in access[serveur])==null) return false;
	access[serveur].remove(salon);
	/*foreach(char[] str;access[serveur][salon].keys) {
		access[serveur][salon].remove(str);
	}*/
	return true;
}

bool del_access(char[] serveur) {
	if((serveur in access)==null) return false;
	access.remove(serveur);
	/*foreach(char[] str;access[serveur].keys) {
		access[serveur].remove(str);
	}*/
	return true;
}

bool del_command(char[] serveur,char[] salon,char[] commande,int index) {
	if((serveur in commandes)==null) return false;
	if((salon in commandes[serveur])==null) return false;
	if((commande in commandes[serveur][salon])==null) return false;
	if((index in commandes[serveur][salon][commande])==null) return false;
	commandes[serveur][salon][commande].remove(index);
	return true;
}

bool del_command(char[] serveur,char[] salon,char[] commande) {
	if((serveur in commandes)==null) return false;
	if((salon in commandes[serveur])==null) return false;
	if((commande in commandes[serveur][salon])==null) return false;
	commandes[serveur][salon].remove(commande);
	/*foreach(int i;commandes[serveur][salon][commande].keys) {
		//del_command(serveur,salon,commande,i);
		commandes[serveur][salon][commande].remove(i);
	}*/
	return true;
}

bool del_command(char[] serveur,char[] salon) {
	if((serveur in commandes)==null) return false;
	if((salon in commandes[serveur])==null) return false;
	commandes[serveur].remove(salon);
	/*foreach(char[] str;commandes[serveur].keys) {
		//del_command(serveur,str);
	}*/
	return true;
}

bool del_command(char[] serveur) {
	if( commandes == null ) return false;
	commandes.remove(serveur);
	/*foreach(char[] str;commandes.keys) {
		del_command(str);
	}*/
	return true;
}

char[][uint] list_command(char[] serveur, char[] salon, bool full= false) {
	if( (serveur in commandes)==null || (salon in commandes[serveur])==null ) return null;
	char[][uint] res;
	uint cpt;
	foreach(char[] str;commandes[serveur][salon].keys) {
		if(full) {
			res[cpt]= "\2"~ str~ "\2 :\r\n";
			foreach(int index; commandes[serveur][salon][str].keys) {
				res[cpt]~= str~ " "~ std.string.toString(index)~ " : "~ commandes[serveur][salon][str][index].value[0]~ " : ";
				res[cpt]~= std.string.toString(commandes[serveur][salon][str][index].value[1])~ " : ";
				res[cpt]~= commandes[serveur][salon][str][index].value[2]~ "";
				res[xpt]~= "\r\n";
			}
		}
		else {
			res[cpt]= "\2" ~str~ "\2";
		}
		cpt++;
	}
	return res;
}

char[][uint] list_access(char[] serveur, char[] salon, bool full= false) {
	if( (serveur in access)==null || (salon in access[serveur])==null ) return null;
	char[][uint] res;
	uint cpt;
	foreach(char[] str;access[serveur][salon].keys) {
		if(full) {
			res[cpt]=str~ " : "~access[serveur][salon][str];
		}
		else {
			res[cpt]=str;
		}
		cpt++;
	}
	return res;
}

char[] latin1_to_unicode(ubyte[] str) {
	char[] res;
	foreach(ubyte c; str) {
		if (c <= 0x7F)
			res ~= cast(char) c;
		else
			std.utf.encode(res, cast(dchar) c);
	}
	return res;
}

char[] latin1_to_unicode(char[] str) {
	return latin1_to_unicode(cast(ubyte[])str);
}

long ip2long(char[] ip) {
	char[] tmp,tmp2;
	long res;
	tmp=ip;
	tmp2=tmp[0..std.string.find(tmp,".")];
	res=std.conv.toLong(tmp2)*256*256*256;
	tmp=ip[tmp2.length+1..$];
	tmp2=tmp[0..std.string.find(tmp,".")];
	res+=std.conv.toLong(tmp2)*256*256;
	tmp=ip[ip.length-tmp.length+tmp2.length+1..$];
	tmp2=tmp[0..std.string.find(tmp,".")];
	res+=std.conv.toLong(tmp2)*256;
	tmp=ip[ip.length-tmp.length+tmp2.length+1..$];
	res+=std.conv.toLong(tmp);
	return res;
}

char[] long2ip(long ip) {
	char[] res;
	long tmp=ip;
	res=std.string.toString(tmp/256/256/256);
	tmp-=(tmp/256/256/256)*256*256*256;
	res~=".";
	res~=std.string.toString(tmp/256/256);
	tmp-=(tmp/256/256)*256*256;
	res~=".";
	res~=std.string.toString(tmp/256);
	tmp-=(tmp/256)*256;
	res~=".";
	res~=std.string.toString(tmp);
	tmp-=(tmp);
	assert(tmp==0);
	return res;
}

//int thread2 (int test);

import dcc_chat;
import small_irc_bot;
