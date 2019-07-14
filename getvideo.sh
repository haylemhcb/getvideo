#!/bin/bash


enlace=""
tit=""
CTEMP=`mktemp -d`
DESCARGASGETVIDEO="DESCARGASGETVIDEO" 
mkdir $DESCARGASGETVIDEO

function uso(){
  echo
  echo "Programa creado por Haylem Candelario Bauza"
  echo
  exit
}


function muestratit(){
 while [ 1 ];do
 sleep 3
 clear
 tit=$1
  echo "*** BUSCANDO VIDEOS $tit ***"
  echo

  wget --no-cache -c  --user-agent="Mozilla"  --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 5 -w 5 --random-wait --retry-connrefused --no-check-certificate  "http://www.youtube.com/results?search_query=$1&max-results=40" -O $CTEMP/sy
  cat $CTEMP/sy|grep " Duration:"|tr "[" "X"|tr "]" "X"|tr "!" "o"|tr "$" "o"|tr "." "o">$CTEMP/sy
  cat $CTEMP/sy|grep "watch"

 if [ $? -ne 0 ];then
 echo "Error  buscando videos."
 sleep 1
 continue
 fi

 clear
 echo
 echo "Algunos videos disponibles:"
 echo "==========================="
 echo
 cat $CTEMP/sy|grep " Duration: "|cut -d">" -f4|cut -d"=" -f7|cut -d"\"" -f2

 break
 done
}


function dvid(){
 echo "https://www.youtube.com"`cat $CTEMP/sy|grep "\"$1\"" |grep " Duration: "|cut -d"\"" -f6|uniq`>$CTEMP/enlace
 enlace=`cat $CTEMP/enlace`
 echo "Enlace a descargar $enlace"
}

if [ "$1" == "-h" ];then
  uso
  exit
fi

  
function descyoutubeqmedia(){

 echo "                Teclee una palabra o frase para buscar en youtube:"
 echo
 echo -n "                -> "
 read frase
 clear

  frase=`echo "$frase"|tr " " "+"`
  echo "Consulta enviada $frase"

  muestratit "$frase"

  echo
  echo  "Escriba el titulo que desea descargar"
  echo -n "> "
  read tit

  if [ -z "$tit" ];then
   exit
  fi

  dvid "$tit"

 while [ 1 ];do
 sleep 3
 clear

   echo "Descargando enlace $enlace autodetectado..."
   wget --no-cache --user-agent="Mozilla" --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 5 -w 5 --random-wait --retry-connrefused --no-check-certificate --no-hsts "http://www.savido.net/download?url=$enlace" -O $CTEMP/pag.html

 if [ $? -ne 0 ];then
  echo "Error de descarga"
  continue
 fi

 urlenc=`cat $CTEMP/pag.html |grep "(medium)"|cut -d "<" -f2|grep -v " (medium)"|cut -d"\"" -f2`

 if [ -z "$urlenc"  ];then
  echo "Enlace no obtenido, puede que esta calidad no se encuentre..."
  continue
 fi

 echo "Enlace detectado"
 echo
 echo "$urlenc"

 echo $urlenc>$CTEMP/url
 sed -i 's/amp;/ /g' "$CTEMP/url"
 cat $CTEMP/url |tr " " "\0">$CTEMP/url2
 ampersandurl=`cat $CTEMP/url2`
 titulo=`cat $CTEMP/pag.html |grep "<title>"|cut -d "<" -f2|uniq|cut -d"-" -f2|tr " " "_"`
 sed -i 's/mime=video%2F/*/g' "$CTEMP/url2"
 formato=`cat $CTEMP/url2|cut -d "*" -f2|cut -d"&" -f1`

 echo "Descargando video real..."
 wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused  $ampersandurl  -O $DESCARGASGETVIDEO/$titulo.$formato

 if [ $? -ne 0  ];then
  echo "Interrupcion de descarga, reintentando..."
  sleep 2
  continue
 fi


 mplayer /usr/share/sounds/gnome/default/alerts/bark.ogg
 mplayer /usr/share/sounds/gnome/default/alerts/bark.ogg
 rm -rv $CTEMP
 exit
 done
}

