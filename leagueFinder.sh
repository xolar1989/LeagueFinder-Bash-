#!/bin/bash -f 



PROGRAM_NAME="League Finder"

OPTION="nothing"

LIGA=""

LIGALEN=(20 18 18 20 20 20 24)

MAXMATCHES=0

LIGACODE=""

LIGAINDEX=2137 


AUTHTOKEN="1737f923086d413e92ad62f9f4e37e52"
URL="https://api.football-data.org/v2/competitions"

# Premier League "PL"
# Eredivisie "DED"
# Bundesliga "BL1"
# Ligue 1 "FL1"
# Seria A "SA"
# La Liga "PD"
# Championship "ELC"



# tabela
DATATABLE=()
# tabela

# strzelcy
DATASCORERS=()
# strzelcy

# terminarz
DATAMATCHES=()
#terminarz


usun(){
	DATATABLE=()
	DATASCORERS=()
	DATAMATCHES=()
	LIGACODE=""

}


pobierz(){

	local URLTMP="${URL}/${LIGACODE}/standings "
	local URLSCORERS="${URL}/${LIGACODE}/scorers "

	echo -n > test.json 
	echo -n > test2.json 

	curl -s   -H "accept: application/json" -H "X-Auth-Token: $AUTHTOKEN" -H "Content-Type: application/json"  ${URLTMP}  >> test.json 
	curl -s   -H "accept: application/json" -H "X-Auth-Token: $AUTHTOKEN" -H "Content-Type: application/json"  ${URLSCORERS}  >> test2.json 
	local t=0

	MAXMATCHES=$(((LIGALEN[$LIGAINDEX]*2) - 2 ))

	for (( i = 0; i < ${LIGALEN[$LIGAINDEX]}; i++ )); 
	do

		
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].position ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].team.name ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].playedGames ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].won ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].draw ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].lost ")
		t=$((t+1))
		DATATABLE[$t]=$(cat test.json | jq ".standings[0].table[$i].points ")
		t=$((t+1))
	done

	local j=0

	for (( i = 0; i < 10; i++ )); do
		DATASCORERS[$j]=$((i+1))
		j=$((j+1))
		DATASCORERS[$j]=$(cat test2.json | jq ".scorers[$i].player.name" )
		j=$((j+1))
		DATASCORERS[$j]=$(cat test2.json | jq ".scorers[$i].team.name" )
		j=$((j+1))
		DATASCORERS[$j]=$(cat test2.json | jq ".scorers[$i].numberOfGoals" )
		j=$((j+1))
	done

}


checkLige(){
	usun

	if [ "$LIGA" == "PREMIER LEAGUE" ]; then
		LIGACODE="PL"
		LIGAINDEX=0
	elif [ "$LIGA" == "EREDIVISIE" ]; then
		LIGACODE="DED"
		LIGAINDEX=1
	elif [ "$LIGA" == "BUNDESLIGA" ]; then
		LIGACODE="BL1"
		LIGAINDEX=2
	elif [ "$LIGA" == "LIGUE" ]; then
		LIGACODE="FL1"
		LIGAINDEX=3
	elif [ "$LIGA" == "SERIA A" ]; then
		LIGACODE="SA"
		LIGAINDEX=4
	elif [ "$LIGA" == "LA LIGA" ] ; then
		LIGACODE="PD"
		LIGAINDEX=5
	elif [ "$LIGA" == "CHAMPIONSHIP" ] ; then
		LIGACODE="ELC"
		LIGAINDEX=6
	fi


	if [[ -n $LIGACODE ]]; then
		pobierz
	fi

	echo $LIGACODE 
}


table(){
	zenity --text ""  --list --column="Pos"  --column="Klub" --column="RM" --column="W" --column="R" --column="P"   --column="Pkt"  "${DATATABLE[@]}"    --width 550 --height 300 --title "$PROGRAM_NAME" --cancel-label "Wstecz" --ok-label "Dalej"
}

tableScorers(){
	zenity --text ""  --list --column="Pos"  --column="Piłkarz" --column="KLub" --column="Gole"   "${DATASCORERS[@]}"    --width 600 --height 300 --title "$PROGRAM_NAME" --cancel-label "Wstecz" --ok-label "Dalej"

}

