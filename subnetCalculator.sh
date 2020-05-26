#!/bin/sh
#Acts as a function that moves a number from decimal to binary using an array of values
#I don't fully understand the inner workings, but it does function as intended so I'm including it
Dec2Bin=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})

read -r -p "What's the given IP address? > " givenIPAddress
read -r -p "What's the shortened netmask? (i.e. /24) > " givenNetmask

echo "Calculating..."



##########################################
#		Finding IP Class Letter			 #
##########################################

quartet1=$(echo $givenIPAddress | cut -d . -f 1)

if [[ "$quartet1" -gt "0" || "$quartet1" -lt "127" ]]; then
	ipClassLetter=A
elif [[ "$quartet1" -gt "127" || "$quartet1" -lt "192" ]]; then
	ipClassLetter=B
elif [[ "$quartet1" -gt "191" || "$quartet1" -lt "224" ]]; then
	ipClassLetter=C
else
	echo "IP address is outside typical class ranges. This may result in strange happenings."
fi



##########################################
#   Grabs Quarter Targeted by Netmask	 #
##########################################

shortNetmask=$(echo $givenNetmask | cut -d / -f 2)

if [[ "$shortNetmask" -gt "0" && "$shortNetmask" -lt "9" ]]; then
	targetQuartet=1
elif [[ "$shortNetmask" -gt "8" && "$shortNetmask" -lt "17" ]]; then
	targetQuartet=2
elif [[ "$shortNetmask" -gt "16" && "$shortNetmask" -lt "25" ]]; then
	targetQuartet=3
elif [[ "$shortNetmask" -gt "24" && "$shortNetmask" -lt "33" ]]; then
	targetQuartet=4
else
	echo "Short netmask is outside valid range. This may result in strange happenings."
fi



##########################################
#	 	  Gets Dec Long Netmask		 	 #
##########################################

networkBitsInTargetQuartet=$((shortNetmask - $(($(($targetQuartet - 1)) * 8))))
hostBitsInTargetQuartet=$((8 - $networkBitsInTargetQuartet))

maxBitVal=128
counter="$networkBitsInTargetQuartet"
targetQuartetVal=0

while [[ "$counter" -gt "0" ]]; do
	targetQuartetVal=$(($targetQuartetVal + $maxBitVal))
	maxBitVal=$(($maxBitVal / 2))
	counter=$((counter - 1))
done

if [[ "$targetQuartet" = "1" ]]; then
	decLongNetmask="$targetQuartetVal.0.0.0"
elif [[ "$targetQuartet" = "2" ]]; then
	decLongNetmask="255.$targetQuartetVal.0.0"
elif [[ "$targetQuartet" = "3" ]]; then
	decLongNetmask="255.255.$targetQuartetVal.0"
elif [[ "$targetQuartet" = "4" ]]; then
	decLongNetmask="255.255.255.$targetQuartetVal"
fi



##########################################
#	 Convert Dec Long Netmask to Bin	 #
##########################################

decLongNetmaskPt1=$(echo $decLongNetmask | cut -d . -f 1)
decLongNetmaskPt2=$(echo $decLongNetmask | cut -d . -f 2)
decLongNetmaskPt3=$(echo $decLongNetmask | cut -d . -f 3)
decLongNetmaskPt4=$(echo $decLongNetmask | cut -d . -f 4)

binLongNetmaskPt1=$(echo ${Dec2Bin[$decLongNetmaskPt1]})
binLongNetmaskPt2=$(echo ${Dec2Bin[$decLongNetmaskPt2]})
binLongNetmaskPt3=$(echo ${Dec2Bin[$decLongNetmaskPt3]})
binLongNetmaskPt4=$(echo ${Dec2Bin[$decLongNetmaskPt4]})

binLongNetmask="$binLongNetmaskPt1.$binLongNetmaskPt2.$binLongNetmaskPt3.$binLongNetmaskPt4"