function descyoutubelink(){
   echo
   echo "                Teclee o pegue el enlace watch del video de youtube:"
   echo
   echo -n "                -> "
   read LWATCH
 
   while [ 1 ];do
   sleep 3
   clear

    echo "Enviando enlace manual $LWATCH"
    wget --no-cache  --user-agent="Mozilla" --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 5 -w 5 --random-wait --retry-connrefused --no-check-certificate --no-hsts  "http://www.savido.net/download?url=$LWATCH" -O $CTEMP/pag.html

 if [ $? -ne 0 ];then
  echo "Error de descarga enlace watch"
  continue
 fi

 urlenc=`cat $CTEMP/pag.html |grep "(medium)"|cut -d "<" -f2|grep -v " (medium)"|cut -d"\"" -f2`

 if [ -z "$urlenc"  ];then
  echo "Enlace no obtenido, puede que esta calidad no se encuentre..."
  continue
 fi

 echo "Enlace detectado"
 echo
 echo "$urlenc"

 echo $urlenc>$CTEMP/url
 sed -i 's/amp;/ /g' "$CTEMP/url"
 cat $CTEMP/url |tr " " "\0">$CTEMP/url2
 ampersandurl=`cat $CTEMP/url2`
 titulo=`cat $CTEMP/pag.html |grep "<title>"|cut -d "<" -f2|uniq|cut -d"-" -f2|tr " " "_"`
 sed -i 's/mime=video%2F/*/g' "$CTEMP/url2"
 formato=`cat $CTEMP/url2|cut -d "*" -f2|cut -d"&" -f1`

 echo "Descargando video real..."
 wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused  $ampersandurl  -O $DESCARGASGETVIDEO/$titulo.$formato

 if [ $? -ne 0  ];then
  echo "Interrupcion de descarga, reintentando..."
  sleep 2
  continue
 fi


 mplayer /usr/share/sounds/gnome/default/alerts/bark.ogg
 mplayer /usr/share/sounds/gnome/default/alerts/bark.ogg
 rm -rv $CTEMP
 exit

  done
}

function descfile(){
   echo
   echo "                Teclee o pegue el enlace URL del archivo:"
   echo
   echo -n "                -> "
   read LF

  clear
  while [ 1 ];do
    echo "DESCARGABDO ENLACE $LF"
   wget --user-agent=Mozilla -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused --directory-prefix="DESCARGASGETVIDEO/" "$LF"

   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    continue
    fi

     rm -rv $CTEMP
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
    exit

  done

}

function descapkpure(){
   echo
   echo "                Teclee una frase o nombre de programa ANDROID:"
   echo
   echo -n "                -> "
   read APK
   echo "                BUSCANDO PROGRAMA  $APK..."
   echo
   echo

  APK=`echo $APK|tr " " "+"`
  while [ 1 ];do
   echo "DESCARGABDO PAGINA APKPURE $APK en $CTEMP"
   wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "www.apkpure.com/es/search?q=$APK" -O $CTEMP/apkpure.html
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done

cat $CTEMP/apkpure.html|grep dt|grep -v div|grep -v link|grep -v class|grep -v "margin:"|grep -v "display:"|cut -d"=" -f2|cut -d '"' -f2|tr " " "_"|tr ":" "_"|tr '&' "_"|tr '|' "_">$CTEMP/titulos
 sed -i 's/amp;/ /g' "$CTEMP/titulos"
cat $CTEMP/apkpure.html|tr " " "_"|tr ":" "_"|tr '&' "_"|tr '|' "_">$CTEMP/apkpure_f.html


    echo "Algunas aplicaciones disponibles:"
    echo "==========================="
    echo
    cat $CTEMP/titulos

    echo
    echo  "Escriba el titulo que desea descargar"
    echo -n "> "
    read tapk

   if [ -z "$tapk" ];then
    exit
   fi

   enlace1=`cat $CTEMP/apkpure_f.html |grep $tapk|cut -d"\"" -f6|cut -d"_" -f1`
   enlace1=`echo http://apkpure.com$enlace1`

   echo "ANALIZANDO ENLACE BUSCADO $APK $enlace1"

   while [ 1 ];do
   echo "DESCARGABDO SUBENLACE1 BUSCADO $APK en $CTEMP"
   wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "$enlace1" -O $CTEMP/subenlace1.html
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done

 subenlace1=`cat $CTEMP/subenlace1.html|tr " " "_"|grep "download?from=details"|grep fsize|cut -d"\"" -f6`
 subenlace1=`echo http://apkpure.com$subenlace1`
 echo "DESCARGANDO SUBENLACE2 $APK $subenlace1"

   while [ 1 ];do
   echo "DESCARGABDO SUBENLACE2 BUSCADO $APK en $CTEMP"
   wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "$subenlace1" -O $CTEMP/subenlace2.html
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done

 #Obtiene enlace real apk
 enlace=`cat $CTEMP/subenlace2.html |grep "Clic aqu" |cut -d"\"" -f12`


   while [ 1 ];do
   echo "DESCARGANDO APLICACION REAL $tapk"
   wget --no-cache --user-agent="Mozilla" -c --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "$enlace" -O "$DESCARGASGETVIDEO/$tapk.apk"
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done

 rm -rv $CTEMP
   
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
     mplayer /usr/share/sounds/gnome/default/alerts/sonar.ogg
     exit
   
}

