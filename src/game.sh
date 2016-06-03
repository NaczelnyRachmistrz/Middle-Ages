#!/bin/bash
MAXINT=2147483647
#Argumenty ustawione na domyślne wartości
n=10
k=100
s=1
p1x=-1
p1y=-1
p2x=-1
p2y=-1
ai1=-human1
ai2=-human2

distance () 
{
	pom1=$(($3-$1));
	if (( $pom1 < 0 )); then
		pom1=$((pom1*(-1)))
	fi
	pom2=$(($4-$2));
	if (( $pom2 < 0 )); then
		pom2=$((pom2*(-1)))
	fi
	if (( $pom1 < $pom2 )); then
		echo $pom2
	else
		echo $pom1
	fi
}

kill_ai ()
{	
	if kill -0 $ai1_pid 2>/dev/null >/dev/null; then
		kill $ai1_pid 2>/dev/null >/dev/null
	fi
	if kill -0 $ai2_pid 2>/dev/null >/dev/null; then
		kill $ai2_pid 2>/dev/null >/dev/null
	fi
}

kill_ai_hum ()
{	
	if kill -0 $ai_pid 2>/dev/null >/dev/null; then
		kill $ai_pid 2>/dev/null >/dev/null
	fi
}

swap_in_out_pid () 
{	
	temp_pid=$curr_pid; curr_pid=$wait_pid; wait_pid=$temp_pid
	temp_in=$curr_in; curr_in=$wait_in; wait_in=$temp_in
	temp_out=$curr_out; curr_out=$wait_out; wait_out=$temp_out
}

#Parsowanie argumentów, sprawdzanie poprawności wejścia
while [ $# -ne 0 ]; do
	case $1 in
		"-n"|"-k"|"-s")
			case $2 in
				''|*[!0-9]*)
					exit 1;;
			esac
			case $1 in
				"-n")
					shift
					if (( $1 < 9 )) || (( $1 > $MAXINT )); then
						exit 1
					fi
					n="$1";;
				"-k")
					shift
					if (( $1 < 1 )) || (( $1 > $MAXINT )); then
						exit 1
					fi
					k="$1";;
				"-s")
					shift
					if (( $1 < 0 )) || (( $1 > $MAXINT )); then
						exit 1
					fi
					s="$1";;
			esac;;
		"-p1"|"-p2")
			if [[ $2 =~ ^[1-9][0-9]*[,][1-9][0-9]* ]]; then
					if [ $1 == "-p1" ]; then
						shift
						p1x=${1%,*}
						p1y=${1##*,}
					else
						shift
						p2x=${1%,*}
						p2y=${1##*,}		
					fi
			else
					exit 1
			fi;;
		"-ai1"|"-ai2")
			if [ -x "$2" ]; then
				if [ $1 == "-ai1" ]; then
					shift
					ai1=$1
				else
					shift
					ai2=$1
				fi
			else
				exit 1
			fi;;
		*)
			exit 1;;
	esac
	shift
done
#Sprawdzanie poprawności pozycji króla obojga graczy, jeśli podana
if (( p1x != -1 )) && (( p2x != -1 )); then
	if (( p1x > n-3 )) || (( p1y > n )) || (( p2x > n-3 )) || (( p2y > n )); then
		exit 1
	else
		temp=$(distance p1x p1y p2x p2y)
		if (( temp < 8 )); then
			exit 1
		fi
	fi
elif (( p1x != -1)); then #Jeżeli tylko jedna pozycja jest podana, sprawdzamy czy można wylosować drugą, jeśli tak - losujemy
	if (( p1x > n-3 )) || (( p1y > n )); then
		exit 1
	fi
	if (( p1x < 9 )) && (( p1x > n - 11)) && (( p1y < 9 )) && (( p1y > n - 8)); then
		exit 1
	fi
	temp=0
	while (( temp < 8 )); do
		p2x=$RANDOM
		((p2x %= (n-3)))
		((p2x += 1))
		p2y=$RANDOM
		((p2y %= (n)))
		((p2y += 1))		
		temp=$(distance p1x p1y p2x p2y)
	done
elif (( p2x != -1)); then
	if (( p2x > n-3 )) || (( p2y > n )); then
		exit 1
	fi
	if (( p2x < 9 )) && (( p2x > n - 11)) && (( p2y < 9 )) && (( p2y > n - 8)); then
		exit 1
	fi
	temp=0
	while (( temp < 8 )); do
		p1x=$RANDOM
		((p1x %= (n-3)))
		((p1x += 1))
		p1y=$RANDOM
		((p1y %= (n)))
		((p1y += 1))		
		temp=$(distance p1x p1y p2x p2y)
	done
else #Jeżeli żadna pozycja nie jest podana - losujemy pozycje obu królów do skutku - szansa,
	temp=0 # że po kilkudziesięciu losowaniach nie wylusujemy dobrej pozycji startowej jest znikoma
	while (( temp < 8 )); do
		p1x=$RANDOM
		((p1x %= (n-3)))
		((p1x += 1))
		p1y=$RANDOM
		((p1y %= (n)))
		((p1y += 1))
		p2x=$RANDOM
		((p2x %= (n-3)))
		((p2x += 1))
		p2y=$RANDOM
		((p2y %= (n)))
		((p2y += 1))		
		temp=$(distance p1x p1y p2x p2y)
	done
fi
PIPE=$(mktemp -u); mkfifo $PIPE; exec 3<>$PIPE; rm $PIPE
PIPE=$(mktemp -u); mkfifo $PIPE; exec 4<>$PIPE; rm $PIPE
if [ "$ai1" == "-human1" ] && [ "$ai2" == "-human2" ]; then
	./sredniowiecze_gui_with_libs.sh -human1 -human2 <&3 >&4 &
	gui_pid=$!
	echo "INIT $n $k 1 $p1x $p1y $p2x $p2y" >&3
	echo "INIT $n $k 2 $p1x $p1y $p2x $p2y" >&3
	wait $gui_pid