schedule(){
	local KOLEJKA=2137
	KOLEJKA=`zenity --entry --title "Wybór Kolejki" --text "Podaj numer interesującej cię kolejki : "`

	if [ $KOLEJKA -le $MAXMATCHES ] && [ $KOLEJKA -gt 0 ]  ; then
		DATAMATCHES=()
		local URLMATCHES="${URL}/${LIGACODE}/matches?matchday=${KOLEJKA}"

		echo -n > test3.json 

		curl -s   -H "accept: application/json" -H "X-Auth-Token: $AUTHTOKEN" -H "Content-Type: application/json"  ${URLMATCHES}  >> test3.json 

		local j=0
		for (( i = 0; i < $((${LIGALEN[$LIGAINDEX]}/2 )); i++ )); do
			DATAMATCHES[$j]=$(cat test3.json | jq ".matches[$i].utcDate" | cut -d 'T' -f 1 | cut -d '"' -f 2 ) 
			j=$((j+1))
			DATAMATCHES[$j]=$(cat test3.json | jq ".matches[$i].homeTeam.name" )
			j=$((j+1))
			DATAMATCHES[$j]=$(cat test3.json | jq ".matches[$i].awayTeam.name")
			j=$((j+1))
			DATAMATCHES[$j]=$(cat test3.json | jq ".matches[$i].score.fullTime.homeTeam" )
			if [ "${DATAMATCHES[${j}]}" == "null"  ]; then
				DATAMATCHES[$j]="-"
			fi
			j=$((j+1))
			DATAMATCHES[$j]=$(cat test3.json | jq ".matches[$i].score.fullTime.awayTeam" )
			if [ "${DATAMATCHES[${j}]}" == "null" ]; then
				DATAMATCHES[$j]="-"
			fi
			j=$((j+1))
		done

		zenity --text ""   --list --column="Date"  --column="Gospodarz" --column="Gość" --column=" " --column=" " "${DATAMATCHES[@]}"    --width 650 --height 300 --title "Kolejka $KOLEJKA"  --cancel-label "Wstecz" --ok-label "Dalej"


	elif [ $KOLEJKA -gt $MAXMATCHES ]; then
		zenity --info --title "$PROGRAM_NAME" --text "Ilość kolejek do wybrania : $MAXMATCHES" --width 250
	fi

}



options(){ 
	if [[ -n $LIGA ]]; 
	then
		if [[ -n $LIGACODE   ]] ; then
			OPTION=`zenity --text ""  --list --column=Menu "${MENU[@]}" --width 300 --height 240 --title "$PROGRAM_NAME" --cancel-label "Wyjdź" --ok-label "Dalej"  `
		else
			OPTION=`zenity --text "Nie poprawna nazwa ligi"  --list --column=Menu "${MENU[0]}" --width 300 --height 240 --title "$PROGRAM_NAME" --cancel-label "Wyjdź" --ok-label "Dalej"  `	
		fi

	else
		OPTION=`zenity --text "Najpierw musisz wpisać Lige"  --list --column=Menu "${MENU[0]}" --width 300 --height 240 --title "$PROGRAM_NAME" --cancel-label "Wyjdź" --ok-label "Dalej"  `
	fi
	
}

KONIEC(){
	 zenity --question --text "Jesteś pewien że chcesz wyjść ?" --no-wrap --title ""
	 if [[ $? = 0  ]]; then
	 	
	 	OPTION="QUIT"
	 	
	 fi
}




while [ "$OPTION" != "QUIT" ]; do
	MENU=("Liga 		$LIGA" "Tabela" "Lista Strzelców" "Terminarz")
	clear
	options

	echo $LIGACODE 
	case $OPTION in
		"Liga "*) LIGA=`zenity --entry --title "Wybór Ligi" --text "Podaj Nazwe Ligi : "`
				  LIGA=$(echo $LIGA | tr a-z A-Z) 
				  checkLige		;;
		"Tabela"*) table;;
		"Lista "*) tableScorers  ;;
		"Termi"*) schedule ;;
		*) KONIEC ;;
		
	esac

	
	
clear
	


	
done