##########################################
#	 Convert givenIPAddress to Binary	 #
##########################################

decGivenIPAddressPt1=$(echo $givenIPAddress | cut -d . -f 1)
decGivenIPAddressPt2=$(echo $givenIPAddress | cut -d . -f 2)
decGivenIPAddressPt3=$(echo $givenIPAddress | cut -d . -f 3)
decGivenIPAddressPt4=$(echo $givenIPAddress | cut -d . -f 4)

binGivenIPAddressPt1=$(echo ${Dec2Bin[$decGivenIPAddressPt1]})
binGivenIPAddressPt2=$(echo ${Dec2Bin[$decGivenIPAddressPt2]})
binGivenIPAddressPt3=$(echo ${Dec2Bin[$decGivenIPAddressPt3]})
binGivenIPAddressPt4=$(echo ${Dec2Bin[$decGivenIPAddressPt4]})

binGivenIPAddress="$binGivenIPAddressPt1.$binGivenIPAddressPt2.$binGivenIPAddressPt3.$binGivenIPAddressPt4"



##########################################
#  ANDing binIP and binNetmask Together  #
##########################################

andingCounter=0
oneChar="1"
zeroChar="0"
periodChar="."

while [[ "$andingCounter" -lt "35" ]]; do
	
	targetIPBit=$(echo ${binGivenIPAddress:$andingCounter:1})
	targetSubBit=$(echo ${binLongNetmask:$andingCounter:1})

	if [[ "$targetIPBit" = "." && "$targetSubBit" = "." ]]; then
		binNetworkAddress="$binNetworkAddress$periodChar"

	elif [[ "$targetIPBit" = "1" && "$targetSubBit" = "1" ]]; then
		binNetworkAddress="$binNetworkAddress$oneChar"

	else
		binNetworkAddress="$binNetworkAddress$zeroChar"

	fi

	andingCounter=$((andingCounter + 1))

done



##########################################
# 		Finding Network Address  		 #
##########################################
# Note, the network address means all HOST bits are set to 0. Network bits aren't touched.
# Host bits are just appended to the existing network bits

binNetworkAddressPt1=$(echo $binNetworkAddress | cut -d . -f 1)
binNetworkAddressPt2=$(echo $binNetworkAddress | cut -d . -f 2)
binNetworkAddressPt3=$(echo $binNetworkAddress | cut -d . -f 3)
binNetworkAddressPt4=$(echo $binNetworkAddress | cut -d . -f 4)