elif [ "$ai1" != "-human1" ] && [ "$ai2" != "-human2" ]; then
	PIPE2=$(mktemp -u); mkfifo $PIPE2; exec 5<>$PIPE2; rm $PIPE2
	PIPE2=$(mktemp -u); mkfifo $PIPE2; exec 6<>$PIPE2; rm $PIPE2
	PIPE3=$(mktemp -u); mkfifo $PIPE3; exec 7<>$PIPE3; rm $PIPE3
	PIPE3=$(mktemp -u); mkfifo $PIPE3; exec 8<>$PIPE3; rm $PIPE3
	./sredniowiecze_gui_with_libs.sh <&3 >&4 &
	gui_pid=$!
	
	echo "INIT $n $k 1 $p1x $p1y $p2x $p2y" >&3
	echo "INIT $n $k 2 $p1x $p1y $p2x $p2y" >&3
	$ai1 <&5 >&6 &
	ai1_pid=$!
	$ai2 <&7 >&8 &
	ai2_pid=$!
	echo "INIT $n $k 1 $p1x $p1y $p2x $p2y" >&5
	if !(kill -0 $ai1_pid); then
		exit 1;
	fi
	echo "INIT $n $k 2 $p1x $p1y $p2x $p2y" >&7
	if !(kill -0 $ai2_pid); then
		exit 1;
	fi
	curr_pid=$ai1_pid; wait_pid=$ai2_pid;
	gui_in=3; curr_out=6; curr_in=7; wait_out=8; wait_in=5;
	(( k *= 2 ))
	while (( 1 )); do	
		read line <&${curr_out}
		echo "$line" >&${curr_in}
		echo "$line" >&${gui_in}
		
		if !(kill -0 $curr_pid 2>/dev/null >/dev/null); then
			wait $curr_pid
			exit_checker=$?
			if (( $exit_checker != 0 )) && (( $exit_checker != 1 )) && (( $exit_checker != 2 )); then
				exit 1
			fi
		fi 
		if ! [[ "$line" =~ MOVE*|END_TURN|PRODUCE* ]]; then
			echo dupa
			sleep 0.004
		fi
		if !(kill -0 $wait_pid 2>/dev/null >/dev/null); then
			wait $wait_pid
			exit_checker=$?
			if (( $exit_checker != 0 )) && (( $exit_checker != 1 )) && (( $exit_checker != 2 )); then
				exit 1
			fi
		fi 
		if (( k == 1 )); then
			sleep 0.01
		fi
		if !(kill -0 $gui_pid 2>/dev/null >/dev/null); then
			wait $gui_pid
			exit_checker=$?
			if (( $exit_checker == 0 )); then
				kill_ai
				exit 0
			else
				exit 1
			fi
		fi
		
		if [ "$line" == "END_TURN" ]; then
			swap_in_out_pid
			(( k -= 1 ))
			sleep $s
		fi
	done
	
else 
	PIPE2=$(mktemp -u); mkfifo $PIPE2; exec 5<>$PIPE2; rm $PIPE2
	PIPE2=$(mktemp -u); mkfifo $PIPE2; exec 6<>$PIPE2; rm $PIPE2
	if [ $ai1 == "-human1" ]; then
		./sredniowiecze_gui_with_libs.sh -human1 <&3 >&4 &
		gui_pid=$!
		$ai2 <&5 >&6 &
		ai_pid=$!
		curr_out=4; curr_in=5; wait_out=6; wait_in=3;
		curr_pid=$gui_pid; wait_pid=$ai_pid
		start=2
	else
		./sredniowiecze_gui_with_libs.sh -human2 <&3 >&4 &
		gui_pid=$!
		$ai1 <&5 >&6 &
		ai_pid=$!
		curr_out=6; curr_in=3; wait_out=4; wait_in=5;
		curr_pid=$ai_pid; wait_pid=$gui_pid
		start=1		
	fi
	echo "INIT $n $k 1 $p1x $p1y $p2x $p2y" >&3
	echo "INIT $n $k 2 $p1x $p1y $p2x $p2y" >&3
	echo "INIT $n $k $start $p1x $p1y $p2x $p2y" >&5
	if !(kill -0 $ai_pid); then
		exit 1;
	fi
	(( k *= 2 ))
	while (( 1 )); do
		if (( $k == 1 )); then
			sleep 0.01
		fi
		read line <&${curr_out}
		echo "$line" >&${curr_in}
		if !(kill -0 $ai_pid 2>/dev/null >/dev/null); then
			wait $ai_pid
			exit_checker=$?
			if (( $exit_checker != 0 )) && (( $exit_checker != 1 )) && (( $exit_checker != 2 )); then
				exit 1
			fi
		fi
		if !(kill -0 $gui_pid 2>/dev/null >/dev/null); then
			sleep 2
			if !(kill -0 $ai_pid 2>/dev/null >/dev/null); then
				wait $ai_pid
				exit_checker=$?
				if (( $exit_checker != 0 )) && (( $exit_checker != 1 )) && (( $exit_checker != 2 )); then
					exit 1
				fi
			fi
			wait $gui_pid
			exit_checker=$?
			if (( $exit_checker == 0 )); then
				kill_ai_hum
				exit 0
			else
				exit 1
			fi
		fi
		if [ "$line" == "END_TURN" ]; then
			((k -= 1 ))
			swap_in_out_pid
		fi
	done		
fi