function buscarevolico(){
   echo
   echo "                Teclee una frase para buscar en revolico:"
   echo
   echo -n "                -> "
   read AN
   echo "                BUSCANDO ANUNCIO  $AN..."
   echo
   echo

  AN=`echo $AN|tr " " "+"`

  while [ 1 ];do
   echo "DESCARGABDO PAGINA REVOLICO $AN en $CTEMP"
   wget --no-cache --user-agent="Mozilla"  --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "https://www.revolico.com/search.html?q=$AN" -O $CTEMP/revolico.html
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done
 sed -i 's/amp;/ /g' "$CTEMP/revolico.html"
 sed -i 's/cute;/ /g' "$CTEMP/revolico.html"
 sed -i 's/quot;/ /g' "$CTEMP/revolico.html"
 sed -i 's/tilde;/ /g' "$CTEMP/revolico.html"
 sed -i 's/ordf;/ /g' "$CTEMP/revolico.html"


 cat $CTEMP/revolico.html|grep "</a>"|grep -v "javascript"|grep -v "href"|grep -v style|grep -v "|<"|grep -v ">>"|grep -v "<a>Buscando"|grep -v "<a"|cut -d "<" -f1>$CTEMP/filtrado1


  clear
    echo "Algunos anuncios disponibles:"
    echo "==========================="
    echo
    cat $CTEMP/filtrado1

    echo
    echo  "Escriba o pegue el titulo del anuncio a ver"
    echo -n "> "
    read tan

   if [ -z "$tan" ];then
    exit
   fi


   enlace=`echo "http://www.revolico.com"``cat $CTEMP/revolico.html |grep "$tan" -B4|grep "<a href=\"/"|cut -d"\"" -f2`

   echo "ANALIZANDO ENLACE BUSCADO $AN $enlace"
   while [ 1 ];do
   echo "DESCARGANDO ANUNCIO REAL $enlace"
   wget --no-cache --user-agent="Mozilla"  --dns-timeout 10 --connect-timeout 10 --read-timeout 10 -t 20 -w 5 --random-wait --retry-connrefused "$enlace" -O "$CTEMP/anuncio.html"
   if [ $? -ne 0  ];then
    echo "Interrupcion de descarga, reintentando..."
    sleep 2
    clear
    continue
    fi
      break
  done
 clear
  cat $CTEMP/anuncio.html|grep showAdText -A24|cut -d"\"" -f3|grep -v "class="
  echo
  echo "Presiona enter para salir"
  read x

}

function menu(){
  clear
  echo
  echo "               ******************************************"
  echo "               *                                        *"
  echo "               *          DESCARGADOR UNIVERSAL         *"
  echo "               *                  DE                    *"
  echo "               *            VIDEOS/ARCHIVOS             *"
  echo "               *  CREADO POR HAYLEM CANDELARIO BAUZA    *"
  echo "               *       LICENCIA GPLv2 O POSTERIOR       *"
  echo "               *                                        *"
  echo "               *          SOFTWARE LIBRE CUBA 2019      *"
  echo "               *                                        *"
  echo "               ******************************************"

  echo
  echo "                [ SELECCIONE UNA OPCION A CONTINUACION ]"
  echo
  echo
  echo "                1-) BUSCAR Y DESCARGAR VIDEOS DE YOUTUBE"
  echo "                2-) DESCARGAR VIDEOS DE YOUTUBE DESDE LINK WATCH"
  echo "                3-) DESCARGAR ARCHIVO DE LA RED."
  echo "                5-) DESCARGAR APLICACIONES ANDROID APK EN APKPURE."
  echo "                6-) BUSCAR EN REVOLICO."
  echo
  echo "                0-) SALIR"
  echo
  echo -n "                -> "
  read OP

  if [ -z "$OP" ];then
    echo
    echo "SALIENDO..."
    exit
  fi

  if [ "$OP" == "0" ];then
    echo
    echo "SALIENDO..."
    exit
  fi

  if [ "$OP" == "1" ];then
    echo
    descyoutubeqmedia
  fi

  if [ "$OP" == "2" ];then
    echo
    descyoutubelink
  fi

  if [ "$OP" == "3" ];then
    echo
    descfile
  fi

  if [ "$OP" == "5" ];then
    echo
    descapkpure
  fi

  if [ "$OP" == "6" ];then
    echo
    buscarevolico
  fi
}


menu