decNetworkAddressPt1=$(echo $((2#$binNetworkAddressPt1)))
decNetworkAddressPt2=$(echo $((2#$binNetworkAddressPt2)))
decNetworkAddressPt3=$(echo $((2#$binNetworkAddressPt3)))
decNetworkAddressPt4=$(echo $((2#$binNetworkAddressPt4)))

networkAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decNetworkAddressPt3.$decNetworkAddressPt4"



##########################################
#  		Finding Broadcast Address 		 #
##########################################
# Note, the broadcast address means all HOST bits are set to 1. Network bits aren't touched.
# Host bits are just appended to the existing network bits

octetOfOnes=11111111
octetOfZeros=00000000
octetLastOne=00000001
#octetLastZero=11111110 #<-- Unused variable!

if [[ "$targetQuartet" = "1" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt1:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s1" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decBroadcastAddress=$((2#$newBinAddress))
	decAllOnes=$((2#$octetOfOnes))
	broadcastAddress="$decBroadcastAddress.$decAllOnes.$decAllOnes.$decAllOnes"

elif [[ "$targetQuartet" = "2" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt2:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s1" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decBroadcastAddress=$((2#$newBinAddress))
	decAllOnes=$((2#$octetOfOnes))
	broadcastAddress="$decNetworkAddressPt1.$decBroadcastAddress.$decAllOnes.$decAllOnes"

elif [[ "$targetQuartet" = "3" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt3:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s1" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decBroadcastAddress=$((2#$newBinAddress))
	decAllOnes=$((2#$octetOfOnes))
	broadcastAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decBroadcastAddress.$decAllOnes"

elif [[ "$targetQuartet" = "4" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt4:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s1" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decBroadcastAddress=$((2#$newBinAddress))
	decAllOnes=$((2#$octetOfOnes))
	broadcastAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decNetworkAddressPt3.$decBroadcastAddress"

else
	echo "Something went wrong with calculating the broadcast address. Whoops!"
fi



##########################################
#	   Getting First Host on Subnet	     #
##########################################
# Note, the first address means all HOST bits are set to 0, except the last bit which is 1.
# Network bits aren't touched.
# Host bits are just appended to the existing network bits

if [[ "$targetQuartet" = "1" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt1:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s0" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decFirstHostAddress=$((2#$newBinAddress))
	decAllZeros=$((2#$octetOfZeros))
	decLastOne=$((2#$octetLastOne))

	firstHostAddress="$decFirstHostAddress.$decAllZeros.$decAllZeros.$decLastOne"

elif [[ "$targetQuartet" = "2" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt2:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s0" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decFirstHostAddress=$((2#$newBinAddress))
	decAllZeros=$((2#$octetOfZeros))
	decLastOne=$((2#$octetLastOne))

	firstHostAddress="$decNetworkAddressPt1.$decFirstHostAddress.$decAllZeros.$decLastOne"

elif [[ "$targetQuartet" = "3" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt3:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s0" $(seq 1 $hostBitsInTargetQuartet))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress"

	decFirstHostAddress=$((2#$newBinAddress))
	decAllZeros=$((2#$octetOfZeros))
	decLastOne=$((2#$octetLastOne))

	firstHostAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decFirstHostAddress.$decLastOne"

elif [[ "$targetQuartet" = "4" ]]; then
	newBinNetworkAddress=${binNetworkAddressPt4:0:$networkBitsInTargetQuartet}
	newBinHostAddress=$(printf "%0.s0" $(seq 1 $(($(($hostBitsInTargetQuartet - 1))))))
	newBinAddress="$newBinNetworkAddress$newBinHostAddress""1"

	decFirstHostAddress=$((2#$newBinAddress))
	decAllZeros=$((2#$octetOfZeros))
	decLastOne=$((2#$octetLastOne))

	firstHostAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decNetworkAddressPt3.$((decFirstHostAddress))"

fi



##########################################
#	   Getting Last Host on Subnet	     #
##########################################
# Note, the first address means all HOST bits are set to 1, except the last bit which is 0.
# Network bits aren't touched.
# Host bits are just appended to the existing network bits

if [[ "$targetQuartet" = "1" ]]; then
	lastHostAddress="$decBroadcastAddress.$decAllOnes.$decAllOnes.$(($decAllOnes - 1))"

elif [[ "$targetQuartet" = "2" ]]; then
	lastHostAddress="$decNetworkAddressPt1.$decBroadcastAddress.$decAllOnes.$(($decAllOnes - 1))"

elif [[ "$targetQuartet" = "3" ]]; then
	lastHostAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decBroadcastAddress.$(($decAllOnes - 1))"

elif [[ "$targetQuartet" = "4" ]]; then
	lastHostAddress="$decNetworkAddressPt1.$decNetworkAddressPt2.$decNetworkAddressPt3.$(($decBroadcastAddress - 1))"

fi



##########################################
#		  Exporting Information			 #
##########################################

echo ""
echo "Information Export Menu"
echo "@=====================@"
echo ""
echo "1) Export information to folder on desktop (ipInfo.txt, ipRange.json, and ReadMe.txt)"
echo "2) Display information in terminal (Only ipInfo.txt)"
echo ""

exitStatement="false"

while [[ "$exitStatement" = "false" ]]; do
	read -r -p "Select an option (1 or 2) > " menuSelection

	if [[ "$menuSelection" = "1" || "$menuSelection" = "2" ]]; then
		exitStatement="true"
	else
		echo "Not a valid selection."
	fi

done

if [[ "$shortNetmask" -lt "31" ]]; then

	if [[ "$menuSelection" = "1" ]]; then
		echo "Where should the folder be placed? (i.e. ~/Desktop)"
		read -r -p "> " unconvertedFolderCreationPath

		convertedFolderCreationPath=$(echo ${unconvertedFolderCreationPath/\~/$HOME})
		cd "$convertedFolderCreationPath"
		mkdir IP_Calculation_Info
		cd IP_Calculation_Info

		echo ""
		echo "Subnet Network Address = $networkAddress"
		echo "Subnet First Host Address = $firstHostAddress"
		echo "Subnet Last Host Address = $lastHostAddress"
		echo "Subnet Broadcast Address = $broadcastAddress"
		echo ""

		#=========================================================#
		# Exports text file containing information of the network #
		#=========================================================#
		echo "Here's your info:" >> ipInfo.txt
		echo "@=====================@" >> ipInfo.txt
		echo "" >> ipInfo.txt
		echo "Given IP Address = $givenIPAddress" >> ipInfo.txt
		echo "IP Address Class Letter = $ipClassLetter" >> ipInfo.txt
		echo "Given Network Mask = /$shortNetmask" >> ipInfo.txt
		echo "Extended Network Mask = $decLongNetmask" >> ipInfo.txt
		echo "Subnet Network Address = $networkAddress" >> ipInfo.txt
		echo "Subnet First Host Address = $firstHostAddress" >> ipInfo.txt
		echo "Subnet Last Host Address = $lastHostAddress" >> ipInfo.txt
		echo "Subnet Broadcast Address = $broadcastAddress"  >> ipInfo.txt

		#=========================================================#
		# Exports file regarding issue with .0 and .255 addresses #
		#=========================================================#
		echo "INFO ON POTENTIAL HOST ADDRESS ISSUES" >> ReadMe.txt
		echo "@===================================@" >> ReadMe.txt
		echo "The JSON file containing all of the usable host addresses for the subnet lists x.x.x.0 and x.x.x.255 host addresses." >> ReadMe.txt
		echo "This is normal behaviour and should be just fine as it is, however, it may also be an issue for host connections." >> ReadMe.txt
		echo "Some ISPs currently block x.x.x.255 addresses as a way to curb the use of Smurf Attacks (listed below)." >> ReadMe.txt
		echo "" >> ReadMe.txt
		echo "If a machine experiences connectivity issues, and contains an x.x.x.255 address, you may want to assign it a different IP address," >> ReadMe.txt
		echo "and remove all x.x.x.255 listings from the JSON whitelist. The x.x.x.0 addresses shouldn't cause any unique issues." >> ReadMe.txt
		echo "" >> ReadMe.txt
		echo "Read more about Smurf Attacks and how to mitigate them: https://usa.kaspersky.com/resource-center/definitions/smurf-attack" >> ReadMe.txt

		#=========================================================#
		# Exports complete JSON file of all usable host addresses #
		#=========================================================#
		if [[ "$shortNetmask" -gt "12" && "$shortNetmask" -lt "31" ]]; then

			decBroadcastAddressMinusOne=$(($decBroadcastAddress - 1))
			echo "Working..."

			if [[ "$targetQuartet" = "1" ]]; then

				jsonString=$( eval echo \[ '\"'{$decFirstHostAddress..$decBroadcastAddress}.{$decAllZeros..$decAllOnes}.{$decAllZeros..$decAllOnes}.{0..255}'\"', ) #<-- Does the actual looping through the IP addresses.
				jsonString=${jsonString:0:${#jsonString} - 1} #<-- Removes the last comma from the JSON file, preventing it from being invalid for use.
				jsonString="$jsonString ]" #<-- Appends a closing bracker to the end of the JSON file string
				jsonString=${jsonString//\"$networkAddress\", /}
				jsonString=${jsonString//, \"$broadcastAddress\"/}
				echo "$jsonString" >> ipRange.json #<-- Prints entire JSON file string into the ipRange.json file

			elif [[ "$targetQuartet" = "2" ]]; then

				jsonString=$( eval echo \[ '\"'{$decNetworkAddressPt1..$decNetworkAddressPt1}.{$decFirstHostAddress..$decBroadcastAddress}.{$decAllZeros..$decAllOnes}.{0..255}'\"', ) #<-- Does the actual looping through the IP addresses.
				jsonString=${jsonString:0:${#jsonString} - 1} #<-- Removes the last comma from the JSON file, preventing it from being invalid for use.
				jsonString="$jsonString ]" #<-- Appends a closing bracker to the end of the JSON file string
				jsonString=${jsonString//\"$networkAddress\", /}
				jsonString=${jsonString//, \"$broadcastAddress\"/}
				echo "$jsonString" >> ipRange.json #<-- Prints entire JSON file string into the ipRange.json file

			elif [[ "$targetQuartet" = "3" ]]; then

				jsonString=$( eval echo \[ '\"'{$decNetworkAddressPt1..$decNetworkAddressPt1}.{$decNetworkAddressPt2..$decNetworkAddressPt2}.{$decFirstHostAddress..$decBroadcastAddress}.{0..255}'\"', ) #<-- Does the actual looping through the IP addresses.
				jsonString=${jsonString:0:${#jsonString} - 1} #<-- Removes the last comma from the JSON file, preventing it from being invalid for use.
				jsonString="$jsonString ]" #<-- Appends a closing bracker to the end of the JSON file string
				jsonString=${jsonString//\"$networkAddress\", /}
				jsonString=${jsonString//, \"$broadcastAddress\"/}
				echo "$jsonString" >> ipRange.json #<-- Prints entire JSON file string into the ipRange.json file

			elif [[ "$targetQuartet" = "4" ]]; then


				jsonString=$( eval echo \[ '\"'{$decNetworkAddressPt1..$decNetworkAddressPt1}.{$decNetworkAddressPt2..$decNetworkAddressPt2}.{$decNetworkAddressPt3..$decNetworkAddressPt3}.{$decFirstHostAddress..$decBroadcastAddressMinusOne}'\"', ) #<-- Does the actual looping through the IP addresses.
				jsonString=${jsonString:0:${#jsonString} - 1} #<-- Removes the last comma from the JSON file, preventing it from being invalid for use.
				jsonString="$jsonString ]" #<-- Appends a closing bracker to the end of the JSON file string
				echo "$jsonString" >> ipRange.json #<-- Prints entire JSON file string into the ipRange.json file

			else
				echo "Something went wrong with exporting the JSON"
				
			fi

		else
			echo ""
			echo "Due to limitations of the system, IPs with a netmask of /12 or less will not be processed."
			echo "Also, any netmasks of /31 or higher won't be processed since it's essentially a pointless netmask."
			echo "Basic information will still be exported to ipInfo.txt."
			echo ""
		fi

		cd "$HOME/Desktop" #<-- Returns to Desktop after the files are created

	elif [[ "$menuSelection" = "2" ]]; then
		echo ""
		echo "Here's your info:"
		echo "@=====================@"
		echo ""
		echo "Given IP Address = $givenIPAddress"
		echo "IP Address Class Letter = $ipClassLetter"
		echo "Given Network Mask = /$shortNetmask"
		echo "Extended Network Mask = $decLongNetmask"
		echo "Subnet Network Address = $networkAddress"
		echo "Subnet First Host Address = $firstHostAddress"
		echo "Subnet Last Host Address = $lastHostAddress"
		echo "Subnet Broadcast Address = $broadcastAddress"
		echo ""

	else
		echo "Something went wrong displaying the results. Whoops!"


	fi

else
	echo "No information will be given for this network since /31 and /32 are broken and useless netmasks"

fi
